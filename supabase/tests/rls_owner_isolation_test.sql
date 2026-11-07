-- ============================================================================
-- KONSENA AI — Phase 00 pgTAP: database RLS owner isolation
--
-- Covers the mandatory Phase 00 matrix:
--   * user A can CRUD its own rows
--   * user B cannot select / insert / update / delete A's rows
--   * anonymous is denied
--   * a child row cannot be attached to a parent owned by B
--   * owner_id cannot be changed to another user
--
-- Method (important, and deliberate):
--   DML runs under `set local role <target>` inside DO blocks. The helper
--   table records the ROW_COUNT of an operation that must SUCCEED, or keeps a
--   0 sentinel when an operation that must be DENIED raises an exception.
--   Every pgTAP assertion then runs as `postgres`.
--   Why: pgTAP's execute privilege and its internal result storage must not
--   depend on the role under test, and a denied statement would otherwise
--   abort the whole transaction before assertions could run.
--
--   encoding: value = row_count  (allowed operation)
--             value = 0          (operation denied -> exception caught)
--             value = -1         (unexpected failure of a test harness query)
--
-- Two harness rules were learned the hard way and are load-bearing here:
--
--   1. A sentinel for an EXPECTED denial must be inserted as its own statement
--      BEFORE the DO block, never inside it. A DO block rolls back to its own
--      implicit savepoint when an exception fires, which silently deletes a
--      sentinel written in the same block and turns the assertion into NULL.
--
--   2. Hosted Supabase enables RLS on every new table in `public`
--      (pg_class.relrowsecurity = true straight after CREATE TABLE), and the
--      `postgres` role there is NOT a superuser. The helper tables below are
--      therefore granted explicitly and have RLS disabled explicitly.
--
--   3. PL/pgSQL takes ONE `exception` keyword followed by a list of `when`
--      clauses; repeating `exception when ...` is a syntax error.
--
--   Reads by `anon` fail with SQLSTATE 42501 because the SELECT grant itself
--   was revoked. That is a denial and is counted as 0, not as -1; only an
--   unexpected SQLSTATE is treated as a harness failure.
--
-- LOCAL SCOPE ONLY: this proves RLS on whatever database it is pointed at.
-- It is evidence only for the database it actually ran on — never assume a
-- hosted project passed because a local run did.
--
-- All identities are fixed UUIDs so the file is deterministic and re-runnable.
-- ============================================================================

begin;

create extension if not exists pgtap with schema extensions;

select plan(38);

-- ---------------------------------------------------------------------------
-- Fixture
-- ---------------------------------------------------------------------------
insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_sso_user, is_anonymous)
values
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'phase00-user-a@test.konsena.local', 'not-a-real-hash', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"phase00_test":true}', false, false),
  ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'phase00-user-b@test.konsena.local', 'not-a-real-hash', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"phase00_test":true}', false, false)
on conflict (id) do nothing;

create table public.phase00_test_results (
  label text,
  value bigint
);

