# PHASE 02 REPORT — Domain data dan penyimpanan lokal

- **Fase:** 02
- **Tanggal:** 2026-11-07
- **Workflow:** READ → THINK → BUILD → REVIEW → FIX → GATE
- **Prasyarat:** Phase 01C PASS (device/TalkBack tetap `NOT_RUN`, ditunda atas
  arahan operator; bukan dianggap lulus).
- **Status awal:** `IN_PROGRESS` setelah READ/THINK; tidak ada implementasi
  Phase 02 saat rencana ini ditulis.
- **NEXT:** Phase 03 hanya bila acceptance Phase 02 lulus.

> Rencana ini dicatat setelah READ dan sebelum perubahan kode Phase 02.
> Phase 02 tidak mengaktifkan cloud, tidak mengimplementasikan OCR/ONNX, dan
> tidak meminta izin kamera.

---

## 1. READ — temuan dan kontrak

### Sumber yang ditinjau

- `docs/PRD_KONSENA_AI_MOBILE.md`: §9.2–9.4 domain/retensi, §14 analysis
  contract, §18 Phase 02, dan urutan fase.
- `docs/KONSENA_AI_PAGE_BY_PAGE.md`: kontrak S14 (workspace dan status sumber),
  S19 (riwayat), S24 (buat sesi lokal UUID, default draft), S15 (analysis
  unavailable sebelum model).
- `lib/app/navigation/audit_draft_store.dart`, `lib/app/app_router.dart`,
  `lib/app/konsena_app.dart`, `lib/main.dart`: saat ini S24 menggunakan store
  in-memory; route S14/S19 membaca store sementara; belum ada init database.
- `lib/features/home/domain/home_summary_repository.dart` dan `home_cubit.dart`:
  dashboard sudah memiliki seam repository, tetapi production default masih
  summary kosong.
- `lib/features/audit/presentation/new_audit_page.dart`,
  `lib/features/history/presentation/history_page.dart`, dan
  `lib/features/navigation/presentation/route_screen_page.dart`: perlu wiring
  async untuk create/resume/delete dan workspace riil.
- `lib/core/journey/journey_store.dart`: `journey.cloud_opt_in` dan
  `journey.analytics_opt_in` default `false`; pertahankan storage/makna ini.
- `pubspec.yaml`: belum ada SQLite/Drift, path provider, UUID atau hash
  dependency. Test memakai `flutter_test` dan dependency injection.
- `supabase/migrations/20261107084034_init_foundation_rls.sql`: skema cloud
  ber-RLS; bukan migrasi DB lokal. Cloud tetap opsional dan di luar fase ini.

### Kontrak dan batasan

- S24 membuat sesi lokal offline tanpa akun, sumber wajib, hasil atau skor
  sintetis. S14 resume workspace berdasarkan ID dan menampilkan status sumber;
  S19 dan S03 menghitung sesi lokal nyata. Tidak ada contoh audit otomatis.
- Persistensikan entitas domain `AuditSession`, `AppPermissionSnapshot`,
  `DocumentSource`, `DocumentSegment`, `ConsentUiSource`, `EvidenceReference`,
  `UserAction`, `AnalysisRun`, `ReportRecord`, dan `PrivacyPreferences`.
- Phase 02 hanya menyimpan model/record yang dapat dibuat secara nyata pada
  phase ini. Snapshot izin, segmen hasil OCR, evidence, report, dan user action
  boleh kosong sampai fiturnya tersedia; tidak dibuat-buat.
- Raw camera/video tidak disimpan. Dokumen/screenshot yang dipilih user disimpan
  di app-private storage dan memiliki SHA-256 serta provenance (halaman/frame/
  locator); SQLite bukan enkripsi. UI/dokumen harus menyatakan batas ini tanpa
  klaim enkripsi.
- `AnalysisRun` tidak pernah sukses dengan provider unavailable. Contract
  `UnavailableAnalysisEngine` menjelaskan bahwa model on-device belum tersedia.
- Kamera tetap just-in-time, tidak meminta permission pada startup. Cloud opt-in
  tetap false default; tidak ada API/service key baru atau upload.

---

## 2. THINK — keputusan teknis sebelum BUILD

### Keputusan

1. **Database:** Drift di atas SQLite dengan `schemaVersion` eksplisit,
   migrator bertahap dan test schema migration. Aktifkan foreign keys, indeks
   untuk parent/status/timestamps, dan serialisasikan waktu UTC epoch
   milliseconds. Test memakai database SQLite in-memory; production database
   berada di app-private support directory.
