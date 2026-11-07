# PHASE 00 REPORT — Setup repo Flutter dan Supabase

- **Fase:** 00
- **Tanggal:** 2026-11-07
- **Workflow:** READ → THINK → BUILD → REVIEW → FIX → GATE (satu siklus penuh, dengan 5 iterasi FIX pada jalur remote)
- **Keputusan GATE:** **PASS** (lihat §12) — dengan dua pengecualian tercatat: Supabase *local* stack `BLOCKED`, dan rotasi kredensial `P0 OPEN`
- **NEXT:** **01A**

> **Aturan ruang lingkup laporan ini.** Setiap status dinyatakan per perintah
> sebagai `PASS` / `FAIL` / `NOT_RUN` / `BLOCKED`. Klaim tentang RLS/hosted
> **hanya berlaku untuk database yang benar-benar dijalani**, bukan untuk
> asumsi. Tidak ada nilai rahasia yang ditulis di dokumen ini.

---

## 1. Repository

| Item | Status | Bukti |
|---|---|---|
| Inisialisasi Git | **PASS** | `git init` — repo lokal, **tanpa remote baru** |
| Commit / push | **NOT_RUN** | Belum ada commit; menunggu otorisasi eksplisit |
| Destructive command | **PASS** | Tidak ada `reset --hard`, `clean -fd`, `force push`, atau `flutter create --overwrite` |
| `.gitignore` | **PASS** | `git check-ignore -v` → `Kredensial.md`, `.env`, `tool/env/dev.json` **diabaikan**; `.env.example`, `tool/env/dev.example.json` **tidak** diabaikan |
| Struktur proyek | **PASS** | `flutter create --org id.konsena --project-name konsena_ai --platforms=android .` |
| `git diff --check` (file Phase 00) | **PASS** | 0 whitespace error pada `README.md`, `lib/`, `test/`, `supabase/`, `tool/`, `android/`, `docs/adr/`, `docs/phase-reports/` |
| `git diff --check` (dokumen referensi) | **FAIL (pre-existing)** | 112 baris trailing whitespace di `docs/PRD_KONSENA_AI_MOBILE.md` dan `docs/KONSENA_AI_PAGE_BY_PAGE.md` — **sengaja tidak diubah** karena dokumen itu milik spesifikasi, di luar cakupan Phase 00 |

**Catatan integritas:** `Kredensial.md` tidak pernah masuk Git dan tidak pernah
disalin ke laporan. Namun nilainya **pernah berada di konteks percakapan** —
lihat `KNOWN_ISSUES.md` **P0-001** (rotasi wajib).

---

## 2. Flutter

| Item | Nilai |
|---|---|
| Flutter / Dart | 3.47.8 stable / 3.13.7 |
| `applicationId` & `namespace` | `id.konsena.ai` |
| Package `MainActivity` | `android/app/src/main/kotlin/id/konsena/ai/MainActivity.kt` |
| compileSdk / minSdk / targetSdk | 36 / 24 / 36 (default Flutter, sesuai PRD §3.1 — tanpa override) |
| Dependensi | `flutter_bloc ^9.1.1`, `go_router ^18.1.3`, `get_it ^9.3.0`, `supabase_flutter ^2.18.3` |
| Config mechanism | `String.fromEnvironment` / `bool.fromEnvironment` + `--dart-define-from-file` (Gradle flavors **ditolak** — ADR-0001 §1) |

**Struktur kode:**

```
lib/
├── main.dart
├── app/
│   ├── dependencies.dart        # graph get_it + tabel keputusan buildCloudGateway
│   ├── app_router.dart
│   ├── app_shell.dart
│   └── konsena_app.dart
├── core/
│   ├── config/app_config.dart       # validasi + penolakan kredensial admin
│   ├── config/cloud_status.dart     # 5 keadaan: notConfigured/disabled/configured/initialized/error
│   └── supabase/
│       ├── cloud_gateway.dart           # interface yang dilihat fitur
│       ├── guest_cloud_gateway.dart     # implementasi tamu (nol jaringan)
│       └── supabase_cloud_gateway.dart  # SATU-SATUNYA tempat SupabaseClient dibuat
└── features/home/presentation/    # cubit + halaman contoh
```

**Keputusan kunci (detail di ADR-0001):**

