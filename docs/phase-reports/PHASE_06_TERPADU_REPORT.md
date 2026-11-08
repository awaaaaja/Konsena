# Phase 06 Terpadu — Evidence, model, pilot, dan rilis Android

Tanggal: 2026-11-08. Scope dokumen ini menggabungkan fase lama 06–11; laporan
00–05 dipertahankan sebagai histori dan tidak ditulis ulang.

## 1. READ — baseline aktual

### Repo dan instruksi

- Root repo sesuai workspace. `AGENTS.md` tidak ditemukan. Working tree sudah
  memiliki perubahan Phase 03–05, termasuk generated Drift file, goldens,
  dependencies, router, dan test; staged changes ada pada
  `lib/app/app_router.dart` serta `test/features/permission_inspector/platform_contract_test.dart`.
  Semua perubahan tersebut dianggap milik operator dan dipertahankan.
- Master spec: `docs/PRD_KONSENA_AI_MOBILE.md`; route contract:
  `docs/KONSENA_AI_PAGE_BY_PAGE.md` dan `lib/app/navigation/route_registry.dart`
  mendefinisikan tepat 40 screen S00–S39 dan shell lima tab.
- Sejarah: Phase 00–05 berstatus PASS di `PHASE_STATUS.md` (Phase 05 atas
  konfirmasi operator); sebagian pengujian fisik/accessibility tetap NOT_RUN
  sebagaimana laporan lama. Status lama 06–11 akan dipetakan ke satu baris
  “06 Terpadu”; fase legacy 07–11 bukan pekerjaan terpisah di siklus ini.

### Implementasi yang dipakai ulang

- Drift `AppDatabase` schema v3, cascade FK, app-private encrypted source files,
  AES-GCM sensitive fields dan key Flutter Secure Storage/Android Keystore,
  repository idempotent/recovery; belum ada CRUD annotation history / report
  cache / cloud sync queue.
- Android: `applicationId id.konsena.ai`, min 24, target/compile 36, Java/Kotlin
  17; manifest utama memiliki CAMERA dan selective launcher/PROCESS_TEXT
  queries. Tidak memakai QUERY_ALL_PACKAGES. Settings permission channel sudah
  ada dari Phase 03.
- OCR: ML Kit Latin pipeline Phase 04; LiveScan Phase 05 menangani frame,
  provenance dan gap. Source lokal dienkripsi. `AnalysisEngine` saat ini hanya
  kontrak return `AnalysisUnavailable`; default `UnavailableAnalysisEngine`.
- Supabase: foundation/gateway dan publishable-key validation tersedia, namun
  user Auth/sync client belum diimplementasikan. Known issues P0-001 (rotasi
  secret) dan P1-002 (project ref belum diputuskan) masih OPEN. Remote production
  tidak disentuh; cloud production `CLOUD_BLOCKED`.
- UI audit: S14 workspace menampilkan sources; S15/S16/S17/S18/S22/S29/S30/S31/
  S32/S33/S34/S36/S37 serta S12/S13 sebagian besar route-spec/placeholder.
  RouteScreenPage punya back CTA generik namun beberapa page aktif tidak punya
  back affordance yang konsisten. Akan diaudit dan diperbaiki terarah.

### Model asset READ

- `assets/models/catalog.json` berisi empat model dan SHA-256 yang disilang
  dengan berkas ONNX. Model binary tidak dimasukkan ke Flutter assets.
- Consent NLI contract: WordPiece pair, length 256, input `input_ids` dan
  `attention_mask` int64, output 3 logits, temperature 1.3195, model version
  `fd543a…`; Android parity masih BLOCKED di metadata.
- ConsentGap contract: 5 label terpisah (aligned/underspecified/not_found/
  contradicted/unverifiable), temp 0.65. Catalog `demo_only`/`failed_parity`;
  tetap karantina.
- Dark Pattern: float32 RGB NCHW 1×3×224×224 → 2 logits, temp 1.07177;
  Android validation BLOCKED, golden_cases mereferensikan fixture yang belum
  terbukti tersedia. Candidate hanya QA_ONLY jika semua input tersedia.
- Privacy Classifier: 9 sigmoid labels dan per-label thresholds; metadata
  `experiment_only`/`release_eligible:false`; bukan user-facing release model.
- Host Python tidak memiliki `onnx`, `onnxruntime`, `tokenizers`, atau
  `transformers`; ONNX Runtime belum ada di Gradle/Flutter. File model tidak
  memiliki lisensi distribusi, dataset card/quality evaluation lengkap, atau
  bukti Android parity yang terlihat. Hash dapat diperiksa, tetapi graph signature
  dan model inference/parity belum bisa diklaim.

### Rencana sebelum BUILD

