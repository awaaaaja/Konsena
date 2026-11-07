-- ============================================================================
-- KONSENA AI — Phase 00 pgTAP: private storage RLS
--
-- Mandatory storage matrix:
--   * bucket konsena-private is private (no public URL)
--   * authenticated user A can read/write/delete ONLY under <auth.uid()>/
--   * user B cannot list, read, update or delete A's objects
--   * anonymous cannot read or write the bucket
--   * an object placed at the bucket root (no owner folder) is owned by nobody
--
-- Encoding is identical to rls_owner_isolation_test.sql:
--   value = row_count  -> allowed operation really happened
--   value = 0          -> operation denied (exception caught, or 0 rows matched)
--   value = -1         -> harness failure
--
-- NOTE ON THE SENTINEL PATTERN: a `DO` block rolls back to its own implicit
-- savepoint when an exception is raised, so a sentinel row inserted INSIDE the
-- same block as the operation that must fail disappears with it and the
-- assertion would read NULL. Sentinels for expected-denial cases are therefore
-- inserted as plain statements BEFORE the block that is expected to fail.
--
-- NOTE ON storage.allow_delete_query: Supabase installs a BEFORE DELETE
-- STATEMENT trigger (storage.protect_delete) that raises SQLSTATE 42501 unless
-- that GUC is 'true'. The Storage API sets it itself before deleting. It is an
-- accident guard, not an access-control boundary — `SET`ting it requires no
-- privilege, and even with it open the RLS policies still decide which rows a
-- role may delete. The test opens it deliberately so that DELETE is measured
-- against RLS rather than against the guard.
--
-- LOCAL SCOPE ONLY — see the header of rls_owner_isolation_test.sql.
-- Phase 00 uploads only synthetic dummy objects; no real user file is ever
-- stored. Production upload flows arrive in Phase 07 after explicit consent.
--
-- This file is self-contained: it does not depend on objects created by the
-- other test file, because each file runs in its own transaction.
-- ============================================================================

begin;

create extension if not exists pgtap with schema extensions;

select plan(17);

-- Open the Storage API's delete guard so that DELETE is measured against RLS.
set local storage.allow_delete_query = 'true';

-- ---------------------------------------------------------------------------
-- Fixture: bucket + dummy objects, created as postgres (RLS bypassed)
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit)
values ('konsena-private', 'konsena-private', false, 52428800)
on conflict (id) do update set public = false;

