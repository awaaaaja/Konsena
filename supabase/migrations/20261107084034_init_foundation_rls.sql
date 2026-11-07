-- ============================================================================
-- KONSENA AI — Phase 00 foundation
-- Cloud subset per PRD §13.1, owner = auth.users.id (PRD §13.1 / §9.1).
--
-- Scope of this migration (Phase 00 only):
--   * core tables, UUID PKs, owner_id, timestamps, FKs, indexes
--   * Row Level Security enabled on every exposed table
--   * per-owner SELECT/INSERT/UPDATE/DELETE policies with WITH CHECK
--   * private storage bucket `konsena-private` + prefix-scoped RLS
--
-- Deliberately OUT of scope:
--   * sync_devices  -> deferred, see docs/adr/ADR-0001-foundation-and-cloud.md
--   * policy text, screenshots, camera recordings, raw OCR -> never stored in
--     the cloud; only safe metadata and user-selected object references.
--
-- Design notes:
--   * Every child row carries owner_id AND a COMPOSITE foreign key
--     (owner_id, parent_id) -> parent(owner_id, id). A user A therefore cannot
--     attach a child to a parent owned by user B even when B's UUID is known:
--     the composite key has no matching parent row, so the INSERT is rejected
--     by the constraint itself — independent of RLS.
--   * No SECURITY DEFINER function is introduced. Policies inline
--     (select auth.uid()), which keeps the trusted computing base minimal.
--   * Idempotent: safe to re-run (create ... if not exists / drop+create).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. Helper: keep updated_at trustworthy
-- ----------------------------------------------------------------------------
-- SECURITY INVOKER (not DEFINER), touches nothing but NEW. EXECUTE stays at
-- the default so the trigger can fire for any role; the body has no data
-- access, so widening EXECUTE grants no capability.
create or replace function public.konsena_set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- ----------------------------------------------------------------------------
-- 1. profiles — identity + privacy preferences (no document content)
-- ----------------------------------------------------------------------------
create table if not exists public.profiles (
  id                 uuid primary key references auth.users (id) on delete cascade,
  locale             text not null default 'id',
  cloud_sync_enabled boolean not null default false,
  privacy_preferences jsonb not null default '{}'::jsonb,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  constraint profiles_locale_length check (char_length(locale) <= 16),
  constraint profiles_prefs_is_object check (jsonb_typeof(privacy_preferences) = 'object')
);

comment on table public.profiles is
  'Cloud identity row. Created only after a validated sign-in session — a guest never writes here.';
comment on column public.profiles.cloud_sync_enabled is
  'Opt-in switch; false by default (PRD §3.3). Sync itself lands in Phase 07.';

-- ----------------------------------------------------------------------------
-- 2. audit_records — one user audit session (metadata only, no full text)
-- ----------------------------------------------------------------------------
create table if not exists public.audit_records (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid not null references auth.users (id) on delete cascade,
  title          text not null default 'Audit tanpa judul',
  status         text not null default 'draft',
  source_summary text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint audit_records_title_length check (char_length(title) <= 200),
  constraint audit_records_source_summary_length check (source_summary is null or char_length(source_summary) <= 500),
  -- PRD §11 state machine. Re-validate the literal set in Phase 02.
  constraint audit_records_status_domain check (status in (
    'draft',
    'has_permission_source',
    'has_document_source',
    'has_consent_ui_source',
    'source_ready',
    'awaiting_analysis',
    'unavailable',
    'running',
    'completed',
    'partial',
    'failed',
    'saved',
    'deleted'
  )),
  -- Enables the composite child foreign keys below.
  constraint audit_records_owner_id_id_key unique (owner_id, id)
);

comment on constraint audit_records_status_domain on public.audit_records is
  'Values map 1:1 to PRD §11. Confirm literals when Phase 02 implements the state machine.';

