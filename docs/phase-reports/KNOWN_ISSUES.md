# KNOWN_ISSUES — KONSENA AI

Diperbarui: 2026-11-07 (Phase 00)
Aturan: isu tidak disembunyikan. Setiap entri memuat severity, gejala,
reproduksi, solusi/owner, dan status.

Severity: **P0** = keamanan/privasi atau data, **P1** = menghalangi gate fase,
**P2** = penghambat kenyamanan/teknis.

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
