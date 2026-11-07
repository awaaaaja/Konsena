# PHASE 01B REPORT — Shell navigasi & route S00–S39

- **Fase:** 01B
- **Tanggal:** 2026-11-07
- **Workflow:** READ → THINK → BUILD → REVIEW → FIX → GATE
- **Prasyarat:** Phase 01A PASS (`PHASE_01A_REPORT.md`)
- **Keputusan GATE:** **PASS** — verifikasi visual dan navigasi berhasil di Firefox ESR headed/X11 pada build web terbaru. Headless compositor limitation tetap dicatat sebagai keterbatasan environment, bukan blocker gate.
- **NEXT:** Phase 01C (aksesibilitas/device review); tidak memulai Phase 02.

> Status bukti ditulis per perintah (`PASS` / `FAIL` / `NOT_RUN` / `BLOCKED`).
> Rencana berikut dicatat sebelum perubahan implementasi Phase 01B.

---

## 1. READ — temuan dan kontrak sumber

### 1a. Dokumen yang dibaca

- `docs/KONSENA_AI_PAGE_BY_PAGE.md` §A–J, terutama §D (indeks route), §E
  (kontrak S00–S39), §F (alur), §G (widget), §H (guard/persistensi), §I
  (event antarmodul), serta anti-dead-end checks §O.
- `lib/app/app_router.dart`, `lib/app/konsena_app.dart`, `lib/theme/*`, dan
  shared button/dashboard widgets dari 01A.
- `pubspec.yaml`, Phase 01A report dan status fase.

### 1b. Route registry canonical — §D (40 ID, bukan alias)

| ID | Canonical path | ID | Canonical path |
|---|---|---|---|
| S00 | `/splash` | S20 | `/settings` |
| S01 | `/welcome` | S21 | `/profile` |
| S02 | `/privacy-setup` | S22 | `/sync` |
| S03 | `/home` | S23 | `/about` |
| S04 | `/audit/apps` | S24 | `/audit/new` |
| S05 | `/audit/apps/:package` | S25 | `/scan/document-type` |
| S06 | `/scan` | S26 | `/scan/import/progress` |
| S07 | `/scan/import` | S27 | `/scan/camera/gaps` |
| S08 | `/scan/camera/setup` | S28 | `/document/:docId/clauses` |
| S09 | `/scan/camera/live` | S29 | `/audit/:id/compare` |
| S10 | `/scan/camera/merge` | S30 | `/audit/:id/risk` |
| S11 | `/scan/review/:docId` | S31 | `/audit/:id/dark-pattern` |
| S12 | `/consent-ui/import` | S32 | `/audit/:id/actions/:actionId` |
| S13 | `/consent-ui/review` | S33 | `/audit/:id/report/export` |
| S14 | `/audit/:id/sources` | S34 | `/history/:auditId` |
| S15 | `/audit/:id/results` | S35 | `/scan/camera/troubleshoot` |
| S16 | `/audit/:id/evidence/:evidenceId` | S36 | `/settings/data` |
| S17 | `/audit/:id/actions` | S37 | `/sync/conflicts/:itemId` |
| S18 | `/audit/:id/report` | S38 | `/audit/:id/source-match` |
| S19 | `/history` | S39 | `/scan/camera/how-to` |

Lima root tab (dan satu-satunya lima tab): S03 `/home`, S24 `/audit/new`,
S06 `/scan`, S19 `/history`, S21 `/profile`. S04 tetap child, bukan tab.
`/account` hanya alias menuju `/profile`, tidak memiliki screen ID. Route
registry harus mempertahankan path/parameter resmi di tabel ini.

### 1c. Audit 01A dan batas fungsional

- Router 01A saat ini mendaftarkan `/splash`, `/welcome`, `/privacy-setup`,
  `/home`, dan placeholder `/audit/new`; belum ada shell atau registry.
- Theme 01A telah menyediakan `KonsenaTheme`, token warna/spacing/radius/shadow,
  typography dan CTA reusable. Dipertahankan; tidak menambah dependency.
- Fase 01B hanya membangun routing, screen-shell, state/navigation seams dan
  profil guest. Tidak mengimplementasikan PackageManager, import/OCR, kamera,
  ONNX, PDF, auth/cloud sync, atau database fase teknis berikutnya.
- Fitur masa depan diberi state unavailable yang menyebut fitur/tahap/aksi
  alternatif spesifik; tidak menampilkan hasil, score, temuan, atau progres
  yang tidak nyata.

---

## 2. THINK — rencana sebelum BUILD

### 2a. Modul/berkas

**Baru**

