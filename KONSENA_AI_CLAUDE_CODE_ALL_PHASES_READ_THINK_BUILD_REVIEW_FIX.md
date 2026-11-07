# KONSENA AI — Satu Prompt Eksekusi Claude Code, Phase 00–10

**Versi 5.0 | 7 November 2026 | Metode wajib: READ → THINK → BUILD → REVIEW → FIX → GATE → NEXT.**

> **INSTRUKSI UNTUK CLAUDE CODE**
>
> Ini adalah **SATU-SATUNYA FILE PROMPT EKSEKUSI** untuk pengembangan KONSENA AI dari awal sampai selesai. **Bukan permintaan membuat dokumen rencana semata**. Implementasikan langsung di repository yang sedang terbuka, satu fase pada satu waktu, mulai **Phase 00: setup repository dan Supabase**. Semua rincian fase ada di file ini; **jangan mencari atau menjalankan file `prompts/PHASE_*.md` lama**.
>
> Pelajari aturan eksekusi secara utuh, tetapi **JANGAN melakukan build atau perubahan lintas fase lebih awal**. Pada tiap fase jalankan kelima tahap **READ, THINK, BUILD, REVIEW, FIX** secara benar. Hanya setelah *gate* PASS yang dibuktikan, lanjut ke fase berikutnya. Jika gate tidak PASS, lanjutkan putaran FIX ↔ REVIEW dalam fase yang sama. Apabila terblokir oleh input/akses/perangkat yang wajib, **STOP dan minta tindakan operator yang spesifik**, jangan melompat atau mengarang kelulusan.

## 0. Kontrak produk yang tidak boleh berubah

- **Produk:** KONSENA AI, asisten analisis persetujuan dan perlindungan privasi digital, fokus Indonesia.
- **Stack:** Flutter/Dart untuk Android-first, Kotlin native Android secukupnya, Cubit/BLoC, `go_router`, SQLite/Drift local-first, Supabase Auth/Postgres/Storage disiapkan di **Phase 00**. Integrasi pengguna ke cloud baru di **Phase 07** setelah opt-in; ONNX baru di **Phase 09**, bila artefak model asli tersedia.
- **Default privasi:** guest-first, offline-first. Tanpa login tetap dapat melakukan audit lokal. Tidak unggah kebijakan privasi, OCR, screenshot, atau evidence ke cloud secara otomatis. Izin kamera diminta *just-in-time*, bukan pada onboarding.
- **Fokus fitur:** audit izin yang Android benar-benar mengekspos, import PDF/teks, OCR lokal, LiveScan kamera ponsel yang memindai **layar laptop/monitor fisik**, screenshot UI persetujuan, source/evidence matching, audit log, laporan PDF dan kontrol data.
- **Akurasi/klaim:** jangan mengarang skor risiko, temuan dark pattern, prediksi ML, status kepatuhan UU PDP, confidence, keberhasilan permission grants, atau metrik. Sebelum ONNX siap, tampilkan **"Analisis AI belum tersedia"** sambil membiarkan fitur non-ML berfungsi.
- **Visual:** referensi Stitch hanya untuk Splash S00, Onboarding S01, dan Dashboard S03 (file di `references/stitch/`). Layar lain mengikuti `docs/DESIGN_SYSTEM.md`, bukan direkayasa memiliki mockup sumber. Aset ikon utama `assets/brand/konsena_mark_transparent.png`; warna `#252148 #342D61 #5A3DAD #7838D8 #C4BDD6 #E5E0F9 #EFE6FB #FDFCFE` dan status `#36C77B #FFB83F #EF6464`. Tipografi Plus Jakarta Sans jika font berlisensi tersedia, fallback dicatat.
- **Bottom navigation tetap lima:** **Beranda** `/home`, **Audit Baru** `/audit/new`, **Pindai** `/scan` (tengah), **Riwayat** `/history`, **Profil** `/profile` (bisa guest). Seluruh 40 layar S00–S39 sesuai `docs/KONSENA_AI_PAGE_BY_PAGE.md`.
- Jangan menyisipkan `service_role` / secret key, API token, password, signing keystore, atau data PII dalam repo/log/README. Jangan melakukan destructive Git commands, push, deploy, migration ke remote/produksi, billing, atau rilis Play tanpa otorisasi yang jelas untuk targetnya.

## 1. Sumber yang dibaca dan konflik aturan

Periksa keberadaan dan baca bagian relevan berkas berikut **di repo yang benar**, jangan menganggap mereka ada jika belum tersedia:

1. `docs/PRD_KONSENA_AI_MOBILE.md` — kebutuhan produk dan batas klaim.
2. `docs/KONSENA_AI_PAGE_BY_PAGE.md` — semua S00–S39 dan kontrak navigasi.
3. `docs/DESIGN_SYSTEM.md` dan `docs/DESIGN_REFERENCE_MAPPING.md` — sistem visual.
4. `docs/REQUIREMENTS_TRACEABILITY.md` — keterlacakan kebutuhan dan hasil.
5. `references/stitch/` dan `assets/brand/` — acuan desain dan logo.
6. Kode, migrasi, tes, dan `docs/phase-reports/` **yang benar-benar ada**.
7. `CLAUDE.md` yang sudah ada di repo (jika ada). Bila masih memerintahkan "file prompt terpisah" atau "selalu STOP setelah tiap fase", identifikasi sebagai **aturan alur versi lama**. Jangan diam-diam bertentangan: konsolidasikan dengan kontrak versi 5 ini, namun jangan mengubah kebijakan keamanan, hak akses, atau tindakan irreversibel tanpa persetujuan. Dokumen spesifikasi produk tetap lebih otoritatif pada perilaku produk daripada contoh implementasi.

Jika dokumen pendukung tidak tersedia, cari di folder lokal paket referensi bila ada. Jangan mengambil ZIP atau template acak dari internet. Jika kontrak esensial hilang, catat `BLOCKED` dan minta dokumen tersebut. Jika perubahan desain dari referensi berbeda dengan kebutuhan keamanan/produk, pilih perilaku aman dan catat dalam ADR.

## 2. Mesin eksekusi wajib untuk setiap fase

### 2.1 Urutan (tidak bisa diparalelkan antar fase)

```text
START → PHASE 00
            │
            ▼
           READ ──> THINK ──> BUILD ──> REVIEW
                                      │
                         ditemukan gagal/temuan?
                              ┌───────┴───────┐
                             YES             NO
                              │               │
                              ▼               ▼
                             FIX ─────────> REVIEW
                                              │
                                         Gate PASS?
                                      ┌───────┴───────┐
                                     NO             YES
                                      │               │
                                  STOP/BLOCKED    NEXT PHASE
```

**READ** — audit proyek `pwd`, `git status --short`, versi tool, sumber dokumen spesifik, report fase sebelumnya, dependensi aktual dan acceptance criteria. Identifikasi file existing yang harus dipertahankan. Output ringkas: kebutuhan, fakta repo, risiko, dan blocker. **Tidak mengubah kode pada tahap READ.**

**THINK** — susun rencana implementasi konkret per berkas, perubahan schema/API/UI, dependensi, strategi test, risiko privasi dan alternatif/rollback. Berikan ringkasan keputusan teknis dan asumsi yang bisa diuji; **tidak perlu membocorkan penalaran internal tersembunyi**. Pastikan scope hanya fase aktif. Jika kontrak atau kebutuhan kritis belum jelas, gunakan pilihan paling aman yang konsisten dengan dokumen dan dokumentasikan ADR.

**BUILD** — kerjakan kode, migration, UI, tests, fixtures dan wiring **sebenarnya** untuk fase aktif. Tidak sekadar desain atau TODO kosong. Integrasi platform/SDK mengikuti versi yang benar-benar terpasang. Tidak menghapus perubahan user atau merekayasa hasil demo. Fitur yang membutuhkan ML tetap unavailable sampai Phase 09.

**REVIEW** — audit diff, cakupan spesifikasi, kondisi empty/loading/error/offline, UX, accessibility, privacy/RLS bila relevan, lint/test/build dan verifikasi manual yang **benar-benar dikerjakan**. Cantumkan command, output ringkas, evidensinya, dan status terpisah `PASS`, `FAIL`, `NOT_RUN`, `BLOCKED`. Review juga dilakukan oleh Claude sendiri, bukan hanya menyatakan "sudah oke".

**FIX** — perbaiki **setiap** masalah P0/P1 dan semua acceptance failure dalam fase aktif, tambahkan regression tests, lalu **ulang REVIEW** termasuk pengujian yang sebelumnya gagal. Tidak cukup hanya menulis workaround di laporan. Jika masalah membutuhkan izin/alat fisik/kunci model yang tidak tersedia, catat blocker dan **STOP** tanpa melewati gate. Batasi percobaan berulang tanpa progres; setelah tiga percobaan per masalah yang sama tanpa perubahan diagnosis, berhenti dengan bukti dan tindakan operator yang spesifik.

### 2.2 Kriteria `GATE PASS` dan kapan boleh NEXT

Sebuah fase menjadi `PASS` **hanya jika semua syarat wajib fase tersebut benar-benar terpenuhi dan diuji**: kode berjalan sejauh skenario yang diminta, seluruh mandatory tests PASS, tidak ada blocker P0/P1, tidak ada data palsu atau kebocoran rahasia, dan laporan fase lengkap. **`NOT_RUN` untuk pengujian wajib bukan PASS.** Jika hardware atau remote service bersifat wajib untuk verifikasi fitur tersebut, fase harus `BLOCKED` sampai bukti tersedia.

