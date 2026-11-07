# DESIGN SYSTEM — KONSENA AI v3.0 (VIOLET · STITCH-ALIGNED)

Target aplikasi **Android-first**, fokus kejelasan dan privasi. Semua teks UI berbahasa Indonesia dengan istilah teknis dijelaskan singkat. Dokumen ini adalah rujukan UI untuk Claude Code; tidak mengubah requirement PRD.

## 1. Visual tokens — VIOLET IDENTITY v3.0 (APPROVED BASE + STITCH LAYOUT)

**Sumber keputusan:** palet yang ditetapkan pengguna untuk prototipe. Warna ini **menggantikan seluruh tema teal/emerald/green lama** dalam UI KONSENA AI. Hijau hanya boleh digunakan untuk status berhasil.

### Palet utama (nilai hex tetap)

| Nama | Hex | Peran |
|---|---|---|
| Midnight Purple | `#252148` | Headline, teks primer, splash dan header |
| Deep Indigo | `#342D61` | Secondary heading, tombol pressed, dark surface |
| Royal Violet | `#5A3DAD` | CTA utama, tombol konfirmasi, active primary |
| Electric Violet | `#7838D8` | Aksen, focus ring, selected control, accent indicator |
| Lavender | `#C4BDD6` | Stroke dan border dekoratif |
| Soft Lilac | `#E5E0F9` | Selected navigation surface, subtle highlight |
| Pale Lavender | `#EFE6FB` | Background utama / hero / kelompok fitur |
| Cloud White | `#FDFCFE` | Background halaman umum |
| White | `#FFFFFF` | Card, modal, dialog |
| Success Green | `#36C77B` | Status berhasil / selesai / validasi teknis |
| Warning Amber | `#FFB83F` | Ketidakpastian OCR, sumber kurang lengkap, perlu tinjau |
| Danger Red | `#EF6464` | Kegagalan kritis, tindakan destruktif, hasil bertentangan yang terverifikasi |

### Semantic token (light)

| Token | Value | Usage |
|---|---|---|
| `color.brand.midnight` | `#252148` | Typography & dark header |
| `color.brand.indigo` | `#342D61` | Body secondary / pressed state |
| `color.primary` | `#5A3DAD` | CTA |
| `color.primaryPressed` | `#342D61` | Pressed action |
| `color.accent` | `#7838D8` | Focus / selected / scanner reticle |
| `color.backgroundMain` | `#EFE6FB` | Homepage hero / main canvas |
| `color.backgroundPage` | `#FDFCFE` | Page scaffold |
| `color.surface` | `#FFFFFF` | Card/dialog |
| `color.surfaceSelected` | `#E5E0F9` | Selected state |
| `color.surfaceSubtle` | `#EFE6FB` | Subtle notice |
| `color.textPrimary` | `#252148` | Content primary |
| `color.textSecondary` | `#342D61` | Meta/caption |
| `color.textOnPrimary` | `#FFFFFF` | On Royal Violet button |
| `color.textOnDark` | `#FDFCFE` | On Midnight Purple header |
| `color.border` | `#C4BDD6` | Decorative outlines only |
| `color.borderStrong` | `#8F83A8` | Accessible control outline — supporting token |
| `color.success` | `#36C77B` | Success fill/icon |
| `color.warning` | `#FFB83F` | Warning fill/icon |
| `color.danger` | `#EF6464` | Danger fill/icon |
| `color.statusText` | `#252148` | Text on success/warning/danger fills |

### Color contrast / accessibility

- White on **Royal Violet**: contrast ~7.76:1 (WCAG AA/AAA normal text). White on **Electric Violet**: ~6.26:1 (WCAG AA normal text).
- **Do not use white text** on Success Green (~2.18:1), Warning Amber (~1.72:1), or Danger Red (~3.15:1). Use Midnight Purple on those fills (approx. 6.92, 8.76, 4.80:1 respectively).
- Lavender is decorative. For interactive outlined controls, `borderStrong #8F83A8` is ~3.51:1 on white; pair with icon/label and focus indication.
- Every status MUST include icon + label + supporting copy, not color alone. Amber is *uncertain/review*, not automatically a privacy violation. Red is reserved for confirmed critical issues or destructive actions.

### Component mapping

