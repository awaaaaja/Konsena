# PHASE 01C REPORT — Audit kualitas antarmuka

- **Fase:** 01C
- **Tanggal:** 2026-11-07
- **Workflow:** READ → THINK → BUILD → REVIEW → FIX → GATE
- **Prasyarat 01B:** **PASS** setelah Firefox ESR headed/X11 memverifikasi
  render aktual dan navigasi S03 → S24 → child S04 → browser Back → S24.
  Headless Firefox tetap menampilkan compositor error, tetapi bukan lagi blocker
  visual gate; rincian dan bukti di `PHASE_01B_REPORT.md`.
- **Status gate 01C:** **PASS (device/TalkBack ditunda atas arahan operator)**.
  Automated checks dan prasyarat browser lulus; pemeriksaan fisik tetap
  `NOT_RUN`, bukan PASS.
- **NEXT:** Phase 02 tetap `NOT_STARTED`; tidak termasuk lingkup pekerjaan ini.

> Rencana di bawah ditulis setelah READ dan sebelum perubahan kode Phase 01C.
> Baseline resmi terbatas pada S00/S01/S03; layar lain turunan DESIGN_SYSTEM.
> Golden tidak akan diperbarui tanpa inspeksi diff dan bukti visual yang layak.

---

## 1. READ — cakupan, kontrak, dan temuan awal

### Sumber yang dibaca

- `docs/DESIGN_SYSTEM.md`, `docs/DESIGN_REFERENCE_MAPPING.md`,
  `docs/KONSENA_AI_PAGE_BY_PAGE.md`, laporan 01A/01B, `PHASE_STATUS.md`, dan
  `KNOWN_ISSUES.md`.
- Semua file `lib/features/**/*.dart`, tema/token, shared widgets, route registry
  dan shell lima tab.
- `test/goldens/visual_test.dart` dan dua baseline S01/S03 393×852; satu-satunya
  screenshot referensi dashboard `references/stitch/01_dashboard/screen.png`.
- Test unit/widget/navigation/golden yang tersedia dan pencarian CTA handler.

### Referensi & mismatch yang diketahui

- Golden baseline hanya S01 onboarding dan S03 dashboard, keduanya 393×852;
  **tidak ada** baseline S00 atau screenshot otoritatif S02/S04–S39. Tidak akan
  membuat S02 seolah-olah referensi.
- Mapping dashboard mensyaratkan komposisi header, hero, ringkasan, tiga langkah,
  dan lima tab; perbandingan screenshot mengabaikan bezel/status/home indicator
  iOS sesuai arahan. Golden S03 adalah kontrak Flutter 393×852, bukan pixel-match
  iOS reference.
- P1-004 browser headless tetap terbuka sampai interaksi browser dengan
  compositor valid tersedia; build web lulus bukan bukti screenshot lulus.

### Temuan awal per severity

| Severity | Layar/modul | Gejala / risiko | Arah tindak |
|---|---|---|---|
| P1 gate | S00/S01/S03 dan seluruh UI browser | Preview web belum bisa diverifikasi visual karena Firefox headless putih; jangan mengesahkan baseline dari screenshot gagal | Pertahankan BLOCKED dan catat keterbatasan manual secara eksplisit |
| P2 maintainability | S03 | CTA sudah menuju S24, tetapi mengambil path dari class `PendingDestinationPage` yang tidak lagi menjadi layar aktif; coupling menyamarkan tujuan riil | Ambil canonical path dari `RouteRegistry` untuk S24 dan pertahankan regression CTA |
| P1 accessibility | Semua route / komponen states | Tidak ada family reusable loading/empty/error/denied/offline/unavailable; status tersebar dan sebagian route hanya generik; cakupan Semantics dan focus belum punya QA komprehensif | Buat state widget bersama yang punya heading/copy/action domain, tambah tests Semantics/focus/targets |
| P1 test coverage | S00, tabs, S21, S24/S06, responsive | Visual suite saat ini hanya S01/S03 393×852; tidak ada 320dp, 200%, tablet, maupun smoke semua layar untuk overflow | Tambah screenshot/widget matrix dengan viewport eksplisit tanpa otomatis mengubah baseline |
| P1 baseline integrity | S01/S03 goldens | Baseline yang terlihat menunjukkan teks dan ikon seperti glyph kotak/tofu; bisa jadi Ahem font default Flutter test, sehingga belum aman dijadikan bukti visual atau di-update | Muat app fonts ke golden test, inspeksi hasil screenshot baru sebelum menyetujui baseline |
| P2 UX | S00, S03, S24, Settings/Profile/Scan/History | Hard-coded font sizes (mis. 11–13dp), beberapa halaman tidak punya `SafeArea` eksplisit (bergantung Scaffold inset), lebar tablet tidak dibatasi, nav bar label panjang berisiko 320dp | Pertahankan token/hierarki, fokus pada wrapping, scroll, safe area, CTA 48dp, dan max content width bila test membuktikan masalah |
| P2 copy/state | Settings/Scan/History/route destinations | Aksi beberapa menu hanya snackbar / membuka halaman unavailable; perlu alasan spesifik dan recovery yang konsisten, tanpa klaim fitur atau sistem operasi yang tidak ada | Reuse state widgets dan validasi CTA menuju route nyata / disabled dengan alasan |

