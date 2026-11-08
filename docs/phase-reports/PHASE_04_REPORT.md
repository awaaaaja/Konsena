# PHASE 04 REPORT — Policy import, PDF extraction and OCR

## Status

**IN_PROGRESS — READ/THINK complete; BUILD not started.** Phase 02 local source
storage is PASS and Phase 03 is PASS. S07, S11, S25, S26 and S28 routes exist,
but currently render route-placeholder screens. No Phase 05 work is in scope.

## READ — current repository and compatibility

- PRD §F04 and Phase 04 acceptance require PDF/JPG/PNG/TXT/paste; PDF text-layer
  extraction before OCR; scanned PDF/image OCR; page traceability; local review;
  recoverable corrupt/password/unsupported errors; no AI classification.
- `file_picker` 13.3.2 is already a dependency. Its endorsed Android
  `android_file_picker` 2.1.3 implementation uses `ACTION_OPEN_DOCUMENT` (SAF),
  supports custom extensions, file size and byte-stream reads. Android's SAF
  access grant can be transient; source bytes therefore must be copied while
  readable to app-private encrypted storage. Do not persist or depend on the
  external URI after import. File read errors map to a recoverable source error.
- `pdfrx` 2.12.0 / `pdfrx_engine` 0.9.1 document PDFium-backed Android support,
  page `loadText`/`loadStructuredText` and bounded page rendering. Package docs
  specify Flutter 3.47 / Dart 3.13+, matching this repo's Flutter 3.47.8 / Dart
  3.13.7. Package license is MIT. Native-assets/PDFium build and memory remain
  integration risks and must be exercised by APK build and fixtures.
- `google_mlkit_text_recognition` 1.0.1 docs specify Android minSdk 21,
  target/compile SDK 36; this app is minSdk 24 / SDK 36. Default Android
  recognition is bundled Latin, suitable for Indonesian and English without
  making network/model-download behavior part of this feature. OCR should be
  isolated behind a replaceable interface and disposed on cancel/completion.
- Existing `DocumentSources` has source type, original name, URL/provenance
  locator, bytes/hash/lifecycle/review metadata; `DocumentSegments` stores
  encrypted text and sequence/page; `EvidenceReferences` can bind source hash,
  segment and quote. Phase 02 files are AES-GCM encrypted locally. Schema v2
  has no extraction method, raw text offsets, bbox, warning or edit/review
  timestamp fields: schema v3 migration is needed for those traceability facts.
- Workspace currently attaches bytes but treats images as consent-UI captures
  and does not extract text; existing audit routes and analyzer mark document
  import/editor/progress placeholders. S11 is `/scan/review/:docId`; S25 is
  `/scan/document-type`; S26 `/scan/import/progress`; S28
  `/document/:docId/clauses`. Audit associations must be explicit and only use
  the selected audit ID; app association is not inferred.

## THINK — decisions before BUILD

1. Keep the Phase 02 encrypted source-file store as the canonical original. On
   Android, use SAF with a strict MIME/extension allowlist, a transient
   read-only grant, size check, then copy bytes immediately; do not save external
   URI grants. Cancellation is a normal outcome. A revoked/missing/unreadable
   source returns a recoverable message, never a crash.
2. Add `pdfrx` as PDF engine: inspect page count first (maximum 100), extract
   text page-by-page, and use rendered page OCR only if extracted text is empty
   or below the tested validity threshold. Render one page at a time at bounded
   dimensions; release each image and honor cancellation between pages. Password
   protected/unsupported PDFs fail explicitly for now (no password persisted).
3. Use bundled Latin Google ML Kit for Indonesian/English OCR. OCR is offline;
   persist its method and review-required warning. OCR is not treated as legal
   truth until the user reviews/saves corrections. The package API will be
   compile-checked before relying on it.
