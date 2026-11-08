# Phase 05 — LiveScan kamera dan rekonstruksi teks

**Status: `IN_PROGRESS` — device acceptance belum dijalankan.**

## 1. READ dan keputusan teknis (dicatat sebelum implementasi)

### Kondisi awal

- Phase 04 OCR lokal ML Kit Latin tersedia di `PolicyDocumentProcessor`; recognition menghasilkan teks, bounding box, dan confidence per block.
- S08, S09, S10, S27, S35, dan S39 sudah terdaftar di `RouteRegistry`, tetapi masih dirender sebagai placeholder `RouteScreenPage`. S06 mengarahkan ke tutorial S39.
- `AuditRepository.attachSource` menyimpan berkas sumber secara terenkripsi dan menerima `AuditSourceType`, warning, serta locator; `DocumentSegment` dapat menyimpan sequence, frame, teks asli, confidence, dan bounding box. Kamera belum punya model/pipeline sendiri.
- Belum ada dependency kamera, deklarasi `CAMERA`, atau pengujian LiveScan. Lifecycle app sudah diamati di beberapa halaman tetapi belum ada pengelola lifecycle kamera.
- Android SM-A556E / Android 16 (API 36) terhubung. Operator mengonfirmasi laptop/monitor fisik tersedia. Ketersediaan ini bukan bukti acceptance.

### Rencana dan keputusan

1. Tambahkan plugin Flutter `camera` untuk preview/image stream dan `permission_handler` untuk status/request just-in-time serta recovery `denied/permanentlyDenied`; tambahkan deklarasi Android `CAMERA` saja, tanpa permission startup, MediaProjection, screenshot internal, atau kendali scroll laptop. Verifikasi kompatibilitas melalui `flutter pub get` dan build Android sebelum mengandalkan API.
2. S39 memberi instruksi posisi kamera, jarak/angle, scroll manual perlahan, glare/low light, local processing, dan consent. Request permission baru saat pengguna menekan lanjut ke setup. S35 memberi retry dan Settings recovery jika ditolak/permanent denied.
3. Pisahkan core algoritme dari widget/platform: session/observation/ROI/provenance models, bounded OCR scheduler (satu task in-flight, target awal 1 frame/detik, tidak mengantre frame stale), dan pure-Dart segment stitcher yang dites dengan fixture. Preview S08 memakai ROI persegi panjang editable (crop valid) dan indikator kualitas heuristik; perspektif quadrilateral/auto-detection tidak akan diklaim bila transformasi tidak benar-benar diimplementasikan. Pengguna mengunci ROI sebelum capture.
4. Terapkan backpressure dan sampling dengan scheduler satu capture/OCR in-flight. API `CameraController.takePicture` membuat satu JPEG sementara di cache plugin; file dibaca lokal, di-crop, lalu dihapus pada `finally`, tidak disalin ke source/evidence atau log. Ini bukan stream in-memory murni dan crash dapat meninggalkan file cache sementara; review memeriksa masa hidup/cache. Pause menghentikan scheduler; background, dispose, atau permission tidak aktif menghentikan capture dan melepas controller; resume memeriksa izin dan membuka ulang secara eksplisit.
5. Stitcher mempertahankan OCR text asli dan seluruh observation (frame index, timestamp, ROI, confidence/quality). Normalisasi hanya untuk matching. Dedupe hanya pada overlap yang alignment-nya cukup kuat; teks berulang pada konteks berbeda tetap dipertahankan. Tidak ada overlap/urutan ambigu menghasilkan gap `possible_missing_text` dan status parsial, bukan paragraf rekaan atau klaim lengkap. Identical block di frame berurutan dideduplikasi dengan event/provenance tetap.
6. Simpan hasil review melalui source terenkripsi yang sudah ada, dengan metadata sesi/ROI/frame dan segment OCR. Integrasikan S11 edit/konfirmasi dan S14 workspace audit; bila auditId tidak ada, sediakan alur kembali/pemilihan audit yang sudah ada, bukan menyimpan ke audit palsu. S27 menampilkan gap dan opsi rescan subset/manual review.
7. Tidak memakai isolate untuk saat ini: plugin ML Kit dan camera image lifetime memerlukan pemrosesan platform, sementara pipeline satu frame in-flight dan resolusi dibatasi memberi batas memori/baterai yang lebih aman. Tinjau ulang hanya bila profiling nyata menunjukkan kebutuhan.

