# KNOWN_ISSUES — KONSENA AI

Diperbarui 2026-11-08 untuk Phase 06 Terpadu.
Aturan: isu tidak disembunyikan. Setiap entri memuat severity, gejala,
reproduksi, solusi/owner, dan status.

Severity: **P0** = keamanan/privasi atau data, **P1** = menghalangi gate fase,
**P2** = penghambat kenyamanan/teknis.

**Review Phase 01A:** tidak ada isu P0/P1 baru yang terbuka dari implementasi
UI. Overflow S03 yang ditemukan golden test sudah diperbaiki dan regression
golden lulus. P0-001 dan P1-002 di bawah tetap terbuka sebagai catatan operator
dan prasyarat khusus sebelum Phase 07; keduanya tidak dihapus atau dianggap
selesai oleh kelulusan gate UI.

**Review awal Phase 01B:** automated test dan build lulus; pada saat itu gate
tertahan oleh pemeriksaan visual browser headless yang gagal merender. P1-004
kemudian ditutup setelah headed browser verification; bukti dicatat pada laporan
Phase 01B dan entri isu di bawah.

**Review Phase 01C:** automated suite (74/74), golden/screenshot matrix,
analyze, formatter, diff check, dan APK debug build lulus. Verifikasi headed
browser kini PASS dan P1-004 ditutup. Pemeriksaan TalkBack/device nyata tetap
NOT_RUN dan ditunda atas arahan operator; bukan diklaim lulus. Phase 01C
difinalisasi PASS dengan penundaan tersebut. P1-005 dan P1-006 (ditemukan saat
audit ini) sudah fixed dan regression-tested.

**Review Phase 02:** local schema/repository, encrypted source storage, cascade
and recovery paths are implemented. Final analyze, 13 data tests, bounded local
restart flow, full suite (90 tests), formatter/diff checks, and APK debug build
all PASS. The reviewed S24 encryption notice golden was updated. APK build used
the process-local JDK 17 workaround (`JAVA_HOME=$HOME/develop/jdk17`); no
shell-profile change was made. Manual/device workflow and TalkBack remain
NOT_RUN; Phase 03 remains NOT_STARTED.

**Review Phase 03:** Phase 02 prerequisite is PASS. Latest implementation is
installed on Samsung SM-A556E, Android API 36. A real `jalanku` snapshot was
partially compared with Settings and lifecycle return refresh was observed.
Full Flutter suite (97 tests), analyzer, latest APK build/install, full Gradle
suite under process-local Temurin 21.0.13, and device checks pass. An owned
CAMERA fixture verified granted/denied, Settings comparison, lifecycle refresh
and uninstall/requery without touching third-party apps. Phase 03 is PASS;
Phase 04 implementation is in progress; automated acceptance currently passes
and APK/device review is pending.

---

## P0-001 — Kredensial pernah berada di luar credential manager

| | |
|---|---|
| **Severity** | P0 |
| **Status** | **OPEN — rotasi wajib** |
| **Owner** | Operator / pemilik project Supabase |

**Gejala.** Tiga jenis rahasia project (`SUPABASE_DB_PASSWORD`,
`SUPABASE_ACCESS_TOKEN`/PAT, secret key) sempat berada di dalam konteks
percakapan agent sebelum mekanisme pembacaan lewat `sed` tanpa pencetakan
diterapkan. File `Kredensial.md` sendiri sudah masuk `.gitignore` dan tidak
pernah disalin ke laporan, tetapi nilai yang pernah keluar dari file tidak
dapat ditarik kembali dari riwayat percakapan.

**Reproduksi.** `git check-ignore -v Kredensial.md` menunjukkan file diabaikan;
`git log --all -- Kredensial.md` tidak menunjukkan apa pun (belum ada commit).
Risikonya bukan di Git, melainkan di salinan konteks percakapan.

**Solusi.** Rotasi bertahap, tanpa menyalin nilai baru ke chat/laporan/Markdown:

1. Ganti **database password** project `yjaerikykirxekukqfwu` (Dashboard →
   Settings → Database → Reset password).
2. **Revoke PAT lama** dan buat token baru dengan scope minimal
   (`database_write`, `projects_read`, `database_pooling_config_read`) di
   supabase.com/dashboard/account/tokens.
3. **Rotate secret key** project (Settings → API).
4. Setelah rotasi, perbarui `Kredensial.md` lokal saja, lalu jalankan ulang
   `supabase link --project-ref yjaerikykirxekukqfwu`.