-- ----------------------------------------------------------------------------
-- 3. audit_sources — safe provenance metadata for a source
-- ----------------------------------------------------------------------------
create table if not exists public.audit_sources (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references auth.users (id) on delete cascade,
  audit_record_id uuid not null,
  type            text not null,
  metadata        jsonb not null default '{}'::jsonb,
  sha256          text,
  storage_path    text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint audit_sources_type_domain check (type in (
    'android_permission',
    'policy_document',
    'consent_ui'
  )),
  constraint audit_sources_metadata_is_object check (jsonb_typeof(metadata) = 'object'),
  constraint audit_sources_sha256_format check (sha256 is null or sha256 ~ '^[0-9a-f]{64}$'),
  -- Only an object reference the user explicitly chose; never a public URL.
  constraint audit_sources_storage_path_format check (
    storage_path is null or (storage_path like '%/%' and storage_path !~ '^(https?|gs|s3)://')
  ),
  constraint audit_sources_owner_record_fk
    foreign key (owner_id, audit_record_id)
    references public.audit_records (owner_id, id)
    on delete cascade
);

comment on column public.audit_sources.storage_path is
  'Private bucket object key (konsena-private), populated only when the user opts in to sync that object.';

-- ----------------------------------------------------------------------------
-- 4. findings — analysis output; empty before Phase 09 (no fabricated ML)
-- ----------------------------------------------------------------------------
create table if not exists public.findings (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references auth.users (id) on delete cascade,
  audit_record_id uuid not null,
  label           text not null,
  summary         text,
  engine_type     text not null default 'none',
  model_version   text,
  confidence      double precision,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint findings_label_length check (char_length(label) <= 200),
  constraint findings_summary_length check (summary is null or char_length(summary) <= 2000),
  constraint findings_model_version_length check (model_version is null or char_length(model_version) <= 64),
  constraint findings_confidence_range check (confidence is null or (confidence >= 0 and confidence <= 1)),
  constraint findings_owner_record_fk
    foreign key (owner_id, audit_record_id)
    references public.audit_records (owner_id, id)
    on delete cascade,
  -- Required so recommendations/evidence_refs can point at a finding through a
  -- COMPOSITE key: PostgreSQL only accepts a referenced column set that is
  -- covered by a unique constraint (SQLSTATE 42830 otherwise).
  constraint findings_owner_id_id_key unique (owner_id, id)
);

comment on column public.findings.confidence is
  'NULL when the engine produced no score — never defaulted to 1 (PRD §9.1).';
comment on column public.findings.model_version is
  'Required for every ONNX output (Phase 09); NULL for rule-based/manual results.';

-- ----------------------------------------------------------------------------
-- 5. recommendations — action centre entries
-- ----------------------------------------------------------------------------
create table if not exists public.recommendations (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references auth.users (id) on delete cascade,
  audit_record_id uuid not null,
  finding_id      uuid,
  text            text not null,
  status          text not null default 'pending',
  origin          text not null default 'rule_based',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint recommendations_text_length check (char_length(text) between 1 and 2000),
  -- PRD §13.1: origin is rule_based or ml.
  constraint recommendations_origin_domain check (origin in ('rule_based', 'ml')),
  constraint recommendations_status_domain check (status in (
    'pending',
    'in_progress',
    'done',
    'dismissed'
  )),
  constraint recommendations_owner_record_fk
    foreign key (owner_id, audit_record_id)
    references public.audit_records (owner_id, id)
    on delete cascade,
  constraint recommendations_owner_finding_fk
    foreign key (owner_id, finding_id)
    references public.findings (owner_id, id)
    on delete cascade
);

comment on constraint recommendations_status_domain on public.recommendations is
  'Provisional set; confirm the action-centre lifecycle when Phase 10/F10 is specified.';

-- ----------------------------------------------------------------------------
-- 6. evidence_refs — short, user-opted excerpts only
-- ----------------------------------------------------------------------------
create table if not exists public.evidence_refs (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references auth.users (id) on delete cascade,
  audit_record_id uuid not null,
  finding_id      uuid,
  excerpt         text not null,
  location_ref    text,
  storage_path    text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  -- Keeps the API payload bounded (PRD §13.1 "limited length").
  constraint evidence_refs_excerpt_length check (char_length(excerpt) between 1 and 1000),
  constraint evidence_refs_location_length check (location_ref is null or char_length(location_ref) <= 200),
  constraint evidence_refs_storage_path_format check (
    storage_path is null or (storage_path like '%/%' and storage_path !~ '^(https?|gs|s3)://')
  ),
  constraint evidence_refs_owner_record_fk
    foreign key (owner_id, audit_record_id)
    references public.audit_records (owner_id, id)
    on delete cascade,
  constraint evidence_refs_owner_finding_fk
    foreign key (owner_id, finding_id)
    references public.findings (owner_id, id)
    on delete cascade
);

