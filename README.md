# KONSENA AI — Android (Flutter)

Audit privasi aplikasi: **guest-first**, **offline-first**, Android-first.
Semua fitur inti bekerja tanpa akun, tanpa jaringan, dan tanpa cloud. Supabase
dipakai hanya untuk sinkronisasi yang **opt-in** dan baru diaktifkan di Phase 07
setelah ada login + explicit consent.

---

## 1. Prasyarat

| Komponen | Versi terverifikasi di repo ini |
|---|---|
| Flutter (stable) | 3.47.8 — Dart 3.13.7 |
| Android SDK | 36.0.0 (`compileSdk 36`, `minSdk 24`, `targetSdk 36`) |
| JDK | 17 |
| Git | 2.47+ |
| Supabase CLI | 3.0.0 (dijalankan lewat `npx supabase ...`) |

Build Android membutuhkan `JAVA_HOME` menunjuk ke JDK 17. Jika `flutter doctor`
melaporkan *"No Java toolchains discovered"*, beri tahu path-nya per perintah:

```bash
export JAVA_HOME="$HOME/develop/jdk17"
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="$HOME/develop/android-sdk"
```

---

## 2. Menjalankan aplikasi

```bash
flutter pub get
flutter run                      # guest mode, tanpa cloud
```

### Konfigurasi (semua opsional)

Konfigurasi dibaca dari **`--dart-define`** / **`--dart-define-from-file`**.
Tanpa definisi apa pun, aplikasi tetap hidup sebagai tamu dengan status cloud
`cloudNotConfigured` — ini keadaan normal, bukan error.

Salin template lalu isi nilai asli Anda (file terisi masuk `.gitignore`):

```bash
cp tool/env/dev.example.json tool/env/dev.json
```

`tool/env/dev.example.json`:

```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT_REF.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_REPLACE_WITH_YOUR_PUBLISHABLE_KEY",
  "ENABLE_CLOUD_SYNC": false,
  "ENABLE_ML": false,
  "ENABLE_DEMO": false
}
```

| Variabel | Default | Arti |
|---|---|---|
| `SUPABASE_URL` | *(kosong)* | Project URL, **wajib `https://`**. Dashboard → Connect → Project URL |
| `SUPABASE_PUBLISHABLE_KEY` | *(kosong)* | Key klien yang aman dibawa di APK **karena semua tabel dan bucket dilindungi RLS** |
| `ENABLE_CLOUD_SYNC` | `false` | Sakelar utama sinkronisasi. **Harus tetap `false` sampai Phase 07 selesai** |
| `ENABLE_ML` | `false` | ONNX / on-device ML. Tetap `false` sampai Phase 09 lolos validasi |
| `ENABLE_DEMO` | `false` | Fixture demo. Jangan aktifkan untuk build yang menyerupai rilis |

Build dengan nilai tersebut:

```bash
flutter run --dart-define-from-file=tool/env/dev.json
flutter build apk --debug --dart-define-from-file=tool/env/dev.json
```

Alternatif per variabel: `flutter run --dart-define=ENABLE_CLOUD_SYNC=false`.
Template `.env.example` tersedia untuk alur berbasis shell, tetapi aplikasi
membaca dart-define, bukan file `.env`.

### Aplikasi menolak kredensial admin

Sebelum klien dibuat, `AppConfig` menolak:

- key berawalan `sb_secret_*`,
- JWT yang klaim `role`-nya bukan `anon` (sehingga `service_role` yang tertempel
  ditolak),
- key yang terlihat seperti placeholder dari template,
- URL non-https atau URL yang membawa `user:pass@`.

Ini pertahanan berlapis: kredensial tidak boleh sampai masuk proses, bukan
sekadar tidak boleh tercetak.

---

## 3. Perintah verifikasi

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

---

## 4. Supabase

Detail lengkap ada di [`docs/adr/ADR-0001-foundation-and-cloud.md`](docs/adr/ADR-0001-foundation-and-cloud.md)
dan laporan fase di [`docs/phase-reports/`](docs/phase-reports/).

### 4a. Local (default)

```bash
npx supabase init                       # sekali, menghasilkan supabase/config.toml
npx supabase start                       # local stack
npx supabase db reset                    # LOCAL ONLY — tidak boleh pernah menunjuk remote
npx supabase test db supabase/tests      # pgTAP lokal
npx supabase stop
```

> **Status di mesin development ini: `BLOCKED`.** Local Supabase stack tidak
> dapat dinyalakan karena runtime kontainer tidak tersedia, sehingga
> `supabase start`, `supabase db reset`, dan `supabase test db` (mode lokal)
> tercatat `NOT_RUN/BLOCKED` — **bukan** PASS. Perintah di atas tetap valid
> untuk mesin yang menyediakan runtime-nya.

### 4b. Remote (butuh izin eksplisit operator)

```bash
# token & password DB dari credential manager / CLI, jangan pernah ditempel ke chat
export SUPABASE_ACCESS_TOKEN=...         # dari supabase.com/dashboard/account/tokens
export SUPABASE_DB_PASSWORD=...          # dari Dashboard → Settings → Database

npx supabase link --project-ref <PROJECT_REF>     # verifikasi nama project dulu
npx supabase migration list --remote              # pastikan history tujuan bersih
npx supabase db push --remote                     # hanya setelah tujuan terverifikasi
npx supabase test db --remote                     # pgTAP terhadap project tujuan
```

Sebelum `db push`, cocokkan **project ref, nama project, dan region** dengan
yang diharapkan. `supabase db reset` **tidak pernah** diarahkan ke remote.

### 4c. Struktur SQL

```
supabase/
├── config.toml                  # konfigurasi project lokal
├── migrations/
│   └── 20261107084034_init_foundation_rls.sql
├── tests/
│   ├── rls_owner_isolation_test.sql   # plan 38
│   └── rls_storage_test.sql           # plan 17
└── seed.sql                     # data SINTETIS, hanya untuk db reset lokal
```

Tabel: `profiles`, `audit_records`, `audit_sources`, `findings`,
`recommendations`, `evidence_refs`. Semua mengaktifkan RLS, semua menolak `anon`, dan
setiap child membawa **composite foreign key**
`(owner_id, parent_id) → parent(owner_id, id)` sehingga kepemilikan divalidasi
oleh PostgreSQL sendiri, bukan hanya oleh policy.

Bucket `konsena-private` dibuat dengan `public = false` dan keempat operasi
dibatasi ke prefix `auth.uid()/`.

---

## 5. Keamanan kredensial

- `.env`, `tool/env/*.json` (selain `*.example.json`), dan `Kredensial.md`
  **masuk `.gitignore`**.
- `service_role`, `sb_secret_*`, password database, PAT, dan signing key JWT
  **tidak boleh** berada di file aplikasi, repo, log, atau laporan Markdown.
- Key publishable/anon memang dirancang untuk klien publik; yang menjaganya
  adalah RLS, bukan kerahasiaan key.

---

## 6. Status fase

Lihat [`docs/phase-reports/PHASE_STATUS.md`](docs/phase-reports/PHASE_STATUS.md).
Fase berikutnya: **01A** (guest UI shell).
