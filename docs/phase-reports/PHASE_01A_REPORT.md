# PHASE 01A REPORT — Fondasi UI berbasis referensi Stitch

- **Fase:** 01A
- **Tanggal:** 2026-11-07
- **Workflow:** READ → THINK → BUILD → REVIEW → FIX → GATE
- **Prasyarat:** Phase 00 **PASS** (commit `fae9964`, branch `main`)
- **Keputusan GATE:** *(diisi setelah REVIEW)*
- **NEXT:** 01B *(jika PASS)*

> **Aturan laporan.** Status dinyatakan per perintah sebagai `PASS` / `FAIL` /
> `NOT_RUN` / `BLOCKED`. Tidak ada klaim PASS tanpa output nyata. Tidak ada
> nilai rahasia yang ditulis di dokumen ini.

---

## 1. READ — temuan prasyarat & sumber

### 1a. Ketersediaan referensi

| Sumber yang disyaratkan | Status | Bukti |
|---|---|---|
| `references/stitch/s00_splash_screen/code.html` | **PASS** | 8.469 byte, disalin dari paket referensi lokal pengguna |
| `references/stitch/s01_onboarding/code.html` | **PASS** | 7.474 byte |
| `references/stitch/01_dashboard/code.html` | **PASS** | 13.450 byte |
| `references/stitch/01_dashboard/screen.png` | **PASS** | 450.249 byte, 834×1768 RGBA |
| `references/stitch/luminous_violet_guardian/DESIGN.md` | **PASS** | sudah ada di repo |
| `docs/DESIGN_SYSTEM.md`, `docs/KONSENA_AI_PAGE_BY_PAGE.md` S00–S03, `docs/DESIGN_REFERENCE_MAPPING.md` | **PASS** | dibaca penuh |
| `assets/brand/konsena_mark_transparent.png` | **PASS** | 379.087 byte, **878×722 RGBA**, 17.373 piksel alpha=0, **0 piksel hitam pekat** → tidak ada latar hitam |

**Catatan sumber.** Keempat file referensi tidak ada di repo saat fase dimulai;
file ditemukan di paket lokal pengguna
`~/Downloads/New Folder/KONSENA_AI_Claude_Code_Per_Phase_v4/` (sama dengan yang
didokumentasikan `references/README.md`) lalu disalin. Tidak ada ZIP/template
yang diambil dari internet.

**Hanya tiga layar punya sumber Stitch langsung (S00, S01, S03).** S02 tidak
memiliki screenshot/HTML — visualnya diturunkan dari pola `DESIGN_SYSTEM.md`
§8.1, **bukan** mengarang referensi.

### 1b. Kontrak layar (ringkas)

| Layar | Route | Kontrak kunci |
|---|---|---|
| S00 Splash | `/splash` | radial violet gelap, logo, nama, tagline `Pahami, Kendalikan, dan Lindungi Data Pribadimu`, state loading + gagal-bootstrap; **tanpa status bar iOS**, tanpa izin OS |
| S01 Onboarding | `/welcome` | permukaan putih/lavender, judul `Ubah Kebijakan Privasi yang Rumit Jadi Mudah Dipahami`, CTA bundar violet, `Lewati`, **3 slide**, semua skip/continue → S02 |
| S02 Privacy Setup | `/privacy-setup` | guest-first, penjelasan data lokal, **cloud opt-in = false**, persetujuan terpisah, **kamera tidak diminta di sini** |
| S03 Dashboard | `/home` | header logo + `KONSENA AI` + `PRIVACY INTELLIGENCE`, hero gradien + `Mulai Audit` → S24, dua kartu ringkasan **dari state (nol bila kosong)**, 3 langkah; **tanpa badge DEMO / angka palsu** |

### 1c. Aturan konflik yang berlaku

1. Palet Stitch **diabaikan** → `docs/DESIGN_SYSTEM.md` (Midnight Purple /
   Deep Indigo / Royal Violet / Electric Violet / Lavender) yang berlaku.