```
lib/app/navigation/route_registry.dart           # typed ScreenId + 40 path specs
lib/app/navigation/route_guards.dart             # param/session/guest guards
lib/app/navigation/konsena_tab_shell.dart        # five indexed retained branches
lib/features/navigation/presentation/route_screen_page.dart # truthful spec-driven screens
lib/features/audit/presentation/new_audit_page.dart           # S24 stateful draft wizard
lib/features/scan/presentation/scan_hub_page.dart             # S06 CTA fan-out
lib/features/history/presentation/history_page.dart           # S19 honest empty state
lib/features/profile/presentation/profile_page.dart           # S21 useful guest controls
lib/features/settings/presentation/settings_page.dart         # S20 settings actions
test/navigation/route_registry_test.dart          # exact 40 IDs + uniqueness/params
test/navigation/navigation_test.dart              # shell, redirects, guards, retention, CTA/back
```

**Diubah**

```
lib/app/app_router.dart                           # shell route graph + guards/error recovery
lib/app/konsena_app.dart                          # inject route/draft seams if required
lib/features/home/presentation/dashboard_page.dart # S03 CTA → canonical routes
docs/KONSENA_AI_PAGE_BY_PAGE.md                    # route traceability/mismatch notes only if needed
docs/phase-reports/PHASE_STATUS.md
docs/phase-reports/KNOWN_ISSUES.md
```

### 2b. Keputusan implementasi

1. Gunakan `StatefulShellRoute.indexedStack` dari `go_router` yang sudah ada;
   lima branch menyimpan state tab saat berpindah. Child routes ditempatkan
   pada branch yang sesuai, tetapi URL tetap persis indeks §D.
2. Satu `ScreenId` enum/registry menjadi sumber tunggal bagi screen ID, nama,
   path, parameter wajib, parent intent, availability copy, dan aksi. Registry
   unik berisi tepat S00–S39. `/account` memakai redirect, bukan registry item.
3. S03/S24/S06/S19/S21 menerima halaman khusus. Screen lain disusun dari
   `ScreenSpec` per-ID dengan judul, tujuan, keterbatasan aktual, CTA tujuan
   canonical, dan recovery; bukan generic “Coming soon”. Screen unsupported
   tidak mengklaim fungsi teknis sudah berjalan.
4. Draft S24 hidup di state store in-memory yang di-inject dan page State
   dipertahankan oleh indexed stack; route back dan pindah tab tidak membuang
   isi. Penyimpanan durable ditunda ke fase data lokal.
5. Validasi parameter (non-empty/whitelist pattern, panjang terbatas) dilakukan
   sebelum menampilkan konten. Session route yang belum ada dalam draft store
   menampilkan recovery “audit tidak ditemukan” dengan CTA S24/S19, bukan data
   contoh. Sync route memeriksa auth/opt-in; guest tidak diblokir dari fitur
   lokal dan mendapat penjelasan + kembali ke Profile.
6. `errorBuilder`/unknown location selalu memunculkan recovery berlabel dan
   navigasi Home/Profile; Back default kembali ke child parent/branch asal.
7. CTA route flow menautkan Home→S24→S04/S14, Scan→S25/S39/S12, History→S34→S18,
   Profile→S20/S23/S36 dan sync yang guarded. Tautan fitur belum tersedia tetap
   hidup sebagai informasi yang dapat dibuka, tidak menjadi tombol mati.

### 2c. Dependencies

Pakai Flutter SDK, `go_router`, `flutter_bloc`, dan `flutter_test` yang telah
terpasang. Tidak menambah package routing/state/UI. Session/auth, persistence,
kamera, scanner, PackageManager dan report repository memakai seam eksplisit
atau unavailable state; implementasi teknis bukan cakupan fase ini.

### 2d. Risiko, penyebab, mitigasi

| Risiko | Penyebab | Mitigasi / regression |
|---|---|---|
| Tab kehilangan draft/scroll | Router biasa mengganti subtree | indexed stack + tes isi S24/tab switch/back |
| Route collision pada pola `/audit/:id/...` | ID dinamis bertumpuk dengan `/audit/new` | registry exact paths + uri smoke semua screen |
| Deep link mengakses sesi/record fiktif | fase ini belum punya repository data | guard session dengan recovery eksplisit; parameter diuji valid/invalid |
| Route resmi berubah diam-diam | indeks tersebar di widget | registry tunggal + test kesamaan S00..S39 dan path canonical |
| CTA mati atau hasil palsu | layar teknis belum dibangun | semua target tercatat; availability beralasan dan alternatif nyata |
| Shell menghalangi root flow S00–S02 | shell harus hanya menampung tab utama | splash/onboarding/privacy tetap di luar shell; regression first-run |
| Login menjadi prasyarat lokal | fitur sync/account belum aktif | profil guest lengkap; guard hanya khusus sync/conflict |

