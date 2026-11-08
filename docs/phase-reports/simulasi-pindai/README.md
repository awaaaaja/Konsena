# Simulasi Pindai Sumber KONSENA AI

Paket uji QA Phase 06. RuangNota, SuaraRapat, PasarRona, dan AntarKini adalah aplikasi fiktif. Setiap pasangan dibuat dengan kondisi berbeda yang bisa diperiksa langsung dari dokumen atau gambar. Kolom **Harapan** adalah label yang ditetapkan dari isi bahan uji. Kolom **Keluaran** berisi keluaran paket FP32 yang dipakai saat pengujian.

## 1. Dokumen atau teks

**Alur** · Pindai Sumber → Dokumen atau teks → pilih atau buat audit → pilih jenis dokumen → pilih file atau tempel teks → periksa hasil ekstraksi dan koreksi → **Simpan koreksi dan tandai ditinjau**. Saat status berubah menjadi **Tersimpan dan ditinjau**, buka audit atau pilih **Tambah sumber lain** untuk memakai audit yang sama.

| Bahan | Variasi dan harapan saat snapshot mencatat izin | Keluaran Consent NLI |
|---|---|---|
| [D01 · RuangNota PDF](dokumen/D01-ruangnota.pdf) | Menyebut izin kamera dan kapan kamera digunakan. **Mendukung**. | Netral · 61,1% |
| [D02 · RuangNota PDF](dokumen/D02-ruangnota.pdf) | Menyatakan aplikasi tidak meminta kamera. **Bertentangan**. | Netral · 60,8% |
| [D03 · SuaraRapat TXT](dokumen/D03-suararapat.txt) | Menjelaskan izin mikrofon dan tombol rekam. **Mendukung**. | Netral · 49,7% |
| [D04 · SuaraRapat TXT](dokumen/D04-suararapat.txt) | Menyatakan aplikasi tidak meminta mikrofon dan hanya mengimpor rekaman. **Bertentangan**. | Netral · 47,1% |

Flutter menjalankan ekstraksi terhadap keempat berkas dan memeriksa bahwa kalimat izin yang berlawanan tetap utuh. Tes teks tempel memeriksa koreksi, konfirmasi sebelum membuang perubahan, status tersimpan, dan tujuan audit saat menambah sumber berikutnya. NLI menerima kutipan dari bahan uji dan pernyataan izin dengan ID Android `android.permission.CAMERA` atau `android.permission.RECORD_AUDIO`. Keluaran NLI pada tabel diukur di host dan dicocokkan melalui instrumentation Android. [Bukti teks tempel Flutter](evidence/D00-teks-tempel-flutter.png) · [Hasil model](evidence/hasil-model-host.json) · [Log NLI Samsung](evidence/android-consent_nli.log)

## 2. Screenshot persetujuan

**Alur** · Pindai Sumber → Screenshot persetujuan → audit tujuan → pilih PNG → **Atur area** → tambah catatan jika diperlukan → **Simpan dan buka audit** → **Review antarmuka** → aktifkan bantuan AI → **Periksa area ini**. Gunakan area kiri `0`, atas `0,5`, lebar `1`, tinggi `0,5`, rotasi `0°` agar crop mencakup panel keputusan. Sumber yang masih tertunda bisa dibuka lagi dari audit untuk menyelesaikan tinjauan.

| Bahan | Variasi dan harapan | Keluaran Dark Pattern |
|---|---|---|
| [S01 · PasarRona](screenshot/S01-pasarrona.png) | Terima dan tolak cookie sama mudah ditemukan. **Tidak terdeteksi**. | Tidak terdeteksi · 64,6% |
| [S02 · PasarRona](screenshot/S02-pasarrona.png) | Terima semua menonjol. Penolakan tersembunyi di pengaturan lanjutan. **Ada indikasi**. | Tidak terdeteksi · 56,3% |
| [S03 · AntarKini](screenshot/S03-antarkini.png) | Aktifkan dan Lewati memiliki penekanan setara. **Tidak terdeteksi**. | Tidak terdeteksi · 73,7% |
| [S04 · AntarKini](screenshot/S04-antarkini.png) | Pilihan promosi dicentang dari awal dan tautan penolakan memakai bahasa yang menekan. **Ada indikasi**. | Tidak terdeteksi · 57,3% |