2. HTML **tidak** disalin jadi UI; hanya komposisi, hierarki, ritme whitespace.
3. Status bar / home indicator iOS pada referensi **tidak** direplikasi.
4. Badge `DEMO`, `Sesi contoh`, `Analisis contoh` **tidak** masuk produksi.
5. Ilustrasi eksternal (URL Google) pada HTML S01 **tidak** dipakai (aset tak
   terlisensi) → diganti komposisi widget buatan sendiri berlabel ilustrasi.

---

## 2. THINK — rencana teknis

### 2a. Pemetaan token → widget reusable

| Token / pola referensi | Widget Flutter reusable | File |
|---|---|---|
| Palet + semantic token (DESIGN_SYSTEM §1) | `KonsenaColors` (konstanta + alias semantik) | `lib/theme/konsena_colors.dart` |
| Spacing 4/8/12/16/20/24/32, radii 12/16/20/24/pill | `KonsenaSpacing`, `KonsenaRadii` | `lib/theme/konsena_spacing.dart` |
| Shadow violet halus (luminous DESIGN.md) | `KonsenaShadows.card/raised/hero/glow` | `lib/theme/konsena_shadows.dart` |
| Plus Jakarta Sans 400–800 | `KonsenaTypography` + `TextTheme` (fallback eksplisit) | `lib/theme/konsena_typography.dart` |
| ThemeData konsisten | `KonsenaTheme.light()` | `lib/theme/konsena_theme.dart` |
| Radial violet splash + planetary horizon | `_SplashAtmosphere` (di dalam S00) | `lib/features/splash/` |
| CTA bundar violet / pill putih | `KonsenaPrimaryButton`, `KonsenaPillButton` | `lib/features/shared/widgets/` |
| Kartu ringkasan / kartu 3 langkah | `SummaryCard`, `StepCard` (state-driven) | `lib/features/home/presentation/widgets/` |
| Pagination dots + tombol lingkaran | `OnboardingDots`, `_RoundCta` | `lib/features/onboarding/` |

### 2b. Modul / berkas yang akan disentuh

**Baru**

```
fonts/PlusJakartaSans-{400,500,600,700,800}.ttf   # SIL OFL 1.1 (sudah diunduh + OFL.txt)
fonts/OFL.txt
lib/theme/{konsena_colors,konsena_spacing,konsena_shadows,konsena_typography,konsena_theme}.dart
lib/core/journey/journey_store.dart                # interface + InMemory + SharedPreferences impl
lib/features/splash/presentation/{splash_cubit,splash_page}.dart
lib/features/onboarding/presentation/{onboarding_page,onboarding_slide}.dart
lib/features/privacy_setup/presentation/privacy_setup_page.dart
lib/features/home/domain/home_summary_repository.dart   # interface + empty impl (nol)
lib/features/home/presentation/{dashboard_page,home_cubit(updated)}.dart
lib/features/home/presentation/widgets/{summary_card,step_card,status_card,brand_header,hero_card}.dart
lib/features/shared/widgets/{konsena_buttons,pending_destination_page}.dart
test/features/onboarding/onboarding_page_test.dart
test/features/splash/splash_page_test.dart
test/features/privacy_setup/privacy_setup_page_test.dart
test/features/home/dashboard_page_test.dart
test/theme/konsena_theme_test.dart
test/goldens/visual_test.dart  (+ test/goldens/*.png)
docs/phase-reports/PHASE_01A_REPORT.md            # dokumen ini
```

**Diubah**

```
pubspec.yaml                  # aset assets/brand/, deklarasi font
lib/app/app_router.dart       # /splash /welcome /privacy-setup /home /audit/new
lib/app/konsena_app.dart      # theme KonsenaTheme + injeksi JourneyStore + repository ringkasan
lib/main.dart                 # menyediakan PreferencesJourneyStore
test/widget_test.dart         # menyesuaikan alur startup baru (SEMUA asertasi lama dipertahankan)
```

**Dihapus**

```
lib/features/home/presentation/home_page.dart   # diganti dashboard S03 (status card dipindah ke S03)
lib/app/app_shell.dart                          # shell Phase 00 diganti rute layar penuh; 5-tab shell masuk 01B
```