### 2e. Test plan dan review gate

- `flutter pub get`, `flutter analyze`, `flutter test test/navigation/`,
  `flutter test`, `flutter build apk --debug`, `dart format --output=none
  --set-exit-if-changed .`, `git diff --check`.
- Tes tepat 40 ID unik S00..S39, semua canonical URI dapat dibuka, semua named
  params valid/invalid, alias `/account`, 404 recovery, deep-link guest & sync
  guard, five labels/tab index, selected branch retention, form draft S24,
  Back child→parent/tab asal, guest profile, dan CTA lintas screen.
- Smoke Android manual Back/tab/deep link dicatat `NOT_RUN` bila perangkat
  emulator tidak tersedia; jangan mengklaim tes widget sebagai tes manual.
- Audit CTA tidak mati/tanpa alasan, layar AI unavailable tanpa nilai palsu,
  route traceability, secret policy, `git diff --check`.

### 2f. Rollback

Perubahan 01B dilakukan di working tree setelah Phase 00 (`fae9964`); working
tree sudah berisi Phase 01A belum di-commit. Rollback 01B hanya dengan memilih
dan membatalkan file yang ditambahkan/diubah khusus Phase 01B dari diff review;
jangan `git checkout .`, `git clean` global, reset, atau menyentuh file Phase 01A.
Tidak ada perubahan database atau dependency yang direncanakan.

---

## 3. BUILD — implementasi

Implementasi inti selesai dan seluruh smoke/widget/build gates lulus. Setelah
review lanjutan di Firefox ESR headed/X11, verifikasi browser interaktif PASS;
hasilnya dan bukti screenshot dicatat pada §4 dan §6.

- `lib/app/navigation/route_registry.dart`: 40 canonical IDs dan path persis
  indeks §D; enum/registry jadi source of truth; validasi path parameters
  mencakup required, karakter aman, dan panjang maksimum; alias tidak masuk ID.
- `lib/app/app_router.dart` + `konsena_tab_shell.dart`: 5 branch
  `StatefulShellRoute.indexedStack`, error recovery URL, `/account` redirect,
  dan guard guest untuk `/sync`/konflik.
- `AuditDraftStore` + S24 wizard: draft in-memory, nama/fokus, child push
  S04/S14 mempertahankan form saat back; tab Pindai menerima alur impor.
- S06, S19, S20, S21, S23: hub Scan, Riwayat nyata dari draft sementara,
  pengaturan, Profil guest penuh, dan Tentang dengan batasan produk eksplisit.
- 32 screen child selain lima tab dan tiga entry onboarding/splash memakai
  `ScreenSpec` khusus: tujuan, keterbatasan, state unavailable dan jalur
  pemulihan. Tidak ada hasil/score/temuan contoh atau klaim fitur teknis aktif.
- Screen invalid/missing session dan unknown URL mendapat recovery; sync tanpa
  autentikasi+consent kembali ke Profil dengan alasan terlihat.
- `web/` Flutter scaffolding ditambahkan karena permintaan debugging browser;
  `index.html`/manifest diberi metadata brand. Tidak ada emulator yang dipakai.
- Tes ditambahkan di `test/navigation/` untuk exact registry, route smoke 40
  ID, param, alias, tab, retained form, CTA, back, guest, dan route recovery.
- Satu tes S03 Phase 01A diubah dari ekspektasi placeholder ke kontrak baru:
  `Mulai Audit` membuka wizard S24 nyata.

---

## 4. REVIEW — bukti