**Catatan.** Publishable key (`sb_publishable_...`) **bukan** rahasia — memang
dirancang untuk klien publik dan dijaga oleh RLS. Tidak perlu dirotasi demi
keamanan, hanya jangan disamakan dengan key admin.

---

## P1-001 — Supabase local stack tidak dapat dijalankan

| | |
|---|---|
| **Severity** | P1 (untuk klaim lokal; **tidak** menghalangi Phase 00 PASS remote) |
| **Status** | **BLOCKED** |
| **Owner** | Operator mesin development |

**Gejala.** `npx supabase start` gagal; tanpa local runtime, `supabase db
reset` dan `supabase test db` mode lokal tidak dapat dijalankan.

**Reproduksi.**

```bash
npx supabase start
```

**Dampak.** `supabase start`, `supabase db reset` (local), dan `supabase test
db` (local) tercatat **`NOT_RUN/BLOCKED`** — bukan PASS. Skema dan RLS
divalidasi lewat jalur **remote**, yang statusnya dicatat terpisah.

**Solusi.** Menyediakan runtime kontainer di mesin ini, **atau** menerima bahwa
verifikasi lokal tetap `BLOCKED` selamanya dan hanya bukti remote yang dipakai.
Tidak ada salah satu yang boleh dilaporkan sebagai PASS.

---

## P1-002 — Remote project `pcrtssaxlvlvjyichive` tidak terjangkau

| | |
|---|---|
| **Severity** | P1 |
| **Status** | **OPEN — butuh keputusan operator** |
| **Owner** | Operator |

**Gejala.** PAT yang tersedia menolak project itu:
`Your account does not have the necessary privileges to access this endpoint`.
Project tersebut juga tidak muncul di `supabase projects list`.

**Reproduksi.**

```bash
SUPABASE_ACCESS_TOKEN=<token> npx supabase link --project-ref pcrtssaxlvlvjyichive
```

**Solusi.** Publikasi migrasi Phase 00 diarahkan ke `yjaerikykirxekukqfwu`
(`konsena_backup_progress`) sesuai persetujuan operator. Jika
`pcrtssaxlvlvjyichive` memang tujuan yang benar, buat PAT baru dengan scope
organization/project yang memadai, atau pindahkan ownership project ke akun ini.

---

## P1-003 — JDK tidak terdeteksi oleh Flutter (`JAVA_HOME` kosong)

| | |
|---|---|
| **Severity** | P1 (untuk build) |
| **Status** | **OPEN — workaround aktif** |
| **Owner** | Operator mesin development |

**Gejala.** `flutter doctor` melaporkan tidak ada toolchain Java, padahal JDK 17
ada di `~/develop/jdk17`.

**Reproduksi.** `flutter doctor | grep -i java`

**Solusi sementara.** Setiap perintah build dibungkus:

```bash
export JAVA_HOME="$HOME/develop/jdk17"
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="$HOME/develop/android-sdk"
```

**Solusi permanen.** Tulis `JAVA_HOME` ke shell profile mesin.

---

## P1-004 — Browser headless tidak menggambar Flutter Web

| | |
|---|---|
| **Severity** | P1 (Phase 01B visual gate) |
| **Status** | **RESOLVED — 2026-11-07; headed visual check PASS** |
| **Owner** | Operator / environment browser |

**Gejala.** `flutter build web` berhasil, tetapi Firefox ESR headless yang
membuka build statis menghasilkan halaman putih. Log browser:
`RenderCompositorSWGL failed mapping default framebuffer`. Tidak ada emulator
Android yang digunakan sesuai arahan; `flutter devices` hanya menampilkan Linux.

**Dampak awal.** Headless screenshot tidak dapat digunakan sebagai bukti. Ini
tidak membatalkan `flutter test` (74/74), `flutter analyze`, route smoke, atau
APK/Web build PASS. Gate 01B ditahan sampai headed visual check dilakukan.

**Verifikasi dan resolusi (2026-11-07).** Build web terbaru dibangun ulang,
kemudian dibuka di Firefox ESR headed pada X11 dengan profil sementara terpisah.
Konfigurasi GTK desktop memuat `window-decorations-gtk-module` yang gagal pada
Firefox (`undefined symbol gtk_module_display_init`); sesi uji menggunakan
`MOZ_ENABLE_WAYLAND=0`, `GDK_BACKEND=x11`, serta XDG GTK config sementara yang
menonaktifkan modul itu. Konfigurasi Firefox/GTK pengguna dan kode produk tidak
diubah.