**Tidak disentuh:** OCR, PackageManager, LiveScan, PDF, ONNX, drift (01B),
S04–S39.

### 2c. Dependency

| Dependency | Keputusan |
|---|---|
| `go_router`, `flutter_bloc`, `get_it` (sudah ada) | dipakai ulang — tidak menambah paket state/routing |
| `shared_preferences` (**baru**, kecil, plugin resmi) | untuk `onboarding_seen`, `privacy_setup_seen`, `cloud_opt_in=false`, `analytics_opt_in=false` — dibutuhkan kontrak state S01/S02 (`onboarding_seen disimpan lokal`) |
| Font Plus Jakarta Sans | **di-bundle** dari Google Fonts (SIL OFL 1.1, `fonts/OFL.txt` disertakan). Fallback eksplisit: `Roboto → Noto Sans → sans-serif` bila aset gagal dimuat |
| Golden test | `flutter_test` bawaan (`matchesGoldenFile`) + `FontLoader` untuk memuat font nyata di test |

### 2d. Keputusan desain penting

1. **S00 sebagai `initialLocation`.** Splash membaca `JourneyStore`:
   pertama kali → `/welcome`; onboarding selesai tapi setup privasi belum →
   `/privacy-setup`; keduanya selesai → `/home`. Gagal membaca → state
   `recoverableError` dengan `Coba lagi` + diagnostik tanpa data pengguna.
2. **`JourneyStore` abstract + `InMemoryJourneyStore` + `PreferencesJourneyStore`.**
   Test meng-inject memori (deterministik, tanpa kanal platform);
   produksi memakai `shared_preferences`.
3. **Ringkasan dari repository, bukan hard-code.**
   `HomeSummaryRepository.load()` → `HomeSummary(auditCount, findingCount)`.
   Implementasi fase ini `EmptyHomeSummaryRepository` = **nol** (initial empty
   state). UI menggambar angka **dari state** — dibuktikan test dengan fake
   repository bernilai non-nol.
4. **`Mulai Audit` → `/audit/new` (S24).** S24 belum diimplementasikan hingga
   fase 02/03, jadi rutenya menampilkan halaman penunjuk yang **jujur**
   menyatakan layar tujuan belum tersedia (tanpa data palsu). Halaman seperti ini
   dipakai hanya untuk target wajib yang belum ada.
5. **Bottom nav 5 tab ditunda ke 01B** (fase `navigasi utama`). Menambah tab
   ke rute yang belum ada = mati/aksesibel palsu di 01A.
6. **Shortcut fitur pendukung (Audit Izin / Policy Scanner / LiveScan / Dark
   Pattern) tidak ditambahkan di 01A** — targetnya S06/S07/S08/S12 belum ada;
   spesifikasi menyatakan "boleh di bawah fold" (opsional). Menghindari tombol
   mati.
7. **Status card Phase 00 dipertahankan di S03 (di bawah fold)** — menampilkan
   `Cloud tidak aktif/terhubung`, salinan status gateway, dan mode tamu. Ini
   dipertahankan karena (a) jujur & berguna untuk aplikasi privasi, dan
   (b) mempertahankan seluruh asertasi regression test Phase 00.

### 2e. Risiko