| Kelompok | Modul yang direncanakan | Risiko konkret | Tes / rollback |
|---|---|---|---|
| Screenshot/evidence + navigasi | S12/S13 pages, encrypted source repository, schema jika diperlukan, audit workspace, route actions/back | image crop/rotation mengubah koordinat anotasi; metadata harus ikut cascade | unit crop/coordinate and persistence tests, widget/route CTA/back; forward-only migration, revert route/UI only |
| Audit fact/evidence/actions/report | S14–S18/S29–S32, provenance resolver, PDF/share if libraries usable | stale/deleted source dapat tampil sebagai evidence aktif; PDF/share SDK compatibility | active-source and delete tests, export tests; keep analysis unavailable |
| History/privacy | S19/S20/S21/S34/S36 guest-first controls | delete local / export scopes overstated | repository restart/cascade tests; retain DB and avoid destructive cleanup |
| Cloud | No production changes; inspect config only | credentials/project target open, no auth/RLS A/B deployment acceptance | fixture-only tests if seam exists; no remote writes, status CLOUD_BLOCKED |
| Model QA | hash/metadata/graph audit, runtime adapter only if runtime & parity feasible | missing runtime/license/fixtures and Android validation; accidental AI claim | default models disabled, ConsentGap quarantined, fallback tests; remove optional adapter cleanly |
| App flow/navigation | CTA trace S00–S39, visible back/parent affordance where appropriate | breaking canonical routes/tab retention | navigation smoke for all IDs, targeted back tests, no shell/path changes |
| Release/handoff | actual tests, manifest/privacy/library audit, release build if signing permits | release build uses debug signing; no Play Data Safety or pilot evidence | APK/AAB build + hash only if succeeds; never publish or expose secrets |

No new dependency is committed by this plan. New native ONNX dependency will be
considered only after model/runtime compatibility and Android QA can be proved.
Rollback is scoped to this execution's route/UI/schema/additions; no global
checkout/reset/clean and no destructive DB changes.

## 2. BUILD / REVIEW / FIX — execution log

Implementation and verification results are appended by work group below.

### Offline implementation

- S12 accepts explicit SAF PNG/JPEG selection, capped at 10 MB / 16 MP with
  magic/decode validation; original bytes use the existing AES-GCM store.
- S13 supports bounded normalized crop, quarter-turn rotation, metadata edit,
  add/edit/delete manual annotations and append-only encrypted revision history.
  Coordinates always refer to the EXIF-baked original. Crop/rotation is a view
  transform, not a destructive replacement of the evidence source.
- Existing schema v3 `user_actions` is reused as an encrypted screenshot
  revision journal. No schema migration/downgrade or cloud SQL change is needed.
  Source detach explicitly deletes source-specific revisions rather than leaving
  sensitive text on the existing SET NULL FK; audit cascade remains intact.
- S14 now links all source acquisition routes with audit context, shows Android
  snapshots and document type/version/date/review, refreshes on repository changes,
  and opens S15 instead of merely displaying an unavailable snackbar.
- S15/S16/S17/S18/S29/S30/S31/S32/S33/S34/S38 route to local fact-based detail
  pages. No findings, confidence, risk score or legal conclusions are invented.
  Each evidence quote must match a segment on the same audit/source/hash. Changed
  quotes, missing/corrupt files and removed sources cannot remain active evidence.
- S18/S33 regenerate PDF from a fresh SQLite snapshot on every open/share, with
  provenance identifiers, timestamps, corrections, manual-annotation labels and
  AI-unavailable status. Source changes during generation invalidate export.
  PDF previews use pdfrx; Android share uses ACTION_SEND, read-only content URI,
  non-exported FileProvider limited to `cache/audit_exports`. Raw sources/images
  are not embedded by default. New dependency: `pdf 3.13.1` (MIT; lockfile updated).
- Export cache is plaintext by explicit export, not advertised as encrypted;
  clear on process startup, explicit controls, and before production deletion.
  Old cache files are expired on subsequent export after one hour. No claim of
  timed deletion while the process is stopped. Shared copies are outside local
  deletion scope; UI says so.
- S19 adds search/focus filtering and S34 resume; S36 lists selected audit
  export/control paths, cache cleanup and confirmed deletion of all audits.
  Preferences remain, and no unsafe undo is offered.
- Reusable visible Back uses stack pop where possible and a defined parent on
  deep links; applied to active import/review, inspector, camera, Settings/About,
  screenshot, report and privacy pages. S25 and S39 offer explicit audit selection
  rather than silently associating the latest audit. Canonical routes and five
  tabs are unchanged.
- Android backup/cloud backup/device-transfer exclusions and cleartext denial
  were added; no broad storage, screen capture, microphone, all-packages or
  telemetry permission was added.

### Model QA, isolated from user-facing analysis

- Created a temporary host venv outside the repo containing ONNX 1.23.2,
  ONNX Runtime 1.31.1, tokenizers 0.23.3 and NumPy 2.5.4. `tool/verify_model_packages.py`
  checks all seven binary SHA-256 values, actual graphs with ONNX checker,
  input/output signatures, host tokenizer IDs/masks, logits and calibrated decode.
- FP32 golden absolute logit tolerance **0.001** was declared before testing in
  the harness. This numerical-contract tolerance is not a quality/license gate.
- Dark Pattern missing golden tensors were reconstructed from the documented
  NumPy PCG64 generator **only after exact published tensor SHA-256 matched**.
  All 14 recovered tensors are in `/tmp/opencode/phase06-golden-tensors`, not app assets.
- Host: NLI 14/14, Dark Pattern 14/14 and Privacy Classifier 14/14 passed authored
  golden probes. These are explicitly NOT evaluation datasets. ConsentGap's
  10 contract probes are diagnosis only; its original failed PyTorch export
  parity remains quarantined regardless of ONNX self-consistency.
- Added ONNX Runtime Android 1.31.1 as **debugImplementation only**, native
  single-worker tensor harness, strict FP32 allowlist/hash check, bounded tensors,
  finite-output check, and closing tensor/session resources. Release/profile
  do not register the QA channel or include this runtime. `ENABLE_MODEL_QA`
  is false by default; production `AnalysisEngine` stays unavailable.