4. Introduce an import domain pipeline separated from picker/UI: validated input,
   PDF/image/TXT/pasted-text processors, page-level progress, cancellation,
   segmentation and recoverable typed failures. Preserve raw extracted text
   encrypted and paragraph boundaries; normalized display text must not alter
   the evidence source. Persist source SHA-256 and segment start/end offsets into
   the original page text, page number, optional OCR bbox, extraction method,
   confidence/warning, and user edit/review timestamps. Quotes/evidence bind to
   source hash + segment.
5. Route all imports through a selected audit workspace. Require the user to
   choose `privacy_policy`, `terms`, or `otherDocument`, with optional URL/version;
   no automatic app association. S11 supports correction and idempotent save;
   S28 provides manual reading only. AI analysis remains unavailable.
6. Proposed files: `pubspec.yaml`/`pubspec.lock`; `lib/data/local/app_database.dart`
   and generated Drift file; audit domain/repository/cipher/source store; new
   `lib/features/policy_import/{domain,data,presentation}/`; router and route
   metadata for S07/S11/S25/S26/S28; relevant unit/widget/navigation tests; this
   report, phase status and known issues. No camera/LiveScan or later-phase
   modules.

### Risks and mitigations

- PDFium native assets could fail under this Flutter/Android toolchain: prove
  `flutter build apk --debug` immediately after adding dependency; if broken,
  stop and select a compatible maintained engine rather than patching upstream.
- OCR/native binaries increase APK size and page rendering can OOM: cap input at
  25 MB / 100 pages, render one page at a time to a bounded image (max 2048 px
  long edge), test long scans and cancellation; never load rendered pages all at
  once.
- File extension/MIME may be absent or deceptive: validate magic bytes and
  content signature; reject unsupported/mismatched input with a recoverable
  message.
- Text extraction order/encoding and scanned-vs-born-digital threshold can be
  misleading: keep per-page raw text, offsets/hash, method and warnings; test
  Indonesian/English/mixed encodings and user review; do not claim coverage or
  legal interpretation.
- PDF encryption/password behavior varies by engine: detect password errors and
  offer retry/unsupported; do not log or persist passwords.
- SQL v3 changes can affect existing Phase 02 users: add a forward-only migration
  test from v2 and rollback by reverting code/dependency while retaining the
  prior schema/data. Never downgrade or delete user data.
- OCR API/package is recently versioned: compile and device-test against locked
  package; isolate it so a version pin/adapter can be reverted without changing
  stored source records.

## Planned test and review matrix

- Parser tests: born-digital PDF (multiple pages), scanned PDF (OCR fallback),
  corrupt/password PDF, 0/101-page and oversize input; JPG/PNG, pasted text,
  UTF-8 TXT and malformed encoding; validity threshold and whitespace/paragraph
  boundaries; page/source/hash/offset/bbox provenance.
- Repository/migration: v2→v3, encrypted raw and segment text, source hash,
  idempotent editor save, correction/review timestamps, evidence quote
  validation, lifecycle/delete and missing-file/revoked-source handling.
- UI: progress, page count, cancel/retry/error recovery, source type selection,
  explicit audit association, S11 edit/resume, no AI result, manual S28 reading.
- Required commands: `flutter analyze`, focused `flutter test
  test/features/policy_import/`, full `flutter test`, `flutter build apk --debug`,
  `git diff --check`; real Android SAF and OCR fixture checks if device remains
  available.

## Rollback

Revert only Phase 04 source/dependency/migration changes if the PDF/OCR engine
cannot pass compatibility or acceptance. Keep forward-compatible schema and
existing encrypted sources; no database downgrade, destructive cleanup, cloud
upload or Phase 05 edits. Re-run Phase 02 regression tests after rollback.

## BUILD / REVIEW / GATE

### Implemented

- Added schema v3 provenance/edit metadata and AES-GCM-encrypted source/page
  text, source URL/version/warnings, source hashes, offsets, page hashes,
  extraction method, OCR confidence/bounds and edit/review timestamps.