| Component | Background | Text/foreground | Accent / border |
|---|---|---|---|
| Splash | Midnight Purple | Cloud White | Electric Violet detail |
| Home | Pale Lavender | Midnight Purple | Royal Violet CTA |
| Standard page | Cloud White | Midnight Purple | Lavender border |
| AppBar | Midnight Purple | Cloud White | N/A |
| Primary button | Royal Violet | White | Deep Indigo pressed |
| Accent/selected | Soft Lilac | Midnight Purple | Electric Violet |
| Card | White | Midnight Purple | Lavender outline |
| BottomNavigation | Cloud White | Midnight Purple | Soft Lilac selected, Electric Violet icon |
| Scanner ROI | Transparent | Cloud White label on dark scrim | Electric Violet contour |
| LiveScan focus OK | Transparent/dark scrim | Cloud White | Success Green symbol |
| OCR incomplete | Pale Lavender | Midnight Purple | Warning Amber icon |
| Risk high / delete | White | Midnight Purple | Danger Red icon + supporting text |
| Evidence highlight | Soft Lilac | Midnight Purple | Electric Violet border |
| Progress bar | Soft Lilac track | N/A | Royal Violet progress |
| Report headings | Cloud White | Midnight Purple | Electric Violet micro-accent |

### Dark mode (optional, separate QA release gate)

Light palette is mandatory. If dark mode is enabled, use Midnight Purple background, Deep Indigo surface, Cloud White text, **Soft Lilac primary button with Midnight Purple foreground**. Do not force Royal Violet buttons with low-contrast secondary label combinations on dark surfaces. Verify all contrast combinations before shipping dark mode.

### Implementation constraints

- Semantic tokens, not literal hex in feature widgets.
- No residual `#087F70`, `#073B43`, `#F7FAF9`, `#13282C`, `#D8E6E2` or green branding elements in the shipped UI.
- Green is status-only; **not a button/action brand color**.
- In tests, compare widgets against updated golden screenshots (old green snapshots are obsolete).
- Aset logo violet dengan alpha transparan tersedia sebagai `assets/brand/konsena_mark_transparent.png`; gunakan tanpa background hitam dan jangan distorsi. Verifikasi keterbacaan pada canvas terang maupun gelap.

Spacing tokens: 4/8/12/16/20/24/32; radii 12 for tile, 16 for card, 20 for hero; shadows subtle; 1px outline. Width: max content 640dp tablets, adaptive two-column where appropriate. Font `TextTheme` from platform, scale up to 200%. Minimum touch target 48dp.

## 2. Navigation

Bottom navigation memiliki **5 tujuan** menurut referensi Dashboard Stitch: **Beranda** `/home`, **Audit Baru** `/audit/new`, **Pindai** `/scan` (aksi tengah yang paling menonjol), **Riwayat** `/history`, dan **Profil** `/profile`. Untuk label referensi berbahasa Inggris (`New Audit`, `Scan`, `History`, `Profile`), gunakan padanan Indonesia ini pada implementasi. S21 `/profile` dapat dibuka oleh tamu; akun dan sinkronisasi tidak diwajibkan. Alias lama `/account` -> `/profile`. Pengaturan dapat diakses dari Profil atau AppBar. Shell menggunakan `StatefulShellRoute` atau struktur yang setara untuk melestarikan state per tab, dan semua action memakai target sentuh minimal 48dp.

## 3. Screen composition patterns

1. **Beranda**: komposisi screenshot referensi sebagai prioritas viewport pertama: header brand/icon dengan `KONSENA AI` dan `PRIVACY INTELLIGENCE`; hero gelap `Pahami izin. Lindungi privasi.`, CTA `Mulai Audit`; dua kartu Ringkasan aktivitas; kartu langkah `Bagaimana cara kerjanya?`; fitur grid lanjutan: Audit Izin, Privacy Policy Scanner, LiveScan, Dark Pattern Screenshot; summary latest audit only if exists. Jangan hardcode angka ringkasan; tampilkan `0` dari repository lokal bila belum ada data. Jangan tampilkan risk score palsu.
2. **Audit Izin**: search field, refresh icon, visible app list, info banner explaining scope; select an app.
3. **App Detail**: app name/package/version; timestamp snapshot; each permission row has status label `Diberikan`, `Belum diberikan`, or `Tidak tersedia`; button “Buka Pengaturan”; button “Tambahkan Kebijakan”.
4. **Scan Hub**: three input mode choices with examples: dokumen (PDF, gambar, teks), kamera ke monitor, screenshot consent; no need to force user to choose an Android app.
5. **Policy Import**: file area, chosen name/type/size, extracted text preview, progress, cancel.
6. **Camera Setup**: viewfinder with editable quadrilateral ROI, focus/glare indicators, CTA “Kunci area”, then “Mulai pindai”.
7. **LiveScan**: camera preview (65% vertical area), unobtrusive stats, `Scroll perlahan`, `Pause`, `Selesai`; warning for fast scroll/missing overlap; no bogus percentage total-document.
8. **Merge Review**: captured segments grouped by order, duplicate count, suspected gaps, paragraph editor, “Scan ulang bagian”/“Konfirmasi hasil OCR”.
9. **Consent UI**: screenshot preview and manual element markup, `AI belum tersedia` prior to ONNX.
10. **Audit Source Hub**: chips for `Android`, `Policy`, `Terms`, `Screenshot`; each source status; disabled analyze CTA with explanation if no model.
11. **Analysis Results**: status banner; modules separate `Policy`, `ConsentGap`, `Dark Pattern`, `Risiko`. Never show results for absent source/model.
12. **Evidence Explorer**: exact quote, page/paragraph/frame origin, highlight and correction log; navigable breadcrumb.
13. **Recommendations**: only action types genuinely implemented; Settings opens Android OS; later re-scan.
14. **Report**: sections: metadata, source list, facts, AI findings if available, evidence, recommendations, limitations; PDF export.
15. **History**: activity cards with date, source badges, status, delete/export controls.
16. **Privacy Settings**: local retention, optional encrypted-save, cache clearing, cloud sync, export/delete, legal note.