- `AnalysisResult` now distinguishes result/insufficientSources/unavailable/error
  compatibly; unavailable fallback and old unavailable-run history are retained.
  Debug tensor output is not persisted as a finding, not mapped to ConsentGap,
  and not presented in audit UI/PDF.
- `tool/prepare_android_model_qa.py` verifies catalog hash and available space,
  then explicitly streams only the selected allowlisted package to private QA
  test storage. No automatic download or inclusion in the base APK.
- Native debug WordPiece validates the supplied case-sensitive BertNormalizer
  contract, Unicode cleaning/Chinese/punctuation splitting, added special tokens,
  longest-first pair truncation, padding and masks; unsupported normalizers fail.
  Android instrumentation compares all 14 original NLP token-ID/mask vectors.

### Device QA observed so far — SM-A556E / API 36 / 8 GB class

| Model / path | Actual result | Measurements (single bounded run, not sustained thermal budget) |
|---|---|---|
| Dark Pattern FP32 tensor inference | `QA_ONLY`, 14/14 | max logit error 3.8445e-6, load 37.45 ms, inference 5.89–11.04 ms, session PSS 126,488 KB |
| Consent NLI FP32 + WordPiece | `QA_ONLY`, 14/14 IDs/masks + logits | max logit error 1.6056e-6, load 1,342.69 ms, inference 328.69–389.68 ms, session PSS 653,293 KB |
| Privacy Classifier FP32 + WordPiece | `QA_ONLY`, 14/14 IDs/masks + logits | max logit error 7.3910e-6, load 1,164.04 ms, inference 328.13–390.62 ms, session PSS 652,075 KB |

Decoded-label Android assertions also passed with the supplied per-model
calibration on the final instrumentation run (14/14 per model). Latest session
metrics: NLI load 1,116.22 ms / PSS 652,481 KB; Dark Pattern load 39.67 ms / PSS
123,133 KB; Privacy Classifier load 1,132.92 ms / PSS 653,927 KB.
Image preprocessing from arbitrary real screenshot ROI is
not yet parity-proven by the tensor harness, so no visual AI release claim is made.
Distribution licenses, dataset/domain/language quality review and sustained
device budget remain unavailable; all models stay disabled for pilot usage.
4/6 GB device classes, sustained battery/thermal tests and full TalkBack are NOT_RUN.

### Kelanjutan setelah log OpenCode

- Log 06:03 WIB mencatat batas penggunaan provider. Cuplikan terakhir
  berhenti saat ringkasan workspace S14 dan panel eksperimen NLI belum
  terhubung. Ringkasan S14 sekarang menampilkan jumlah snapshot, Policy,
  Terms, screenshot, status tinjauan dan waktu perubahan.
- S15 membuka eksperimen hanya di Flutter debug dengan
  `--dart-define=ENABLE_MODEL_QA=true` dan persetujuan per sesi. Engine
  memeriksa dokumen aktif dari audit yang sama, segmen yang dipilih, dan izin
  yang dideklarasikan pada snapshot. Hasil memuat versi model, hash sumber,
  segmen, package dan waktu. Perubahan revisi membatalkan hasil. Panel
  menyimpan hasil sementara di memori. Histori, evidence dan PDF tetap
  memakai data faktual.
- Tautan provenance screenshot di PDF membuka S13. Dialog ganti nama S14
  memakai input yang mengikuti lifecycle dialog. Regresi mencakup rute PDF,
  dialog pada 320 dp/200%, flag QA, salah asosiasi audit, izin yang tidak
  tercatat dan koreksi saat inferensi berjalan.
- S11 menampilkan **Tersimpan dan ditinjau** setelah semua paragraf berhasil
  disimpan. Status dibaca ulang saat dokumen dibuka kembali. Perubahan teks
  mengaktifkan tombol simpan lagi. Kegagalan menulis mempertahankan teks
  edit dan menyediakan percobaan ulang.
- Audit APK gabungan menemukan izin mikrofon dan penyimpanan warisan dari
  CameraX. Manifest app menghapus tiga deklarasi tersebut. LiveScan
  menggunakan gambar tanpa audio dan pemilih sumber memakai SAF. Runtime
  ONNX debug juga mematikan event telemetry sebelum inferensi.

### BUILD → REVIEW → FIX log