| Perintah / pemeriksaan | Status | Hasil |
|---|---|---|
| `flutter pub get` | **PASS** | dependency resolve, exit 0 |
| `flutter analyze` | **PASS** | `No issues found!` |
| `flutter test test/navigation/` | **PASS** | 13 test lulus; 40 URI smoke, exact IDs, guards, CTA, tab/draft/back |
| `flutter test` | **PASS** | 61 test lulus, termasuk seluruh test sebelumnya dan route/navigation |
| Golden S01/S03 393×852 | **PASS** | `flutter test --update-goldens test/goldens/visual_test.dart`; baseline diperbarui setelah shell masuk S03 |
| `dart format --output=none --set-exit-if-changed .` | **PASS** | `Formatted 53 files (0 changed)` |
| `git diff --check` | **PASS** | tidak ada whitespace error |
| `flutter build apk --debug` | **PASS** | `✓ Built build/app/outputs/flutter-apk/app-debug.apk` (53.9s) |
| `flutter build web` | **PASS** | original 01B build 131.9s; rebuilt latest 01C code on 2026-11-07 (140.1s) before headed browser review |
| `flutter run -d web-server` | **PASS** | debug server berhasil serve `http://127.0.0.1:8765` |
| Firefox headless smoke (static web build) | **BLOCKED** | screenshot tetap putih; stderr memuat `RenderCompositorSWGL failed mapping default framebuffer`; tidak ada klaim visual PASS |
| Firefox ESR headed, X11, `http://127.0.0.1:8766` (build terbaru) | **PASS** | S01→S02 guest→S03 terlihat; lima-tab shell tampil; tab Audit Baru→S24; CTA utama→S04 child; browser Back kembali ke S24. Screenshot disimpan di `evidence/firefox_s03_1567x1028.png`, `firefox_s04_child_1567x1028.png`, dan `firefox_s24_after_browser_back_1567x1028.png` |
| GTK/browser workaround | **PASS** | `MOZ_ENABLE_WAYLAND=0`, `GDK_BACKEND=x11`, profil Firefox/GTK sementara tanpa modul `window-decorations-gtk-module` yang tidak kompatibel. Tidak mengubah konfigurasi browser pengguna atau kode produk. |
| Android emulator/device manual | **NOT_RUN** | sesuai instruksi operator, emulator tidak digunakan; `flutter devices` hanya Linux dan `adb devices` kosong |
| Tab retention / draft / child back | **PASS** | widget test S24 bertahan saat pindah tab; push child/back kembali ke wizard |
| Param invalid, missing session, unknown URL, guest sync guard | **PASS** | recovery UI terlihat; test route negatif lulus |
| Route registry | **PASS** | 40 ID berurutan S00–S39, 40 path unik; `/account` tidak masuk registry |
| Label tab | **PASS** | lima tujuan persis Beranda/Audit Baru/Pindai/Riwayat/Profil |
| Audit model palsu/dead route | **PASS** | unavailable copy per-screen, tanpa temuan/score buatan; S33 terlacak di branch audit |

Flutter web scaffold dibuat untuk pemeriksaan browser karena sebelumnya target
web belum ada. Headless Firefox tetap gagal menggambar canvas pada environment
ini; tetapi build terbaru berhasil ditinjau di Firefox ESR headed/X11 dengan
profil terpisah. GTK modules dari konfigurasi desktop menyebabkan warning
`undefined symbol gtk_module_display_init`; profil GTK temporer kosong dan
backend X11 menghindari modul tersebut tanpa mengubah konfigurasi pengguna.
Screenshot interaktif tersedia pada folder `evidence/` yang ditautkan di atas.

---

## 5. FIX — gejala → akar → perubahan → regression → REVIEW

FIX dan regression terbaru:

- **Test dashboard lama FAIL** — gejala: assertion mencari
  `PendingDestinationPage` di `/audit/new`; akar: S24 telah berkembang dari
  placeholder 01A menjadi wizard sesuai 01B. Perubahan: assertion kini
  memverifikasi `NewAuditPage`; regression suite dashboard PASS.
- **Route registry orphan S33 ditemukan saat audit branch** — gejala: indeks
  punya ID S33 tetapi shell branch belum mendaftarkan screen tersebut; akar:
  route ekspor terlewat saat pengelompokan route audit. Perubahan: masukkan S33
  ke branch Audit dan kuatkan route smoke agar memverifikasi widget screen,
  bukan hanya Scaffold/error fallback. Regression: `flutter test
  test/navigation/` PASS.
- **Route S33 terlewat (FIXED).** Regression route smoke kini meminta actual
  widget tujuan, bukan hanya Scaffold, dan `flutter test test/navigation/`
  PASS 13/13.
- **Firefox headless compositor (RESOLVED untuk gate visual).** Headless masih
  mencetak `RenderCompositorSWGL failed mapping default framebuffer`, namun
  headed ESR/X11 merender build web terkini. S01, S02, S03, lima tab, S24, S04,
  dan browser Back diperiksa manual; screenshot tersedia di `evidence/`.
  P1-004 ditutup atas bukti browser interaktif, bukan berdasarkan headless.

---

## 6. GATE — keputusan

**PASS untuk Phase 01B.** Automated acceptance/build lulus dan browser interaktif
ESR/X11 memverifikasi layar serta navigasi S03→S24→S04→browser Back→S24. Headless
Firefox tetap memiliki keterbatasan compositor, namun tidak menghalangi gate
setelah browser headed diverifikasi. Pemeriksaan Android device tidak menjadi
gate 01B; emulator tidak digunakan. NEXT adalah Phase 01C, bukan Phase 02.