## 4. Component states and copy

| State | Suggested copy | Interaction |
|---|---|---|
| Initial/empty | “Belum ada audit. Pilih aplikasi atau pindai dokumen.” | Start audit |
| Missing policy | “Belum ada Privacy Policy untuk dibandingkan.” | Add document |
| Missing model | “Analisis AI belum tersedia pada versi ini. Data hasil scan tetap dapat disimpan dan ditinjau.” | Review source |
| OCR blur | “Teks kurang jelas. Dekatkan kamera atau atur fokus.” | Refocus |
| Scroll too fast | “Scroll terlalu cepat. Gulir sedikit ke atas agar bagian yang terlewat terbaca.” | Resume |
| Scan gap | “Kemungkinan ada paragraf belum tertangkap.” | Rescan |
| Hidden Android app | “Sebagian aplikasi tidak ditampilkan Android. Anda masih dapat memeriksa dokumen secara manual.” | Document import |
| No net | “Anda offline. Scan dan audit lokal tetap tersedia.” | Continue |
| Success saved | “Hasil tersimpan di perangkat.” | View report |
| Sync requires consent | “Pilih hasil yang boleh diunggah. File asli tidak diunggah otomatis.” | Select |
| Uncertain result | “Hasil ini perlu ditinjau karena bukti belum cukup.” | Show evidence |

## 5. Interaction and animation

- Micro-animations 150–250ms; respect reduced-motion, no infinite scanning animation masking idle failures.
- Camera uses actual preview state and focus overlay; UI controls never appear to “record” if camera unavailable.
- Sensitive actions (delete/cloud share) get confirmation bottom sheet; deleting locally doesn't claim cloud deleted until confirmed.
- Do not send raw camera frame to clipboard or telemetry.
- Accessibility: announcements for OCR segment count, scan paused, missing text, status changed.

## 6. Screenshot/golden tests

Required in `test/goldens/`: `home_empty`, `audit_app_list`, `permission_details`, `scan_hub`, `camera_ready`, `camera_blurry`, `camera_gap`, `merge_review`, `analysis_unavailable`, `evidence_detail`, `report_preml`, `history_empty`, `settings_privacy`; light/dark and large-font variants for key screens.

## 7. Prototype/demo discipline

Demo fixtures must live in `assets/demo/`, debug/internal flavor only. Show `DEMO — DATA SIMULASI` on all demo-screen screenshots. Production builds must not display made-up scores, permissions, labels, or analyses.


## 8. Referensi visual Stitch: aturan penerjemahan ke Flutter

### 8.1 Cakupan aktual

| Stitch source | Target Flutter | Yang harus dipertahankan | Perbedaan disengaja |
|---|---|---|---|
| `s00_splash_screen/code.html` | S00 | latar radial violet gelap, lambang K, identitas, tagline, iluminasi lembut | tanpa iOS status bar, tidak menampilkan izin OS |
| `s01_onboarding/code.html` | S01 | permukaan pucat, hierarki headline, `Lewati`, CTA bundar violet, ritme whitespace | tiga pesan nilai dengan alur skip yang konsisten, konten tidak menyatakan diagnosis hukum |
| `01_dashboard/screen.png` + `code.html` | S03 | header wordmark, hero, ringkasan dua kartu, kartu 3 langkah, bottom bar 5 item | badge `DEMO` hanya flavor demo; nilai ringkasan dari DB nyata |
| `luminous_violet_guardian/DESIGN.md` | shared theme | `Plus Jakarta Sans`, radius 12–24dp, whitespace, shadows violet halus, component anatomy | contoh warna Stitch tidak menggantikan palet brand KONSENA yang telah disetujui |