Pengecualian eksplisit dan terbatas: (a) Phase 00 boleh **PASS untuk fondasi offline** bila remote Supabase belum tersedia, dengan `REMOTE_PENDING` yang tidak menghambat UI, namun sinkronisasi Phase 07 tetap tidak boleh diklaim PASS; (b) Phase 09 boleh dicatat `NOT_APPLICABLE_MODEL_NOT_DELIVERED` sebagai **jalur rilis pre-ML**, bukan model selesai, hanya jika seluruh fitur AI dinonaktifkan dan Scope Phase 10 disebut **pre-ML pilot**; untuk klaim rilis AI penuh Phase 09 tetap `BLOCKED`. Tidak boleh menyamakan waiver dengan kelulusan kemampuan yang tidak ada.

Setelah `PASS`, Claude Code **boleh lanjut otomatis ke fase berikutnya dalam file ini tanpa prompt baru**, tetapi **tidak boleh menggabungkan atau memulai dua fase sekaligus**. Saat ada tindakan irreversibel, akses remote berisiko, upload ke Play, atau pembelian sumber daya, minta persetujuan target secara khusus dahulu walaupun tes sebelumnya lulus. Jika user meminta stop setelah fase tertentu, patuhi.

### 2.3 Dokumentasi progres yang wajib dibangun oleh Claude Code di repo

Di setiap fase perbarui (ini adalah **artefak implementasi**, bukan prompt fase lain):

- `docs/phase-reports/PHASE_<ID>_REPORT.md`: tanggal, scope, berkas berubah, bukti READ/THINK/BUILD/REVIEW/FIX, hasil command dan test, isu, risiko, keputusan gate, keterlacakan requirement, next phase.
- `docs/phase-reports/PHASE_STATUS.md`: tabel satu baris per fase `NOT_STARTED | IN_PROGRESS | PASS | BLOCKED | PRE_ML_DEFERRED`, jam update dan tautan laporan.
- `docs/phase-reports/KNOWN_ISSUES.md`: severity, reproduksi, owner/solusi, status; jangan disembunyikan.
- `docs/adr/ADR-*.md` hanya bila keputusan arsitektur perlu didokumentasikan.

Format tabel pengujian dalam laporan fase:

| Check | Perintah atau skenario aktual | Hasil | Bukti/penyebab |
|---|---|---|---|
| Static analysis | `flutter analyze` | `PASS/FAIL/NOT_RUN` | Potongan hasil asli |
| Unit/widget tests | `flutter test` | `PASS/FAIL/NOT_RUN` | Jumlah test asli |
| Build debug | `flutter build apk --debug` | `PASS/FAIL/NOT_RUN` | Path/exit code asli |
| Verifikasi khusus fase | tes fitur | `PASS/FAIL/BLOCKED` | Device/API/fixture |

Perintah default **jika toolchain tersedia**:

```bash
pwd && git status --short
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

Jangan mencatat perintah sebagai PASS bila tidak dijalankan. Selalu jelaskan bila format/lint/package upgrade mengubah file di luar scope; minta review sebelum perubahan besar. Jangan commit, push, upload, deploy atau mengubah remote DB secara otomatis.

### 2.4 Protokol resume ketika sesi Claude Code terputus

1. Baca kembali **file prompt tunggal ini**, `git status`, `PHASE_STATUS.md`, laporan fase terbaru, dan diff aktual.
2. Cari fase berstatus bukan PASS paling awal. **Jangan percaya status dari laporan tanpa memeriksa bukti tes dan source.**
3. Jika fase sebelumnya PASS dan bukti valid, lanjut ke READ fase berikutnya. Jika belum, mulai dari tahap yang belum tuntas di fase yang sama, lalu REVIEW ulang.
4. Bila ada modifikasi user di luar fase, pertahankan; konflik harus diperiksa, tidak dihapus.

## 3. Peta implementasi wajib (urutan tetap)

| Urutan | Fase | Output minimum | Status gate |
|---|---|---|---|
| 1 | 00 | Flutter repo, Supabase local schema/RLS/private storage | Wajib pertama |
| 2 | 01A | S00–S03, tema Stitch, guest setup | Setelah 00 PASS |
| 3 | 01B | 5 tabs, 40 route S00–S39 | Setelah 01A PASS |
| 4 | 01C | UI accessibility/visual regression | Setelah 01B PASS |
| 5 | 02 | SQLite/Drift & domain data | Setelah 01C PASS |
| 6 | 03 | Kotlin Android permission inspector | Setelah 02 PASS |
| 7 | 04 | PDF/teks import & OCR | Setelah 03 PASS |
| 8 | 05 | LiveScan kamera ke monitor | Setelah 04 PASS |
| 9 | 06 | Screenshot consent, evidence/action | Setelah 05 PASS |
| 10 | 07 | Report, histori, Supabase opt-in sync | Setelah 06 PASS |
| 11 | 08 | Security/hardening/release candidate pre-ML | Setelah 07 PASS |
| 12 | 09 | ONNX asli dan parity bila tersedia | Setelah 08 PASS atau jalur pre-ML terdokumentasi |
| 13 | 10 | Pilot, build release, handoff | Setelah 09 PASS / pre-ML gate |

**Prompt mulai:** baca bagian ini dan **langsung kerjakan Phase 00 — READ**. Jangan membuat 13 file prompt atau master prompt baru. Langsung implementasikan di repo dan ikuti gate yang ditentukan di bawah.

---

## Phase 00 — Setup Repo Flutter dan Supabase

**Tujuan:** Bertindak sebagai lead Flutter engineer, Supabase/PostgreSQL engineer dan security reviewer KONSENA AI. Tugas kali ini adalah **membuat pondasi repository dan Supabase benar-benar berjalan sejauh environment dan hak akses memungkinkan**, bukan sekadar membuat checklist atau desain. Repo ini adalah satu aplikasi Flutter Android-first, guest-first, offline-first. Cloud di-*provision* sejak Phase 00 tetapi penggunaan Auth/sync oleh pengguna tetap **opsional dan opt-in**. Jangan mengerjakan UI 40 layar, OCR, PackageManager, LiveScan, PDF reporting, atau ONNX pada fase ini.

Baca aturan dan sumber yang relevan: `CLAUDE.md`, `docs/PRD_KONSENA_AI_MOBILE.md` (khusus §3, §13, arsitektur/data), `docs/REQUIREMENTS_TRACEABILITY.md`, `docs/DESIGN_SYSTEM.md`, `docs/KONSENA_AI_PAGE_BY_PAGE.md` dan folder `references/`. Jika file tidak ada, laporkan secara eksplisit; jangan menganggap dokumen atau repo sudah ada.

### READ — pahami repository dan prasyarat

Audit root Git, toolchain Flutter/Dart/Android, Java, Supabase CLI, existing Supabase migrations/remote; baca PRD arsitektur, kebutuhan privasi, dan laporan yang mungkin sudah ada. Jangan hapus pekerjaan sebelumnya.

**Prasyarat khusus:**

- Root repository proyek yang benar sudah tersedia untuk audit; jangan menebak cloud project, URL, key atau perangkat.
- Supabase remote hanya jika user memberi target project dan izin untuk aksi remote. Lokal tetap bisa dipersiapkan.

**Audit spesifik Phase 00:**

1. Jalankan `pwd`, `ls -la`, `git status --short`, `git remote -v`, dan identifikasi apakah repo kosong atau telah berisi Flutter/app lain. **Jangan menghapus kode existing, melakukan force push, `git reset --hard`, `git clean -fd`, atau `flutter create --overwrite`.**
2. Periksa `flutter --version`, `flutter doctor -v`, `dart --version`, `java -version`, `git --version`, `supabase --version` (atau `npx supabase --version`) sesuai ketersediaan. Laporkan versi aktual, bukan asumsi. Jika command belum tersedia, dokumentasikan yang terhalang.
3. Jika repo belum punya Git, **catat kebutuhan `git init` pada rencana THINK, dan eksekusi di BUILD saja** untuk repo yang telah diverifikasi; jika remote sudah terpasang, pertahankan. Jangan membuat repository GitHub baru, menghubungkan remote, commit, push, atau memodifikasi project cloud produksi tanpa otorisasi/operator yang jelas.
4. Tulis rencana file yang akan dibuat/diubah dan status blocker dalam laporan fase. Jika ada source existing, integrasikan secara non-destruktif.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Tetapkan rencana file bootstrap Flutter, struktur modul minimum, env guest/cloud-disabled, migrasi Postgres owner-based, policy RLS dan Storage privat. Identifikasi perintah yang aman lokal vs remote; siapkan strategi pgTAP user A/B dan konfigurasi emulator.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

**Bootstrap Flutter Android-first**

0. Jika repo ini belum diinisialisasi Git dan root sudah diverifikasi aman, jalankan `git init` sebelum bootstrap Flutter.
1. Jika belum ada Flutter project, buat `konsena_ai` (mis. `flutter create --org id.konsena --platforms=android .` **hanya jika root aman dan sesuai**). Tetapkan Android applicationId `id.konsena.ai` jika tidak berbenturan dengan package existing; pertahankan id bila telah digunakan.
2. Tambahkan `flutter_bloc`/Cubit, `go_router`, `supabase_flutter`, lint/test, dan dependency injection sederhana sesuai versi Flutter **yang ditemukan**, tanpa menambah puluhan dependency fitur untuk fase berikutnya. Susun `lib/app/`, `lib/core/config/`, `lib/core/network/`, `lib/core/supabase/`, `lib/features/`, dan `test/` secukupnya; jangan menciptakan folder tanpa penggunaan.
3. Buat bootstrap `main.dart` + `KonsenaApp`, konfigurasi flavor minimal/dev bila relevan, router halaman shell awal **tanpa mengimplementasikan S00–S39**. Logo dan referensi desain tetap di assets dan docs.
4. Buat `AppConfig` bertipe dengan `String.fromEnvironment` atau `--dart-define-from-file`, validasi URL dan publishable key. Ketika konfigurasi kosong, aplikasi guest tetap hidup dengan state `cloudNotConfigured`/`cloudDisabled`; jangan crash ataupun memakai URL/kunci contoh seolah valid.
5. Inisialisasi Supabase **hanya bila konfigurasi valid**, menggunakan API `supabase_flutter` aktual (`publishableKey` bila didukung SDK versi terpasang; `anonKey` hanya bila SDK yang terpasang mengharuskan parameter legacy). Pisahkan `SupabaseClient` di belakang interface/gateway sehingga fitur lokal tidak tergantung network.
6. `.gitignore` harus melindungi build, `.env*` lokal, JSON dart-define aktual, token, credential dan tool caches. Sediakan `.env.example` dan `tool/env/dev.example.json` berisi **placeholder**, tanpa secret. `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `ENABLE_CLOUD_SYNC=false`, `ENABLE_ML=false` dijelaskan dalam README. Publishable key boleh berada di client **hanya bersama RLS yang benar**; `service_role`, `secret` key, database password, PAT, JWT signing secrets tidak boleh disertakan ke aplikasi atau Git.

