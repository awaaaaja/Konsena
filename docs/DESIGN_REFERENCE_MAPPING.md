# KONSENA AI v3 — Mapping sumber Stitch ke Flutter

**Tanggal audit:** 7 November 2026. **Status:** dokumen desain, bukan kode yang sudah dibangun.

## Yang benar-benar tersedia dalam ZIP

| Artefak ZIP | Jenis | Dampak implementasi |
|---|---|---|
| `s00_splash_screen/code.html` | HTML referensi | Splash gradient radial ungu, logo KONSENA, tagline, tanpa OS permission prompt |
| `s01_onboarding/code.html` | HTML referensi | Headline, `Lewati`, CTA bulat, ruang lega, copy privasi mudah dipahami |
| `01_dashboard/code.html` | HTML referensi | Header, hero CTA, ringkasan, 3 langkah, bar 5 tab |
| `01_dashboard/screen.png` | screenshot UI | Kontrak komposisi S03, **bukan** pixel-perfect Android target |
| `luminous_violet_guardian/DESIGN.md` | tokens/pattern | Plus Jakarta Sans, radius, ambient shadow, soft glow, semantic colors |

**Tidak ada** screenshot atau HTML untuk halaman S02/S04–S39 pada ZIP. Jika Claude Code membutuhkan visual, turunkan pola dari `DESIGN_SYSTEM.md`; tidak mengarang referensi lainnya.

## Mapping detail layar

### S00 — Splash

- Latar full-bleed radial violet-black sesuai referensi tanpa iOS status bar palsu.
- Aset PNG ungu transparan pada center, logo tidak digambar ulang dari bentuk generik.
- Brand copy `Konsena AI`, tagline `Pahami, Kendalikan, dan Lindungi Data Pribadimu`.
- Bootstrap loading aktual; animasi tidak menghambat layar recovery.

### S01 — Onboarding

- Headline contoh sumber: `Ubah Kebijakan Privasi yang Rumit Jadi Mudah Dipahami`.
- Tombol `Lewati` selalu menavigasi S02; CTA lanjut, indikator slide.
- Tiga slide informasi ringkas (izin, kebijakan panjang/LiveScan, bukti) memakai hierarki dan warna yang sama.
- Hindari kalimat yang menjamin hasil hukum otomatis dan diagnosis ketidakpatuhan UU PDP.

### S03 — Dashboard

1. Header brand (logo mark di surface putih dan uppercase name). Label kecil `PRIVACY INTELLIGENCE` di bawah. Badge `DEMO` **hanya** build flavor demo.
2. Hero dark-violet gradient dengan overline `AUDIT PERSETUJUAN DIGITAL`, headline `Pahami izin. Lindungi privasi.`, body singkat, CTA putih `Mulai Audit` menuju `/audit/new`.
3. Dua kartu summary `Audit tersimpan` dan `Analisis yang tersedia` dari data nyata. Jika engine belum tersedia, tunjukkan status eksplisit, bukan hardcode angka demo atau prediksi.
4. Panel `Bagaimana cara kerjanya?`: (1) Pilih aplikasi (2) Cek izin & dokumen (3) Tinjau rekomendasi. Tiap langkah memiliki label konteks dan penjelasan accessible.
5. Bottom nav **lima**: `Beranda`, `Audit Baru`, `Pindai`, `Riwayat`, `Profil`. Ikon Pindai tengah tampil menonjol. Android safe area diperhatikan.
6. Pada perangkat kecil 320dp atau font 200%, ringkasan dua kartu berubah single column; tidak memaksakan skala mockup iPhone.

## Prioritas konflik yang eksplisit

| Isu | Dokumen v2 | Screenshot Stitch | Keputusan v3 |
|---|---|---|---|
| Bottom navigation | 4 tab | 5 tab | **5 tab** sesuai screenshot; S21 `/profile` guest-first; S24 root tab |
| Palette | `#252148`/`#5A3DAD` approved | Luminous Violet `#430CBF`/`#5B36D6` | **Palet v2 approved tetap**; Stitch mengarahkan komposisi/gradien/efek saja |
| Font | platform text theme | Plus Jakarta Sans | **Plus Jakarta Sans**, dengan fallback dan lisensi diverifikasi |
| Badge DEMO | fitur nyata + model belum siap | DEMO terlihat | **Hanya flavor demo**, tidak pada produksi |
| Angka aktivitas | dari SQLite | 0 contoh | **Query nyata**, nol bila kosong; dilarang dummy analytics |
| Card structure | dashboard lama shortcut utama | hero, dua summary, langkah | **Screenshot above fold**, quick actions dapat menjadi section lanjutan |
| Account | Settings child | tab Profile | **Profil root tab untuk tamu**; auth/sync opsional |
| S00 dan S01 | UI spesifikasi | HTML sumber | ikuti visual screenshot/HTML tanpa mengubah alur local-first |

## Komponen Flutter yang disarankan

`KonsenaTheme`, `KonsenaAppShell`, `KonsenaBottomNav`, `KonsenaBrandHeader`, `KonsenaHeroCard`, `AuditSummaryCard`, `HowItWorksCard`, `KonsenaStatusBadge`, `KonsenaPrimaryButton`, `KonsenaEmptyState`, `KonsenaUnavailableNotice`, `KonsenaSourceChip`, `KonsenaEvidenceCard`.

Simpan ukuran dan warna pada token/theme, gunakan `MediaQuery`/layout constraints yang aman; jangan menyalin CSS/Tailwind atau menampilkan elemen UI hanya demi screenshot.

## Rekomendasi uji visual

- S00, S01, S03: device 360x800, 393x852, 430x932; tablet 800dp; Android nav inset; light palette.
- `flutter test` widget/golden untuk splash, onboarding, dashboard empty, 1 audit, tab profile guest, 200% text scaling.
- Tampilan HTML iPhone pada ZIP hanyalah referensi: jangan meniru bezel iPhone, status bar jam 09:41, atau browser-only alert.