| Symptom | Root cause | Fix | Regression / latest status |
|---|---|---|---|
| Evidence could accept an invented quote | Old repository checked only segment identity/hash | Exact current-text matching, encrypted locator, active-source/file checks and stale-quote filtering | New evidence integrity, correction, wrong-audit, missing-file and cascade tests |
| Screenshot edits could lose their coordinate basis after transformation | Crop/rotation without a stable source-space contract | Original-normalized EXIF-baked coordinates stored with every revision; preview separate | Crop/rotation/roundtrip/invalid ROI tests PASS |
| Child deep link had no automatic AppBar back | AppBar only infers stack pop | Explicit parent-fallback Back widget | Push/pop and direct deep-link back test PASS |
| Workspace could remain stale after child imports | Cubit loaded once, not subscribed to source changes | Listen to repository changes and clear deleted session state | Existing Cubit/restart tests rerun below |
| Kotlin debug build failed on PSS metric type | `Debug.getPss()` returned Long | Use Bundle.putLong | Debug APK rebuild PASS |
| Host model harness failed at ConsentGap case `text` | ConsentGap golden data only supplies tensors | Diagnose input tensors without claiming tokenizer parity for that model | Host verification completed; ConsentGap still QUARANTINED |
| Full test initial run: 128 pass / 2 fail | S25 CTA wording changed; screenshot S06 copy changed intentionally | Update explicit audit-selection assertion; inspect old/new S06 image before updating that single golden | Focused golden rerun PASS; suite akhir 134 PASS |
| Focused golden update captured a missing logo; subsequent full suite detected 676-pixel mismatch | Asset decode was outside fake clock; an isolated run had not awaited it | Precache the brand asset with tester.runAsync before captures | Full golden matrix and full suite PASS; no image comparison tolerance weakened |
| On-device crop Apply led to Flutter red assertion | Dialog controllers disposed as soon as showDialog future returned, before reverse transition unmounted fields | Dialog now owns/disposes its controllers with its widget State; validates invalid coordinates visibly | Focused crop Apply/Cancel regression PASS; real SM-A556E crop/rotate/annotation/save retest PASS |
| Kompilasi awal S15 gagal | Tipe record dropdown dan daftar segmen kosong terinferensi sebagai `Object?` atau `dynamic` | Tipe record dan elemen segmen dibuat eksplisit | Hasil build dan uji ulang pada §4 |
| Tombol S11 tetap menawarkan simpan setelah sukses | Label sebelumnya hanya membedakan sedang simpan dan idle | Label mengikuti status tinjauan persisten dan perbedaan teks saat ini terhadap teks yang tersimpan | Regresi mencakup simpan, buka ulang, edit, gagal tulis dan coba ulang |

### Physical offline pilot observed

- Samsung SM-A556E / Android 16/API 36, 8 GB class (`MemTotal 7,606,432 KB`).
  `am start -S -W` reported a debug cold launch TotalTime 4,259 ms; another
  install/cold-launch reported 5,464 ms. These are debug timings, not release SLOs.
- Created a fresh local audit through the explicit screenshot flow. The only
  selected screenshot was `tool/generate_pilot_fixture.dart`'s authored synthetic
  consent PNG (720×960; no personal content). No real document was selected and
  LiveScan was not recaptured.
- SAF selection → encrypted original → S13 succeeded. After the crop-dialog fix,
  bounded crop/rotation, manual annotation `Synthetic_QA_evidence`, and save to
  workspace succeeded. Existing audits were retained.
- S18 built and opened a real PDF in pdfrx, containing current metadata,
  original-coordinate annotation and evidence/source ID. Android ACTION_SEND
  opened `com.android.intentresolver/.ChooserActivityLauncher`; no receiver was
  selected, so no actual external delivery is claimed.
- A generated cache PDF existed under `cache/audit_exports`; explicit cache
  cleanup left the directory empty, checked with app-scoped `run-as ls`.
- Verifikasi restart/resume pada kelanjutan memakai audit sintetis terpisah
  dengan nama `Pilot Phase 06 Codex`. Uji bulk delete menggunakan fixture
  repository agar data audit perangkat dapat dipertahankan.

## 2a. S00–S39 capability and navigation matrix

PASS below means the stated offline implementation/automated scope, not every
possible manual case or AI inference. Device cases not observed remain NOT_RUN.

| Screen | Current flow / button destination | Verification scope |
|---|---|---|
| S00 | Bootstrap → onboarding/privacy/home | PASS regression; first-install reset on current device NOT_RUN (preserve data) |
| S01 | Tutorial → S02 | PASS regression, target/200% tests |
| S02 | Guest privacy choices → S03; Back when revisited | PASS regression, separate opt-ins |
| S03 | Start → S24; five tabs retained | PASS golden/route; device launch |
| S04 | Visible launcher app picker → S05 with audit context | PASS existing Phase 03 + regression |
| S05 | Facts → Android Settings/refresh/workspace | PASS Phase 03 and contract tests; uninstall/error tests retained |
| S06 | Document → S25; camera → S39; screenshot → S12 | PASS route/golden + device screenshot path |
| S07 | SAF/paste → S26 | PASS parser/UI regression |
| S08 | JIT camera permission → S09; help S35 | PASS route; fresh physical deny/permission prompt NOT_RUN here |
| S09 | Capture/pause/finish → S10; Back/dispose releases camera | PASS stitcher/route; Phase 05 operator acceptance, no rescan here |
| S10 | Review/confirm → S11; gaps → S27 | PASS existing route/unit scope; no new capture |
| S11 | Koreksi OCR, indikator tersimpan, edit ulang → audit/baca dokumen | PASS persistence/parser dan regresi simpan/gagal/coba ulang |
| S12 | Choose/create audit → SAF screenshot → S13 | PASS synthetic device selection |
| S13 | Crop/rotate/metadata/manual annotations/revisions → S14 | PASS unit/dialog and synthetic device retest |
| S14 | App/policy/Terms/screenshot → review; status S15; report S18 | PASS repository/route and device path; change subscription |
| S15 | Source facts/clauses → S16/S17/S18/S29/S31; eksperimen Consent NLI dengan opt-in | PASS route 320 dp/200%; inferensi di build QA saja |
| S16 | Exact quote or manual screenshot evidence → active source | PASS integrity/correction/missing/deleted-source tests; screenshot accessible |
| S17 | Neutral source/permission review → S05/S11/S14 | PASS route/empty state; no invented recommendations |
| S18 | Fresh report preview → local PDF/share | PASS generated PDF test + physical viewer |
| S19 | Search/filter → S34 | PASS routes; device resume path |
| S20 | Data → S36; profile/about/privacy/tutorial | PASS route/back; no auto-cloud activation |
| S21 | Guest controls remain useful | PASS regression; login not shipped |
| S22 | Guest recovery / cloud unavailable | BLOCKED cloud production; no upload |
| S23 | Limitations + four per-model unavailable reasons | PASS catalog widget/route |
| S24 | Create app/document/visual audit → picker/workspace | PASS create/restart/regression |
| S25 | Choose audit + explicit Policy/Terms → S07 | PASS association-selection regression |
| S26 | Extraction/progress/cancel/retry → S11 | PASS parser/cancellation tests |
| S27 | Explicit uncertain gaps → merge review | PASS existing unit/route; no fabricated missing text |
| S28 | Manual clause reading → review/audit | PASS route/parser; classification unavailable |
| S29 | Compare actual source/version metadata | PASS fact-only empty/partial route; ConsentGap disabled |
| S30 | No risk score; source facts and limitations | PASS route/200%; rubric not invented |
| S31 | Real manual screenshot annotations; no detection label | PASS source/revision tests and route; vision AI disabled |
| S32 | Neutral action detail follows audit/source view | PASS route/empty scope; no persisted recommendation engine shipped |
| S33 | Regenerate/open/share PDF; clear cache | PASS channel test + chooser/cache physical check |
| S34 | History detail/resume → S14/report | PASS route + physical resume path |
| S35 | Camera Settings/help/import alternative | PASS route; fresh physical denial NOT_RUN |
| S36 | Selected audit control/export; confirmed local-audit/cache delete | PASS repository/channel scope; bulk physical deletion NOT_RUN to preserve operator data |
| S37 | No unsafe conflict overwrite; guest recovery | BLOCKED cloud production; conflict client NOT_RUN |
| S38 | Audit source association/version/unknown metadata | PASS fact-only route; no automatic matching claim |
| S39 | Tutorial + explicit audit choice → S08 | PASS route; physical text rescan deliberately not run |