Terdapat **3 layar bernama** di ZIP (hanya Dashboard memiliki gambar PNG). Jangan klaim ada screenshot sumber untuk S02 atau S04–S39. Untuk semua layar lain, bangun pola visual konsisten: app bar ringkas, konten hierarkis, 16–24dp padding, card radius 20–24dp, states jelas, dan CTA tunggal yang dominan.

### 8.2 Visual geometry

- Layar kecil: padding horizontal 20dp (fallback 16dp pada width yang sangat sempit), safe area status/navigation Android.
- Header: identitas KONSENA di kiri, label status/akun di kanan sesuai mode. Jangan gunakan angka atau klaim `protected` yang tidak terukur.
- Hero S03: container gradien `Midnight Purple -> Deep Indigo -> Royal Violet`, sudut 24dp, padding 24dp; tiga baris: overline, headline dua baris, deskripsi; `Mulai Audit` bersifat white-filled dengan teks violet.
- Ringkasan: dua kartu pada lebar normal dengan 16dp gap, radius 20–24dp, outline lavender lembut, ikon pada chip Soft Lilac; untuk 320dp / text-scale besar, ubah menjadi single column.
- Edukasi langkah: satu card berisi tiga row bernomor 1–3, pembatas longgar, pill label Android/Bukti/Pengguna; row tap hanya jika mengarah ke info/aksi nyata.
- Bottom bar: 5 item termasuk ikon scanner tengah yang diberi surface lebih menonjol, label selalu tersedia untuk aksesibilitas; Android system inset ditangani otomatis.
- Splash: latar gelap radial violet; logo transparan berukuran tepat tanpa bayangan palsu jika brand icon sudah memiliki gradien.
- Onboarding: `Plus Jakarta Sans`, headline 23–28sp, ilustrasi fleksibel, tombol `Lewati` terlihat, satu CTA utama; jangan copy iOS faux system clock.

### 8.3 Type / motion / accessibility

- **Font:** Plus Jakarta Sans sebagai font utama; simpan sumber berlisensi sesuai repo bila di-bundle. Jika aset font belum tersedia, gunakan fallback platform yang konsisten (jangan mengaku font telah terpasang).
- Headline hero 28–32sp / semibold-bold, body 14–16sp; `textScaler` sistem didukung hingga 200% tanpa clipping horizontal.
- Motion: 150–250ms untuk press, 200–350ms untuk navigation, hormati `disableAnimations` / reduce motion. Hindari glow besar pada semua elemen; letakkan luminous effect pada hero dan splash.
- A11y: contrast WCAG AA, semantik status berbasis label, TalkBack urut logis, target touch minimal 48dp, tidak mengandalkan warna saja.
- Gunakan theme tokens di Dart (mis. `KonsenaColors`, `KonsenaTypography`, `KonsenaRadii`, `KonsenaSpacing`); jangan memakai hex acak langsung di page.

### 8.4 Prototype-vs-production rules

- Badge `DEMO` di screenshot hanya untuk flavor demo, tidak pada produksi.
- Teks `Sesi contoh` dan `Analisis contoh` pada prototipe harus diganti dengan state yang benar-benar dihitung dari database atau dihapus; jangan mengesankan model AI sudah berjalan.
- Jika model ONNX belum ada, tampilkan `Analisis AI belum tersedia` secara jelas. No mock risk score, confidence, atau klaim kepatuhan UU PDP.
- CTA `Mulai Audit` membuka S24; tab `Pindai` membuka S06; `Profil` membuka S21 meski tamu.

## 9. Screenshot/golden acceptance baseline

Prioritaskan pengujian visual untuk S00, S01, S03 pada ukuran 360x800, 393x852 dan tablet. `01_dashboard/screen.png` adalah komposisi acuan, **bukan pixel-perfect target** karena mockup memasukkan bezel dan status bar iOS. Golden test memotret Flutter widget/device tanpa bezel. Skenario wajib: onboarding awal, skip onboarding, 0 audit, 1 audit, font 200%, high contrast, keyboard navigation, dan tab switch state retention.