**Supabase local**

1. Periksa apakah folder `supabase/` dan proyek remote sebelumnya sudah ada. Jika belum, jalankan `supabase init` (atau `npx supabase init`) di root. Jangan menimpa konfigurasi lama.
2. Bila Supabase CLI tersedia, jalankan `supabase start`; kumpulkan endpoint *lokal* yang benar dari output `supabase status` **tanpa menyalin credential sensitif ke laporan**. Perhatikan URL yang dapat dijangkau emulator Android berbeda dari localhost komputer; catat mapping yang diperlukan, jangan mengasumsikan `localhost` Android = laptop.
3. Struktur minimum: `supabase/config.toml`, `supabase/migrations/`, `supabase/tests/` dan bila perlu `supabase/seed.sql` berisi **data sintetis yang jelas bertanda test**, tanpa bukti nyata pengguna.
4. Bila Supabase CLI tidak tersedia, migrasi dan tes SQL tetap disiapkan, namun status Supabase local runtime harus **NOT_RUN/BLOCKED**, bukan PASS.

**Postgres / RLS**

Buat **migrasi SQL versioned** dengan nama timestamp yang dihasilkan CLI, idempotensi sesuai konvensi migrasi Supabase. Ikuti subset cloud pada PRD §13 dan jadikan `auth.users.id` sebagai pemilik. Rancang tabel inti minimal `profiles`, `audit_records`, `audit_sources`, `findings`, `recommendations`, `evidence_refs`; `sync_devices` boleh ditunda dengan alasan ADR. Kolom yang dibutuhkan meliputi UUID PK, `owner_id` yang valid, timestamps, foreign key, status/domain fields, dan `created_at`/`updated_at` yang konsisten. **Jangan mewajibkan menyimpan teks kebijakan, screenshot, rekaman kamera, atau OCR mentah di cloud.** Skema boleh menyimpan metadata aman serta referensi objek yang jelas dipilih pengguna untuk sync.

1. Aktifkan RLS pada **setiap** tabel exposed; konfigurasi grant hanya seperlunya untuk `authenticated`, tanpa kebijakan publik `USING (true)`.
2. Semua `SELECT`, `INSERT`, `UPDATE`, `DELETE` untuk data privat menggunakan `auth.uid()`/owner. `INSERT`/`UPDATE` wajib `WITH CHECK`; periksa ownership pada relasi child agar user A tidak bisa menautkan child milik user B walau UUID diketahui.
3. Buat index pada `owner_id`, foreign keys dan kolom pencarian yang perlu; batasi payload evidence, hindari log/dump PII.
4. Untuk identitas `profiles`, buat profile dengan uid dari session yang tervalidasi; jangan memberi guest offline identitas cloud palsu. Guest lokal **tidak menulis ke Postgres** sebelum sign in dan opt-in.
5. Jika merancang trigger atau function `SECURITY DEFINER`, tetapkan search_path aman, scope sekecil mungkin, dan jelaskan kebutuhan. Tidak ada RPC yang menonaktifkan RLS untuk akses umum.

**Private Storage**

1. Definisikan bucket `konsena-private` dengan `public=false` melalui migration/config sesuai CLI yang tersedia; jangan buat public bucket untuk screenshot/dokumen pengguna.
2. Siapkan RLS Storage pada `storage.objects` agar pengguna terautentikasi **hanya** boleh membaca/mengunggah/menghapus objek di prefix `auth.uid()/...` dalam bucket tersebut; pastikan operasi list dan download tidak memberi akses silang. Ikuti ketentuan SQL Supabase Storage versi aktual.
3. Pada Phase 00 **jangan unggah file pengguna**; tes dengan objek test dummy hanya pada Supabase lokal. Semua upload production baru tersedia di Phase 07 setelah explicit consent, allowlist field, upload preview, cancel, dan delete.

**Supabase remote — opsional/izin operator**

1. Jika user/operator sudah memiliki project remote dan akses CLI, pastikan **project ref yang benar** sebelum `supabase link --project-ref ...`. Bandingkan project/branch dan migration history, terutama jika repo pernah digunakan. Jangan melakukan reset remote.
2. Jika belum ada project remote, jangan mengarang project URL/kunci. Buat instruksi **operator**: membuat project melalui Supabase Dashboard, mendapatkan `Project URL` + `publishable key` dari Connect panel, menjalankan `supabase login` secara interaktif, lalu `supabase link --project-ref <PROJECT_REF>`.
3. `supabase db push --remote` boleh dijalankan **hanya ketika project/branch tujuan sudah diverifikasi dan operator mengizinkan perubahan schema remote**. Bila belum, tandai `REMOTE_PENDING` dan jangan berpura-pura Supabase hosted selesai.
4. Jangan pernah meminta operator menempelkan `service_role`, database password, personal access token, atau kunci admin ke isi chat, log atau Markdown. Gunakan credential manager/CLI interaktif lokal.

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

Phase 00 dianggap **PASS** jika setup repo + Flutter berjalan, konfigurasi cloud aman, migration/Storage policies tersedia dan uji lokal yang dapat dijalankan lulus. Jika environment tidak menyediakan Supabase CLI atau izin remote, nilai bagian terkait `BLOCKED/NOT_RUN`, beri instruksi operator yang dapat dieksekusi, **jangan berbohong semua selesai**. Pekerjaan UI Phase 01A boleh dimulai dengan mode guest lokal hanya setelah fondasi Flutter dan kontrak config berfungsi; pekerjaan sync Phase 07 memerlukan Supabase yang terkonfigurasi dan RLS tervalidasi.

**Pengujian wajib yang relevan:**

