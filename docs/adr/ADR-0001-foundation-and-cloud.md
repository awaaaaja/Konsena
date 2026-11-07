# ADR-0001 — Foundation and cloud posture for Phase 00

- **Status:** Accepted
- **Date:** 2026-11-07
- **Phase:** 00 (Setup repo Flutter dan Supabase)
- **Deciders:** lead Flutter engineer, Supabase/PostgreSQL engineer, security reviewer

## Context

KONSENA AI is one Android-first Flutter application that must be **guest-first**
and **offline-first**. Supabase is provisioned from Phase 00 so that Auth,
Postgres RLS and a private Storage bucket exist as infrastructure, while actual
use of Auth/sync by end users stays optional and opt-in (PRD §3.1, §3.3, §13).

Constraints discovered during the Phase 00 audit:

| Fact | Consequence |
|---|---|
| Flutter 3.47.8 stable, Dart 3.13.7 | dependency versions chosen against this SDK |
| Android SDK 36.0.0 installed; Flutter defaults compileSdk 36 / minSdk 24 / targetSdk 36 | matches PRD §3.1 compatibility policy with no override |
| JDK 17 present at `~/develop/jdk17` but `JAVA_HOME` unset | `flutter build apk` needs `JAVA_HOME` exported per command |
| Supabase CLI 3.0.0 available through `npx` | `supabase init`, `migration new`, `link`, `push`, `test db` usable |
| **No container runtime on the machine** | `supabase start` cannot bring up the local stack, so local verification is unavailable |
| A Supabase hosted project exists and the operator granted link/push/test | remote becomes the only place RLS can actually be executed |

## Decisions

### 1. Config via `--dart-define` / `--dart-define-from-file`, not Gradle flavors

`AppConfig` reads `String.fromEnvironment` / `bool.fromEnvironment`. The
template lives in `tool/env/dev.example.json` and real values in
`tool/env/dev.json` (git-ignored).

*Rejected:* Android `productFlavors`. They force `--flavor` into every command,
complicate CI and add nothing that dart-define does not already provide for a
single-applicationId app. Revisit only if store-internal builds are needed.

### 2. Empty configuration is a normal state, never a crash

`AppConfig.evaluate()` maps the world into exactly five states:
`cloudNotConfigured`, `cloudDisabled`, `cloudConfigured`, `cloudInitialized`,
`cloudError`. Anything unusable resolves to `cloudNotConfigured` and the app
starts as a guest. `ENABLE_CLOUD_SYNC` defaults to `false`, so the out-of-box
build is `cloudDisabled` even when a URL and key are present.

### 3. The client refuses admin credentials at load time

`AppConfig._checkKey()` rejects, before any client is created:

- `sb_secret_*` keys,
- any JWT whose `role` claim is not `anon` (so a pasted `service_role` JWT is
  refused),
- keys that merely *look* like a placeholder from `dev.example.json`,
- non-https URLs and URLs carrying `user:pass@` credentials.

This is defence in depth: the credential must never reach the process, not just
never be logged.

### 4. Cloud access is behind an interface, not a global singleton

Features depend on `CloudGateway` (`CloudStatus`, `statusReason`,
`isCloudLive`, `isAuthenticated`, `initialize()`). `SupabaseCloudGateway` is the
only implementation that may construct a `SupabaseClient`, and it is reached
only through a single injectable `SupabaseInitializer` seam — which is what lets
tests prove that startup performs **zero** uploads or REST calls.

*Rejected:* letting widgets call `Supabase.instance` directly. It would make
offline features fail when cloud is absent, violating guest-first.

### 5. Composite foreign keys carry ownership, not just RLS

Every child table stores `owner_id` **and** declares
`(owner_id, parent_id) → parent(owner_id, id)`. A user who knows another user's
UUID still cannot attach a child to that user's parent: no matching composite
key exists, so PostgreSQL rejects the row regardless of which policy is in
force. RLS `WITH CHECK` is kept as a second, independent layer.

No `SECURITY DEFINER` function is introduced. The one trigger function
(`konsena_set_updated_at`) is `SECURITY INVOKER` with `search_path = ''` and
touches only `NEW.updated_at`; its justification is that clients must not be
able to backdate `updated_at`.

### 6. What is deliberately *not* in the cloud

Per PRD §13.1 and §9.4 the cloud subset carries only safe metadata and
references the user explicitly chose: no policy text, no screenshots, no camera
recordings, no raw OCR. `evidence_refs.excerpt` is capped at 1000 characters.

**`sync_devices` is deferred.** It is optional in PRD §13.1 and its cursor
semantics only become meaningful when Phase 07 implements the sync orchestrator
(queue, retry, conflict resolution). Adding an unused table with unproven cursor
semantics in Phase 00 would create schema we cannot yet test — record devices
then, when there is a client that writes them.

### 7. Private bucket, prefix-scoped Storage RLS

`konsena-private` is created with `public = false`. All four operations are
restricted to `name` whose first path segment equals `auth.uid()`, using
`string_to_array(name, '/')` rather than `storage.foldername()` so the rule does
not depend on a helper whose implementation has changed across Storage
releases. Objects at the bucket root have no owner folder and are therefore
visible to nobody.

### 8. Testing posture: remote is the executable source of truth

Because no container runtime exists, `supabase start` cannot run, so local
pgTAP execution is **BLOCKED**, not passed. The operator authorised linking the
existing hosted project, pushing migrations and running the pgTAP suite there.
Consequences:

- Statements about RLS are only true for the database the suite actually ran on.
- `supabase db reset` stays a **local-only** command and is never pointed at
  remote.
- Hosted results are recorded separately from local results in the phase report.

## Consequences

- Build commands need `JAVA_HOME=$HOME/develop/jdk17` until it is exported
  shell-wide.
- `dev.json` and `Kredensial.md` are git-ignored; the credential scratch file
  must still be rotated (see `docs/phase-reports/KNOWN_ISSUES.md`).
- Phase 01A may start on guest/local mode now that the config contract and
  router shell are proven.
- Phase 07 remains gated on a validated RLS suite and an explicit sync consent
  flow.

## References

- `docs/PRD_KONSENA_AI_MOBILE.md` §3.1, §3.3, §9.1, §9.4, §11, §13
- `docs/REQUIREMENTS_TRACEABILITY.md` (row: Phase 00)
- `docs/DESIGN_SYSTEM.md` (colour tokens used by the Phase 00 shell)