-- Holds A's real parent id so section 5 can attempt a *literal* cross-owner
-- reference (B knows A's UUID) instead of a subquery that would return no rows.
create table public.phase00_test_fixture (
  audit_record_id uuid
);

-- Hosted Supabase turns RLS ON by default for every new table in `public`
-- (verified: pg_class.relrowsecurity = true right after CREATE TABLE), and
-- these two tables are written by the role under test. Without an explicit
-- DISABLE the harness would report a policy violation instead of the RLS
-- result we are actually measuring. The tables are dropped by ROLLBACK.
alter table public.phase00_test_results disable row level security;
alter table public.phase00_test_fixture disable row level security;

grant usage on schema public to authenticated, anon;
grant insert, select, update, delete on public.phase00_test_results to authenticated, anon;
grant usage on language plpgsql to authenticated, anon;

-- ---------------------------------------------------------------------------
-- 1. Structural audit — 5 assertions (as postgres)
-- ---------------------------------------------------------------------------
select is(
  (select count(*) from pg_class c
   join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public'
     and c.relkind = 'r'
     and c.relname in ('profiles','audit_records','audit_sources','findings','recommendations','evidence_refs')
     and not c.relrowsecurity),
  0::bigint,
  'all exposed tables have RLS enabled'
);

select is(
  (select count(*) from pg_policies
   where schemaname = 'public' and roles::text[] @> array['anon']),
  0::bigint,
  'no policy is granted to the anon role'
);

select is(
  (select count(*) from pg_policies
   where schemaname = 'public' and (qual = 'true' or with_check = 'true')),
  0::bigint,
  'no USING (true) / WITH CHECK (true) policy exists'
);

select is(
  (select public from storage.buckets where id = 'konsena-private'),
  false,
  'bucket konsena-private is private (no public URL)'
);

select is(
  (select count(*) from pg_policies
   where schemaname = 'storage' and tablename = 'objects'
     and policyname like 'konsena_private%' and roles::text[] @> array['anon']),
  0::bigint,
  'no anon policy on konsena-private storage objects'
);

-- ---------------------------------------------------------------------------
-- 2. User A can CRUD its own rows — 11 assertions
-- ---------------------------------------------------------------------------
create function public.phase00_become(p_user text, p_role text) returns void
language plpgsql
as $$
begin
  perform set_config('request.jwt.claims',
    json_build_object('sub', p_user, 'role', p_role)::text, true);
  perform set_config('request.jwt.claim.sub', p_user, true);
  execute 'set local role ' || p_role;
end;
$$;

select phase00_become('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'authenticated');

do $$
declare v bigint;
begin
  insert into public.audit_records (owner_id, title, status)
  values ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Audit A', 'draft');
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('a_insert_record', v);
exception when others then
  insert into public.phase00_test_results values ('a_insert_record', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from public.audit_records;
  insert into public.phase00_test_results values ('a_select_own_record', v);
exception when others then
  insert into public.phase00_test_results values ('a_select_own_record', -1);
end $$;

do $$
declare v bigint;
begin
  update public.audit_records set title = 'Audit A v2' where title = 'Audit A';
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('a_update_own_record', v);
exception when others then
  insert into public.phase00_test_results values ('a_update_own_record', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from public.audit_records where title = 'Audit A v2';
  insert into public.phase00_test_results values ('a_sees_updated_title', v);
exception when others then
  insert into public.phase00_test_results values ('a_sees_updated_title', -1);
end $$;

do $$
declare v bigint;
begin
  -- disposable row so the delete test does not destroy the parent used below
  insert into public.audit_records (owner_id, title, status)
  values ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'temporary-me', 'draft');
  delete from public.audit_records where title = 'temporary-me';
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('a_delete_own_record', v);
exception when others then
  insert into public.phase00_test_results values ('a_delete_own_record', -1);
end $$;

do $$
declare v bigint;
begin
  insert into public.audit_sources (owner_id, audit_record_id, type, metadata)
  select 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', id, 'android_permission',
         '{"packageName":"com.example.app"}'::jsonb
    from public.audit_records where title = 'Audit A v2';
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('a_insert_source_child', v);
exception when others then
  insert into public.phase00_test_results values ('a_insert_source_child', -1);
end $$;

do $$
declare v bigint;
begin
  insert into public.findings (owner_id, audit_record_id, label, summary, engine_type)
  select 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', id, 'Izin lokasi berlebih', 'Ringkasan', 'none'
    from public.audit_records where title = 'Audit A v2';
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('a_insert_finding', v);
exception when others then
  insert into public.phase00_test_results values ('a_insert_finding', -1);
end $$;

do $$
declare v bigint;
begin
  insert into public.recommendations (owner_id, audit_record_id, text, origin)
  select 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', id, 'Cabut izin lokasi', 'rule_based'
    from public.audit_records where title = 'Audit A v2';
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('a_insert_recommendation', v);
exception when others then
  insert into public.phase00_test_results values ('a_insert_recommendation', -1);
end $$;

do $$
declare v bigint;
begin
  insert into public.evidence_refs (owner_id, audit_record_id, excerpt)
  select 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', id, 'Kutipan bukti singkat'
    from public.audit_records where title = 'Audit A v2';
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('a_insert_evidence', v);
exception when others then
  insert into public.phase00_test_results values ('a_insert_evidence', -1);
end $$;

do $$
declare v bigint;
begin
  insert into public.profiles (id, locale)
  values ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'id');
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('a_insert_profile', v);
exception when others then
  insert into public.phase00_test_results values ('a_insert_profile', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from public.profiles;
  insert into public.phase00_test_results values ('a_select_own_profile', v);
exception when others then
  insert into public.phase00_test_results values ('a_select_own_profile', -1);
end $$;

reset role;

select is((select value from public.phase00_test_results where label = 'a_insert_record'), 1::bigint, 'A: inserts its own audit_records row');
select is((select value from public.phase00_test_results where label = 'a_select_own_record'), 1::bigint, 'A: selects only its own audit_records row');
select is((select value from public.phase00_test_results where label = 'a_update_own_record'), 1::bigint, 'A: updates its own audit_records row');
select is((select value from public.phase00_test_results where label = 'a_sees_updated_title'), 1::bigint, 'A: sees the updated title');
select is((select value from public.phase00_test_results where label = 'a_delete_own_record'), 1::bigint, 'A: deletes its own audit_records row');
select is((select value from public.phase00_test_results where label = 'a_insert_source_child'), 1::bigint, 'A: attaches audit_sources child to its own parent');
select is((select value from public.phase00_test_results where label = 'a_insert_finding'), 1::bigint, 'A: inserts finding on its own parent');
select is((select value from public.phase00_test_results where label = 'a_insert_recommendation'), 1::bigint, 'A: inserts recommendation on its own parent');
select is((select value from public.phase00_test_results where label = 'a_insert_evidence'), 1::bigint, 'A: inserts evidence_ref on its own parent');
select is((select value from public.phase00_test_results where label = 'a_insert_profile'), 1::bigint, 'A: creates its own profile keyed by session uid');
select is((select value from public.phase00_test_results where label = 'a_select_own_profile'), 1::bigint, 'A: reads only its own profile');

-- capture A's parent id for the cross-owner tests, as postgres
insert into public.phase00_test_fixture (audit_record_id)
select id from public.audit_records where title = 'Audit A v2';

-- ---------------------------------------------------------------------------
-- 3. User B cannot read A's rows — 6 assertions
-- ---------------------------------------------------------------------------
select phase00_become('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'authenticated');

do $$
declare v bigint;
begin
  select count(*) into v from public.audit_records;
  insert into public.phase00_test_results values ('b_select_audit_records', v);
exception when others then
  insert into public.phase00_test_results values ('b_select_audit_records', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from public.audit_sources;
  insert into public.phase00_test_results values ('b_select_audit_sources', v);
exception when others then
  insert into public.phase00_test_results values ('b_select_audit_sources', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from public.findings;
  insert into public.phase00_test_results values ('b_select_findings', v);
exception when others then
  insert into public.phase00_test_results values ('b_select_findings', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from public.recommendations;
  insert into public.phase00_test_results values ('b_select_recommendations', v);
exception when others then
  insert into public.phase00_test_results values ('b_select_recommendations', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from public.evidence_refs;
  insert into public.phase00_test_results values ('b_select_evidence_refs', v);
exception when others then
  insert into public.phase00_test_results values ('b_select_evidence_refs', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from public.profiles;
  insert into public.phase00_test_results values ('b_select_profiles', v);
exception when others then
  insert into public.phase00_test_results values ('b_select_profiles', -1);
end $$;

reset role;

select is((select value from public.phase00_test_results where label = 'b_select_audit_records'), 0::bigint, 'B: sees 0 audit_records belonging to A');
select is((select value from public.phase00_test_results where label = 'b_select_audit_sources'), 0::bigint, 'B: sees 0 audit_sources belonging to A');
select is((select value from public.phase00_test_results where label = 'b_select_findings'), 0::bigint, 'B: sees 0 findings belonging to A');
select is((select value from public.phase00_test_results where label = 'b_select_recommendations'), 0::bigint, 'B: sees 0 recommendations belonging to A');
select is((select value from public.phase00_test_results where label = 'b_select_evidence_refs'), 0::bigint, 'B: sees 0 evidence_refs belonging to A');
select is((select value from public.phase00_test_results where label = 'b_select_profiles'), 0::bigint, 'B: sees 0 profiles belonging to A');

-- ---------------------------------------------------------------------------
-- 4. User B cannot write A's rows — 6 assertions
-- ---------------------------------------------------------------------------
select phase00_become('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'authenticated');

-- Sentinel as its own statement: a DO block rolls back to its own savepoint on
-- exception, so a sentinel written inside the block would vanish with it.
insert into public.phase00_test_results values ('b_insert_owner_a', 0);
do $$
declare v bigint;
begin
  insert into public.audit_records (owner_id, title, status)
  values ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Forged by B', 'draft');
  get diagnostics v = row_count;
  update public.phase00_test_results set value = v where label = 'b_insert_owner_a';
exception when others then
  null;
end $$;

do $$
declare v bigint;
begin
  update public.audit_records set title = 'hacked';
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('b_update_a_record', v);
exception when others then
  insert into public.phase00_test_results values ('b_update_a_record', -1);
end $$;

do $$
declare v bigint;
begin
  delete from public.audit_records;
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('b_delete_a_record', v);
exception when others then
  insert into public.phase00_test_results values ('b_delete_a_record', -1);
end $$;

insert into public.phase00_test_results values ('b_insert_source_on_a', 0);
do $$
declare v bigint;
begin
  insert into public.audit_sources (owner_id, audit_record_id, type)
  select 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
         (select audit_record_id from public.phase00_test_fixture),
         'android_permission';
  get diagnostics v = row_count;
  update public.phase00_test_results set value = v where label = 'b_insert_source_on_a';
exception when others then
  null;
end $$;

do $$
declare v bigint;
begin
  update public.audit_sources set metadata = '{}'::jsonb;
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('b_update_a_source', v);
exception when others then
  insert into public.phase00_test_results values ('b_update_a_source', -1);
end $$;

do $$
declare v bigint;
begin
  delete from public.audit_sources;
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('b_delete_a_source', v);
exception when others then
  insert into public.phase00_test_results values ('b_delete_a_source', -1);
end $$;

reset role;

select is((select value from public.phase00_test_results where label = 'b_insert_owner_a'), 0::bigint, 'B: cannot insert a row owned by A');
select is((select value from public.phase00_test_results where label = 'b_update_a_record'), 0::bigint, 'B: cannot update A''s audit_records');
select is((select value from public.phase00_test_results where label = 'b_delete_a_record'), 0::bigint, 'B: cannot delete A''s audit_records');
select is((select value from public.phase00_test_results where label = 'b_insert_source_on_a'), 0::bigint, 'B: cannot attach a child to A''s parent');
select is((select value from public.phase00_test_results where label = 'b_update_a_source'), 0::bigint, 'B: cannot update A''s audit_sources');
select is((select value from public.phase00_test_results where label = 'b_delete_a_source'), 0::bigint, 'B: cannot delete A''s audit_sources');

-- ---------------------------------------------------------------------------
-- 5. Child cannot be linked to a parent owned by another user — 2 assertions
--    B supplies its OWN owner_id plus A's KNOWN parent uuid.
-- ---------------------------------------------------------------------------
select phase00_become('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'authenticated');

insert into public.phase00_test_results values ('child_cross_owner_rls', 0);
do $$
declare v bigint;
begin
  insert into public.findings (owner_id, audit_record_id, label)
  values ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
          (select audit_record_id from public.phase00_test_fixture),
          'cross owner');
  get diagnostics v = row_count;
  update public.phase00_test_results set value = v where label = 'child_cross_owner_rls';
exception when others then
  null;
end $$;

reset role;

select is(
  (select value from public.phase00_test_results where label = 'child_cross_owner_rls'),
  0::bigint,
  'RLS blocks a child whose parent belongs to another user'
);

-- Same attack with RLS bypassed (postgres): proves the COMPOSITE FOREIGN KEY
-- enforces ownership structurally, not only via policy.
insert into public.phase00_test_results values ('child_cross_owner_fk', 0);
do $$
declare v bigint;
begin
  insert into public.findings (owner_id, audit_record_id, label)
  values ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
          (select audit_record_id from public.phase00_test_fixture),
          'cross owner fk');
  get diagnostics v = row_count;
  update public.phase00_test_results set value = v where label = 'child_cross_owner_fk';
exception when others then
  null;
end $$;

select is(
  (select value from public.phase00_test_results where label = 'child_cross_owner_fk'),
  0::bigint,
  'composite FK rejects cross-owner parent reference even without RLS'
);

-- ---------------------------------------------------------------------------
-- 6. owner_id cannot be reassigned to another user — 2 assertions
-- ---------------------------------------------------------------------------
select phase00_become('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'authenticated');

insert into public.phase00_test_results values ('a_reassign_owner_to_b', 0);
do $$
declare v bigint;
begin
  update public.audit_records set owner_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
  get diagnostics v = row_count;
  update public.phase00_test_results set value = v where label = 'a_reassign_owner_to_b';
exception when others then
  null;
end $$;

select phase00_become('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'authenticated');

insert into public.phase00_test_results values ('b_reassign_owner_to_a', 0);
do $$
declare v bigint;
begin
  insert into public.profiles (id, locale)
  values ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'id')
  on conflict (id) do nothing;

  update public.profiles set id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  get diagnostics v = row_count;
  update public.phase00_test_results set value = v where label = 'b_reassign_owner_to_a';
exception when others then
  null;
end $$;

reset role;

select is(
  (select value from public.phase00_test_results where label = 'a_reassign_owner_to_b'),
  0::bigint,
  'A cannot transfer its row to B by changing owner_id'
);

select is(
  (select value from public.phase00_test_results where label = 'b_reassign_owner_to_a'),
  0::bigint,
  'B cannot take over a profile by changing the owner id'
);

-- ---------------------------------------------------------------------------
-- 7. Profile identity cannot be forged — 2 assertions
-- ---------------------------------------------------------------------------
select phase00_become('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'authenticated');

insert into public.phase00_test_results values ('a_forged_profile_for_b', 0);
do $$
declare v bigint;
begin
  insert into public.profiles (id, locale)
  values ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'id');
  get diagnostics v = row_count;
  update public.phase00_test_results set value = v where label = 'a_forged_profile_for_b';
exception when others then
  null;
end $$;

select phase00_become('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'authenticated');

do $$
declare v bigint;
begin
  -- positive control: the caller's own uid is always acceptable
  insert into public.profiles (id, locale)
  values ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'en')
  on conflict (id) do update set locale = excluded.locale;
  get diagnostics v = row_count;
  insert into public.phase00_test_results values ('b_own_profile_control', v);
exception when others then
  insert into public.phase00_test_results values ('b_own_profile_control', -1);
end $$;

reset role;

select is(
  (select value from public.phase00_test_results where label = 'a_forged_profile_for_b'),
  0::bigint,
  'A cannot mint a profile carrying B''s uid'
);

select is(
  (select value from public.phase00_test_results where label = 'b_own_profile_control'),
  1::bigint,
  'control: writing one''s own profile still succeeds'
);

-- ---------------------------------------------------------------------------
-- 8. Anonymous denied — 4 assertions
-- ---------------------------------------------------------------------------
select phase00_become('', 'anon');

-- anon has NO SELECT grant on these tables (deny-by-default), so the read is
-- refused with SQLSTATE 42501 before RLS is even consulted. Both a revoked
-- grant and an RLS filter are denials; only an unexpected SQLSTATE is a
-- harness failure.
do $$
declare v bigint;
begin
  select count(*) into v from public.audit_records;
  insert into public.phase00_test_results values ('anon_select_records', v);
exception
  when insufficient_privilege then
    insert into public.phase00_test_results values ('anon_select_records', 0);
  when others then
    insert into public.phase00_test_results values ('anon_select_records', -1);
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from public.profiles;
  insert into public.phase00_test_results values ('anon_select_profiles', v);
exception
  when insufficient_privilege then
    insert into public.phase00_test_results values ('anon_select_profiles', 0);
  when others then
    insert into public.phase00_test_results values ('anon_select_profiles', -1);
end $$;

insert into public.phase00_test_results values ('anon_insert_records', 0);
do $$
declare v bigint;
begin
  insert into public.audit_records (owner_id, title)
  values ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'anon forge');
  get diagnostics v = row_count;
  update public.phase00_test_results set value = v where label = 'anon_insert_records';
exception when others then
  null;
end $$;

do $$
declare v bigint;
begin
  select count(*) into v from storage.objects where bucket_id = 'konsena-private';
  insert into public.phase00_test_results values ('anon_select_storage', v);
exception when others then
  insert into public.phase00_test_results values ('anon_select_storage', -1);
end $$;

reset role;

select is((select value from public.phase00_test_results where label = 'anon_select_records'), 0::bigint, 'anonymous: cannot read audit_records (SELECT grant revoked)');
select is((select value from public.phase00_test_results where label = 'anon_select_profiles'), 0::bigint, 'anonymous: cannot read profiles (SELECT grant revoked)');
select is((select value from public.phase00_test_results where label = 'anon_insert_records'), 0::bigint, 'anonymous: cannot insert audit_records');
select is((select value from public.phase00_test_results where label = 'anon_select_storage'), 0::bigint, 'anonymous: reads 0 private storage objects');

select * from finish();
rollback;