Model melewatkan dua kasus berindikasi. Skor kelas **ada indikasi** memang naik pada kedua versi bermasalah, dari 35,4% ke 43,7% dan dari 26,3% ke 42,7%, tetapi label terpilih masih sama. Tes UI juga memastikan perubahan area atau rotasi bisa dibatalkan dengan konfirmasi dan membuka screenshot tersimpan tidak menambah revisi duplikat. [Hasil model](evidence/hasil-model-host.json) · [Log tensor Samsung](evidence/android-dark_pattern.log)

## 3. LiveScan

**Alur** · Pindai Sumber → LiveScan → audit tujuan → **Siapkan kamera** → tampilkan bingkai 1 di monitor lalu gulir ke bingkai 2 → **Tinjau hasil** → periksa koreksi dan jenis dokumen → **Simpan hasil tinjauan**. Jika kamera tidak bisa digunakan, **Bantuan izin kamera** → **Impor dokumen sebagai alternatif** memakai audit yang sama.

| Pasangan | Variasi | Hasil alur | Keluaran NLI pada teks gabungan |
|---|---|---|---|
| L01 · [bingkai 1](livescan/L01-bingkai-1.png) · [bingkai 2](livescan/L01-bingkai-2.png) | Menjelaskan pemakaian kamera. **Mendukung**. | Dua bingkai tergabung, judul bagian yang tumpang tindih muncul sekali, teks awal dan koreksi tersimpan. | Netral · 58,8% |
| L02 · [bingkai 1](livescan/L02-bingkai-1.png) · [bingkai 2](livescan/L02-bingkai-2.png) | Menyangkal permintaan kamera. **Bertentangan**. | Dua bingkai tergabung, judul bagian yang tumpang tindih muncul sekali, teks awal dan koreksi tersimpan. | Netral · 60,1% |

Kedua pasangan LiveScan memasukkan transkripsi sintetis bingkai ke `LiveScanStitcher` pada tes Flutter. Bukti mencakup konfirmasi agar koreksi tidak hilang saat kembali dan status akhir tersimpan. Pengambilan gambar monitor dengan kamera fisik belum dijalankan untuk pasangan ini. [L01 tinjauan](evidence/L01-tinjauan-flutter.png) · [L01 tersimpan](evidence/L01-tersimpan-flutter.png) · [L02 tinjauan](evidence/L02-tinjauan-flutter.png) · [L02 tersimpan](evidence/L02-tersimpan-flutter.png)

## 4. Pemeriksaan tambahan untuk model MVP

| Model | Hasil pada pasangan dan variasi baru | Bukti di Android |
|---|---|---|
| Consent NLI FP32 | **0 dari 6** cocok dengan harapan semantik. Semua netral. | 20 dari 20 cocok dengan referensi teknis, termasuk 6 kasus baru. |
| Dark Pattern FP32 | **2 dari 4** cocok dengan harapan visual. Kedua kasus berindikasi terlewat. | 18 dari 18 cocok dengan referensi teknis, termasuk 4 kasus baru. |
| Privacy Classifier FP32 | Topik utama terdeteksi pada **4 dari 4**. Set label persis cocok pada **3 dari 4**. P03 menambahkan label pilihan pengguna. | 18 dari 18 cocok dengan referensi teknis, termasuk 4 variasi baru. Model masih di jalur uji teknis. |
| ConsentGap | Paket demo dikarantina. Bukti ekspor yang tersedia mencatat 6 dari 10 prediksi cocok dengan checkpoint. | Dikeluarkan dari jalur inferensi Android. |

Kecocokan teknis membandingkan keluaran Android dengan host pada input yang sama, dengan toleransi logit 0,001. Kecocokan semantik membandingkan prediksi dengan harapan dari isi bahan uji. Sampel ini dipilih untuk menguji perbedaan yang jelas dan belum mewakili tingkat akurasi produk. [Manifest skenario](manifest.json) · [Keluaran dan skor per kelas](evidence/hasil-model-host.json) · [Log Privacy Classifier](evidence/android-privacy_classifier.log)

## 5. Bukti pelaksanaan

Nama bukti dengan akhiran `flutter` berasal dari render tes widget dengan data sintetis. Bukti dengan nama kasus tanpa akhiran tersebut berasal dari APK QA pada Samsung SM-A556E. Log teknis terpisah dari bukti layar.