## 2b. Pilot notes, privacy and Data Safety draft

### Shipped / disabled / experimental

| Scope | State |
|---|---|
| Offline audit, permission facts, policy/OCR, screenshot manual evidence, fact report/PDF/cache deletion | Implemented; automated + recorded synthetic device scope |
| LiveScan | Existing Phase 05 operator acceptance; original limitations preserved |
| User-facing ML, NLI recommendations, ConsentGap labels and risk scores | DISABLED; engine unavailable |
| FP32 internal Android harness dan panel Consent NLI S15 | QA_ONLY; debug runtime/allowlist, flag default off; persetujuan per sesi untuk panel |
| ConsentGap demo and failed INT8 | QUARANTINED; not allowed by mobile QA adapter |
| Cloud OTP/sync/conflict/delete propagation | CLOUD_BLOCKED, not shipped |
| Production/public distribution | BLOCKED pending signing, publisher declarations, broader device/accessibility review |

### Release notes (internal pilot draft)

- Screenshot capture by explicit file choice, manual source-based annotations,
  crop/rotation and revision history.
- Inspect real source facts/provenance, keep exact quotes and suppress stale
  evidence after edits/deletion; no AI/legal claims.
- Factual local PDFs and Android share chooser; visible local/shared deletion
  boundaries and app-managed cache cleanup.
- Searchable local history, clearer source association, parent-aware back buttons
  and workspace refresh after returning from edits/imports.

### Privacy policy / Data Safety working draft (not a published legal policy)

- Guest use requires no account. Permission snapshots, imported documents,
  screenshots, OCR and manual annotations are processed locally in this pilot.
  No audit upload or audit telemetry is enabled by default. Reading Android grant
  facts does not reveal actual third-party permission usage or network activity.
- User-selected raw sources and sensitive fields are AES-GCM encrypted in private
  application storage. Some database metadata (IDs, dates, lifecycle, hashes) is
  not whole-database encrypted. Android backups/device transfer are excluded.
- Camera is requested just in time. Camera JPEGs are transient cache files deleted
  in normal finally cleanup; process death can leave cache (Phase 05 limitation).
  No zero-disk guarantee is made.
- Audit/source deletion is logical DB/cascade and file cleanup, not a guarantee
  of forensic overwrite on flash/SQLite journals. Tombstone IDs remain for lifecycle
  integrity; deleted audit titles are replaced with a neutral encrypted title.
  Preferences/onboarding and QA model packages are not represented as deleted
  by “hapus seluruh audit”.
- Explicit PDF export creates plaintext in a narrowly scoped app-managed cache;
  user-initiated share exposes only that PDF through a temporary read grant.
  A receiving app may retain its copy; local deletion cannot revoke it.
- Retain sources until user deletes them. Export-cache recovery/expiry is checked
  on process startup or subsequent operations, not a promised background timer.
- Publisher must add real support contact, hosted privacy policy, SDK disclosure
  review (including ML Kit), distribution license review and final Play Data Safety
  answers before public distribution. No contact/legal declaration is invented.

### Install / support / backlog

- Test-device install: `adb install -r build/app/outputs/flutter-apk/app-debug.apk`.
  This is a debug-signed internal QA build, not a production store artifact.
- Use guest; create/select audit, add sources, review corrections/annotations,
  inspect status/evidence and open/share PDF only when intended. Delete the chosen
  audit with confirmation; clear app export cache through S36.
- Report non-sensitive screen ID, build/version, Android model/API and action
  sequence to the operator; do not attach private policy text, screenshots, tokens,
  or raw audit data without a separate deliberate choice.
