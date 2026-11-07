-- ============================================================================
-- KONSENA AI — Phase 00 seed
--
-- SYNTHETIC TEST DATA ONLY. Every row below is clearly marked and exists only
-- so that `supabase db reset` (LOCAL) yields a non-empty schema for manual
-- inspection. It contains no real user, no real device, no real document and
-- no real evidence.
--
-- This file is executed by `supabase db reset`, which is a LOCAL-ONLY command.
-- It is intentionally never applied to a remote/production project.
-- ============================================================================

-- Test identity. The password hash is a placeholder: no sign-in is possible
-- with it and none is intended.
insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_sso_user, is_anonymous
)
values (
  '00000000-0000-4000-8000-0000000000aa',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'phase00-seed@test.konsena.local',
  'synthetic-hash-not-valid-for-signin',
  now(), now(), now(),
  '{"provider":"email","providers":["email"]}',
  '{"seed":true,"synthetic":true}',
  false,
  false
)
on conflict (id) do nothing;

insert into public.profiles (id, locale, cloud_sync_enabled, privacy_preferences)
values (
  '00000000-0000-4000-8000-0000000000aa',
  'id',
  false,
  '{"analytics":false,"cloudSync":false,"synthetic":true}'::jsonb
)
on conflict (id) do nothing;

insert into public.audit_records (id, owner_id, title, status, source_summary)
values (
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-0000000000aa',
  '[TEST] Audit contoh (data sintetis)',
  'draft',
  'Sintetis — bukan hasil pindaian nyata'
)
on conflict (id) do nothing;

insert into public.audit_sources (id, owner_id, audit_record_id, type, metadata)
values (
  '00000000-0000-4000-8000-000000000011',
  '00000000-0000-4000-8000-0000000000aa',
  '00000000-0000-4000-8000-000000000001',
  'android_permission',
  '{"packageName":"com.example.synthetic","synthetic":true}'::jsonb
)
on conflict (id) do nothing;

insert into public.findings (id, owner_id, audit_record_id, label, summary, engine_type)
values (
  '00000000-0000-4000-8000-000000000021',
  '00000000-0000-4000-8000-0000000000aa',
  '00000000-0000-4000-8000-000000000001',
  '[TEST] Temuan contoh',
  'Sintetis — bukan hasil analisis',
  'none'
)
on conflict (id) do nothing;

insert into public.recommendations (id, owner_id, audit_record_id, finding_id, text, status, origin)
values (
  '00000000-0000-4000-8000-000000000031',
  '00000000-0000-4000-8000-0000000000aa',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000021',
  '[TEST] Rekomendasi contoh — data sintetis',
  'pending',
  'rule_based'
)
on conflict (id) do nothing;

insert into public.evidence_refs (id, owner_id, audit_record_id, finding_id, excerpt, location_ref)
values (
  '00000000-0000-4000-8000-000000000041',
  '00000000-0000-4000-8000-0000000000aa',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000021',
  '[TEST] Kutipan sintetis pendek, bukan teks kebijakan asli.',
  'synthetic#L1'
)
on conflict (id) do nothing;

-- One synthetic object reference; the file itself is never uploaded by Phase 00.
insert into storage.buckets (id, name, public, file_size_limit)
values ('konsena-private', 'konsena-private', false, 52428800)
on conflict (id) do update set public = false;