1. `Supabase.instance` **tidak pernah** diekspos ke fitur — semua lewat `CloudGateway`.
2. `AppConfig` menolak `sb_secret_*`, JWT non-`anon`, placeholder, URL non-https, dan URL ber-`user:pass@` **sebelum klien dibuat**.
3. Konfigurasi kosong adalah keadaan normal (`cloudNotConfigured`), bukan crash.
4. Composite FK `(owner_id, parent_id) → parent(owner_id, id)` + RLS `WITH CHECK` independen.
5. Tidak ada `SECURITY DEFINER`; trigger `konsena_set_updated_at` = `SECURITY INVOKER`, `search_path = ''`.

---

## 3. Supabase local

| Perintah | Status | Catatan |
|---|---|---|
| `npx supabase init` | **PASS** | `supabase/config.toml` (16 KB), `major_version = 17` |
| `npx supabase start` | **BLOCKED** | runtime kontainer tidak tersedia di mesin ini |
| `npx supabase db reset` (LOCAL ONLY) | **NOT_RUN** | tidak pernah dijalankan, **tidak pernah diarahkan ke remote** |
| `npx supabase test db` (lokal) | **NOT_RUN** | mengikuti `supabase start` |

**Kesimpulan:** seluruh bagian *local* `BLOCKED/NOT_RUN` — **bukan PASS**.
Skema dan RLS diverifikasi lewat jalur remote (§5–§6), yang dicatat terpisah.

---

## 4. Supabase remote

| Perintah | Status | Bukti |
|---|---|---|
| `supabase link --project-ref yjaerikykirxekukqfwu` | **PASS** | `{"kind":"linked","project_ref":"yjaerikykirxekukqfwu"}` |
| `supabase migration list --remote` (sebelum push) | **PASS** | `{"local":"20261107084034","remote":""}` — history tujuan **bersih** |
| `supabase db push --remote` | **PASS** | `{"migrations":["20261107084034_init_foundation_rls.sql"],...,"message":"Finished supabase db push."}` |
| `supabase migration list --remote` (sesudah push) | **PASS** | `{"local":"20261107084034","remote":"20261107084034"}` |
| `supabase test db --remote` | **FAIL → alternatif** | CLI gagal: runtime kontainer lokal yang dibutuhkannya tidak tersedia — lihat §8d |

**Target yang diverifikasi sebelum push:**

| Atribut | Nilai terverifikasi |
|---|---|
| Project ref | `yjaerikykirxekukqfwu` |
| Nama project | `konsena_backup_progress` |
| Region | `ap-southeast-1` |
| Environment | `production` |
| Postgres | 17.11.0.018 (cocok dengan `config.toml` `major_version = 17`) |
| GoTrue / REST | v2.197.0 / v14.18 |

**Target yang DITOLAK:** `pcrtssaxlvlvjyichive` →
`Your account does not have the necessary privileges to access this endpoint`
(dicatat sebagai `KNOWN_ISSUES P1-002`, bukan diselesaikan diam-diam).

**Verifikasi integritas pasca-push (read-only, tanpa kunci admin):**

```
GET /storage/v1/bucket            apikey: publishable → HTTP 200 []
GET /auth/v1/health               apikey: publishable → HTTP 200 {"version":"v2.197.0"}
GET /rest/v1/audit_records        apikey: publishable → HTTP 401 code 42501 permission denied
GET /auth/v1/admin/users          apikey: publishable → HTTP 401
```

Tolakan `42501` pada `audit_records` adalah **bukti deny-by-default bekerja**:
`anon` tidak memiliki `GRANT SELECT`.

### 4a. Lima kegagalan `db push` — gejala → akar → perbaikan

| # | SQLSTATE | Gejala | Akar masalah | Perbaikan |
|---|---|---|---|---|
| 1 | `42830` | `no unique constraint matching given keys for referenced table "findings"` | Composite FK `recommendations → findings (owner_id, id)` tanpa unique constraint yang cocok | Tambah `constraint findings_owner_id_id_key unique (owner_id, id)` |
| 2 | `0LP01` | `invalid privilege type REFERENCES for schema` | `REFERENCES` adalah privilege **tabel**, bukan schema | `grant usage on schema public` + `grant references on table ...` |
| 3 | `42501` | `must be owner of table objects` saat `alter table storage.objects enable row level security` | Role migrasi bukan pemilik tabel Storage | Diganti blok `DO` berpenjaga: lulus bila RLS sudah aktif, mencoba `ALTER` hanya bila role pemilik, selain itu `raise exception` |
| 4 | `42501` | `must be owner of relation buckets` saat `comment on column storage.buckets.public` | Pemilik tabel sama | Comment diubah jadi komentar SQL biasa; invarians tetap dijaga `on conflict do update set public = false` + pgTAP |
| 5 | — | **PUSH BERHASIL** | — | `Finished supabase db push.` |