| # | Risiko | Dampak | Mitigasi |
|---|---|---|---|
| R1 | API `ThemeData` Flutter 3.47 berbeda dari ingatan (mis. `CardThemeData`) | `flutter analyze` FAIL | pakai token langsung pada widget; hanya properti theme yang stabil; REVIEW mengejar |
| R2 | Overflow pada 320dp / teks 200% | P1 gate | `LayoutBuilder` untuk kartu ringkasan (kolom tunggal), teks fleksibel; test eksplisit ukuran 320×640 dan `textScaler` 2.0 + `tester.takeException()` |
| R3 | Animasi loading splash tak henti → `pumpAndSettle` hang di test | test gagal | animasi hanya ada pada state loading; test memompa frame terarah; navigasi terjadi setelah bootstrap selesai |
| R4 | Font tidak termuat di golden → teks kotak | golden tidak bermakna | `FontLoader` di `setUpAll` golden test; bila toolchain tetap tidak mendukung → catat jujur |
| R5 | Regression test Phase 00 (startup guest) patah setelah alur berubah ke `/splash` | FAIL wajib diperbaiki | `KonsenaApp` menerima seam `journeyStore`; test Phase 00 di-set "sudah onboarding" lalu semua asertasi lama dipertahankan |
| R6 | Menambah `shared_preferences` = plugin platform → test butuh mock | error kanal | `SharedPreferences.setMockInitialValues` hanya bila dipakai; default test = `InMemoryJourneyStore` |
| R7 | Logo hitam di atas scaffold gelap/terang | visual rusak | PNG RGBA sudah diverifikasi transparan; test memuat logo & memastikan tidak ada exception; tinjau visual manual |
| R8 | Build APK Phase 00 belum selesai saat fase ini berjalan | bukti tertunda | baris build diperbarui dengan hasil nyata; build 01A dijalankan sendiri pada REVIEW |

### 2f. Test plan

| Perintah / test | Yang dibuktikan |
|---|---|
| `flutter pub get` | dependency + font/aset ter-resolve |
| `flutter analyze` | nol issue |
| `flutter test test/features/onboarding/` | 3 slide, `Lewati`→S02, continue→S02, judul, target ≥48dp, 320dp & 200% tanpa overflow |
| `flutter test` (seluruh suite) | termasuk regression Phase 00 (startup guest) + splash + privacy setup + dashboard + tema + golden |
| `flutter build apk --debug` | build Android nyata |
| Golden `test/goldens/` | S00/S01/S03 pada 393×852; mismatch dicatat jujur |
| `git diff --check` | tanpa whitespace error pada file fase ini |
| Audit rahasia / DEMO badge / angka hard-code | grep `DEMO`, `Sesi contoh`, `Analisis contoh`, pola rahasia |
| AndroidManifest | **tidak ada** izin `CAMERA` (S02 tidak meminta kamera) |

### 2g. Rollback

Seluruh perubahan fase ini berada di working tree **setelah** commit Phase 00
(`fae9964`) — tidak ada commit fase 01A sebelum REVIEW lolos. Rollback =

```bash
git checkout -- .            # membuang perubahan file ter-tracked
git clean -fd lib/features/{splash,onboarding,privacy_setup} lib/theme \
  test/features test/goldens test/theme fonts assets references/stitch \
  docs/phase-reports/PHASE_01A_REPORT.md   # membuang file baru (perlu konfirmasi)
```

Tidak ada perubahan skema database, tidak ada `git reset --hard`, tidak ada
`clean -fd` global, tidak ada destructive git operation lain. Dependency baru
dihapus dengan mengembalikan `pubspec.yaml` + `flutter pub get`.

---

## 3. BUILD — implementasi

**Status: PASS.** Implementasi selesai sesuai keputusan §2, dengan tambahan
golden baseline untuk S01/S03 dan test integrasi untuk S00/S02.

- Design tokens dan `KonsenaTheme.light()` memakai palet yang disetujui;
  Plus Jakarta Sans SIL OFL dibundel berikut lisensinya.
- Journey lokal memiliki implementasi in-memory dan `shared_preferences`;
  routing S00 → S01/S02/S03 dan state gagal-bootstrap dapat diuji tanpa kanal
  platform atau jaringan.
- S01 terdiri dari tiga slide; Lewati dan CTA akhir membuka S02, sementara
  pilihan S02 disimpan terpisah dengan cloud/analytics off secara default.
- S03 menggunakan `HomeSummaryRepository`; empty state menampilkan nilai dari
  state dan tombol audit membuka tujuan S24 yang secara eksplisit ditandai
  belum tersedia (Phase 02).
- Reusable widgets ditambahkan untuk CTA, header, kartu ringkasan, langkah,
  status lokal, dan tujuan tertunda. Shell lima tab tetap di 01B.
- Test baru: onboarding, splash, privacy setup/manifest, dashboard, theme, dan
  visual golden S01/S03 pada 393×852.
- File Phase 00 `test/widget_test.dart` dipertahankan tanpa mengurangi assertion;
  startup regression tetap menjalankan keenam kasus guest/config.