comment on column public.evidence_refs.excerpt is
  'Capped at 1000 chars. Full policy text / raw OCR is never uploaded (PRD §13.1, §9.4).';

-- ----------------------------------------------------------------------------
-- 7. updated_at triggers
-- ----------------------------------------------------------------------------
drop trigger if exists trg_audit_records_updated_at on public.audit_records;
create trigger trg_audit_records_updated_at
  before update on public.audit_records
  for each row execute function public.konsena_set_updated_at();

drop trigger if exists trg_audit_sources_updated_at on public.audit_sources;
create trigger trg_audit_sources_updated_at
  before update on public.audit_sources
  for each row execute function public.konsena_set_updated_at();

drop trigger if exists trg_findings_updated_at on public.findings;
create trigger trg_findings_updated_at
  before update on public.findings
  for each row execute function public.konsena_set_updated_at();

drop trigger if exists trg_recommendations_updated_at on public.recommendations;
create trigger trg_recommendations_updated_at
  before update on public.recommendations
  for each row execute function public.konsena_set_updated_at();

drop trigger if exists trg_evidence_refs_updated_at on public.evidence_refs;
create trigger trg_evidence_refs_updated_at
  before update on public.evidence_refs
  for each row execute function public.konsena_set_updated_at();

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
  before update on public.profiles
  for each row execute function public.konsena_set_updated_at();

-- ----------------------------------------------------------------------------
-- 8. Indexes — owner lookups, FK joins, ordered list queries
-- ----------------------------------------------------------------------------
create index if not exists idx_audit_records_owner_created
  on public.audit_records (owner_id, created_at desc);
create index if not exists idx_audit_records_owner_status
  on public.audit_records (owner_id, status);

create index if not exists idx_audit_sources_owner_record
  on public.audit_sources (owner_id, audit_record_id);
create index if not exists idx_audit_sources_record
  on public.audit_sources (audit_record_id);

create index if not exists idx_findings_owner_record
  on public.findings (owner_id, audit_record_id);
create index if not exists idx_findings_record
  on public.findings (audit_record_id);

create index if not exists idx_recommendations_owner_status
  on public.recommendations (owner_id, status);
create index if not exists idx_recommendations_record
  on public.recommendations (audit_record_id);

create index if not exists idx_evidence_refs_owner_finding
  on public.evidence_refs (owner_id, finding_id);
create index if not exists idx_evidence_refs_record
  on public.evidence_refs (audit_record_id);

-- ----------------------------------------------------------------------------
-- 9. Grants — deny by default for anon, minimal for authenticated
-- ----------------------------------------------------------------------------
-- authenticated needs REFERENCES on the parent of every composite FK, and on
-- auth.users for the owner_id FK. It never receives SELECT on auth.users.
-- NB: REFERENCES is a TABLE privilege; a schema only accepts USAGE/CREATE.
grant usage on schema public to authenticated;
grant references on table public.audit_records to authenticated;
grant references on table public.findings to authenticated;
do $$
begin
  if exists (
    select 1 from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'auth' and c.relname = 'users'
  ) then
    execute 'grant references on auth.users to authenticated';
  end if;
end;
$$;

revoke all on table public.profiles from anon, public;
revoke all on table public.audit_records from anon, public;
revoke all on table public.audit_sources from anon, public;
revoke all on table public.findings from anon, public;
revoke all on table public.recommendations from anon, public;
revoke all on table public.evidence_refs from anon, public;