2. **IDs:** UUID v4 untuk seluruh PK yang dibuat aplikasi. FK merupakan UUID
   string; tidak bergantung pada user/cloud ID. Nilai nama/fokus/status dibatasi
   panjangnya dan divalidasi di repository.
3. **Tabel dan hubungan:** audit sessions sebagai root; permission snapshots,
   document sources/segments, consent UI sources, evidence references, user
   actions, analysis runs, dan report records memiliki FK ke audit/source yang
   tepat. Privacy preferences satu baris lokal. `AnalysisRun` menyimpan status,
   engine/reason dan source ID, tetapi tidak memiliki default success.
4. **Source files dan sensitive fields (THINK amendment setelah review PRD
   §9.4):** simpan file AES-GCM di `ApplicationSupportDirectory`; gunakan key
   256-bit acak yang dijaga `flutter_secure_storage` (Android Keystore-backed).
   Simpan nonce/tag/version bersama ciphertext. SHA-256 dihitung atas plaintext
   untuk provenance, bukan ciphertext. `DocumentSegment` content dan
   `EvidenceReference.quote` dienkripsi field-level AES-GCM sebelum SQLite;
   tidak mencatat raw bytes, OCR, filename/path sensitif, ciphertext, atau hash
   sumber ke log. Missing key/authentication failure fail-closed dan tidak
   menghapus atau menimpa file/database. Tests memakai key provider palsu.
5. **Provenance/lifecycle:** source record mencatat tipe, lifecycle/review
   state, created/updated timestamp, digest, ukuran/media type dan metadata
   provenance page/frame sebagai kolom nullable. Attach/detach serta perubahan
   state memperbarui audit `updatedAt`; detach menghapus hanya source terpilih
   dan turunannya, bukan sesi.
6. **Delete/failure safety:** penghapusan sesi menandai root tombstoned dan
   mencatat file sumber sebagai pending-delete dalam satu transaksi DB; child
   rows dihapus melalui FK cascade. Setelah commit, hapus file dan tandai
   cleanup selesai. Jika proses mati/gagal di antara tahap, janitor mengulangi
   pending-delete; entri bertombstone tidak tampil/terbuka. File orphan hasil
   crash sebelum metadata commit dibersihkan melalui rekonsiliasi direktori.
   Ini memberi failure recovery tanpa mengklaim transaksi atomik lintas DB dan
   filesystem.
7. **Preference migration:** pertahankan `SharedPreferences` journey flags dan
   kunci yang sudah ada, sehingga nilai `cloud_opt_in=false` tidak reset/naik
   diam-diam. DB `PrivacyPreferences` default cloud/analytics false; tidak
   mengaktifkan kamera. Tidak ada migrasi cloud Supabase.
8. **UI seams:** repository async dipakai oleh S24 create, S14 load/attach/
   detach/delete, S19 history/resume, S03 summary. Cubit mengelola loading/error/
   empty dan refresh. Injection database/repository/file store memungkinkan
   widget dan restart tests tanpa plugin.
9. **Dependencies:** `drift` + `drift_dev`/`build_runner` untuk schema/codegen/
   migrator; `sqlite3_flutter_libs` untuk SQLite native; `path_provider` untuk
   lokasi privat; `uuid` dan `crypto` untuk ID/hash; `file_picker` hanya untuk
   pemilihan file eksplisit user; `cryptography` AES-GCM dan
   `flutter_secure_storage` untuk key lifecycle/secure platform storage.

### Berkas/modul yang direncanakan disentuh

- `pubspec.yaml`, `pubspec.lock` (dependensi yang disebut di atas dan codegen).
- `lib/data/local/app_database.dart` (+ generated part) serta migrasi/schema
  test fixtures.
- `lib/domain/audit/` entity/value types, validation dan
  `AnalysisEngine`/`UnavailableAnalysisEngine`.
- `lib/data/audit/` repositories, SQLite DAO/query, file store dan cleanup
  recovery.
- `lib/app/dependencies.dart`, `lib/main.dart`, `lib/app/konsena_app.dart`,
  `lib/app/app_router.dart` untuk production construction/injection.
- `lib/app/navigation/audit_draft_store.dart` sebagai adapter sementara/compat
  seam yang dialihkan ke repository durable (atau dihapus setelah caller/test
  dipindah).
- `lib/features/audit/`, `lib/features/history/`,
  `lib/features/navigation/`, `lib/features/home/` untuk Cubit dan layar S24,
  S14, S19, S03.
- `test/data/`, `test/features/`, serta test navigation/harness yang terdampak.
- `docs/phase-reports/PHASE_02_REPORT.md`, `PHASE_STATUS.md`,
  `KNOWN_ISSUES.md`.