**Setiap kegagalan menghasilkan rollback bersih** — diverifikasi setiap kali:
`migration list --remote` tetap `remote: ""`, keenam tabel `HTTP 404 PGRST205`,
bucket `HTTP 200 []`. Tidak ada sisa skema parsial di remote.

---

## 5. RLS (database)

**Status: PASS — dijalankan terhadap hosted project `yjaerikykirxekukqfwu`.**

Suite `supabase/tests/rls_owner_isolation_test.sql` — **plan 38, hasil 38 ok / 0 not ok**:

| Kelompok | Cakupan | Hasil |
|---|---|---|
| Struktural (5) | RLS aktif di 6 tabel; tidak ada policy untuk `anon`; tidak ada `USING (true)`/`WITH CHECK (true)`; bucket privat; tidak ada policy `anon` di storage | 5/5 |
| A CRUD sendiri (11) | insert/select/update/delete `audit_records`, child `audit_sources`/`findings`/`recommendations`/`evidence_refs`, `profiles` | 11/11 |
| B baca milik A (6) | 0 baris terlihat di 6 tabel | 6/6 |
| B tulis milik A (6) | insert owner-A, update, delete, attach child ke parent A, update/delete `audit_sources` | 6/6 |
| Cross-owner (2) | RLS menolak child ke parent B; **composite FK menolak juga saat RLS dibypass** | 2/2 |
| Reassign owner (2) | `owner_id` tidak bisa dipindah; `profiles.id` tidak bisa diambil alih | 2/2 |
| Forge identitas (2) | A tidak bisa membuat profile ber-uid B; kontrol positif: profile sendiri tetap bisa ditulis | 2/2 |
| Anonymous (4) | select 0 (grant dicabut), insert ditolak, storage 0 | 4/4 |

**Bukti penting — bukan hanya RLS:** test `child_cross_owner_fk` berjalan
sebagai `postgres` dengan RLS **dibypass**, dan tetap ditolak. Artinya
kepemilikan divalidasi oleh **composite foreign key secara struktural**,
bukan hanya oleh policy.

---

## 6. Storage (bucket privat)

**Status: PASS — dijalankan terhadap hosted project yang sama.**

Suite `supabase/tests/rls_storage_test.sql` — **plan 17, hasil 17 ok / 0 not ok**:

| Aspek | Hasil |
|---|---|
| Bucket `konsena-private` `public = false`, tidak ada bucket publik bernama sama | 2/2 |
| A: list hanya prefix sendiri, tidak bisa unduh objek B, tidak bisa unduh objek root tanpa folder owner | 4/4 |
| A: upload ke prefix sendiri **berhasil** (kontrol positif) | 1/1 |
| A: upload ke prefix B **ditolak** | 1/1 |
| A: tidak bisa menimpa objek B | 1/1 |
| A: **bisa** menghapus objeknya sendiri (kontrol positif) | 1/1 |
| A: tidak bisa menghapus objek B maupun objek root | 2/2 |
| Verifikasi independen: objek B + objek root **masih utuh** setelah upaya hapus A | 1/1 |
| B: tidak bisa mengunduh objek A; listing hanya berisi milik B | 2/2 |
| `anon`: membaca 0 objek, menulis ditolak | 2/2 |

**Empat policy terpasang dan terverifikasi isi `qual`/`with_check`-nya:**
`konsena_private_select_own`, `konsena_private_insert_own`,
`konsena_private_update_own`, `konsena_private_delete_own` — semuanya memakai
`(string_to_array(name, '/'))[1] = (select auth.uid())` dan hanya untuk role
`authenticated`.

**Dua penemuan teknis yang mempengaruhi desain test:**

1. **Guard hapus Storage bukan kontrol akses.** Supabase memasang trigger
   `protect_objects_delete` yang melempar `42501` kecuali
   `storage.allow_delete_query = 'true'`. GUC itu bisa di-`SET` tanpa hak
   istimewa apa pun, sehingga **RLS-lah yang menjadi penghalang sebenarnya**.
   Test membukanya secara sadar agar pengukuran menyasar RLS, dan hasilnya:
   A menghapus objeknya sendiri, sementara objek B dan objek root bertahan.