**Regression / REVIEW.** Layar onboarding/privacy/home merender dengan app font
dan logo. S03 terlihat; perpindahan tab Audit Baru membuka S24, CTA S24 membuka
S04 child, dan tombol Back browser kembali ke S24. Screenshot aktual tersimpan
di `evidence/firefox_s03_1567x1028.png`,
`evidence/firefox_s04_child_1567x1028.png`, dan
`evidence/firefox_s24_after_browser_back_1567x1028.png`.

Firefox **headless** masih mengalami compositor error; masalah tersebut tidak
lagi memblokir gate karena jalur browser headed sudah terverifikasi. Emulator
Android tidak digunakan.

---

## P1-005 — CTA overflow dan tab labels terpotong pada 200% text scale

| | |
|---|---|
| **Severity** | P1 (aksesibilitas/viewport) |
| **Status** | **RESOLVED — 2026-11-07** |
| **Owner** | Phase 01C |

**Gejala.** Pada 320dp/200%, CTA S03 membuka S24 dengan RenderFlex overflow
154px; lima tab tidak overflow renderer tetapi label terbelah menjadi potongan
kata dan sulit dibaca.

**Akar.** Icon + long label dipaksa satu baris, dan tiap tujuan tab hanya
mendapat lebar sekitar 64dp.

**Perubahan.** Button kini membatasi lebar dan wrap label; ornamen icon
disembunyikan pada text scale besar. Bottom navigation memakai dua baris pada
200% dengan semantic label/action yang sama.

**Regression / REVIEW.** `test/features/responsive_ui_test.dart` di 320dp/200%
memastikan scroll, CTA ke S24, tanpa exception; `tab_semantics_test.dart`
memastikan semantic action dan target ≥48dp. Screenshot
`s03_dashboard_320_200pct.png` ditinjau; `flutter test` 74/74 PASS.

---

## P1-006 — Golden S01/S03 memakai glyph Ahem, bukan font aplikasi

| | |
|---|---|
| **Severity** | P1 (integritas bukti visual) |
| **Status** | **RESOLVED — 2026-11-07** |
| **Owner** | Phase 01C |

**Gejala.** Baseline S01/S03 menampilkan huruf dan ikon sebagai kotak/tofu;
gambar tidak valid untuk visual approval.

**Akar.** Golden tests menggunakan Ahem default Flutter test karena app fonts
tidak dimuat sebelum capture.

**Perubahan.** Test harness memuat family dan file font di `FontManifest.json`
sebelum screenshot; baseline resmi dan turunan screenshot direview lalu
diperbarui.

**Regression / REVIEW.** Screenshot baru menampilkan teks Plus Jakarta Sans dan
Material Icons yang terbaca; `flutter test test/goldens/visual_test.dart` PASS
tanpa update. UI baseline S01/S03 sudah dibaca manual melalui image viewer.

---

## P1-007 — Phase 03 device acceptance (RESOLVED)

| | |
|---|---|
| **Severity** | P1 (gate fase) |
| **Status** | **CLOSED — Phase 03 PASS** |
| **Owner** | Phase 03 implementation/review |

**Gejala.** Acceptance Phase 03 sempat tertahan saat READ awal tidak menemukan
device Android.

**Akar masalah.** Device baru tersambung/terotorisasi setelah probe READ awal;
verifikasi denied/uninstall memerlukan fixture sendiri agar tidak mengubah app
pihak ketiga.

**Perubahan / kondisi kini.** Samsung SM-A556E, API 36, serial `RRCY102L98L`;
APK terpasang. Snapshot jalanku (`id.jalanku.jalanku`) melaporkan
`ACCESS_FINE_LOCATION` granted, sesuai Settings. Fixture owned
`id.konsena.phase03_permission_fixture` juga membuktikan CAMERA granted vs
denied, lifecycle refresh, dan hilang dari S04 serta unavailable/historical di
S05 setelah uninstall. Tidak ada izin pihak ketiga yang diubah.

**Regression / REVIEW.** Device checks PASS dengan fixture disposable; full
Flutter suite (97 tests), analyze, APK build/install, full `./gradlew test`
(Temurin 21.0.13) dan `git diff --check` PASS. Tidak ada izin pihak ketiga yang
diubah; isu ditutup dan Phase 03 berstatus PASS.