grant select, insert, update, delete, references on table public.profiles to authenticated;
grant select, insert, update, delete, references on table public.audit_records to authenticated;
grant select, insert, update, delete, references on table public.audit_sources to authenticated;
grant select, insert, update, delete, references on table public.findings to authenticated;
grant select, insert, update, delete, references on table public.recommendations to authenticated;
grant select, insert, update, delete, references on table public.evidence_refs to authenticated;

-- ----------------------------------------------------------------------------
-- 10. Row Level Security — enabled everywhere, owner-scoped policies
-- ----------------------------------------------------------------------------
alter table public.profiles        enable row level security;
alter table public.audit_records   enable row level security;
alter table public.audit_sources   enable row level security;
alter table public.findings        enable row level security;
alter table public.recommendations enable row level security;
alter table public.evidence_refs   enable row level security;

-- profiles: identity is the owner. INSERT is restricted to the session uid, so
-- a caller cannot mint a profile for somebody else's account.
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own
  on public.profiles for select
  to authenticated
  using (id = (select auth.uid()));

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own
  on public.profiles for insert
  to authenticated
  with check (id = (select auth.uid()));

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own
  on public.profiles for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

drop policy if exists profiles_delete_own on public.profiles;
create policy profiles_delete_own
  on public.profiles for delete
  to authenticated
  using (id = (select auth.uid()));

-- audit_records
drop policy if exists audit_records_select_own on public.audit_records;
create policy audit_records_select_own
  on public.audit_records for select
  to authenticated
  using (owner_id = (select auth.uid()));

drop policy if exists audit_records_insert_own on public.audit_records;
create policy audit_records_insert_own
  on public.audit_records for insert
  to authenticated
  with check (owner_id = (select auth.uid()));

drop policy if exists audit_records_update_own on public.audit_records;
create policy audit_records_update_own
  on public.audit_records for update
  to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy if exists audit_records_delete_own on public.audit_records;
create policy audit_records_delete_own
  on public.audit_records for delete
  to authenticated
  using (owner_id = (select auth.uid()));

-- audit_sources
drop policy if exists audit_sources_select_own on public.audit_sources;
create policy audit_sources_select_own
  on public.audit_sources for select
  to authenticated
  using (owner_id = (select auth.uid()));

drop policy if exists audit_sources_insert_own on public.audit_sources;
create policy audit_sources_insert_own
  on public.audit_sources for insert
  to authenticated
  with check (
    owner_id = (select auth.uid())
    -- belt and braces on top of the composite FK: the parent row must belong
    -- to the same authenticated user.
    and exists (
      select 1 from public.audit_records r
      where r.id = audit_record_id and r.owner_id = (select auth.uid())
    )
  );

drop policy if exists audit_sources_update_own on public.audit_sources;
create policy audit_sources_update_own
  on public.audit_sources for update
  to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy if exists audit_sources_delete_own on public.audit_sources;
create policy audit_sources_delete_own
  on public.audit_sources for delete
  to authenticated
  using (owner_id = (select auth.uid()));

-- findings
drop policy if exists findings_select_own on public.findings;
create policy findings_select_own
  on public.findings for select
  to authenticated
  using (owner_id = (select auth.uid()));

drop policy if exists findings_insert_own on public.findings;
create policy findings_insert_own
  on public.findings for insert
  to authenticated
  with check (
    owner_id = (select auth.uid())
    and exists (
      select 1 from public.audit_records r
      where r.id = audit_record_id and r.owner_id = (select auth.uid())
    )
  );

drop policy if exists findings_update_own on public.findings;
create policy findings_update_own
  on public.findings for update
  to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy if exists findings_delete_own on public.findings;
create policy findings_delete_own
  on public.findings for delete
  to authenticated
  using (owner_id = (select auth.uid()));

-- recommendations
drop policy if exists recommendations_select_own on public.recommendations;
create policy recommendations_select_own
  on public.recommendations for select
  to authenticated
  using (owner_id = (select auth.uid()));

drop policy if exists recommendations_insert_own on public.recommendations;
create policy recommendations_insert_own
  on public.recommendations for insert
  to authenticated
  with check (
    owner_id = (select auth.uid())
    and exists (
      select 1 from public.audit_records r
      where r.id = audit_record_id and r.owner_id = (select auth.uid())
    )
    and (
      finding_id is null
      or exists (
        select 1 from public.findings f
        where f.id = finding_id and f.owner_id = (select auth.uid())
      )
    )
  );