### Modul/berkas yang direncanakan

- Dependency/platform: `pubspec.yaml`, `pubspec.lock`, `android/app/src/main/AndroidManifest.xml`.
- Domain/core scanner baru di `lib/features/live_scan/domain/` dan `data/` (session, frame provenance, stitch/dedupe/gap, OCR adapter).
- UI/routes: `lib/app/app_router.dart`, `lib/features/scan/presentation/scan_hub_page.dart`, halaman LiveScan baru di `lib/features/live_scan/presentation/`, dan integrasi route/actions S35/S39/S08/S09/S10/S27/S11/S14.
- Persistence: integrasi terbatas `lib/data/audit/audit_repository.dart` / domain entities hanya jika API eksisting tidak cukup; perubahan schema/database dihindari kecuali bukti menunjukkan wajib.
- Tests: unit stitcher/scheduler/provenance, widget/router/permission-state tests, Android manifest/security contract tests, serta fixture OCR sintetis yang tidak memuat data pribadi.
- Artefak: laporan ini, `docs/phase-reports/PHASE_STATUS.md`, dan `docs/phase-reports/KNOWN_ISSUES.md`.

### Risiko, mitigasi, dan rollback

| Risiko | Mitigasi / rollback |
|---|---|
| API camera plugin, permission, lifecycle OEM berbeda | Kunci versi yang berhasil diuji; adapter permission/camera terisolasi; jika gagal, hapus deklarasi/dependency dan kembali ke S39 placeholder tanpa mengubah flow impor Phase 04. |
| Format YUV camera tidak cocok langsung untuk ML Kit | Adapter konversi dibatasi pada satu frame; tes channel/device. Tidak menyimpan bytes; jika orientasi/format tidak tervalidasi, hentikan dengan state error yang dapat dicoba ulang. |
| OCR salah menggabungkan teks/gap palsu | Pure core tests untuk overlap, fuzzy match, duplicates, reorder/no-overlap; matching konservatif, gap dapat ditinjau, teks sumber tidak dibuang. |
| Kebocoran kamera/raw frames atau konsumsi termal | Backpressure, bounded resolution/rate, file JPEG sementara dihapus pada `finally`, dispose lifecycle, scheduler stop saat background/pause. Crash sebelum cleanup masih dapat meninggalkan cache file; verifikasi pada device dan jangan mengklaim nol disk writes. |
| Perubahan database mengancam data Phase 03/04 | Hindari schema change; persist teks+metadata melalui API source yang ada. Jika perubahan schema diperlukan, migration additive dan rollback harus dibuktikan sebelum lanjut. |
| Working tree berisi perubahan Phase 03/04 yang belum di-commit | Hindari reset/checkout dan edit hanya file Phase 05 yang teridentifikasi; review diff terhadap baseline lokal dan pertahankan semua edit terdahulu. |

### Test plan dan gate

- Unit: exact/fuzzy overlap, partial overlap, duplicate frames/clauses, urutan frame tidak berurutan, no-overlap → gap, teks identik dengan konteks berbeda, pause/resume dan interrupted session, provenance timestamp/ROI/confidence.
- Widget/integration: S39 tutorial, JIT granted/denied/permanently denied/retry/Settings, manual ROI, pause/resume/finish/cancel/retry, background/dispose cleanup, S27 gap review, S11 correction dan source linkage S14; no-camera/error states.
- Mandatory: `flutter analyze`, seluruh `flutter test`, `flutter build apk --debug`, `git diff --check`, code/security review (permission scope, raw frame persistence/logging, camera release, data linking).
- Device acceptance: SM-A556E Android 16/API 36 + laptop/monitor fisik, uji slow/fast scroll, overlap/duplikasi/reordering/gap, glare/low light, rotation/interruption, pause/resume, koreksi, camera cleanup. Catat jarak, durasi, jumlah segment/gap, koreksi OCR, kondisi cahaya dan hasil setiap kasus. Tidak mengklaim lulus sebelum dijalankan.
- Gate Phase 05 memerlukan demonstrasi end-to-end monitor fisik dan pemeriksaan gap tercatat sebelum PASS; tidak memulai Phase 06 sebelum review bukti.

