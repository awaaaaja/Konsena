# PHASE_STATUS

Terakhir diperbarui: **2026-11-08** (Phase 03 device connected; implementation in progress)

| Phase | Nama | Status | Laporan |
|---|---|---|---|
| 00 | Setup repo Flutter dan Supabase | **PASS** | [PHASE_00_REPORT.md](PHASE_00_REPORT.md) |
| 01A | Design system, komponen dasar, aplikasi shell, guest navigation | **PASS** | [PHASE_01A_REPORT.md](PHASE_01A_REPORT.md) |
| 01B | Navigasi lima tab, route registry S00–S39, draft-safe shell | **PASS — headed browser visual check** | [PHASE_01B_REPORT.md](PHASE_01B_REPORT.md) |
| 01C | Aksesibilitas, responsive states, visual QA | **PASS — device/TalkBack ditunda; NOT_RUN** | [PHASE_01C_REPORT.md](PHASE_01C_REPORT.md) |
| 02 | Domain data, penyimpanan lokal, dan audit workspace | **PASS — automated gate; device/manual checks NOT_RUN** | [PHASE_02_REPORT.md](PHASE_02_REPORT.md) |
| 03 | Audit izin aplikasi (PackageManager), detail izin, sumber | **IN_PROGRESS — SM-A556E / API 36 connected; device acceptance pending** | [PHASE_03_REPORT.md](PHASE_03_REPORT.md) |
| 04 | Policy scanner manual + evidence map | `NOT_STARTED` | — |
| 05 | LiveScan kamera, OCR fallback, gap review | `NOT_STARTED` | — |
| 06 | Dark pattern screenshot, manual annotations, report local | `NOT_STARTED` | — |
| 07 | Auth opsional, RLS aman, cloud sync selektif | `NOT_STARTED` | — |
| 08 | PDF report, share, delete data | `NOT_STARTED` | — |
| 09 | Release hardening / pre-ML pilot | `NOT_STARTED` | — |
| 10 | ONNX integration (tertunda sampai model diserahkan) | `NOT_STARTED` | — |
| 11 | Usability, security & privacy review, beta | `NOT_STARTED` | — |

---

## Rincian Phase 00

**Status akhir: `PASS`** — ruang lingkup: fondasi repository + Flutter +
Supabase remote.

Bagian yang **TIDAK** dihitung PASS (dicatat terpisah, tidak disembunyikan):

| Bagian | Status | Keterangan |
|---|---|---|
| Supabase local (`start`, `db reset`, `test db` lokal) | **BLOCKED** | runtime kontainer tidak tersedia di mesin ini |
| `supabase test db --remote` (via CLI) | **FAIL** | CLI v3.0.0 membutuhkan kontainer lokal; pgTAP dijalankan langsung ke Postgres remote sebagai gantinya |
| Verifikasi build APK | lihat laporan §8c | status akhir ada di `PHASE_00_REPORT.md` §8a |

Bukti inti yang **sudah** dijalankan:

- `flutter analyze` → `No issues found!`
- `flutter test` → **31/31**
- `dart format --set-exit-if-changed` → **0 perubahan**
- pgTAP terhadap hosted `yjaerikykirxekukqfwu` → **38/38 + 17/17 = 55/55**
- `supabase db push --remote` → `Finished supabase db push.`, history tercatat

**Gate lanjut:** Phase 01B/01C berstatus **PASS**; pemeriksaan TalkBack/device ditunda atas arahan operator dan tetap tercatat `NOT_RUN`. Phase 02 tetap `NOT_STARTED` dan tidak dimulai dalam lingkup pekerjaan ini.

**Prasyarat sebelum Phase 07** (belum terpenuhi):

1. `KNOWN_ISSUES` **P0-001** — rotasi password DB, PAT, dan secret key.
2. `KNOWN_ISSUES` **P1-002** — putuskan tujuan project remote yang benar.
3. Alur login + explicit consent + pemilihan record (cakupan Phase 07 sendiri).
