# PHASE_STATUS

Terakhir diperbarui **2026-11-08** untuk handoff Phase 06 Terpadu.

| Phase | Nama | Status | Laporan |
|---|---|---|---|
| 00 | Setup repo Flutter dan Supabase | **PASS** | [PHASE_00_REPORT.md](PHASE_00_REPORT.md) |
| 01A | Design system, komponen dasar, aplikasi shell, guest navigation | **PASS** | [PHASE_01A_REPORT.md](PHASE_01A_REPORT.md) |
| 01B | Navigasi lima tab, route registry S00–S39, draft-safe shell | **PASS — headed browser visual check** | [PHASE_01B_REPORT.md](PHASE_01B_REPORT.md) |
| 01C | Aksesibilitas, responsive states, visual QA | **PASS — device/TalkBack ditunda; NOT_RUN** | [PHASE_01C_REPORT.md](PHASE_01C_REPORT.md) |
| 02 | Domain data, penyimpanan lokal, dan audit workspace | **PASS — automated gate; device/manual checks NOT_RUN** | [PHASE_02_REPORT.md](PHASE_02_REPORT.md) |
| 03 | Audit izin aplikasi (PackageManager), detail izin, sumber | **PASS — SM-A556E / API 36; automated + device acceptance** | [PHASE_03_REPORT.md](PHASE_03_REPORT.md) |
| 04 | Impor kebijakan dan OCR | **PASS — automated + SM-A556E / Android 16 device acceptance** | [PHASE_04_REPORT.md](PHASE_04_REPORT.md) |
| 05 | LiveScan kamera, OCR fallback, gap review | **PASS — device acceptance confirmed by operator** | [PHASE_05_REPORT.md](PHASE_05_REPORT.md) |
| 06 Terpadu | Screenshot/evidence, audit, model QA, pilot dan rilis Android (scope legacy 06–11) | **BLOCKED untuk MVP AI. Tiga FP32 lulus QA Android. Alur Dark Pattern dari PNG dan tampilan hasil S31 terverifikasi. ConsentGap gagal parity ekspor. Cloud dan rilis publik tertahan.** | [PHASE_06_TERPADU_REPORT.md](PHASE_06_TERPADU_REPORT.md) |

> Pemetaan: baris fase legacy 06–11 digabung menjadi satu siklus Phase 06
> Terpadu sesuai prompt operator; laporan Phase 00–05 tetap histori.

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

**Prasyarat cloud dalam Phase 06 Terpadu (legacy Phase 07)** belum terpenuhi.

1. `KNOWN_ISSUES` **P0-001** — rotasi password DB, PAT, dan secret key.
2. `KNOWN_ISSUES` **P1-002** — putuskan tujuan project remote yang benar.
3. Alur login, persetujuan eksplisit, dan pemilihan record.