## 2. Implementasi dan hasil verifikasi

### Implementasi

- Added `camera: ^0.12.2` and `permission_handler: ^12.0.1` (resolved Android permission plugin compile SDK 35, compatible with the project API 36 toolchain). Version 13 was rejected during build because its Android plugin requested SDK 37; project SDK was not raised.
- Added just-in-time permission request in S08, recoverable denied/permanent-denied guidance in S35, and physical-monitor tutorial S39. S06 and audit workspace now expose the new route while retaining the existing tab shell/navigation.
- S09 uses `CameraController` medium still captures on an 1.8-second scheduler with one capture/OCR in-flight. Pause stops scheduling; background/dispose/revoked permission dispose the controller. Each `takePicture` JPEG is cropped in memory after reading the plugin cache file and deleted in `finally`; this is transient disk use, not a zero-disk camera stream. No image is attached as evidence.
- S08 has an editable normalized rectangular ROI, tap-to-focus where supported, local crop, and heuristic glare/low-detail guidance. The preview is aspect-ratio-correct and larger; controls sit below the preview, outside the image capture area. Auto-monitor detection, perspective quadrilateral correction, and calibrated motion/blur classification are **not implemented** and are not claimed.
- Reuses Phase 04 local ML Kit Latin recognition. The conservative stitcher sorts by timestamp; exact/fuzzy overlap removes only aligned tokens; repeated long near-identical frames (including a rescan after intervening frames) are not appended twice, but all original frame observations remain in provenance. Short repeated clauses are retained. No overlap produces explicit uncertainty gap; no missing text is invented.
- S10 has editable OCR text, Terms/Privacy Policy source type, visible duplicate/gap counts, explicit user confirmation without requiring an edit, and S27 gap review. Save uses the existing encrypted `AuditRepository.attachSource` + `saveImportedSegments`, then S11 review; provenance stores frame timestamp, ROI, confidence and gaps. S14 workspace offers LiveScan and displays the linked source.

### Regression/review log (FIX → REVIEW)

| Gejala | Akar masalah | Perubahan | Regression test / hasil review |
|---|---|---|---|
| Capture ulang teks yang sama berisiko menambah paragraf dua kali | Dedupe awal hanya mengenali frame identik yang berdekatan atau overlap kata yang cukup | Bandingkan frame panjang berurutan dengan semua frame sesi; pertahankan semua provenance, dedupe isi konservatif; frasa pendek non-adjacent tetap | `rescanning an already captured paragraph does not append it twice`, `identical clause in a later distinct segment is not silently erased`; kedua PASS |
| Preview tampak gepeng/ROI melenceng | Parent AspectRatio menimpa rasio internal `CameraPreview` yang menyesuaikan orientasi; ROI Align memakai anchor center yang salah untuk koordinat kiri/atas | Hilangkan aspect wrapper yang memaksa rasio; gunakan rasio native plugin dan ROI dengan `Positioned(left/top/width/height)`; layout preview diperbesar, controls dipindah di bawah area gambar | SM-A556E preview setelah perubahan dikonfirmasi operator “sudah proporsional”; route/widget smoke tidak overflow, analyze PASS. Monitor tidak dipindai ulang sesuai instruksi operator. |
| APK gagal saat permission plugin terbaru meminta SDK 37 | `permission_handler 13` Android plugin compileSdk 37, sedangkan project SDK 36 | Gunakan constraint `^12.0.1` → Android plugin 13.0.1 / compileSdk 35 | Debug APK build PASS dengan project SDK 36 |
| Host test gagal mencari compiler PDFium native hook | Host tidak menyediakan `clang` | Menjalankan test dengan workaround lokal `/tmp/opencode/phase05/bin/clang` ke GCC; tidak masuk repo | Fokus + full suite dapat berjalan; lihat hasil suite di bawah |