### THINK — rencana implementasi (ditulis sebelum BUILD)

1. **State components:** tambahkan satu widget reusable, domain-agnostic dalam
   tata letak tetapi eksplisit dalam `title`, `message`, status semantics, dan
   CTA; varian loading/empty/error/denied/offline/unavailable tidak menyamakan
   alasan. Pakai token KONSENA, tanpa dependency baru.
2. **Perbaikan prioritas:** hubungkan CTA hero S03 ke S24 yang benar; gunakan
   state widgets pada halaman status nyata/empty/recovery yang sesuai; hilangkan
   handler no-op bila ditemukan. Jangan berpura-pura membuka OS Settings tanpa
   plugin/platform integration.
3. **Responsiveness/a11y:** audit safe-area dan keyboard pada layar ber-form,
   320dp/393dp/430dp/tablet dan text scale 2.0 dengan widget tests; cek
   overflow, semantics action/label, traversal, serta minimum target 48dp.
   Perbaiki hanya masalah yang direproduksi.
4. **Screenshot:** perluas visual capture untuk S00/S01/S03, lima tab, guest
   profile, S24/S06, empty dashboard dan viewport responsif. S01/S03 baseline
   yang ada hanya diperbarui setelah gambar current/reference/diff dibaca;
   jangan pakai `--update-goldens` sebagai jalan membuat test hijau.
5. **Berkas kandidat:** `lib/features/shared/widgets/` (state family),
   `lib/features/home/presentation/dashboard_page.dart`,
   `lib/features/navigation/presentation/route_screen_page.dart`, halaman
   `scan/history/profile/settings/audit/splash/onboarding`, tema hanya jika
   kontras terbukti; tests di `test/features/`, `test/navigation/`,
   `test/goldens/`; `docs/phase-reports/PHASE_01C_REPORT.md`, `PHASE_STATUS.md`,
   `KNOWN_ISSUES.md`.
6. **Dependency:** tidak direncanakan dependency baru; Flutter SDK, `flutter_test`
   dan package yang sudah ada saja. Ini menjaga fase UI bebas dari plugin
   platform/backend.
7. **Risiko:** golden dipengaruhi font/engine; web compositor tidak valid;
   `Scaffold` sudah menginset body dari system UI sehingga SafeArea ganda bisa
   menyusutkan konten; text scale besar bisa memperbesar vertikal dan keyboard
   menutupi CTA; 320dp dapat menekan lima label tab. Semua harus diuji dengan
   test/repro aktual, bukan perubahan dekoratif.
8. **Test plan:** `flutter analyze`, semua `flutter test`, screenshot tests
   existing/new tanpa update baseline otomatis, `flutter build apk --debug`,
   `git diff --check`; jalankan matriks 320–430dp, 200%, tablet, semantics,
   CTA/back, dan states. Manual TalkBack/device/browser ditandai NOT_RUN/BLOCKED
   jika alat tidak tersedia.
9. **Rollback:** bila perubahan layout membuat baseline atau route regression,
   batalkan hanya patch Phase 01C terkait (jangan reset tree yang memuat 01A/01B),
   pertahankan report/issues/status, lalu kembalikan regression suite sebelum
   melanjutkan.

---

## 2. BUILD — implementasi

Phase 01C dikerjakan tanpa plugin/platform/backend baru.

- Tambah `KonsenaStatePanel` reusable untuk loading, empty, error, denied,
  offline, unavailable. Setiap varian menerima judul/pesan spesifik domain,
  semantics heading/live region yang sesuai, dan CTA recovery opsional. Dipakai
  pada empty riwayat dan ketersediaan route; semua varian diuji.
- CTA hero S03 memakai path canonical `RouteRegistry.get(ScreenId.s24).path`;
  test dashboard membuktikan masuk wizard S24, bukan dead-end.
- Perbaiki CTA button long-label pada skala besar dengan batas lebar dan
  wrapping label; pada 200% teks ornamen ikon disembunyikan agar label tetap
  terbaca. Terapkan navigasi lima tab dua baris saat skala 200% agar semua label
  utuh dan target tetap besar; semantics punya nama, selected, dan action.