---

## 4. REVIEW — verifikasi & bukti

| Perintah / pemeriksaan | Status | Hasil |
|---|---|---|
| `flutter pub get` | **PASS** | dependency terselesaikan, exit 0 |
| `dart format --output=none --set-exit-if-changed .` | **PASS** | `Formatted 40 files (0 changed)`, exit 0 |
| `flutter analyze` | **PASS** | `No issues found!` |
| `flutter test test/features/onboarding/` | **PASS** | 7/7; headline, 3 slides, routing, ≥48dp, 320dp, text scale 200% |
| `flutter test` | **PASS** | 48 test lulus, exit 0 (termasuk semua regression Phase 00) |
| `flutter test --update-goldens test/goldens/visual_test.dart` | **PASS** | baseline S01/S03 393×852 dibuat; kedua test golden lulus |
| `flutter build apk --debug` | **PASS** | `✓ Built build/app/outputs/flutter-apk/app-debug.apk`; build awal 692.8s, verifikasi incremental 23.1s |
| `git diff --check` | **PASS** | tidak ada whitespace error |
| Android manifest: CAMERA | **PASS** | tidak ditemukan `android.permission.CAMERA` |
| Audit label demo di layar produksi | **PASS** | tidak ada label `DEMO`, `Sesi contoh`, `Analisis contoh`; pemakaian kata “demo” hanya dokumentasi/komentar penegasan |
| Audit istilah runtime kontainer pada Markdown | **PASS** | 0 kemunculan (constraint Phase 00) |
| Audit rahasia | **PASS** | tidak ada nilai rahasia nyata ditambahkan; string `sb_secret_` di test adalah fixture sintetis untuk menguji penolakan key admin |

**Golden note.** Baseline visual ada di `test/goldens/`; gambar tidak dibuat
untuk S02 karena S02 memang tidak memiliki sumber Stitch langsung.

---

## 5. FIX — gejala → akar → perubahan → regression → REVIEW

1. **Test harness onboarding — diperbaiki.** Gejala: suite berhenti sebelum
   assertion dengan `Guarded function conflict`. Akar: helper test memanggil
   `pumpWidget` tanpa `await`. Perubahan: jadikan `pumpKonsena` asynchronous
   dan tunggu semua pemanggil. Regression: `flutter test
   test/features/onboarding/` **PASS 7/7**.
2. **Golden S03 — diperbaiki.** Gejala: overflow horizontal 147px pada
   393×852. Akar: header `Ringkasan aktivitas` dan `Tersimpan di perangkat`
   dipaksa satu baris. Perubahan: `Wrap` responsif menggantikan `Row`.
   Regression: visual golden S03 serta `flutter test` **PASS**.
3. **Semantic handle — diperbaiki.** Gejala: handle semantik masih hidup
   setelah test target sentuh. Akar: teardown terdaftar dan disposal eksplisit
   bertabrakan. Perubahan: dispose sekali sebelum test selesai. Regression:
   onboarding suite **PASS**.
4. **Test kontrak minor — diperbaiki.** Font-family aktual mengikuti deklarasi
   `PlusJakartaSans`; splash route dapat selesai dalam frame pertama; dan
   tombol S02 berada di bawah fold. Expectation diselaraskan dengan kontrak,
   assertion keselamatan tetap ada, serta test S02 memastikan tombol terlihat
   sebelum tap. Regression: seluruh suite **48/48 PASS**.

---

## 6. GATE — keputusan

**PASS — Phase 01A ditutup.** Implementasi S00–S03, regression Phase 00,
golden S01/S03, analisis statis, dan APK debug lulus. **NEXT: 01B** (Drift,
audit draft, navigasi utama, offline state).

Isu lintas fase yang tetap terbuka tidak disamarkan: P0-001 rotasi kredensial
dan P1-002 keputusan project remote tercatat di `KNOWN_ISSUES.md`; keduanya
tetap prasyarat khusus sebelum Phase 07. Phase 01A tidak menambah akses cloud,
permintaan kamera, atau data audit palsu.