---

## P2-001 — Distribusi Gradle 9.3.1 korup saat unduhan pertama

| | |
|---|---|
| **Severity** | P2 |
| **Status** | **CLOSED** (sudah diperbaiki) |
| **Owner** | — |

**Gejala.** `flutter build apk --debug` gagal dengan
`java.util.zip.ZipException: zip END header not found` selama ±20 menit.

**Akar masalah.** Berkas `gradle-9.3.1-all.zip` terpotong (121 MB, tanpa tanda
`.ok`), lalu wrapper mencoba unzip berkas yang tidak lengkap.

**Reproduksi / solusi.**

```bash
python3 -c "import zipfile; zipfile.ZipFile('$HOME/.gradle/wrapper/dists/gradle-9.3.1-all/*/gradle-9.3.1-all.zip')"   # BadZipFile
rm -rf ~/.gradle/wrapper/dists/gradle-9.3.1-all
flutter build apk --debug        # unduh ulang
```

---

## P2-002 — Koneksi IPv6 ke host database tidak stabil

| | |
|---|---|
| **Severity** | P2 |
| **Status** | **OPEN — workaround aktif** |
| **Owner** | Operator jaringan |

**Gejala.** `db.yjaerikykirxekukqfwu.supabase.co` hanya memiliki **AAAA**
(tanpa record A). Saat IPv6 mesin hilang, koneksi langsung gagal dengan
`ENETUNREACH 2406:.../5432`.

**Reproduksi.** `ip -6 route show default` → kosong, lalu coba koneksi ke host
database.

**Solusi.** Jalur yang terbukti: sambung ke **IPv4 pooler**
(`aws-0-ap-southeast-1.pooler.supabase.com` → `52.77.146.31`) dengan parameter
TLS `servername = db.<PROJECT_REF>.supabase.co`. Perlu dicatat bahwa klien `pg`
versi 8.x **menimpa** `servername` dengan `host`, sehingga `servername` hanya
dipertahankan bila `host` berupa alamat IP — inilah alasan koneksi memakai IP
literal.

---

## P2-003 — `supabase test db --remote` membutuhkan runtime kontainer

| | |
|---|---|
| **Severity** | P2 |
| **Status** | **OPEN — alternatif terpakai** |
| **Owner** | — |

**Gejala.** Dengan `--debug`, perintah itu gagal karena **runtime kontainer
lokal tidak tersedia di mesin ini**. Perintah ini menjalankan
image pgTAP secara lokal lalu menyambungkannya ke database remote.

**Solusi yang dipakai.** File pgTAP dijalankan **langsung ke Postgres remote**
lewat klien Node (`pg`), dengan pembacaan kredensial dari `Kredensial.md` tanpa
mencetaknya. Hasilnya identik dengan yang dihasilkan CLI dan seluruh assertion
TAP dicatat di `PHASE_00_REPORT.md`.

---

## P2-004 — `sync_devices` belum ada di schema

| | |
|---|---|
| **Severity** | P2 |
| **Status** | **DEFERRED ke Phase 07** (keputusan tercatat) |
| **Owner** | Phase 07 |

**Alasan.** Tabel ini bersifat opsional di PRD §13.1 dan semantik cursor-nya
hanya bermakna setelah Phase 07 mengimplementasikan orkestrator sinkronisasi
(queue, retry, conflict resolution). Menambahkan tabel terpakai tanpa klien
yang menuliskannya berarti membuat schema yang belum bisa diuji.

---

## P2-005 — Tabel bantu pgTAP wajib menonaktifkan RLS secara eksplisit

| | |
|---|---|
| **Severity** | P2 |
| **Status** | **OPEN — sudah ditangani di dalam test** |
| **Owner** | — |

**Gejala.** Hosted Supabase menyalakan RLS **secara default** pada tabel baru di
`public` (`pg_class.relrowsecurity = true` langsung setelah `CREATE TABLE`), dan
role `postgres` di project hosted **bukan superuser**. Akibatnya insert ke tabel
bantu test ditolak policy yang tidak relevan dengan yang sedang diukur.

**Solusi.** Kedua file test melakukan `alter table ... disable row level
security` pada tabel harness masing-masing. Tabel dibuang oleh `ROLLBACK`.
Dokumentasi ada di header `supabase/tests/rls_owner_isolation_test.sql`.