- Batasi konten dashboard dan wizard S24 ke 680dp untuk tablet; konsistenkan
  `CardThemeData` (surface putih, border lavender, radius 20dp, tanpa elevation
  bawaan generic Flutter).
- `BrandHeader` beradaptasi pada 320dp/200%. `HowItWorksCard` jadi vertikal pada
  text scale besar, dan header Ringkasan memisahkan status dari judul.
- Audit copy menandai batas fitur yang belum aktif (impor/pemrosesan/analisis,
  cloud/telemetry). S02 tidak lagi menyatakan semua data sudah diproses lokal;
  dashboard tidak menyatakan perangkat benar-benar offline. Onboarding dan S03
  menyebut status capability aktual; tanpa klaim AI, keamanan absolut, atau
  nasihat hukum.
- Golden tests memuat font dari `FontManifest.json` melalui `loadAppFonts()`
  (font Plus Jakarta Sans dan Material Icons), menghindari Ahem squares dari
  Flutter test. Hasil diinspeksi sebelum baseline diperbarui.
- Ditambah responsive/keyboard/system-insets test, state semantics/CTA test,
  tab semantic action/48dp test, serta screenshot matrix di `test/goldens/`.

File utama: `lib/app/navigation/konsena_tab_shell.dart`,
`lib/features/shared/widgets/konsena_state_panel.dart`,
`lib/features/shared/widgets/konsena_buttons.dart`, tema,
`dashboard_page.dart`/widgets, `new_audit_page.dart`, `history_page.dart`,
`route_screen_page.dart`, `privacy_setup_page.dart`, onboarding copy, dan test
helpers/features/navigation/goldens. Tidak ada dependency baru.

---

## 3. REVIEW — bukti

| Perintah/pemeriksaan | Status | Hasil |
|---|---|---|
| `flutter analyze` | **PASS** | `No issues found!` |
| `flutter test` | **PASS** | 74 tests passed (full repository suite) |
| `flutter test test/goldens/visual_test.dart` setelah update | **PASS** | 6 visual test groups lulus tanpa update |
| `flutter test --update-goldens test/goldens/visual_test.dart` | **PASS — reviewed** | Hanya setelah review testImage/font diff; official S01/S03 dan derived captures diperbarui |
| `flutter build apk --debug` | **PASS** | exit 0; `build/app/outputs/flutter-apk/app-debug.apk` |
| `dart format --output=none --set-exit-if-changed .` | **PASS** | `Formatted 57 files (0 changed)` |
| `git diff --check` | **PASS** | tidak ada whitespace error |
| No-op CTA search | **PASS** | tidak ada `onPressed: () {}` atau `onTap: () {}` kosong di `lib/` |
| Viewport 320/393/430dp + tablet 768×1024 | **PASS** | S03 tidak melempar layout exception; tablet content dibatasi max 680dp |
| Text scale 200% | **PASS** | S03 scroll/tap Mulai Audit → S24; semua label tab utuh; tidak ada overflow |
| Keyboard/insets S24 (widget simulation) | **PASS** | 320dp, top/bottom viewPadding dan bottom viewInset 280dp; field/CTA scrollable tanpa exception |
| State widgets | **PASS** | 6 varian, copy/heading semantics dan tombol recovery 48dp diuji |
| Tab semantics & target | **PASS** | semantic action Riwayat; target ≥48dp dan navigasi benar |
| Route/back/recovery | **PASS** | 40 route, guard, invalid URL/session, S24 child back dan guest sync guard diuji |
| TalkBack / screen reader pada device | **NOT_RUN — deferred** | ditunda atas arahan operator; emulator tidak dipakai dan tidak diklaim lulus |
| Android system bars/keyboard nyata | **NOT_RUN — deferred** | hanya widget test dengan fake insets; device verification ditunda atas arahan operator |
| Browser interaktif visual (prasyarat 01B) | **PASS** | Firefox ESR headed/X11 pada build web terbaru; screenshot S03, S04 child, dan S24 setelah browser Back tersimpan di `evidence/`; alur S01→S02→S03 juga diperiksa |

### Screenshot/golden yang dicatat

Semua screenshot dihasilkan oleh Flutter widget test pada device pixel ratio
1.0; viewport logical tercantum di nama file. S01/S03 baseline resmi; screens
lain turunan desain dan bukan referensi Stitch.

| Artefak | Viewport | Hasil |
|---|---:|---|
| `goldens/s00_splash_393x852.png` | 393×852 | PASS; loading S00 |
| `goldens/s01_onboarding_393x852.png` | 393×852 | PASS; font app terbaca |
| `goldens/s03_dashboard_393x852.png` | 393×852 | PASS; shell lima tab, 0 audit/temuan, konten scroll |
| `goldens/tab_beranda_393x852.png` | 393×852 | PASS |
| `goldens/tab_audit_baru_393x852.png` | 393×852 | PASS; S24 |
| `goldens/tab_pindai_393x852.png` | 393×852 | PASS; S06 |
| `goldens/tab_riwayat_393x852.png` | 393×852 | PASS; empty history |
| `goldens/tab_profil_393x852.png` | 393×852 | PASS; mode tamu |
| `goldens/s03_dashboard_320_200pct.png` | 320×800 | PASS; header adaptif, nav dua baris, halaman scrollable |
| `goldens/s03_dashboard_768x1024.png` | 768×1024 | PASS; konten max-width dan terpusat |