### Risiko dan mitigasi

| Risiko | Mitigasi / verifikasi |
|---|---|
| File system dan SQLite tidak satu transaksi | Tombstone + pending-delete di DB, cleanup idempotent, recovery test untuk kegagalan tiap tahap |
| Migration merusak database lama | schema version eksplisit, upgrade fixtures per versi, test FK dan rollback; jangan overwrite database |
| Async hydration membuat route/UI race | state Cubit loading/error, ID UUID dan reload repository saat route dibuka; tests operasi concurrent |
| Source path traversal atau orphan | path disusun hanya dari UUID, containment check, hash check dan janitor; negative tests |
| Log membocorkan isi/raw evidence | tanpa logging payload; capture logger pada tests negative dan review diff |
| Drift/codegen/native SQLite tidak kompatibel | pin dependency constraints, generate code, analyze/test/build APK; bila toolchain gagal laporkan BLOCKED |
| Kehilangan/invalidasi key membuat ciphertext tak terbaca | gunakan secure-storage, fail-closed, jangan auto-reset key atau hapus ciphertext; test missing/wrong key dan authentication failure |

### Test plan

- Migration baru/upgrade, schema version, foreign keys, rollback saat transaction
  gagal, dan data tidak terputus.
- CRUD tiap entity yang dapat dihasilkan, status review, hubungan/source counts,
  preferences default false, dan `AnalysisRun` unavailable/non-success.
- Create/update/read sesudah database ditutup dan dibuka lagi; S24 resume dan
  S03/S19 summary dari repo nyata.
- AES-GCM file/field add-read/hash, nonce/tag tamper, missing/wrong key,
  provenance, invalid/escaping path, hash mismatch, duplicate IDs, missing file,
  attach/detach dan sumber tak yatim.
- Cascade delete: sumber/segmen/evidence/action/run/report terhapus, file
  dibersihkan, tombstone tidak terlihat; retry cleanup setelah simulated crash.
- Concurrent create/update/attach/delete untuk audit sama dan berbeda; operasi
  gagal tidak menghasilkan orphan metadata/file yang tak dapat dipulihkan.
- Cubit/UI loading/error/empty, create→workspace, resume/delete, dashboard/history
  count; logger test memastikan raw content tidak masuk log.
- Wajib final: `flutter analyze`, `flutter test test/data/` (sesuaikan jika perlu),
  `flutter test`, `flutter build apk --debug`, `dart format --set-exit-if-changed`
  (scope repo), `git diff --check`, review keamanan/diff.
- Manual skenario jika runtime tersedia: create → attach source → restart app →
  resume → delete → counter nol. Jangan menyebutnya PASS tanpa dijalankan.

### Rollback

Rollback dilakukan hanya dengan membatalkan perubahan yang dibuat Phase 02,
setelah diff/status ditinjau; tidak memakai reset/checkout/clean global dan tidak
menyentuh artefak Phase 00/01. Database lokal tidak dihapus otomatis. Jika schema
baru sudah dipakai, pertahankan migrasi forward/backup; jangan downgrade destruktif.
Jika implementasi terblokir, report mencatat blocker dan status `BLOCKED`, tanpa
memulai Phase 03.

---

## 3. BUILD — implementasi

- Dependensi aktual: `drift`, `drift_dev`, `build_runner`,
  `sqlite3_flutter_libs`, `path_provider`, `path`, `uuid`, `crypto`,
  `file_picker`, `cryptography`, `flutter_secure_storage`.
- `lib/data/local/app_database.dart` + generated `app_database.g.dart`: schema
  version 1, foreign keys, cascade relations, indexes, local privacy prefs,
  tombstone, pending file-delete queue, and no-success check on `AnalysisRuns`.
- `lib/domain/audit/`: domain entities/value enums and `AnalysisEngine` /
  `UnavailableAnalysisEngine` with `on_device_model_not_installed` reason.
- `lib/data/audit/`: async serialized `AuditRepository`; source lifecycle,
  provenance/hash, child associations, migration bridge, audit CRUD, cascade and
  recoverable file cleanup; `LocalDataCipher` AES-256-GCM and secure key provider;
  `LocalSourceFileStore` encrypts source files in app-private storage. User audit
  titles, source filenames, permission names/status/details, provenance locator,
  user action details, segment text and evidence quotes are field-encrypted.
- Production startup opens the local DB, secure key, source store, performs
  cleanup recovery and preserves existing SharedPreferences privacy flags.
  S24 creates/edits, S14 resumes/attaches/reviews/detaches/deletes, S19 lists
  persistent history, and S03 reads a real session count. No seed/example audits.