- Backlog: visual drag handles/highlight overlay instead of numeric ROI editing,
  source-specific recommendation/action persistence, full real-screenshot image
  preprocessing parity, cancellation/rollback UX for QA installation, validated
  model quality/license packets, cloud auth/sync once credential/project issues are
  closed, 4/6 GB and sustained thermal/battery budgets, comprehensive TalkBack,
  publisher signing/Play declarations and actual external pilot-user feedback.

## 3. Cloud / remote and release boundaries

- `CLOUD_BLOCKED`: P0-001 and P1-002 remain open. No credential file was read,
  no remote SQL/migration/upload/auth session was performed, and production cloud
  remains off. OTP/session recovery/selected-source offline sync queue/conflict/
  logout/delete propagation and current A/B RLS/storage deployment acceptance are
  NOT_RUN/not shipped; historical Phase 00 RLS results are not reused as current
  cloud-ready proof. Guest path continues independently.
- Production signing is not configured: Gradle currently uses debug signing for
  release. APK/AAB release and Play publication are NOT_RUN until operator supplies
  production signing outside repo. Debug artifact is test-device only.
- Official Play target/API policy was fetched on 2026-11-08:
  <https://support.google.com/googleplay/android-developer/answer/11926878>:
  new apps/updates require Android 16/API 36 from 2026-08-31. Project target 36
  meets this API requirement; this is not a claim of full Play approval.
- Official Data Safety guidance fetched:
  <https://support.google.com/googleplay/android-developer/answer/10787469>.
  Declarations must cover third-party SDK behavior as well as app code. Local-only
  processing is not off-device collection; explicit user-initiated sharing has
  specified exceptions but must be clearly disclosed. Final publisher declaration,
  hosted privacy-policy URL and publisher contact remain operator actions.