### Automated tests

- `flutter analyze` → **PASS — no issues found** (setelah perubahan terakhir).
- `flutter test test/features/live_scan` → **PASS — 7 test**, meliputi exact/fuzzy overlap, duplicate/rescan, ordering, no-overlap/gap, repeated clause, provenance, dan glare/blur heuristic.
- `flutter test test/navigation/navigation_test.dart` → **PASS — 10 test**; S08/S09/S35/S39 routes smoke-tested.
- `flutter test --concurrency=1` → **PASS — 120 tests** after making the About model-catalog widget test deterministic with a test asset bundle. Root cause was the test's reliance on the platform root asset bundle plus scrolling to a model row without a stable rendered target; production model catalog behavior was unchanged.
- `flutter build apk --debug` → **PASS** after selecting permission plugin compatible with API 36; rebuilt after the final UI layout changes.
- `git diff --check` → clean in final review.

### Earlier partial device observation (before operator's final acceptance confirmation)

- Device: Samsung SM-A556E, Android 16/API 36. The app opened LiveScan and showed a real laptop display in the camera preview; the operator noted the original preview looked “gepeng”. After the ratio/layout correction the operator confirmed “Sudah proporsional”.
- Latest debug APK installed with `adb install -r` on the connected SM-A556E and launcher start smoke-tested (`monkey -p id.konsena.ai 1`). This verifies install/start only, not camera acceptance.
- A temporary screen displayed camera preview and counters (partial session observed with 5 OCR frames / 3 possible gaps). No image evidence was retained. The session was not used to claim accuracy or completeness and no final source save/correction was recorded.
- Camera-to-monitor distance, calibrated scan duration, lighting notes, ground-truth text comparison, OCR corrections, pause/resume on the same valid text, denied/permanently-denied recovery, camera cleanup after finish, and final S27/S11/S14 persisted audit join are **NOT_RUN / NOT_RECORDED**.
- The operator explicitly instructed not to scan text already captured again. No further camera capture was performed after that instruction. Existing partial result was not finalized as accepted policy content.

### Operator acceptance confirmation

- The operator subsequently confirmed that the physical acceptance test has been performed and explicitly instructed that Phase 05 be marked PASS.
- This gate records the operator's acceptance confirmation. Detailed measurements/results (distance, duration, lighting, OCR corrections, pause/resume and persisted S27/S11/S14 outcome) were not supplied in this report and are not fabricated here.

## 3. Review keamanan dan privasi

- Manifest hanya menambah `CAMERA`; no audio permission, MediaProjection, internal screen capture, or laptop automation.
- App flow checks camera status at S08; however the device may already have had permission from earlier testing, so a fresh OS permission prompt/denial was not proven on this final run.
- No frame bytes or OCR text are logged. No raw photo is attached to the audit. A camera JPEG does briefly exist in plugin cache between `takePicture` and the `finally` deletion; app process death during that interval could leave a cache file. Crash/cache cleanup inspection is NOT_RUN, so zero raw-frame retention is not claimed.
- OCR text/source is stored by the existing encrypted local source API only after explicit confirmation. User can view likely gaps before saving. The text remains editable; confirmation does not imply full document coverage or legal/AI analysis.

## 4. Keputusan gate

**`PASS` — physical acceptance confirmed by the operator.** Automated analyzer, full test suite, focused tests, APK build, and device install/start are verified; physical acceptance is accepted on the operator's confirmation. Detailed measurements/results were not supplied here, so they are not represented as independently verified or included. This PASS does not claim legal analysis or AI analysis. Phase 06 has not been started.