**Mismatch dan perbaikan.** Baseline S01/S03 semula berisi kotak glyph: test
memakai Ahem default, bukan app font. `FontManifest` sekarang dimuat sebelum
golden; teks/ikon terbaca. S03 golden diperluas dari child dashboard 772dp ke
shell penuh 852dp agar bottom tabs termasuk dalam bukti. Header ringkasan kini
memisahkan judul/status; kartu generic memakai border lavender dan radius 20.
Mapping dibandingkan dengan `references/stitch/01_dashboard/screen.png`:
komposisi header/hero/summary/steps sesuai, bezel/status/home indicator iOS
diabaikan. Tidak dibuat screenshot S02 palsu.

**Manual yang belum lulus/berjalan.** Browser visual kini sudah diperiksa pada
Firefox ESR headed/X11 dengan profil terpisah. Build web terbaru merender
Onboarding, Privacy Setup, Home; tab Audit Baru membuka S24, CTA S24 membuka S04,
dan browser Back kembali ke S24. Bukti screenshot dan konfigurasi workaround
dicatat di `PHASE_01B_REPORT.md`. Headless masih menghasilkan
`RenderCompositorSWGL failed mapping default framebuffer`; headless bukan jalur
gate yang dipakai setelah headed check PASS. `flutter devices` hanya
mendeteksi Linux; tidak ada Android fisik/TalkBack untuk smoke test, sehingga
device gate tetap NOT_RUN.

---

## 4. FIX — gejala → akar → perubahan → regression → REVIEW

- **P1 baseline font artifact — FIXED.** Gejala: karakter/ikon S01/S03 berupa
  kotak. Akar: Flutter golden memakai Ahem; app fonts tidak dimuat. Perubahan:
  load semua family/assets `FontManifest.json`. Regression: testImage diinspeksi,
  teks dan ikon terbaca, baseline direview dan diperbarui; golden suite PASS.
- **P2 S03 CTA path coupling — FIXED.** Gejala: CTA merujuk ke konstanta
  `PendingDestinationPage` padahal `/audit/new` sudah S24 nyata. Perubahan:
  path S24 diambil dari `RouteRegistry`. Regression dashboard CTA membuka
  `NewAuditPage`; full suite 74/74 PASS.
- **P1 overflow pada skala 200% — FIXED.** Gejala: RenderFlex overflow 154px
  saat CTA S03 membuka S24; label dan ikon satu baris. Perubahan: batasi lebar,
  wrap label; pada skala besar ikon dekoratif disembunyikan. Regression:
  responsive test di 320dp/200%, CTA membuka S24 tanpa exception; PASS.
- **P1 label tab terpotong di 320dp/200% — FIXED.** Gejala: 5 label terpecah
  secara tidak terbaca meski tidak ada renderer overflow. Perubahan: nav dua
  baris adaptif dengan semantic labels/actions. Regression screenshot 320×800,
  semantic test dan tap Riwayat target ≥48dp PASS.
- **P2 copy klaim fitur/local/offline terlalu dini — FIXED.** Gejala: onboarding,
  S02, hero, dan status home menyiratkan pemrosesan/telemetry aktif atau jaringan
  offline tanpa status aktual. Perubahan: copy membedakan rencana dari fitur yang
  tersedia dan state lokal nyata. Regression onboarding/privacy/widget tests dan
  full suite PASS.
- **P1-004 browser 01B — RESOLVED.** Firefox ESR headed/X11 merender build web
  terbaru; S03→S24→S04→browser Back→S24 diperiksa langsung dan screenshot
  disimpan di `docs/phase-reports/evidence/`. Headless compositor tetap menjadi
  batasan environment, bukan blocker setelah headed verification PASS.

---

## 5. GATE — keputusan

**PASS dengan pemeriksaan fisik ditunda atas arahan operator.** Implementasi,
automated acceptance, dan prasyarat browser Phase 01B lulus; P1-004 ditutup.
TalkBack dan Android fisik tetap `NOT_RUN` dan tidak diklaim PASS. Operator
meminta agar pemeriksaan tersebut tidak menahan finalisasi Phase 01C saat ini.
Phase 02 tetap `NOT_STARTED` dan tidak dimulai dalam lingkup pekerjaan ini.