insert into storage.objects (bucket_id, name)
values
  ('konsena-private', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa/dummy-a.txt'),
  ('konsena-private', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb/dummy-b.txt'),
  ('konsena-private', 'orphan-root-file.txt')
on conflict do nothing;

create table public.phase00_storage_results (
  label text,
  value bigint
);

-- Hosted Supabase enables RLS by default on new `public` tables, so this
-- harness table must opt out explicitly or every insert made while the role
-- under test is active would be rejected by a policy that has nothing to do
-- with what we are measuring. Dropped by ROLLBACK.
alter table public.phase00_storage_results disable row level security;

create function public.phase00_storage_become(p_user text, p_role text) returns void
language plpgsql
as $$
begin
  perform set_config('request.jwt.claims',
    json_build_object('sub', p_user, 'role', p_role)::text, true);
  perform set_config('request.jwt.claim.sub', p_user, true);
  execute 'set local role ' || p_role;
end;
$$;

grant usage on schema public to authenticated, anon;
grant insert, select, update, delete on public.phase00_storage_results to authenticated, anon;
grant usage on language plpgsql to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 1. Bucket posture — 2 assertions
-- ---------------------------------------------------------------------------
select is(
  (select public from storage.buckets where id = 'konsena-private'),
  false,
  'konsena-private is not public'
);

select is(
  (select count(*) from storage.buckets where id = 'konsena-private' and public = true),
  0::bigint,
  'no public bucket named konsena-private exists'
);

-- ---------------------------------------------------------------------------
-- 2. User A: scoped read/list — 4 assertions
-- ---------------------------------------------------------------------------
select phase00_storage_become('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'authenticated');

do $$
declare v bigint;
begin
  select count(*) into v from storage.objects
   where bucket_id = 'konsena-private'
     and name like 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa/%';
  insert into public.phase00_storage_results values ('a_list_own_prefix', v);
exception when others then
  insert into public.phase00_storage_results values ('a_list_own_prefix', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from storage.objects
   where bucket_id = 'konsena-private';
  insert into public.phase00_storage_results values ('a_sees_only_own', v);
exception when others then
  insert into public.phase00_storage_results values ('a_sees_only_own', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from storage.objects
   where bucket_id = 'konsena-private'
     and name = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb/dummy-b.txt';
  insert into public.phase00_storage_results values ('a_reads_b_object', v);
exception when others then
  insert into public.phase00_storage_results values ('a_reads_b_object', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from storage.objects
   where bucket_id = 'konsena-private' and name = 'orphan-root-file.txt';
  insert into public.phase00_storage_results values ('a_reads_orphan_root', v);
exception when others then
  insert into public.phase00_storage_results values ('a_reads_orphan_root', -1);
end $$;

reset role;

select is((select value from public.phase00_storage_results where label = 'a_list_own_prefix'), 1::bigint, 'A: lists its own prefixed object');
select is((select value from public.phase00_storage_results where label = 'a_sees_only_own'), 1::bigint, 'A: bucket listing contains only its own objects');
select is((select value from public.phase00_storage_results where label = 'a_reads_b_object'), 0::bigint, 'A: cannot download B''s object');
select is((select value from public.phase00_storage_results where label = 'a_reads_orphan_root'), 0::bigint, 'A: cannot download a root-level object with no owner folder');

-- ---------------------------------------------------------------------------
-- 3. User A: scoped write AND scoped delete — 6 assertions
-- ---------------------------------------------------------------------------
select phase00_storage_become('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'authenticated');

-- (positive control) A uploads under its own prefix
do $$
declare v bigint;
begin
  insert into storage.objects (bucket_id, name)
  values ('konsena-private', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa/new-dummy.txt');
  get diagnostics v = row_count;
  insert into public.phase00_storage_results values ('a_insert_own', v);
exception when others then
  insert into public.phase00_storage_results values ('a_insert_own', -1);
end $$;

-- Sentinel FIRST, in its own statement, so it survives the expected denial.
insert into public.phase00_storage_results values ('a_insert_into_b_prefix', 0);
do $$
declare v bigint;
begin
  insert into storage.objects (bucket_id, name)
  values ('konsena-private', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb/planted.txt');
  get diagnostics v = row_count;
  update public.phase00_storage_results set value = v where label = 'a_insert_into_b_prefix';
exception when others then
  null;
end $$;

do $$
declare v bigint;
begin
  update storage.objects set name = name || '.x'
   where bucket_id = 'konsena-private'
     and name = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb/dummy-b.txt';
  get diagnostics v = row_count;
  insert into public.phase00_storage_results values ('a_update_b_object', v);
exception when others then
  insert into public.phase00_storage_results values ('a_update_b_object', -1);
end $$;

-- Positive control: A creates then deletes an object under its own prefix.
do $$
declare v bigint;
begin
  insert into storage.objects (bucket_id, name)
  values ('konsena-private', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa/disposable.txt');
  delete from storage.objects
   where bucket_id = 'konsena-private'
     and name = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa/disposable.txt';
  get diagnostics v = row_count;
  insert into public.phase00_storage_results values ('a_delete_own_object', v);
exception when others then
  insert into public.phase00_storage_results values ('a_delete_own_object', -1);
end $$;

do $$
declare v bigint;
begin
  delete from storage.objects
   where bucket_id = 'konsena-private'
     and name = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb/dummy-b.txt';
  get diagnostics v = row_count;
  insert into public.phase00_storage_results values ('a_delete_b_object', v);
exception when others then
  insert into public.phase00_storage_results values ('a_delete_b_object', -1);
end $$;

do $$
declare v bigint;
begin
  delete from storage.objects
   where bucket_id = 'konsena-private' and name = 'orphan-root-file.txt';
  get diagnostics v = row_count;
  insert into public.phase00_storage_results values ('a_delete_orphan_root', v);
exception when others then
  insert into public.phase00_storage_results values ('a_delete_orphan_root', -1);
end $$;

reset role;

select is((select value from public.phase00_storage_results where label = 'a_insert_own'), 1::bigint, 'A: upload under its own prefix succeeds');
select is((select value from public.phase00_storage_results where label = 'a_insert_into_b_prefix'), 0::bigint, 'A: upload under B''s prefix is rejected');
select is((select value from public.phase00_storage_results where label = 'a_update_b_object'), 0::bigint, 'A: cannot overwrite B''s object');
select is((select value from public.phase00_storage_results where label = 'a_delete_own_object'), 1::bigint, 'A: can delete an object under its own prefix (positive control)');
select is((select value from public.phase00_storage_results where label = 'a_delete_b_object'), 0::bigint, 'A: cannot delete B''s object (RLS, not the delete guard)');
select is((select value from public.phase00_storage_results where label = 'a_delete_orphan_root'), 0::bigint, 'A: cannot delete a root-level object with no owner folder');

-- Independent check as postgres: B's object and the orphan must still exist.
select is(
  (select count(*) from storage.objects
    where bucket_id = 'konsena-private'
      and name in ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb/dummy-b.txt',
                   'orphan-root-file.txt')),
  2::bigint,
  'B''s object and the orphan object survived A''s delete attempts'
);

-- ---------------------------------------------------------------------------
-- 4. User B: cannot read A's object, still sees its own — 2 assertions
-- ---------------------------------------------------------------------------
select phase00_storage_become('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'authenticated');

do $$
declare v bigint;
begin
  select count(*) into v from storage.objects
   where bucket_id = 'konsena-private'
     and name = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa/dummy-a.txt';
  insert into public.phase00_storage_results values ('b_reads_a_object', v);
exception when others then
  insert into public.phase00_storage_results values ('b_reads_a_object', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from storage.objects
   where bucket_id = 'konsena-private';
  insert into public.phase00_storage_results values ('b_sees_only_own', v);
exception when others then
  insert into public.phase00_storage_results values ('b_sees_only_own', -1);
end $$;

reset role;

select is((select value from public.phase00_storage_results where label = 'b_reads_a_object'), 0::bigint, 'B: cannot download A''s object');
select is((select value from public.phase00_storage_results where label = 'b_sees_only_own'), 1::bigint, 'B: bucket listing contains only its own objects');

-- ---------------------------------------------------------------------------
-- 5. Anonymous denied for read AND write — 2 assertions
-- ---------------------------------------------------------------------------
select phase00_storage_become('', 'anon');

do $$
declare v bigint;
begin
  select count(*) into v from storage.objects
   where bucket_id = 'konsena-private';
  insert into public.phase00_storage_results values ('anon_read', v);
exception when others then
  insert into public.phase00_storage_results values ('anon_read', -1);
end $$;

-- Sentinel first, so it survives the expected WITH CHECK denial.
insert into public.phase00_storage_results values ('anon_write', 0);
do $$
declare v bigint;
begin
  insert into storage.objects (bucket_id, name)
  values ('konsena-private', 'anonymous/forge.txt');
  get diagnostics v = row_count;
  update public.phase00_storage_results set value = v where label = 'anon_write';
exception when others then
  null;
end $$;

reset role;

select is((select value from public.phase00_storage_results where label = 'anon_read'), 0::bigint, 'anonymous: reads 0 objects from konsena-private');
select is((select value from public.phase00_storage_results where label = 'anon_write'), 0::bigint, 'anonymous: cannot write to konsena-private');

select * from finish();
rollback;