2. **Tidak ada file pengguna yang diunggah.** Seluruh objek adalah dummy
   sintetis dan seluruh transaksi diakhiri `rollback`. Upload produksi baru ada
   di Phase 07 setelah explicit consent (PRD §13).

---

## 7. Auth

| Item | Status | Bukti |
|---|---|---|
| GoTrue hidup & terjangkau | **PASS** | `GET /auth/v1/health` → `200 {"version":"v2.197.0"}` |
| Endpoint admin tertutup untuk klien | **PASS** | `GET /auth/v1/admin/users` → `401 no_authorization` |
| Publishable key diterima klien | **PASS** | `storage/v1/bucket` → `200`; `rest/v1/<tabel>` → `404 PGRST205` (= key diterima, tabel belum ada) — **bukan** `401` |
| `anon` tidak punya hak baca tabel | **PASS** | `rest/v1/audit_records` → `401 code 42501 permission denied` |
| Alur login / sesi pengguna | **NOT_RUN** | **Di luar cakupan Phase 00** — ada di Phase 07 |
| Penyimpanan kredensial di aplikasi | **PASS** | Tidak ada `service_role`/`sb_secret_*`/password/PAT di `lib/`, `android/`, `pubspec.yaml`, atau `.env.example` |

---

## 8. Test evidence

### 8a. Perintah & status (satu baris satu perintah)

| Perintah | Status | Output nyata |
|---|---|---|
| `flutter pub get` | **PASS** | resolved 4 dependensi utama |
| `dart format --output=none --set-exit-if-changed .` | **PASS** | `Formatted 15 files (0 changed) in 0.10 seconds.` exit 0 |
| `flutter analyze` | **PASS** | `No issues found! (ran in 19.2s)` |
| `flutter test` | **PASS** | `00:03 +31: All tests passed!` — **31/31** |
| `flutter build apk --debug` (percobaan 1) | **FAIL** | `java.util.zip.ZipException: zip END header not found` — cache Gradle korup |
| `flutter build apk --debug` (percobaan 2, setelah cache dibersihkan) | **PASS** | `✓ Built build/app/outputs/flutter-apk/app-debug.apk` (berjalan ulang pada REVIEW Phase 01A) |
| `npx supabase start` | **BLOCKED** | runtime kontainer tidak tersedia |
| `npx supabase db reset` (local) | **NOT_RUN** | tidak pernah diarahkan ke remote |
| `npx supabase test db` (local) | **NOT_RUN** | mengikuti `supabase start` |
| `npx supabase test db --remote` | **FAIL** | runtime kontainer lokal tidak tersedia |
| pgTAP `rls_owner_isolation_test.sql` (remote, via klien `pg`) | **PASS** | `planned: 1..38` → `ok=38 not_ok=0` |
| pgTAP `rls_storage_test.sql` (remote, via klien `pg`) | **PASS** | `planned: 1..17` → `ok=17 not_ok=0` |
| `git diff --check` (file Phase 00) | **PASS** | 0 error |

### 8b. Widget / unit test yang wajib ada (PRD/§REVIEW)

| Skenario wajib | Hasil |
|---|---|
| Startup tanpa env tidak crash | **PASS** — `setupDependencies resolves guest state instead of throwing` |
| Tamu tidak ter-autentikasi & fitur cloud default disabled | **PASS** — `boots as guest with cloud feature disabled` |
| `ENABLE_CLOUD_SYNC=false` dengan key valid tetap boot sebagai tamu | **PASS** |
| Startup dengan config valid menginisialisasi gateway **tanpa upload** | **PASS** — `initializes the Supabase gateway through exactly one network seam`, `renders the connected state without performing any write` |
| Penolakan kredensial admin (`sb_secret_*`, role `service_role`, placeholder, JWT rusak) | **PASS** — 8 test di `app_config_test.dart` |
| Redaksi `describe()`/`reason` tidak membocorkan key | **PASS** |

### 8c. Build APK