- `flutter pub get`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test` dan `flutter build apk --debug` bila SDK tersedia; status command dicatat per baris.
- `supabase start`, `supabase db reset` **LOCAL ONLY**, dan `supabase test db` bila CLI/containers tersedia. Perintah `db reset` tidak boleh menunjuk remote.
- Tes SQL/pgTAP minimal: user A bisa CRUD row sendiri; user B gagal select/insert/update/delete data A; anonymous gagal; child tak bisa menggunakan parent milik B; private Storage tidak dapat dibaca/ditulis silang; user tidak bisa mengubah owner_id.
- Widget/unit test: startup tanpa env tidak crash, guest tidak ter-autentikasi dan cloud feature default disabled; startup dengan config valid menginisialisasi gateway Supabase tanpa mengeksekusi upload.
- Jangan mengklaim hosted auth/RLS PASS jika hanya pengujian lokal; tulis ruang lingkup dan status `PASS`/`FAIL`/`NOT_RUN`/`BLOCKED` nyata.

**Audit tambahan:** Periksa penyimpanan kredensial, default `ENABLE_CLOUD_SYNC=false`, startup tanpa env, flutter analysis/test/build, migration RLS pada setiap tabel, seluruh operasi owner user A/B, private Storage per prefix, serta pemisahan remote/local. Catat status Supabase local/remote terpisah.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Setiap syntax error, missing index/foreign-key constraint, RLS kebocoran silang, crash tanpa env dan build failure harus diperbaiki dan diuji ulang. Remote pending boleh ditunda hanya sesuai kontrak pengecualian gate; jangan menonaktifkan RLS demi membuat tes lulus.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** Flutter guest bootstrap teruji, migration & policies tersimpan dengan test yang benar-benar dijalankan bila local infra tersedia; catat status remote secara terpisah. Tidak ada service secret di app. NEXT: 01A.

**Artefak wajib:** - `pubspec.yaml`, konfigurasi Android/Flutter, `lib/main.dart`, `lib/app/...`, `lib/core/config/...`, `lib/core/supabase/...`, `test/...`
- `supabase/config.toml`, minimal satu migration timestamped, `supabase/tests/*_rls_test.sql`, dokumentasi bucket/Storage policy
- `.env.example`, `tool/env/dev.example.json`, `.gitignore`, README perintah setup Flutter dan Supabase lokal/remote; `docs/adr/ADR-0001-foundation-and-cloud.md`
- `docs/phase-reports/PHASE_00_REPORT.md` dan `docs/phase-reports/KNOWN_ISSUES.md` dengan bagian: repository, Flutter, Supabase local, Supabase remote, RLS, Storage, auth, test evidence, blocker, file changed, exact next phase.

Simpan laporan `docs/phase-reports/PHASE_00_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---


## Phase 01A — Fondasi UI berbasis referensi Stitch

**Tujuan:** Buat design system Flutter dan implementasikan Splash S00, Onboarding S01, Privacy Setup S02 dan Dashboard S03 secara visual konsisten dengan sumber Stitch. Ini fase referensi desain paling penting.

### READ — pahami repository dan prasyarat

Periksa referensi Stitch `s00_splash_screen/code.html`, `s01_onboarding/code.html`, `01_dashboard/code.html` dan screenshot dashboard; baca Design System dan layar S00–S03; periksa aset PNG alpha dan phase 00 report.

**Prasyarat khusus:**

- Phase 00 sudah PASS atau source Flutter setara telah valid.
- Referensi bisa dibaca: `references/stitch/s00_splash_screen/code.html`, `s01_onboarding/code.html`, `01_dashboard/code.html`, `01_dashboard/screen.png` dan `DESIGN.md`.
- Hanya tiga layar yang punya sumber Stitch langsung: jangan mengarang screenshot untuk S02.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Petakan token warna, font, hierarki, responsivitas, state onboarding dan Dashboard ke komponen Flutter reusable. Bagi menjadi widget/theming tanpa menyalin HTML menjadi UI palsu.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

1. Bangun `KonsenaTheme`, `KonsenaColors`, spacing, radii, semantic shadows dan `Plus Jakarta Sans` (bundle font berlisensi jika tersedia, fallback eksplisit). Approved palette Midnight Purple/Deep Indigo/Royal Violet/Electric Violet/Lavender.
2. Gunakan asset `assets/brand/konsena_mark_transparent.png`; pastikan logo RGBA tidak memiliki background hitam pada scaffold terang/gelap.
3. S00: dark radial violet gradient, logo, nama dan tagline `Pahami, Kendalikan, dan Lindungi Data Pribadimu`, loading/failed-bootstrap states; jangan fake iPhone status bar.
4. S01: layout white/lavender, judul `Ubah Kebijakan Privasi yang Rumit Jadi Mudah Dipahami`, CTA bundar violet, tombol Lewati; tiga slide dengan nilai manfaat yang sesuai PRD; semua skip/continue ke S02.
5. S02: privacy setup guest-first, penjelasan data lokal, cloud opt-in false, camera permission **tidak diminta di sini**; persetujuan yang terpisah.
6. S03: header logo + brand + subtitle `PRIVACY INTELLIGENCE`; hero gradient violet berisi `AUDIT PERSETUJUAN DIGITAL`, `Pahami izin. Lindungi privasi.`, deskripsi dan CTA putih `Mulai Audit` -> S24; dua summary cards; how-it-works 3 langkah; aksi fitur pendukung boleh di bawah fold.
7. Dashboard **jangan** menyajikan angka analisis palsu atau badge DEMO pada production. Buat repository interface untuk ringkasan dengan initial empty state; UI menampilkan nol dari state, bukan angka hard-coded yang diklaim real.
8. Buat widget composable reusable dan atur responsive 320dp–430dp + tablet + text scale 200%.

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

- Layout S00/S01/S03 memiliki visual hierarchy yang jelas dan dapat dibandingkan dengan sumber tanpa pixel-perfect iOS chrome.
- Tombol Lewati, Lanjut, Mulai Audit berfungsi; S02 tetap guest-first.
- Tidak ada overflow pada 320dp atau 200% scaling, semua target >=48dp.
- Screenshot/golden Flutter untuk S00/S01/S03 tersedia jika toolchain mendukung; mismatch dicatat jujur.

**Pengujian wajib yang relevan:**

```bash
flutter pub get
flutter analyze
flutter test test/features/onboarding/  # sesuaikan dengan lokasi yang benar
flutter test                    # bila suite tersedia
flutter build apk --debug       # bila Android SDK tersedia
```
Periksa secara manual badge DEMO hanya muncul saat explicit demo flavor; screen dari ZIP tidak otomatis berarti hasil app nyata.

**Audit tambahan:** Bandingkan screenshot nyata atau golden dengan referensi; cek CTA, guest consent, angka ringkasan berasal dari state, 320dp dan 200% font scaling, TalkBack 48dp targets dan dark/light logo.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Tuntaskan pixel/spacing/overflow, button/route yang mati, text truncation dan state palsu; perbarui golden hanya setelah melakukan review visual nyata.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** S00/S01/S02/S03 terimplementasi, navigasi efektif, tidak ada overflow P1 atau data sintetis yang diklaim nyata. NEXT: 01B.

**Artefak wajib:** Implementasi riil, perubahan kode/tes/dokumen, bukti pengujian, laporan fase, dan `KNOWN_ISSUES.md` yang diperbarui.

Simpan laporan `docs/phase-reports/PHASE_01A_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---


## Phase 01B — Navigasi lima tab dan 40 layar

**Tujuan:** Bangun shell navigasi lima tab dan seluruh 40 rute yang stabil, tanpa memalsukan fungsi yang akan dibangun pada fase teknis berikutnya.

### READ — pahami repository dan prasyarat

Baca seluruh daftar S00–S39 di page-by-page, routes, cross-screen actions dan dependency; audit router/theme dari 01A.

**Prasyarat khusus:**

- Phase 01A selesai dan theme/reusable widgets sudah ada.
- Baca indeks route di bagian D dokumen page-by-page, jangan membuat route alternatif diam-diam.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Buat route registry unik 40 screen, route params/deep link guard, lima root tabs, mekanisme draft-safe navigation dan state unavailable untuk fitur belum tersedia.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

1. Implementasikan `StatefulShellRoute` atau struktur stateful setara untuk: Beranda S03 `/home`; Audit Baru S24 `/audit/new`; Pindai S06 `/scan` (tab tengah prominent); Riwayat S19 `/history`; Profil S21 `/profile`.
2. S21 **harus** punya konten guest yang berguna, kontrol data, pengaturan, dan login opsional; `/account` redirect ke `/profile`.
3. Route S00–S39 seluruhnya tersedia sesuai page specs; S04 `/audit/apps` adalah child dari Audit Baru, bukan tab root. Komponen awal menampilkan copy/CTA/empty/loading/unavailable yang akurat, bukan generic placeholder `Coming soon` tanpa penjelasan.
4. Implementasikan deep-link guard, missing session fallback, route param validation, back behavior dan draft-safe navigation (antarmuka repository bisa sementara).
5. Buat navigasi CTA dari hero Home->S24->S04/S14; Scan->PDF/Camera/Screenshot; History->detail/report; Profile->Settings, About, data controls, optional sync.
6. Tab state retained setelah pindah; modal flow tidak menghapus form atau audit yang sedang diisi.
7. Untuk mesin AI yang belum aktif, UI results/compare/dark-pattern berstatus unavailable, tanpa risk score atau finding palsu.
8. Buat test route registry yang memastikan tepat 40 Screen IDs S00..S39 (route alias `/account` tidak dihitung screen baru).

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

- Tidak ada halaman yatim, dead navigation, blank screen, atau profile gated by login.
- Semua S00–S39 dapat dibuka via navigasi internal/route tests dengan data valid; invalid IDs memiliki recovery UI.
- Bottom nav tepat lima label Indonesia, scan sebagai ikon tengah; tombol disabled selalu menjelaskan alasannya.
- Route sheet/traceability diperbarui bila ada mismatch implementasi.

**Pengujian wajib yang relevan:**

```bash
flutter analyze
flutter test test/navigation/   # atau suite route yang sesuai
flutter test
flutter build apk --debug      # jika toolchain tersedia
```
Uji manual Back Android, tab switch retention dan deep link invalid session.

**Audit tambahan:** Tes route registry S00–S39, invalid param, guest profile, back stack, retained tab state, CTA utama, zero orphan screen, go_router redirects dan device width.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Perbaiki collision route, orphan pages, dead actions, lost drafts, blank/404 dan claim AI semu; tambahkan smoke test untuk setiap route.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** Kelima tab sesuai kontrak, 40 screen IDs navigable, tidak ada dead CTA yang tidak dijelaskan. NEXT: 01C.

**Artefak wajib:** Implementasi riil, perubahan kode/tes/dokumen, bukti pengujian, laporan fase, dan `KNOWN_ISSUES.md` yang diperbarui.

Simpan laporan `docs/phase-reports/PHASE_01B_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---


## Phase 01C — Audit kualitas antarmuka

**Tujuan:** Finalisasi UX dan uji visual sebelum memasukkan domain/backend; produk harus terasa seperti KONSENA, bukan generic Flutter app.

### READ — pahami repository dan prasyarat

Inspeksi goldens/screenshot, implementasi UI semua layar, platform font scale/safe area, reference mapping, kontrak a11y.

**Prasyarat khusus:**

- Phase 01B PASS atau daftar ketidaksesuaian dinyatakan secara eksplisit.
- Golden baseline reference hanya untuk S00/S01/S03; screens lain adalah turunan desain.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Kelompokkan temuan per severity dan layar; rencanakan perbaikan layout/a11y paling berdampak sebelum snapshot golden.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

1. Review seluruh route UI, periksa konsistensi hierarki 24/20/16dp, radius 20–24dp card, gradients halus, contrast dan depth; jangan menambah AI-slop decorations.
2. Implementasikan generic reusable state widgets (loading, empty, error, denied, offline, unavailable) dengan copy berbeda sesuai domain masing-masing.
3. Pastikan safe areas Android, keyboard resize, scroll, focus traversal, `Semantics` untuk TalkBack, 48dp tap targets, error recovery.
4. Screenshot/golden untuk S00, S01, S03, 5 tab, profile mode tamu, flow S24/S06, dashboard 0 audit, font scale 200%, mobile kecil 320dp dan tablet.
5. Audit semua CTA: berfungsi ke route sebenarnya, buka settings OS hanya jika plugin tersedia, atau disabled dengan reason; dilarang `onPressed: () {}`.
6. Audit copy produk: bahasa Indonesia, sumber status nyata, tidak mengklaim AI ONNX, hukum, atau keamanan absolut.
7. Review layout terhadap `references/stitch/01_dashboard/screen.png` sambil mengabaikan iOS bezel/status icons.

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

- Golden/screenshot dicatat dengan device viewport aktual, mismatch list dan fix.
- Tidak ada overflow, broken routes, contrast fatal, atau dead CTA pada suite yang dapat dijalankan.
- 200% text scale dan TalkBack navigable; jika device test tidak tersedia catat manual gate `NOT_RUN`.
- UI siap dipakai untuk integrasi persistence di Phase 02.

**Pengujian wajib yang relevan:**

```bash
flutter analyze
flutter test
flutter test --update-goldens  # HANYA jika baseline review disetujui dan diff dicek
flutter build apk --debug
```
Jangan menjalankan `--update-goldens` otomatis hanya untuk membuat test hijau.

**Audit tambahan:** Screen width 320–430dp, tablet, font scale 200%, TalkBack semantics, route back navigation, empty/loading/error/offline, contrast dan screenshot per referensi tersedia.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Perbaiki seluruh overflow, state/semantics, keyboard/safe area, warna dan komponen tidak konsisten, lalu re-run widget + golden regression.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** Tidak ada critical UX issue; hasil visual/functional test dapat direproduksi. NEXT: 02.

**Artefak wajib:** Implementasi riil, perubahan kode/tes/dokumen, bukti pengujian, laporan fase, dan `KNOWN_ISSUES.md` yang diperbarui.

Simpan laporan `docs/phase-reports/PHASE_01C_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---


## Phase 02 — Domain data dan penyimpanan lokal

**Tujuan:** Jadikan audit/session/source/evidence benar-benar persist secara lokal tanpa akun atau cloud. Gantikan state simulasi UI dengan repository yang berfungsi.

### READ — pahami repository dan prasyarat

Periksa model domain PRD, route S14/S19/S24, layer repo dari UI, guest-first constraints, status migrasi DB.

**Prasyarat khusus:**

- Phase 01C/UX baseline cukup stabil.
- Tidak perlu ONNX atau API cloud; jangan menambah service key.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Definisikan entity IDs, schema Drift/SQLite, migration versioning, provenance hash, source lifecycle, deletion semantics, transactions, test fixtures.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

1. Implementasikan entity yang diuraikan PRD: `AuditSession`, `AppPermissionSnapshot`, `DocumentSource`, `DocumentSegment`, `ConsentUiSource`, `EvidenceReference`, `UserAction`, `AnalysisRun` (`unavailable` sebelum ONNX), `ReportRecord`, `PrivacyPreferences`.
2. Gunakan SQLite/Drift dengan schema migrations versi, referential integrity, timestamps, hash sumber, provenance page/frame, tombstone/delete; simpan file lokal di app-private storage.
3. Repository+Cubits menyediakan create/resume audit S24/S14, attach/detach sumber, delete cascade aman, summary riwayat S03/S19, source review states.
4. Rehydrate draft setelah kill/restart. Mode guest tidak wajib punya user cloud. Jangan membuat contoh audit otomatis pada build produksi.
5. Sediakan interface `AnalysisEngine` dan implementasi `UnavailableAnalysisEngine` dengan alasan jelas; hasil on-device belum tersedia.
6. Buat migration, CRUD, cascade delete, hash/path validation, concurrency tests termasuk raw evidence tidak muncul di log.
7. Migrasi preferensi cloud opt-in=false dan camera permission JIT tetap dipertahankan.

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

- Real user bisa membuat sesi audit, menyimpan draft, merestart aplikasi, melanjutkan, menghapus; dashboard counter berubah dari data nyata.
- 100% migration tests yang dapat dijalankan lulus; sumber tidak menjadi yatim saat delete.
- No phantom `AnalysisRun.success` sebelum model nyata.

**Pengujian wajib yang relevan:**

```bash
flutter analyze
flutter test test/data/      # sesuaikan dengan source aktual
flutter test
flutter build apk --debug
```
Skenario manual: create → attach → restart → resume → delete → counter nol.

**Audit tambahan:** Tes create/edit/delete/resume audit offline setelah restart, migration upgrade, rollback/failure states, source attachment, record association and correct counts.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Perbaiki foreign keys, race conditions, data loss, corrupt migrations, state hydration, hash/provenance dan query/filter issue, tambahkan regression.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** Audit lokal nyata dapat dibuat, dilanjutkan dan dihapus secara aman tanpa cloud. NEXT: 03.

**Artefak wajib:** Implementasi riil, perubahan kode/tes/dokumen, bukti pengujian, laporan fase, dan `KNOWN_ISSUES.md` yang diperbarui.

Simpan laporan `docs/phase-reports/PHASE_02_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---


## Phase 03 — Pemeriksa izin aplikasi Android

**Tujuan:** Buat pemeriksaan izin aplikasi Android yang nyata dan terbatas sesuai visibilitas PackageManager; tidak mengubah izin aplikasi pihak ketiga.

### READ — pahami repository dan prasyarat

Audit Android SDK/toolchain aktual, manifest, package visibility, Kotlin/Flutter channel contracts, policy permission dan available Android test device.

**Prasyarat khusus:**

- Phase 02 local domain PASS.
- Harus ada perangkat Android nyata atau emulator yang bisa menunjukkan scope package visibility; jika tidak tersedia, laporkan device acceptance sebagai `NOT_RUN`.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Rancang hasil snapshot package-permission yang OS benar-benar mengizinkan dengan timestamp, unknown status dan Settings intent; jangan gunakan paket nonvisible.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

1. Implementasikan Kotlin MethodChannel/Pigeon atau plugin native yang mereturn launcher-visible installed apps, package id, version, requested permissions, grant flags yang benar-benar dapat diketahui OS, `snapshot_time`, dan error code.
2. Terapkan package visibility sesuai kebijakan Android yang terbaru/yang benar-benar terverifikasi. Hindari `QUERY_ALL_PACKAGES` untuk aplikasi consumer jika tidak benar-benar dibutuhkan dan layak menurut kebijakan store.
3. Handle Android API level/perubahan visibility; empty list bukan klaim tidak ada aplikasi; tunjukkan penjelasan batas akses.
4. Flutter S04 menampilkan daftar aplikasi tampak + pencarian + refresh, S05 detail izin status `Diberikan`, `Belum diberikan`, `Tidak tersedia` sesuai API.
5. Intent ke Settings sistem untuk pengguna mengubah izin sendiri; KONSENA tidak pernah mengubah permission pihak ketiga.
6. Persist snapshot ke SQLite dengan provenance dan timestamp; dukung package uninstalled dan permission label unknown.
7. Unit Kotlin test jika mungkin, Flutter platform fake contract tests, snapshot schema tests, device matrix.

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

- User dapat melihat permission snapshot nyata minimal pada satu perangkat Android dan membuka Settings OS.
- UI tidak mengklaim tracking real-time permission usage atau membaca paket di luar visibility.
- Fallback APIs, query restrictions, error cases terdokumentasi, tidak meminta privilege berlebihan.

**Pengujian wajib yang relevan:**

```bash
flutter analyze
flutter test
cd android && ./gradlew test && cd ..  # bila Gradle wrapper ada
flutter build apk --debug
```
Manual device: pilih app nyata, cek requested+grant terhadap Settings, refresh, uninstall case. Catat Android API level.

**Audit tambahan:** Bandingkan native result dengan Settings di device/API nyata, refresh, uninstall, nonvisible package, denied grant; Kotlin tests, Flutter contract tests, build.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Perbaiki native bridge, null mapping, API compatibility, visibility disclosure dan Settings routing. Jangan meminta `QUERY_ALL_PACKAGES` demi lulus manual test.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** Snapshot Android nyata diverifikasi di perangkat tersedia; tanpa device, status BLOCKED untuk gate perangkat. NEXT: 04.

**Artefak wajib:** Implementasi riil, perubahan kode/tes/dokumen, bukti pengujian, laporan fase, dan `KNOWN_ISSUES.md` yang diperbarui.

Simpan laporan `docs/phase-reports/PHASE_03_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---


## Phase 04 — Impor kebijakan dan OCR

**Tujuan:** Buat impor Privacy Policy/Terms yang benar-benar dapat diproses dari file atau teks, dengan kutipan/halaman yang traceable.

### READ — pahami repository dan prasyarat

Periksa file picker/SAF Android, PDF parser/OCR libraries yang benar-benar kompatibel, source/evidence schema dan halaman S07/S11/S25/S26/S28.

**Prasyarat khusus:**

- Phase 02 local data PASS, UI S07/S11/S25/S26/S28 tersedia.
- Model AI ONNX **tidak** dibutuhkan. OCR lokal diterapkan menggunakan library/platform yang telah dicek kompatibilitasnya.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Susun pipeline PDF text layer lebih dulu, OCR fallback on-device, bahasa Indonesia/Inggris, limits file, segment offsets/hash, recovery password/corrupt.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

1. Implementasikan Android file picker/SAF import dengan MIME allowlist/size cap; handle file hilang, tidak bisa dibaca, password PDF, corrupt, terlalu besar, revoke URI permission.
2. PDF born-digital: extract text first, simpan page number dan raw text boundaries; PDF hasil scan: render page ke image dengan batas memori lalu OCR fallback yang teruji; input gambar tunggal via OCR; input teks manual.
3. Teks Indonesia dan Inggris; normalisasi whitespace yang tidak menghapus bukti, paragraph breaks, provenance `(source_id, page, bounding box/segment if available)`.
4. Editor S11 untuk koreksi user, track edit/review timestamp, serta idempotent save; jangan menganggap OCR tanpa verifikasi adalah hasil hukum.
5. S14 attach source ke audit dengan source type `privacy_policy` vs `terms` berbeda, versi/URL bila diketahui; jangan auto-associate dokumen ke aplikasi yang salah.
6. Unit tests parser + fixtures yang dapat dipakai dalam repo; UI progress/cancel/retry; no document leakage via logs.
7. Hasilnya boleh dipakai untuk manual reading/export, namun analisis AI tetap unavailable.

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

- Born-digital PDF, scanned PDF, image, plain text bisa diproses sesuai toolchain.
- Corrupt/password/oversize/empty/file missing memperlihatkan pesan dan recover, tidak crash.
- Setiap paragraph disimpan bersama sumber dan page; user dapat koreksi dan resume.

**Pengujian wajib yang relevan:**

```bash
flutter analyze
flutter test test/features/policy_import/  # sesuaikan
flutter test
flutter build apk --debug
```
Uji fixture: PDF text, PDF scan, JPG/PNG, pasted text, corrupt PDF, password, oversize.

**Audit tambahan:** Uji text PDFs, scanned PDFs, corrupted/password protected, image, long documents, different encodings, source quotations and correction flow.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Perbaiki OCR offset/provenance, misleading extraction, cancellation, OOM, mime errors, encoding, editing persistence dan progress state.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** Impor dan review teks bekerja dengan sumber jelas, kegagalan tertangani. NEXT: 05.

**Artefak wajib:** Implementasi riil, perubahan kode/tes/dokumen, bukti pengujian, laporan fase, dan `KNOWN_ISSUES.md` yang diperbarui.

Simpan laporan `docs/phase-reports/PHASE_04_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---


## Phase 05 — LiveScan kamera dan rekonstruksi teks

**Tujuan:** Implementasikan LiveScan sesuai PRD: kamera ponsel memotret Terms/Privacy Policy pada **monitor laptop fisik** saat pengguna scroll manual. Fokus pada provenance, overlap dan gap handling, bukan AI classifier.

### READ — pahami repository dan prasyarat

Periksa camera APIs, lifecycle, frame sampling, quality/ROI state, OCR output model, source security, rute LiveScan dan contoh penggunaan layar laptop.

**Prasyarat khusus:**

- Phase 04 OCR pipeline sudah bekerja.
- Perlu perangkat Android berkamera dan monitor/laptop nyata untuk acceptance; bila tidak ada, tidak boleh klaim device gate lulus.
- Jangan gunakan MediaProjection, screen capture internal ponsel, atau mengendalikan scroll laptop tanpa kebutuhan.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Rancang sequence permission just-in-time, ROI manual/autodetection, capture stride, overlap de-dup, scroll gaps, pause/resume dan cost battery.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

1. S39 tutorial: pengguna posisikan kamera di depan layar laptop, scroll perlahan, pencahayaan/glare, izin camera JIT. S35 recovery untuk denied/permanent denied.
2. S08 camera preview, ROI editable crop/perspective quadrilateral, indikator focus/glare/stability, buffer size, privacy safe recording.
3. S09 capture scheduler dengan dedupe OCR, background isolate bila kompatibel, pause/resume/finish, scroll-gap warning, progress berbasis segment terambil (bukan persentase keseluruhan dokumen yang tak diketahui).
4. S10 stitching: character/token overlap fuzzy alignment, confidence bounds, keep all source segments+frame timestamp and ROI; suspect gap disimpan, jangan menyisipkan paragraf hasil imajinasi.
5. S27 pemeriksaan missing sections; S11 OCR review/edit, re-scan subset, konfirmasi final; audit source join S14.
6. Tahan battery/thermal/memory; camera release on dispose; stop capture on app background/permission revoked; hindari penyimpanan raw frame tanpa kebutuhan dan consent.
7. Unit test overlap/no-overlap/duplicates/reordering; integration real device slow/fast scroll, glare, low light, rotation, interrupted permission.

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

- Dapat mendemonstrasikan scan nyata dari layar laptop, scroll menghasilkan dokumen teks terurut plus provenance.
- Fast scroll/nonoverlap menampilkan gap, bukan diam-diam menyatakan lengkap.
- Pause/resume, cancel, retry, frame retention dan camera cleanup berjalan; abnormal cases dicatat jujur.

**Pengujian wajib yang relevan:**

```bash
flutter analyze
flutter test
flutter build apk --debug
```
Catat uji perangkat fisik dengan Android version, model, jarak kamera-monitor, durasi, jumlah segment, gap count, sample OCR corrections. Tanpa device = device gate `NOT_RUN`.

**Audit tambahan:** Tes pemindaian nyata monitor laptop: ROI, scroll, reordering, gap uncertain, editing, pause/resume, low light, disposal camera; catat device specs.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Perbaiki frame leaks, duplicate clauses, wrong ordering, gap false certainty, camera denial/crash, thermal runaway; buat evidence fixtures & regression tests.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** LiveScan end-to-end perangkat nyata dan verifikasi gap teruji. Tanpa physical camera device, BLOCKED. NEXT: 06.

**Artefak wajib:** Implementasi riil, perubahan kode/tes/dokumen, bukti pengujian, laporan fase, dan `KNOWN_ISSUES.md` yang diperbarui.

Simpan laporan `docs/phase-reports/PHASE_05_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---


## Phase 06 — Consent UI, evidence dan rekomendasi

**Tujuan:** Sediakan bukti yang dapat diperiksa pengguna dan action center berbasis fakta. Dark-pattern/ConsentGap AI belum diklaim aktif.

### READ — pahami repository dan prasyarat

Pelajari S12/S13/S14–S17/S29–S32/S38, Evidence store, hasil OCR, dokumen policy, batas klaim ML dan UU PDP.

**Prasyarat khusus:**

- Phase 02 repository dan Phase 04 sumber dokumen tersedia; Phase 05 LiveScan idealnya selesai.
- ONNX masih belum tersedia. Hasil CV/ML harus unavailable, bukan dummy.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Rancang screenshot ROI/edit, provenance per kutipan, aturan rekomendasi netral, UI unknown/missing evidence, intent ke Settings OS.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

1. S12 screenshot permission/consent import dengan crop/rotate/edit metadata dan user-provided source; jangan mengintip layar aplikasi pihak ketiga secara otomatis.
2. S13 manual annotation elemen seperti tombol setuju/tolak, checkbox, teks tujuan, label evidence; hasil manual dibedakan dari deteksi AI.
3. S14 workspace membandingkan keberadaan sumber Android/Policy/Terms/Screenshot, association audit, mismatch source/date/version dan incomplete states.
4. S15 summary faktual dari permission snapshot + klausa hasil OCR; S29 ConsentGap dan S31 Dark Pattern menampilkan `Analisis AI belum tersedia` hingga fase 09.
5. S16 evidence explorer menampilkan quote persis, page/segment/frame/screenshot origin, koreksi user, timestamp dan sumber; `sourceId` missing ditangani.
6. S17/S32 recommendations berbasis aturan netral yang benar-benar dapat dikerjakan (buka Settings Android, cek izin, baca policy, koreksi OCR, hapus source), **bukan** vonis pelanggaran hukum.
7. Validasi setiap generated report finding memiliki provenance/trace; audit false positive sources di test.

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

- Screenshot import/edit menyimpan evidence yang dapat dibuka ulang.
- Tiap kutipan punya tautan asal; rekomendasi action benar-benar membuka lokasi/halaman yang relevan.
- Tidak ada `dark pattern detected`, `risk 95%`, atau label `melanggar UU PDP` tanpa data/model dan expert validation.

**Pengujian wajib yang relevan:**

```bash
flutter analyze
flutter test
flutter build apk --debug
```
Test missing evidence, screenshot delete, crop bounds, edit history, model unavailable UI and OS Settings action.

**Audit tambahan:** Cek setiap quote kembali ke sumber, deletion cascade, audit tanpa dokumen lengkap, tanpa ML, crop bounds, states dan aksi ke OS Settings yang benar.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Perbaiki orphan evidence, source link, misleading compliance labels, null-case, dark pattern fabricated, action intents, delete privacy issues.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** Evidence and action berbasis sumber tersimpan; tidak ada klaim AI palsu. NEXT: 07.

**Artefak wajib:** Implementasi riil, perubahan kode/tes/dokumen, bukti pengujian, laporan fase, dan `KNOWN_ISSUES.md` yang diperbarui.

Simpan laporan `docs/phase-reports/PHASE_06_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---


## Phase 07 — Laporan PDF, histori dan cloud opt-in

**Tujuan:** Selesaikan pengalaman offline-first end-to-end: riwayat audit, laporan PDF berbasis fakta, bagikan, ekspor/hapus data, serta **implementasi sync Supabase berdasarkan fondasi migrasi, RLS, Storage, dan client dari Phase 00**. Aktivasi cloud oleh pengguna selalu opt-in.

### READ — pahami repository dan prasyarat

Audit migrasi/policies Supabase Phase 00, cloud auth gateway, local DB, consent settings, halaman S18/S19/S20/S21/S22/S33/S34/S36/S37.

**Prasyarat khusus:**

- Phase 06 evidence dan actions selesai.
- Phase 00 sudah membuat konfigurasi dan migration awal Supabase. Audit schema, policy, dan laporan Phase 00 terlebih dahulu. Jika project remote atau credential belum tersedia, selesaikan alur offline; laporkan cloud sebagai `BLOCKED/NOT_CONFIGURED`. Jangan membuat dummy URL atau mengganti migration lama diam-diam.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Definisikan report source-aware, opt-in upload contracts, cloud metadata minimization, sync queue/idempotency, conflict/deletion, test owner isolation.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

1. S18 report preview, S33 export/share PDF Android dengan metadata tanggal/sumber lengkap, status belum dianalisis jika ONNX belum ada; no fake score/AI insights.
2. S19 history dan S34 resume/detail audit, filter, search, delete confirmation, undo jika aman; semua bersumber SQLite.
3. S20/S36 privacy controls: lihat data tersimpan, retensi, ekspor terpilih, hapus audit dan seluruh data lokal terverifikasi; protect sensitive logs/export.
4. S21 `/profile` guest berfungsi penuh untuk storage/privacy/about; OTP/login hanya opt-in. S22 sync pilihan sumber satu per satu, default raw documents/screenshots excluded; cloud opt-in false.
5. Gunakan tabel cloud, RLS dan private bucket yang telah disiapkan Phase 00; tambahkan **migration incremental** bila schema perlu diperluas. Implementasikan OTP/login opt-in, session restore, explicit upload selection dan preview, conflict resolver S37, retry/offline queue, logout, serta delete propagation. Jangan membangun ulang atau menonaktifkan policies yang telah diuji. Tidak menyimpan service-role key dalam Flutter.
6. Uji unauthorized user A tidak baca/tulis audit user B (hanya jika backend benar-benar dikonfigurasi). Simulasi konektivitas offline, token expired, upload partial.
7. Jangan mengirim audit data sensitif ke telemetry secara default.

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

- Mode guest bisa menyelesaikan create/audit/source/recommendation/report/export/delete sepenuhnya offline.
- PDF memuat sumber dan status model yang benar; report tidak menyalin data yang telah dihapus.
- Jika sync aktif, user consent eksplisit + RLS user A/B tests terhadap deployment yang dituju, dan tidak ada upload sebelum opt-in. Jika inactive, UI tetap bekerja dan statusnya jelas. Phase 00 setup ≠ Phase 07 sync feature.

**Pengujian wajib yang relevan:**

```bash
flutter analyze
flutter test
flutter build apk --debug
```
Test PDF reader/manual share intent, data delete, user A/B RLS if enabled, offline restart, logout/guest state.

**Audit tambahan:** Cek PDF offline, share intent, delete all local copies, guest continuity, no silent sync, RLS user A/B, object storage isolation, retry/token expired/offline.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Perbaiki kebocoran auth/data, ghost records, upload without consent, conflict overwrite, private bucket ACL, PDF misstatement, delete propagation.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** Report/history/privacy offline PASS. Cloud sync hanya PASS jika remote telah divalidasi dan kasus keamanan lulus; bila remote tidak ada, CLOUD_BLOCKED dan jangan mengklaim fitur synced siap. NEXT: 08 hanya dengan scope tercatat dan tanpa critical privacy blocker.

**Artefak wajib:** Implementasi riil, perubahan kode/tes/dokumen, bukti pengujian, laporan fase, dan `KNOWN_ISSUES.md` yang diperbarui.

Simpan laporan `docs/phase-reports/PHASE_07_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---


## Phase 08 — Stabilisasi, keamanan dan aksesibilitas

**Tujuan:** Audit produk sebelum ML agar seluruh workflow non-ML dapat bekerja stabil di Android; jangan menunda bug dasar sampai ONNX.

### READ — pahami repository dan prasyarat

Audit seluruh report 00–07, known issues, manifest, package licenses, privacy statements, device & UI test matrix.

**Prasyarat khusus:**

- Phases 00–07 sudah selesai atau ada daftar gap secara eksplisit; jika critical blockers, jangan klaim release candidate siap.
- ONNX masih tidak diintegrasikan.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Prioritaskan perbaikan issue P0/P1, scope pre-ML, perf/camera energy budget, security and Android Store release requirements aktual.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

1. Test audit route S00–S39, offline-first guest journey, Android permissions, PDF imports, camera LiveScan, screenshot evidence, PDF report, data deletion.
2. Profiling cold start, memory while OCR+camera, battery/thermal yang bisa diukur; capture logs redacted, dispose resources.
3. Accessibility full pass TalkBack/200% font/high contrast/target 48dp/safe area; fix overflow per screen width.
4. Security review: secrets, file storage, telemetry, Android manifest permissions, SDK levels, cleartext network, Supabase RLS where enabled, export/share privacy.
5. Verify status UI for unavailable model, unsupported permission visibility, incomplete source and uncertain OCR.
6. Review external package licenses, policy disclosures, Android store requirements aktual dari dokumen resmi saat release.
7. Update CI/test fixtures/goldens only after visual review; save checklist of known manual-device gates.

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

- Zero known critical blockers in implemented scope; every waived issue has severity and rationale.
- Tests show reproducible results, not only text claims.
- No shipping placeholder AI risk scores, false legal compliance or silent data cloud uploads.

**Pengujian wajib yang relevan:**

```bash
flutter analyze
flutter test
flutter build apk --debug
flutter build appbundle  # hanya jika signing/config tersedia
```
Manual physical devices 4/6/8GB jika benar tersedia; jika tidak, catat `NOT_RUN` by device class.

**Audit tambahan:** Jalankan full test/physical QA, cold start/camera memory/perf, accessibility, private data exposure, Android manifest, RLS when cloud enabled, source evidence integrity.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Tutup critical bugs, secret leak, log PII, UI false claims, battery/thermal/resource leaks, permission/visibility overreach; ulang full regression.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** Pre-ML release candidate tanpa known P0/P1, semua fitur yang ditandai shipped lolos. NEXT: 09.

**Artefak wajib:** Implementasi riil, perubahan kode/tes/dokumen, bukti pengujian, laporan fase, dan `KNOWN_ISSUES.md` yang diperbarui.

Simpan laporan `docs/phase-reports/PHASE_08_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---


## Phase 09 — Integrasi ONNX dengan gate artefak asli

**Tujuan:** Integrasikan hanya **model nyata terlatih** dari pipeline Kaggle setelah paket model, tokenizer, preprocessing, label mapping, manifest, test vectors dan evaluation tersedia. Fase ini tidak boleh dipaksakan jika artefak belum ada.

### READ — pahami repository dan prasyarat

Verifikasi artefak ONNX training asli, tokenizer/vocab/normalisasi, label mapping, tensor signatures, model card, goldens dan evaluasi publikasi; periksa hak cipta/license.

**Prasyarat khusus:**

**Gate model penuh:** jika artefak di bawah belum ada, hentikan integrasi ONNX, catat `NOT_APPLICABLE_MODEL_NOT_DELIVERED` (pre-ML pilot saja), lalu jalankan Phase 10 dengan seluruh fitur AI dinonaktifkan. Jangan klaim Phase 09 PASS:
- File `model.onnx` NLP/CV yang asli dari training terverifikasi, bersama model hash/version dan sumber dataset/catatan evaluasi.
- Tokenizer/vocab/normalization yang **exact match** dengan model NLP asli.
- Label mapping, threshold calibration, postprocess, output shape/type, golden input/output vectors.
- Model card termasuk batasan bahasa/domain, makro-F1/precision/recall dan sumber evaluasi yang nyata.
- Preprocess OCR/vision image dan tensor spec untuk CV bila komponen CV hendak diaktifkan.

Jika belum ada, jangan download model acak, buat output random, hardcode label, atau mengklaim prediksi sukses. Laporkan kebutuhan artefak dan berhenti.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Susun adapter ONNX + fallback, parity tolerance, tensor mapping, evidence binding, model gates terpisah untuk NLP/CV, resource limits.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

1. Inspect signatures ONNX aktual (names/shapes/dtypes/dynamic axes), model manifests, golden test vectors dari notebook dan lisensi.
2. Adapter Kotlin ONNX Runtime Android (atau runtime compatible yang terbukti) melalui interface `AnalysisEngine` yang sudah ada; mode fallback `UnavailableAnalysisEngine` jika model gagal dimuat.
3. Implement exactly tokenizer/preprocess/normalization pipeline dari Kaggle; `input_ids`, attention mask, token type, image tensor, coordinate transform **hanya** jika sesuai signature model.
4. Pasangkan hasil NLP policy clauses dan source matching ke evidence references, bukan hanya label tanpa sumber. Score dan uncertainty calibration wajib terdokumentasi.
5. Pipeline ConsentGap NLI didasarkan pada klausa sumber yang relevan, metadata app/izin dan screenshot hanya bila tersedia; missing evidence -> `bukti belum mencukupi`.
6. Dark-pattern visual classifier dinyalakan **hanya** jika CV model asli + test valid; jangan memanfaatkan hasil manual seakan output model.
7. Benchmark Android memory/latency/thermal dengan device metrics sesungguhnya, kesetaraan hasil (parity) melawan original Kaggle test vectors dalam toleransi yang ditulis.
8. A/B runtime disable flags, rollback model, update model card/privacy docs/report fields.

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

- Parity test pada golden vectors lulus toleransi eksplisit atau status FAIL tanpa mengarang.
- Semua label output dikaitkan ke bukti; tidak ada temuan jika raw source tidak tersedia.
- Runtime failure -> graceful fallback, tanpa membatalkan riwayat audit lokal.
- Model ML legal/privacy findings tidak dinyatakan sebagai kepastian hukum.

**Pengujian wajib yang relevan:**

```bash
flutter analyze
flutter test
flutter build apk --debug
```
Tambahkan pipeline parity tests dari test vectors nyata, run di emulator/device yang tersedia dan catat metrics riil. Jangan meluluskan hanya dari fake/mock ONNX.

**Audit tambahan:** Uji golden vectors/model parity, sumber evidence, policy compliance claims, failover, Android latency/memory/thermal, legal/privacy wording.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Perbaiki mismatch tensor/tokenization/labels/threshold, crash/fallback, unsupported languages, source-binding dan regression. Jangan buat model palsu.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** ML FULL hanya PASS dengan artefak valid dan parity/device tests. Jika artefak tidak ada, jangan jalankan BUILD palsu: catat NOT_APPLICABLE_MODEL_NOT_DELIVERED dan lanjut hanya jalur pre-ML pilot yang menyembunyikan semua klaim AI. NEXT: 10.

**Artefak wajib:** Implementasi riil, perubahan kode/tes/dokumen, bukti pengujian, laporan fase, dan `KNOWN_ISSUES.md` yang diperbarui.

Simpan laporan `docs/phase-reports/PHASE_09_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---


## Phase 10 — Pilot dan rilis Android

**Tujuan:** Siapkan release KONSENA AI berdasarkan fitur yang benar-benar selesai, uji pilot pengguna, transparansi privasi dan bukti pengujian. Release tidak boleh menjanjikan AI jika Phase 09 masih blocked.

### READ — pahami repository dan prasyarat

Review 00–09 reports, app functional claims, release toolchain/signing, Play policy, privacy data safety, pilot evidence and outstanding blockers.

**Prasyarat khusus:**

- Phase 08 pre-ML product PASS; Phase 09 optional hanya bila model benar-benar available dan tested.
- Tidak boleh klaim AAB sudah diupload/disetujui store kecuali operator melakukan tindakan tersebut.

### THINK — rumuskan keputusan teknis sebelum mengubah kode

Putuskan scope resmi `PRE_ML_PILOT` atau `FULL_ML_RELEASE`, jadwalkan test matrix, release notes, artifacts dan support flow yang sesuai fakta.

Tuliskan **ringkasan rencana nyata** di laporan fase: modul/berkas yang akan disentuh, dependency yang dipakai, penyebab risiko, test plan dan rollback. Jangan mengimplementasikan fase lain dalam proses ini.

### BUILD — implementasikan tugas fase ini

1. Buat release scope matrix (feature shipped/disabled/experimental), known limitations, release notes, privacy-policy draft dan support flow.
2. Pilot test script: first launch, guest privacy setup, pilih app, capture permission, import policy, LiveScan, attach source, evidence, report, delete.
3. Siapkan feedback non-sensitive, usability metrics, crash reporting opt-in bila diterapkan, bug triage, accessibility check.
4. Audit keamanan produksi: signing keystore tidak masuk repo, environment secrets, RLS & storage, backup/retention/deletion, Android manifest + Play privacy declarations.
5. Generate APK/AAB hanya jika signing/toolchain tersedia; catat hash/checksum build dan test evidence.
6. Review readme/installation/manual QA/capture screenshots yang berasal dari app sebenarnya. Jangan gunakan screenshot prototipe sebagai screenshot aplikasi yang telah dibangun.
7. Jika model belum ada, AI tabs tetap unavailable dan marketing copy tidak menyebut deteksi selesai; rilis boleh ditunda/ditandai pre-ML pilot.
8. Serahkan backlog pasca-pilot dan batasan evaluasi, termasuk rekomendasi dataset benchmark bukan klaim validasi tanpa eksperimen.

### REVIEW — verifikasi implementasi terhadap spesifikasi

**Acceptance criteria:**

- Release docs lengkap dan konsisten dengan fakta implementasi, risiko/legal scope tidak overclaim.
- Pilot test dicatat hasil sebenarnya dan bug severity.
- APK/AAB hanya diklaim sukses jika command beneran lulus; tidak ada kredensial dalam file artefak.
- Pengguna bisa menggunakan fitur yang dinyatakan shipped tanpa pembatas login yang tidak perlu.

**Pengujian wajib yang relevan:**

```bash
flutter analyze
flutter test
flutter build apk --release   # bila konfigurasi release tersedia
flutter build appbundle --release # bila signing tersedia
```
Sertakan SHA-256 artefak jika benar-benar dihasilkan, release artifact naming, serta status `NOT_RUN` untuk upload Store yang tidak dilakukan.

**Audit tambahan:** Jalankan final lint/test/build release, pilot acceptance scenarios real, manifest+secrets scan, verify signing/keystore, SHA256 output, privacy docs, evidence links.

Lihat `git diff --check`, periksa diff kode, isu keamanan, scenario negatif, dan hasil tes aktual. Jangan berasumsi PASS dari kode yang tampak benar.

### FIX — perbaiki, tes ulang, lalu REVIEW lagi

Tutup blocker pilot/production, perbaiki test/release, hapus klaim fitur atau hasil uji yang tidak didukung bukti, update release notes dan known limits; jangan publish/store tanpa izin.

Untuk setiap FAIL/P0/P1: tulis gejala → akar masalah → perubahan → regression test → hasil REVIEW terbaru. Jika semua tes mandatory PASS, jangan membuat perubahan dekoratif yang tidak terkait fase.

### GATE — keputusan lanjut fase berikutnya

**Ketentuan kelulusan:** Dokumen handoff, APK/AAB yang benar-benar terbangun bila toolchain tersedia, pilot evidence jujur. Jika signing/Play/hardware belum tersedia, status BLOCKED untuk rilis publik, bukan DONE palsu.

**Artefak wajib:** Implementasi riil, perubahan kode/tes/dokumen, bukti pengujian, laporan fase, dan `KNOWN_ISSUES.md` yang diperbarui.

Simpan laporan `docs/phase-reports/PHASE_10_REPORT.md` dan update `PHASE_STATUS.md` + `KNOWN_ISSUES.md`. Jika `PASS`, lanjut hanya ke fase berikutnya berdasarkan tabel urutan. Jika `FAIL` → FIX → REVIEW; jika `BLOCKED` → STOP; jangan lompat fase.

---

## 4. Checklist akhir semua fase — syarat penyerahan, bukan asumsi

Setelah Phase 10 benar-benar selesai/terblokir:

1. Verifikasi status **setiap fase** di `docs/phase-reports/PHASE_STATUS.md` serta tautan ke bukti tes, jangan mengubah BLOCKED menjadi PASS untuk tampilan bagus.
2. Lampirkan ringkasan source directory, migration yang diterapkan, daftar test dan output, matriks S00–S39, status perangkat Android, status database remote, model ONNX, dan laporan security/privacy.
3. Jelaskan scope akhir dalam satu label: `PRE_ML_PILOT`, `FULL_ML_RELEASE`, atau `BLOCKED`. Hanya gunakan `FULL_ML_RELEASE` bila parity ONNX berhasil dan fitur dinyatakan siap secara nyata.
4. Informasikan file APK/AAB **hanya jika dibuat**, nama berkas dan SHA-256 asli; jangan menciptakan tautan atau membuat klaim publikasi Play Store tanpa bukti.
5. Cantumkan daftar keterbatasan / pengujian manual tersisa dan tindakan operator yang perlu dilakukan. Tidak memerlukan prompt baru untuk membuat ringkasan; tetapi semua tindakan berdampak ke remote/produksi tetap memerlukan otorisasi pengguna.

**Instruksi akhir untuk Claude Code:** Mulailah sekarang dari **Phase 00 → READ**, lanjutkan secara **sekuensial** hanya pada gerbang yang benar-benar PASS. Untuk setiap fase wajib **READ, THINK, BUILD, REVIEW, FIX** dan uji ulang sampai aman atau sampai harus BLOCKED. Jangan pernah mempercepat dengan melewati REVIEW/FIX, mengisi tes palsu, melanjutkan melewati blocker, atau mengeksekusi seluruh fase paralel.