drop policy if exists recommendations_update_own on public.recommendations;
create policy recommendations_update_own
  on public.recommendations for update
  to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy if exists recommendations_delete_own on public.recommendations;
create policy recommendations_delete_own
  on public.recommendations for delete
  to authenticated
  using (owner_id = (select auth.uid()));

-- evidence_refs
drop policy if exists evidence_refs_select_own on public.evidence_refs;
create policy evidence_refs_select_own
  on public.evidence_refs for select
  to authenticated
  using (owner_id = (select auth.uid()));

drop policy if exists evidence_refs_insert_own on public.evidence_refs;
create policy evidence_refs_insert_own
  on public.evidence_refs for insert
  to authenticated
  with check (
    owner_id = (select auth.uid())
    and exists (
      select 1 from public.audit_records r
      where r.id = audit_record_id and r.owner_id = (select auth.uid())
    )
    and (
      finding_id is null
      or exists (
        select 1 from public.findings f
        where f.id = finding_id and f.owner_id = (select auth.uid())
      )
    )
  );

drop policy if exists evidence_refs_update_own on public.evidence_refs;
create policy evidence_refs_update_own
  on public.evidence_refs for update
  to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy if exists evidence_refs_delete_own on public.evidence_refs;
create policy evidence_refs_delete_own
  on public.evidence_refs for delete
  to authenticated
  using (owner_id = (select auth.uid()));

-- No policy is granted to anon or to public; with RLS on and zero permissive
-- policies for those roles, every anonymous operation is denied.

-- ----------------------------------------------------------------------------
-- 11. Private storage bucket + prefix-scoped RLS
-- ----------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('konsena-private', 'konsena-private', false, 52428800, null)
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit;

-- Supabase initialises storage.objects with RLS already on, and the migration
-- role is NOT its owner, so a bare ALTER fails with SQLSTATE 42501. Assert the
-- invariant instead of assuming it: pass when it already holds, attempt the
-- ALTER when this role owns the table, and fail loudly if neither works.
do $$
declare
  v_enabled boolean;
begin
  select c.relrowsecurity
    into v_enabled
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'storage' and c.relname = 'objects';

  if coalesce(v_enabled, false) then
    return;
  end if;

  begin
    execute 'alter table storage.objects enable row level security';
  exception when insufficient_privilege then
    raise exception 'storage.objects has RLS disabled and this role cannot enable it';
  end;
end;
$$;

-- Objects live under `<auth.uid()>/...`. string_to_array is used rather than
-- storage.foldername() so the rule does not depend on a helper that has moved
-- between Storage releases. A file placed at the bucket root has no folder and
-- is therefore never owned by anybody -> denied.
drop policy if exists konsena_private_select_own on storage.objects;
create policy konsena_private_select_own
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'konsena-private'
    and (string_to_array(name, '/'))[1] = (select auth.uid())::text
  );

drop policy if exists konsena_private_insert_own on storage.objects;
create policy konsena_private_insert_own
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'konsena-private'
    and (string_to_array(name, '/'))[1] = (select auth.uid())::text
  );

drop policy if exists konsena_private_update_own on storage.objects;
create policy konsena_private_update_own
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'konsena-private'
    and (string_to_array(name, '/'))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'konsena-private'
    and (string_to_array(name, '/'))[1] = (select auth.uid())::text
  );

drop policy if exists konsena_private_delete_own on storage.objects;
create policy konsena_private_delete_own
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'konsena-private'
    and (string_to_array(name, '/'))[1] = (select auth.uid())::text
  );

-- konsena-private must stay public=false: no public URL for user
-- screenshots/documents (PRD §13.3). This is enforced by the bucket insert
-- above (`on conflict do update set public = false`) and asserted by the pgTAP
-- suite. A `comment on column storage.buckets.public` statement was removed:
-- the migration role does not own storage tables (SQLSTATE 42501), and a
-- comment adds no safety that the constraint + tests do not already provide.