- Ukuran halaman memori 16 KB juga merupakan gate Play untuk aplikasi target
  Android 15 ke atas. Perangkat uji melaporkan page size 4.096 byte. Hasil uji
  runtime pada perangkat 16 KB dan verifikasi artefak produksi masih `NOT_RUN`.
  [Android Developers: dukungan ukuran halaman 16 KB](https://developer.android.com/guide/practices/page-sizes)

## 4. Final checks / handoff

**Handoff `BLOCKED` untuk MVP AI.** Arahan terbaru menetapkan AI yang
berfungsi dengan tepat sebagai bagian wajib MVP. Aplikasi guest offline
tersedia sebagai build debug internal untuk verifikasi.

### Verifikasi model pada artefak saat ini

Host `tool/verify_model_packages.py` memverifikasi ulang SHA-256 ketujuh
berkas, signature graph dan vektor paket. Samsung SM-A556E, API 36, menjalankan
ulang instrumentation debug dengan ONNX Runtime 1.31.1. Batas selisih logit
absolut untuk QA FP32 adalah 0,001.

| Model | Bukti terbaru | Gate MVP yang terbuka |
|---|---|---|
| Consent NLI FP32 | `QA_ONLY`. Host dan Android 14/14. Android memverifikasi ID token, mask, logit dan label. Selisih maksimum 0,000001606, load 1.144 ms, inferensi 326–340 ms, PSS 650.935 KB. | Akurasi pada kebijakan dan izin aplikasi Indonesia, lisensi distribusi dan budget perangkat. |
| Dark Pattern FP32 | `QA_ONLY`. Host dan Android 14/14 tensor, logit dan label. Selisih maksimum 0,000003845, load 37 ms, inferensi 6–11 ms, PSS 121.232 KB. Parity PNG dengan ROI dicatat di §5. | Cakupan JPEG dan orientasi EXIF, evaluasi kualitas pada data produk dan hak atas data/model. Macro F1 0,463 pada sampel evaluasi ekspor. |
| Privacy Classifier FP32 | `QA_ONLY`. Host dan Android 14/14. Android memverifikasi ID token, mask, logit, sigmoid dan ambang tiap kelas. Selisih maksimum 0,000007391, load 1.055 ms, inferensi 325–334 ms, PSS 652.155 KB. | Paket `release_eligible: false`, jalur produk dan izin distribusi masih terbuka. |
| ConsentGap lima kelas | `FAIL` pada parity ekspor PyTorch–ONNX. Hanya 6/10 prediksi sesuai, selisih logit 0,20694, dengan gate 0,99/0,001. Sepuluh probe host berasal dari paket demonstrasi yang sama. | Checkpoint dan vektor referensi asli atau paket pengganti hasil pelatihan data beranotasi yang sah. |

Model FP32 QA memakai input sintetis. Angka perangkat berasal dari satu sesi
per model. Uji kelas 4/6 GB dan beban termal berulang masih `NOT_RUN`.
Ketiga INT8 gagal gate ekspor dan tidak diaktifkan. Folder pelatihan
`KONSENA` yang diperiksa memuat kode dan catatan lisensi. Checkpoint bobot
ConsentGap yang diperlukan untuk ekspor ulang belum ditemukan. Hak penggunaan
APP-350/OPP-115 harus diperiksa untuk distribusi paket hasil pelatihan.
[Usable Privacy Policy Project — ketentuan dataset](https://usableprivacy.org/data)

### Pemeriksaan aplikasi dan artefak

| Pemeriksaan | Hasil |
|---|---|
| `flutter analyze --no-pub` | `PASS`, tanpa temuan |
| `flutter test --no-pub --concurrency=2` | `PASS`, 134 tes termasuk migrasi Drift v1/v2 → v3, regresi S11, guest restart, cascade, golden dan rute 320 dp/200% |
| `flutter test --no-pub --dart-define=ENABLE_MODEL_QA=true` untuk evidence, rute offline dan impor | `PASS`, 8 tes termasuk asosiasi, opt-in dan penolakan hasil yang usang |
| `flutter build apk --debug --no-pub --target-platform android-arm64` | `PASS`, JDK 17 dan SDK lokal, flag model default off |
| Build debug arm64 dengan `--dart-define=ENABLE_MODEL_QA=true` | `QA_ONLY`, `PASS` build, pemasangan dan smoke test S15 |
| `git diff --check`, `git diff --cached --check` | `PASS` |
| APK/AAB release produksi dan publikasi Play | `NOT_RUN`, signing dan gate rilis belum tersedia |

APK debug internal **`konsena-1.0.0-phase06-pilot-arm64.apk`**, package
`id.konsena.ai`, versi 1.0.0+1, min API 24, target API 36, 286.674.386 byte.
Lokasi `build/app/outputs/flutter-apk/`. Signature Android Debug valid.
SHA-256 `8aac2b7e063f0f8bbd402518dc0b8c2001f32a2b310215f882aceefc5099375d`.
ZIP alignment 16 KB lulus `zipalign -c -P 16 4`. APK tidak berisi bobot ONNX.
Manifest gabungan tidak memuat izin audio atau penyimpanan lama. Debug memuat
`INTERNET`, `ACCESS_NETWORK_STATE`, `CAMERA`, dan izin receiver internal.
Tes host memakai symlink GCC melalui `/tmp/opencode/phase05/bin/clang`
untuk hook PDFium. SDK dan JDK dipilih hanya untuk proses build ini.

Samsung SM-A556E membuka build terbaru setelah cold start 4.330 ms.
Impor teks, simpan, restart, resume dari riwayat, dan buka kembali dokumen
sintetis lulus. Status tersimpan tetap tampil setelah restart. Edit
mengaktifkan simpan lagi, dan simpan ulang mengembalikan status tersimpan.
[Screenshot S11 dari APK debug](evidence/phase06_s11_tersimpan.png)

Pada build QA, S15 menjalankan Consent NLI dengan opt-in per sesi, satu
klausul Privacy Policy yang ditinjau dan snapshot izin CAMERA dari aplikasi
fixture `id.konsena.phase06_fixture`. Label `entailment` dan probabilitas
81,4% / 10,2% / 8,4% cocok dengan ONNX Runtime host pada input yang sama.
Android mencatat 1.502 ms untuk load dan inferensi pada percobaan ini.
Hasil merupakan uji end-to-end satu contoh sintetis.
[Screenshot S15 dari APK QA](evidence/phase06_s15_nli_qa.png)

Penghapusan audit sintetis dikonfirmasi melalui UI. Audit hilang dari riwayat,
jumlah file sumber kembali ke baseline enam, dan cache ekspor berisi nol file.
Aplikasi fixture di-uninstall setelah pengujian. Capture LiveScan fisik setelah
perubahan manifest, TalkBack penuh dan feedback pengguna eksternal masih
`NOT_RUN`. Regresi cascade dan lifecycle lokal tercakup pada suite Flutter.

## 5. QA tambahan dengan paket model yang tersedia

Operator memilih melanjutkan QA dengan artefak saat ini. S31 sekarang
menjalankan Dark Pattern FP32 dari screenshot lokal yang telah ditinjau.
Panel memerlukan flag debug dan opt-in per sesi. Panel mengambil file sumber
dan geometri S13 dari audit yang sama, memproses crop dan rotasi pada
resolusi asli di isolate, lalu menerapkan resize bilinear antialias 224×224
dan normalisasi ImageNet float32 NCHW. Hasil sementara memuat provenance
dan hash tensor. Perubahan sumber membatalkan hasil.
[Implementasi bilinear referensi Pillow](https://github.com/python-pillow/Pillow/blob/12.3.0/src/libImaging/Resample.c)

- Batas jalur QA adalah PNG statis RGB/RGBA 8-bit tanpa EXIF, maksimum
  8.192 piksel per sisi, 16 megapiksel dan 10 MB. PNG ber-EXIF dikecualikan
  karena decoder PNG pada review S13 belum menerapkan orientasinya.
- Fixture RGBA yang dikecilkan dan fixture RGB yang dibesarkan cocok
  byte demi byte dengan Pillow 12.3.0 setelah crop dan rotasi. Tes tambahan
  mencakup EXIF, opt-in, audit yang salah, dan revisi ROI saat inferensi.
- Verifikasi terbaru mencatat `PASS` pada analyzer, 138 tes Flutter default,
  sembilan tes terfokus dengan flag QA, dan kedua build debug arm64.
  `apksigner verify` lulus untuk kedua APK.
- Bobot ONNX dimuat dari penyimpanan privat perangkat uji untuk APK QA.
  Artefak antarmuka terbaru dicatat di §6.

Untuk mengulang, pasang APK QA pada perangkat uji. Jalankan
`tool/prepare_android_model_qa.py` dengan `--adb` dan `--model dark_pattern`
setelah menyiapkan fixture tensor dengan `tool/verify_model_packages.py`.
Impor PNG dari audit, simpan crop di S13, lalu buka **Lihat status analisis**
dan **Review antarmuka**. Pilih screenshot, aktifkan bantuan AI, dan tekan
**Periksa area ini**.

Samsung SM-A556E menjalankan model dari S31 pada PNG sintetis 720×960
dengan crop `[0.1, 0.2, 0.7, 0.6]` dan rotasi 90°. SHA-256 tensor
`3e718c54f0374b2d8bd814bb32cb6378a6bef6d297390dca9bc2ea403f3da0cd`
identik dengan referensi Pillow. Selisih logit maksimum Android–host sekitar
0,00001222 terhadap batas 0,001. Keduanya menghasilkan label
`no_pattern_detected` dengan probabilitas 54,7% dan 45,3% pada presisi tampilan.
Waktu load dan inferensi pada percobaan ini 49 ms.
[Bukti parity S31 sebelum perapian tampilan](evidence/phase06_s31_dark_pattern_qa.png)

## 6. Tampilan hasil dan review antarmuka

S31 dibagi menjadi **Screenshot**, **Pemeriksaan AI**, dan **Catatan manual**.
Bagian screenshot menampilkan pratinjau area yang dipilih dan akses ke editor
S13. Catatan diberi ikon serta nama yang mudah dipahami. Bagian hasil Dark
Pattern dan Consent NLI memakai kesimpulan pendek, penjelasan ruang lingkup,
dan tindakan **Yang bisa dicek**. Saat pemeriksaan selesai, layar bergulir
ke hasil. NLI menampilkan aplikasi dan izin, dengan kutipan yang bisa dibuka.
Label model, probabilitas dan provenance tersedia di **Detail teknis QA**.

Analyzer dan 10 tes dengan flag QA lulus. Uji 320 dp dengan teks 200%
memeriksa struktur bagian, kesimpulan yang terbaca, kutipan sumber, dan
detail teknis yang tertutup secara default. Suite default lulus 138 tes
dengan satu tes yang khusus dijalankan pada build QA. Build APK QA berhasil
setelah Gradle dijalankan dengan batas heap 2 GB melalui konfigurasi proses.
Kedua APK debug arm64 berhasil dibangun dan lulus pemeriksaan signature
serta ZIP alignment 16 KB. Versi APK QA terbaru dicatat di §7.

Pada Samsung, S31 menampilkan pratinjau crop yang tersimpan. Setelah inferensi,
hasil dan langkah **Yang bisa dicek** terlihat langsung. Detail teknis masih
tertutup. Uji antarmuka NLI menggunakan hasil model fixture pada tes Flutter.
[Tampilan Review Antarmuka](evidence/phase06_s31_review_ui.png) ·
[Tampilan hasil pemeriksaan](evidence/phase06_s31_hasil_ui.png)

Audit sintetis dibersihkan dan jumlah file sumber kembali ke baseline enam.
Build QA akhir menjalankan ulang Consent NLI, Dark Pattern dan Privacy
Classifier, masing-masing 14/14 vektor dengan status `QA_ONLY`.

## 7. Alur Pindai Sumber

- LiveScan, screenshot dan dokumen/teks memakai pemilih audit yang sama.
  Pengguna bisa memilih audit yang sudah ada atau membuat audit bernama
  tanpa meninggalkan alur. Tombol **Buat audit baru** berada di atas daftar
  dan membuka formulir tersendiri. Setelah audit dipilih, tombol Kembali
  langsung menuju layar sebelumnya.
- LiveScan mempertahankan audit saat mencoba izin lagi atau beralih ke
  impor dokumen. Kamera ditutup saat pengguna meninjau hasil. Simpan
  menyertakan OCR asli dan koreksi yang telah dikonfirmasi. Review Teks
  menampilkan status tersimpan dan menyediakan tombol **Buka audit**.
- Screenshot menampilkan nama audit tujuan serta petunjuk memilih PNG/JPEG.
  Setelah atur area dan catatan, **Simpan dan buka audit** kembali ke workspace
  tempat sumber tersimpan.
- Dokumen memilih audit lalu jenis dokumen. Impor file dan tempel teks
  tampil sebagai dua bagian terpisah. Review Teks meminta konfirmasi
  sebelum membuang koreksi yang belum disimpan. Hasil impor yang sudah
  disimpan dapat dibuka kembali dari audit yang sama.

Analyzer bersih. Suite akhir lulus 142 tes standar dengan satu tes khusus
QA dilewati. Uji dengan flag QA aktif lulus 14 tes. Uji LiveScan mencakup
rute pemulihan izin serta konfirmasi dengan hasil OCR sintetis.
[Tampilan Pindai Sumber pada Samsung](evidence/phase06_s06_scan_flow.png)

Di Samsung SM-A556E, teks sintetis disimpan dan **Buka audit** menampilkan
sumber di workspace. Audit bernama dibuat dari jalur screenshot, file
PNG dipilih melalui Android, lalu **Simpan dan buka audit** kembali ke
workspace dengan satu screenshot yang ditinjau. Dari audit itu, **Bantuan
izin kamera** dan **Impor dokumen sebagai alternatif** mempertahankan nama
audit tujuan. Pemindaian monitor dengan kamera fisik belum diulang.

Kedua APK lulus verifikasi signature dan ZIP alignment 16 KB. APK QA
`konsena-1.0.0-phase06-model-qa-arm64.apk` berukuran 286.674.318 byte
dengan SHA-256
`08fcd7a930546392c78b6c471ea91f7d6b1e0c95414faac1357d345a9798724b`.