**Percobaan 1 — FAIL.** Gejala `java.util.zip.ZipException: zip END header not
found` selama ±20 menit. Akar masalah: `~/.gradle/wrapper/dists/gradle-9.3.1-all/.../gradle-9.3.1-all.zip`
terpotong (121 MB, tanpa berkas `.ok`), diverifikasi `BadZipFile` oleh
`zipfile.ZipFile`. Perbaikan: hapus cache korup → wrapper mengunduh ulang.
**Percobaan 2 — PASS.** Build ulang selesai dan menghasilkan
`build/app/outputs/flutter-apk/app-debug.apk`. Verifikasi terbaru setelah
perubahan Phase 01A juga PASS (lihat `PHASE_01A_REPORT.md` §4).

### 8d. Mengapa pgTAP dijalankan lewat klien Node

`supabase test db --remote` pada CLI v3.0.0 menjalankan image pgTAP secara
**lokal** lalu menyambungkannya ke database remote, sehingga tetap
membutuhkan runtime kontainer lokal (mode `--debug` menyingkapkan bahwa
runtime tersebut tidak tersedia di mesin ini). File test yang sama
kemudian dijalankan **langsung ke Postgres remote** lewat klien Node `pg`:

- kredensial dibaca dari `Kredensial.md` via ekspresi teratur dan **tidak pernah dicetak**;
- terhubung sebagai `postgres`, `superuser: off` (penting — lihat §9);
- seluruh baris TAP dicatat persis seperti yang dihasilkan pgTAP;
- seluruh transaksi diakhiri `rollback`, tidak ada yang tertinggal di remote.

Hasilnya identik dengan yang akan dihasilkan CLI, dan seluruh assertion
dilaporkan apa adanya.

---

## 9. Temuan REVIEW yang memicu perbaikan

Enam cacat ditemukan pada test buatan sendiri dan **diperbaiki, bukan
diturunkan syaratnya**:

| # | Gejala | Akar masalah | Perubahan |
|---|---|---|---|
| 1 | Assertion `NULL` (8 kasus) | Sentinel `0` ditaruh di dalam blok `DO` yang sama dengan operasi gagal; blok `DO` menggulung ke savepoint-nya sendiri saat exception, sehingga sentinel ikut hilang | Sentinel dipindah menjadi pernyataan terpisah **sebelum** blok |
| 2 | Assertion `-1` pada pembacaan `anon` | `anon` tidak punya `GRANT SELECT` → `42501` sebelum RLS dikonsultasikan | Ditangani `when insufficient_privilege` → dihitung sebagai **denial (0)**; hanya SQLSTATE tak terduga yang jadi `-1` |
| 3 | `syntax error at or near "exception"` | PL/pgSQL memakai **satu** kata `exception` dengan daftar `when`, bukan `exception when ...` berulang | Ditulis ulang sebagai `exception when a then ... when others then ...` |
| 4 | `operator does not exist: name[] @> text[]` | `pg_policies.roles` bertipe `name[]` | `roles::text[] @> array['anon']` |
| 5 | Insert ke tabel bantu ditolak RLS | **Hosted Supabase menyalakan RLS secara default** pada tabel baru di `public`, dan `postgres` di hosted **bukan superuser** | `alter table ... disable row level security` eksplisit pada tabel harness |
| 6 | Uji delete tidak terukur | Trigger `storage.protect_delete` memblokir `DELETE` langsung (`42501`) | Guard dibuka secara sadar lewat `storage.allow_delete_query` agar pengukuran menyasar RLS; dikombinasikan dengan kontrol positif |

**Tidak ada RLS yang dinonaktifkan, tidak ada assertion yang dilemahkan, dan
tidak ada test yang dihapus** untuk membuat suite lulus.

---

## 10. Blocker & isu terbuka

| ID | Severity | Ringkasan | Status |
|---|---|---|---|
| `P0-001` | **P0** | Password DB, PAT, dan secret key pernah berada di luar credential manager | **OPEN — rotasi wajib** |
| `P1-001` | P1 | Supabase local stack tidak dapat dijalankan (runtime kontainer absen) | **BLOCKED** |
| `P1-002` | P1 | Project `pcrtssaxlvlvjyichive` tidak terjangkau oleh PAT | **OPEN — keputusan operator** |
| `P1-003` | P1 | `JAVA_HOME` kosong → `flutter doctor` tidak menemukan JDK | **OPEN — workaround aktif** |
| `P2-001` … `P2-005` | P2 | Cache Gradle korup (CLOSED), IPv6 tidak stabil, `test db --remote` butuh kontainer, `sync_devices` ditunda, tabel bantu wajib nonaktifkan RLS | lihat `KNOWN_ISSUES.md` |