- A PRD §9.4 security review amended THINK before final verification: sensitive
  file bytes and database fields are AES-GCM encrypted; hashes are computed from
  plaintext and used only as local provenance. Missing key is checked before
  recovery can mutate files, and is fail-closed. No whole-database encryption
  claim is made.
- Scope remains Phase 02: no cloud upload/API keys, no camera request, no OCR,
  no Android permission enumeration, no analysis success or ONNX model.

---

## 4. REVIEW — bukti aktual

| Perintah / pemeriksaan | Status | Hasil |
|---|---|---|
| `dart run build_runner build` | **PASS** | Drift codegen selesai; warning custom `CHECK` diperbaiki dengan `NOT NULL` dan codegen dijalankan kembali |
| `flutter analyze` | **PASS** | `No issues found!` (final tree) |
| `flutter test test/data/` | **PASS** | 13 repository/security tests, termasuk schema/FK, restart, encryption, deletion/recovery, concurrency, and unavailable analysis |
| `flutter test test/features/local_audit_flow_test.dart` | **PASS** | Flow repository guest: create → attach → close/reopen DB → resume/read source → delete; 1 test |
| `flutter test` | **PASS** | 90 tests lulus, termasuk visual goldens, routing, S14 Cubit/workspace, data, privacy, dan responsive UI |
| `flutter build apk --debug` | **PASS** | APK debug berhasil dibangun dengan workaround JDK 17 pada proses build |
| `dart format --output=none --set-exit-if-changed .` | **PASS** | 70 file; tidak ada perubahan format tertunda |
| `git diff --check` | **PASS** | Tidak ada whitespace/error diff |
| Manual create→attach→restart→resume→delete→counter nol | **NOT_RUN** | Restart diuji dengan close/reopen SQLite; pemeriksaan manual/perangkat dan TalkBack tidak dijalankan |

---

## 5. FIX — temuan

| Gejala | Akar masalah | Perubahan | Regression / REVIEW |
|---|---|---|---|
| Perencanaan awal menyimpan source files/teks permanen tanpa enkripsi | Review menemukan PRD §9.4 mensyaratkan AES-GCM untuk persistent sensitive content | THINK diamendemen sebelum gate; AES-GCM file + field cipher, secure key storage, fail-closed | Data test membuktikan ciphertext tak memuat source/segment/quote; tamper/wrong/missing key ditolak; data test PASS |
| Analyze gagal pada Drift generated class collisions dan asumsi API `file_picker` lama | Drift data-class names berbenturan dengan domain types; API v13 mengembalikan `PlatformFile` berbeda | Beri `@DataClassName` unik; gunakan `FilePicker.pickFile()` + `readAsBytes`; pilih jenis dokumen eksplisit (Terms tidak dilabel otomatis sebagai policy) | Analyze pernah PASS; final rerun berlangsung |
| Trigger source-delete failure sempat jadi skenario rollback yang perlu dibuktikan | Cascading database delete harus atomik, file cleanup tidak dapat masuk transaksi SQLite | Tombstone + pending queue dalam DB transaction, cleanup di luar transaction dan retry/reconcile saat startup | Test memaksa delete source rollback, serta pending queue trigger failure; assertions lulus di `flutter test test/data/` |
| Batas 60 karakter judul menolak judul yang sudah dienkripsi | Batas kolom SQL memeriksa ciphertext yang lebih panjang daripada plaintext | Batas dipertahankan pada repository sebelum AES-GCM; kolom ciphertext tidak memakai `maxLength` plaintext | Codegen dijalankan ulang; repository tests kemudian PASS, final rerun berlangsung |
| Golden S24 berbeda setelah notice enkripsi dikoreksi | Copy lama menyatakan sumber tidak dienkripsi | Hanya golden `tab_audit_baru_393x852.png` diperbarui setelah membandingkan master/test image; perbedaan hanya notice yang dikoreksi | `flutter test --update-goldens test/goldens/visual_test.dart` PASS |

---

## 6. GATE

**PASS — automated Phase 02 gate.** Analyze, 13 data/security tests, bounded
create/attach/reopen/resume/delete flow, full 90-test suite, formatter/diff
checks, dan APK debug build lulus. Restart direpresentasikan oleh close/reopen
SQLite; manual/device workflow dan TalkBack tetap **NOT_RUN**, tanpa deteksi
perangkat atau klaim validasi fisik. Phase 03 tetap `NOT_STARTED` sampai diminta.