- Added SAF allowlisted import with transient read-only access, capped stream
  reads and immediate encrypted app-private source copy before extraction.
- Added PDF text-first extraction, bounded single-page PDF rendering, local
  Latin ML Kit OCR fallback, JPG/PNG OCR, UTF-8/UTF-16/Latin-1 TXT and pasted
  text, progress/cancel/retry, recoverable typed errors and password retry.
- Wired S07/S11/S25/S26/S28 and audit workspace source review. Source types and
  audit selection are explicit; reading and quote-to-source evidence linking
  remain manual. AI analysis is not enabled.

### Regression log: failures and fixes

| Gejala | Akar masalah | Perubahan | Regression / latest review |
|---|---|---|---|
| Host `flutter test` could not resolve a C compiler for PDFium's hook | Host has GCC but no `clang` executable | Used an external `/tmp/opencode/phase04/host-toolchain/clang` wrapper to GCC; no repo/toolchain profile changes | Focused and full test suites pass with this environment wrapper; see KNOWN_ISSUES P2 note |
| PDF fixtures initially all appeared corrupt in Flutter VM tests | Flutter VM worker did not discover hook-built PDFium library | Test setup locates hook output and creates/removes a test-owned link at the VM runner's expected library path | Born-digital, scanned, password, corrupt and long-PDF tests pass |
| Invalid image decoder exception escaped typed failure handling | `image` decoder can throw `ImageException` before OCR | Catch malformed decoder/frame exceptions and return `invalid_image` | Invalid PNG test passes |
| v1 migration test hit duplicate Phase 04 columns | Fixture started from current v3 DB but only removed Phase 02/v2 fields | Fixture now removes all v2/v3 fields before setting legacy version 1 | v1 and v2→v3 migration tests pass |
| Navigation canonical-route test expected placeholder on active Phase 04 routes | S07/S11/S25/S26/S28 now render feature pages | Updated route expectation to active page types | Canonical route test passes |
| S06 golden changed | Scan hub now truthfully offers local document import and explains audit requirement | Updated only `tab_pindai_393x852.png`; other golden baselines preserved | Full visual suite passes |

### Verification so far

- `flutter analyze` → **PASS**, no issues found.
- `flutter test test/features/policy_import/` → **PASS** (13 tests, including
  real PDFium parsing/rendering on host, with OCR isolated through test adapter).
- `flutter test test/data/audit_repository_test.dart` → **PASS** (17 tests,
  including v1 and v2 migrations, encryption, idempotency and edit timestamps).
- `flutter test` → **PASS, 112 tests**.
- `dart format --set-exit-if-changed lib test` → **PASS**, zero changes.
- `git diff --check` → **PASS**.
- `flutter build apk --debug` → **PASS**, final-source debug APK built in
  41.6 s and reinstalled successfully on the target device; latest dashboard
  launched and retained local audit records.
- Samsung SM-A556E / Android 16 (API 36), serial `RRCY102L98L`: device
  acceptance opened S06, reached S07/S25, audit workspace and SAF DocumentsUI.
  A synthetic local PNG selected through SAF was copied into encrypted source
  storage, processed by on-device Latin ML Kit OCR, and opened in S11 for
  mandatory review. OCR recognized the synthetic policy paragraph with 78%
  reported confidence; page, extraction method and page hash appeared in the
  review UI. No real user document was selected. The final-source APK was then
  built, reinstalled and launched; local audit records remained available.
  (Temporary generator and image remain outside the repository in
  `/tmp/opencode/phase04`.)

### Final gate: **PASS — 2026-11-08**

All Phase 04 automated gates, latest-source APK build/install, SAF selection,
on-device OCR and manual-review acceptance passed. Known host-only PDFium test
toolchain workaround is documented as P2-006. Phase 05 may proceed as a separate
task; no Phase 05 behavior was started here.