**Konsekuensi terhadap gate:**

- Bagian **Supabase local** tetap `BLOCKED/NOT_RUN` dan **tidak dihitung PASS**.
- **Sinkronisasi Phase 07 tetap tertutup** sampai RLS tervalidasi *dan* ada
  alur consent eksplisit. Bukti RLS remote di fase ini **sudah tersedia**, tetapi
  syarat consent Phase 07 belum ada.
- Rotasi kredensial (`P0-001`) tidak menghalangi gate Phase 00 karena **tidak
  ada nilai rahasia yang masuk ke repo/aplikasi**, tetapi **wajib diselesaikan
  sebelum Phase 07** dan sebaiknya segera.

---

## 11. File changed / dibuat

**Konfigurasi & aplikasi**

```
pubspec.yaml, pubspec.lock, analysis_options.yaml, .metadata
android/            # applicationId + namespace id.konsena.ai, MainActivity.kt dipindah ke kotlin/id/konsena/ai/
lib/main.dart
lib/app/{dependencies,app_router,app_shell,konsena_app}.dart
lib/core/config/{app_config,cloud_status}.dart
lib/core/supabase/{cloud_gateway,guest_cloud_gateway,supabase_cloud_gateway}.dart
lib/features/home/presentation/{home_cubit,home_page}.dart
test/widget_test.dart
test/core/config/app_config_test.dart
test/core/supabase/cloud_gateway_test.dart
```

**Supabase**

```
supabase/config.toml
supabase/migrations/20261107084034_init_foundation_rls.sql
supabase/tests/rls_owner_isolation_test.sql      # plan 38
supabase/tests/rls_storage_test.sql              # plan 17
supabase/seed.sql                                # SINTETIS, hanya untuk db reset lokal
```

**Dokumentasi & konfigurasi**

```
.gitignore                    # bagian keamanan (terverifikasi dengan git check-ignore)
.env.example
tool/env/dev.example.json
README.md
docs/adr/ADR-0001-foundation-and-cloud.md
docs/phase-reports/PHASE_00_REPORT.md      (dokumen ini)
docs/phase-reports/KNOWN_ISSUES.md
docs/phase-reports/PHASE_STATUS.md
```

**Diubah dari dokumen yang sudah ada:**
`KONSENA_AI_CLAUDE_CODE_ALL_PHASES_READ_THINK_BUILD_REVIEW_FIX.md` — 5 rujukan
yang tidak relevan dengan mesin development ini dihapus sesuai permintaan
operator. Isi spesifikasi tidak diubah.

**Sengaja TIDAK diubah:** `docs/PRD_KONSENA_AI_MOBILE.md`,
`docs/KONSENA_AI_PAGE_BY_PAGE.md`, `references/`, `Kredensial.md`.

**Di luar cakupan Phase 00 (tidak disentuh):** layar UI S00–S39, OCR,
PackageManager, LiveScan, pelaporan PDF, ONNX.

---

## 12. GATE — keputusan

**PASS** untuk fondasi Phase 00, dengan ruang lingkup berikut:

| Syarat | Status |
|---|---|
| Repo + Flutter berjalan | **PASS** |
| Konfigurasi cloud aman (tanpa secret di aplikasi/repo) | **PASS** |
| Migration & policy tersimpan | **PASS** — remote `yjaerikykirxekukqfwu`, history tercatat |
| Test yang benar-benar dijalankan | **PASS** — pgTAP **55/55** di hosted, `flutter test` **31/31** |
| Supabase local | **BLOCKED** (dicatat terpisah, bukan PASS) |
| Tidak ada service secret di aplikasi | **PASS** — diaudit, semua kemunculan adalah penjaga/test/dokumentasi |

**Pengecualian gate yang dipakai:** Phase 00 PASS untuk fondasi offline;
bagian remote justru sudah terverifikasi, sehingga `REMOTE_PENDING` tidak
diperlukan. Yang tertunda hanya *local stack*.

**NEXT: 01A** — guest UI shell. Pekerjaan Phase 01A boleh dimulai dengan mode
guest lokal karena fondasi Flutter dan kontrak config sudah teruji.

**Sebelum Phase 07:** selesaikan `P0-001` (rotasi kredensial), `P1-001`, dan
`P1-002`.