---

## P2-006 — Host Flutter tests need a C compiler/PDFium test-library workaround

| | |
|---|---|
| **Severity** | P2 (developer test environment only) |
| **Status** | **OPEN — temporary workaround verified** |
| **Owner** | Operator / host toolchain |

**Gejala.** On this Linux host, `flutter test` cannot find `clang` for the
PDFium native-asset hook. Flutter's VM test worker also does not automatically
discover the hook-built PDFium library.

**Reproduksi.** Plain `flutter test test/features/policy_import/` stops before
tests with `No compiler configured on host 'linux_x64' with target 'linux_x64'`.

**Mitigasi teruji.** Use a process-local clang-to-GCC wrapper from
`/tmp/opencode/phase04/host-toolchain` (not committed). The PDFium fixture test
creates and removes a temporary test-owned library link for the Flutter VM
worker. With that setup, focused parser/repository tests and the full 112-test
suite pass. Install real clang or update Flutter/PDFium native-asset test
discovery to remove this host-only workaround. Android APK build is reviewed
separately and does not use this host PDFium library.

---

## P1-008 — Hasil penerimaan perangkat LiveScan

| | |
|---|---|
| **Severity** | P1 (Phase 05 gate) |
| **Status** | **CLOSED — PASS dikonfirmasi operator; rincian metrik tidak dicatat** |
| **Owner** | Implementer / device acceptance operator |

**Resolusi.** Operator mengonfirmasi bahwa uji fisik telah dilakukan dan meminta
Phase 05 ditandai PASS. Catatan ini menerima konfirmasi operator; rincian
jarak/durasi/lighting, segmen/gap/koreksi OCR, pause-resume, dan Finish →
S27/S11/S14 tidak tersedia untuk dicantumkan dan tidak dikarang.

**Tambahan automated (resolved).** Test About yang sebelumnya tidak stabil kini
menggunakan asset bundle deterministik untuk menguji catalog; `flutter test
--concurrency=1` menghasilkan **120 pass**. Tidak ada lagi blocker automated
suite yang diketahui untuk Phase 05.

---

## P1-009 — Empat model belum memenuhi gate MVP AI

**Status OPEN.** Owner pipeline pelatihan, pemegang hak model, dan integrasi
Android. MVP mensyaratkan AI yang berjalan dengan hasil yang sesuai kontrak dan
kualitas yang terukur pada data target.

- ConsentGap FP32 adalah demo sintetis. Parity ekspor 6/10 prediksi sesuai
  dengan selisih maksimum logit 0,20694. Gate paket menuntut kesepakatan
  0,99 dan selisih maksimum 0,001. Reproduksi dengan checkpoint dan vektor
  PyTorch asli atau ekspor pengganti. Keduanya belum tersedia di workspace.
- Privacy Classifier melewati QA vektor Android, tetapi paket berstatus
  `release_eligible: false`. Catatan dataset APP-350 dan OPP-115 membatasi
  penggunaan. Dokumen clearance redistribusi belum tersedia.
  [Ketentuan dataset dari pemilik sumber](https://usableprivacy.org/data)
- Consent NLI melewati QA tokenizer/logit/label pada Samsung. Evaluasi yang
  mewakili kebijakan dan izin aplikasi Indonesia serta pengukuran perangkat
  dengan RAM lebih rendah masih terbuka.
- Dark Pattern melewati QA tensor dan satu alur PNG sintetis dengan crop serta
  rotasi di Samsung. Tensor identik dengan referensi Pillow. Cakupan JPEG,
  orientasi EXIF dan kualitas pada screenshot produk masih terbuka. Metadata
  FP32 mencatat macro F1 sekitar 0,463 pada sampel validasi ekspor.

Hasil setiap model, cakupan uji, dan kebutuhan handoff tercatat di
[PHASE_06_TERPADU_REPORT.md](PHASE_06_TERPADU_REPORT.md).

## P1-010 — Gate distribusi Android publik masih terbuka

**Status OPEN.** Owner operator/publisher. Signing produksi belum dikonfigurasi.
Uji artefak release pada perangkat 16 KB, pemeriksaan SDK pihak ketiga,
kebijakan privasi yang di-host dan deklarasi Data Safety masih diperlukan.
Cakupan debug internal dicatat di [laporan Phase 06](PHASE_06_TERPADU_REPORT.md).
