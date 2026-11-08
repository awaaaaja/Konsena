/// Canonical screen IDs and paths from `KONSENA_AI_PAGE_BY_PAGE.md` §D.
///
/// Aliases are deliberately not represented here: `/account` redirects to
/// `/profile` and must never inflate the product's screen count.
enum ScreenId {
  s00,
  s01,
  s02,
  s03,
  s04,
  s05,
  s06,
  s07,
  s08,
  s09,
  s10,
  s11,
  s12,
  s13,
  s14,
  s15,
  s16,
  s17,
  s18,
  s19,
  s20,
  s21,
  s22,
  s23,
  s24,
  s25,
  s26,
  s27,
  s28,
  s29,
  s30,
  s31,
  s32,
  s33,
  s34,
  s35,
  s36,
  s37,
  s38,
  s39;

  String get code => 'S${name.substring(1).padLeft(2, '0')}';
}

enum AppTab { home, audit, scan, history, profile }

class ScreenSpec {
  const ScreenSpec({
    required this.id,
    required this.path,
    required this.title,
    required this.summary,
    required this.availability,
    this.tab,
  });

  final ScreenId id;
  final String path;
  final String title;
  final String summary;
  final String availability;
  final AppTab? tab;

  List<String> get parameterNames =>
      RegExp(r':([A-Za-z][A-Za-z0-9_]*)')
          .allMatches(path)
          .map((match) => match.group(1)!)
          .toList(growable: false);
}

abstract final class RouteRegistry {
  static const List<ScreenSpec> screens = [
    ScreenSpec(
      id: ScreenId.s00,
      path: '/splash',
      title: 'Memulai KONSENA AI',
      summary: 'Menyiapkan preferensi dan perjalanan lokal.',
      availability: 'Bootstrap lokal tersedia.',
    ),
    ScreenSpec(
      id: ScreenId.s01,
      path: '/welcome',
      title: 'Selamat datang',
      summary: 'Pahami cara kerja KONSENA AI sebelum memulai.',
      availability: 'Onboarding tersedia.',
    ),
    ScreenSpec(
      id: ScreenId.s02,
      path: '/privacy-setup',
      title: 'Pengaturan Privasi',
      summary: 'Pilih cara menyimpan dan mengelola data.',
      availability: 'Pengaturan guest tersedia.',
    ),
    ScreenSpec(
      id: ScreenId.s03,
      path: '/home',
      title: 'Beranda',
      summary: 'Ringkasan lokal dan pintasan audit.',
      availability: 'Dashboard tersedia.',
      tab: AppTab.home,
    ),
    ScreenSpec(
      id: ScreenId.s04,
      path: '/audit/apps',
      title: 'Pilih Aplikasi',
      summary: 'Pilih aplikasi yang terlihat melalui query launcher Android.',
      availability: 'Aktif — cakupan terbatas pada aplikasi yang terlihat.',
    ),
    ScreenSpec(
      id: ScreenId.s05,
      path: '/audit/apps/:package',
      title: 'Detail Izin Aplikasi',
      summary: 'Snapshot deklarasi/grant izin Android, bukan penggunaan izin.',
      availability: 'Aktif — Settings dan refresh snapshot tersedia.',
    ),
    ScreenSpec(
      id: ScreenId.s06,
      path: '/scan',
      title: 'Pindai Sumber',
      summary: 'Pilih dokumen, kamera, atau screenshot sebagai sumber.',
      availability: 'Hub navigasi tersedia.',
      tab: AppTab.scan,
    ),
    ScreenSpec(
      id: ScreenId.s07,
      path: '/scan/import',
      title: 'Impor Dokumen',
      summary:
          'Impor file atau teks; PDF diekstrak lokal dan OCR menjadi fallback.',
      availability: 'Aktif — hasil ekstraksi perlu ditinjau.',
    ),
    ScreenSpec(
      id: ScreenId.s08,
      path: '/scan/camera/setup',
      title: 'Persiapan Kamera',
      summary: 'Atur ROI dan berikan izin kamera hanya saat memulai LiveScan.',
      availability: 'Izin diminta just-in-time sebelum kamera dibuka.',
    ),
    ScreenSpec(
      id: ScreenId.s09,
      path: '/scan/camera/live',
      title: 'LiveScan',
      summary:
          'Capture lokal satu frame pada satu waktu; pause untuk berhenti.',
      availability: 'Kamera aktif hanya selama layar capture digunakan.',
    ),
    ScreenSpec(
      id: ScreenId.s10,
      path: '/scan/camera/merge',
      title: 'Rekonstruksi Dokumen',
      summary: 'Tinjau hasil merge, duplikasi, dan kemungkinan gap.',
      availability: 'Hasil OCR tetap perlu koreksi pengguna.',
    ),
    ScreenSpec(
      id: ScreenId.s11,
      path: '/scan/review/:docId',
      title: 'Review Teks',
      summary: 'Koreksi paragraf hasil impor dengan jejak sumber dan halaman.',
      availability: 'Aktif — review manual, bukan analisis hukum.',
    ),
    ScreenSpec(
      id: ScreenId.s12,
      path: '/consent-ui/import',
      title: 'Impor Screenshot',
      summary:
          'Pilih PNG/JPEG melalui pemilih berkas untuk audit yang dipilih.',
      availability: 'Aktif — simpan sumber terenkripsi lokal.',
    ),
    ScreenSpec(
      id: ScreenId.s13,
      path: '/consent-ui/review',
      title: 'Review Elemen Persetujuan',
      summary: 'Crop, rotasi, metadata dan anotasi manual bersumber.',
      availability: 'Aktif — bukan klasifikasi AI.',
    ),
    ScreenSpec(
      id: ScreenId.s14,
      path: '/audit/:id/sources',
      title: 'Workspace Audit',
      summary: 'Kelola sumber untuk audit lokal ini.',
      availability: 'Audit dan sumber tersimpan lokal terenkripsi.',
    ),
    ScreenSpec(
      id: ScreenId.s15,
      path: '/audit/:id/results',
      title: 'Status Analisis',
      summary: 'Belum ada hasil analisis tervalidasi untuk ditampilkan.',
      availability: 'Engine analisis belum tersedia; tidak ada score atau temuan simulasi.',
    ),
    ScreenSpec(
      id: ScreenId.s16,
      path: '/audit/:id/evidence/:evidenceId',
      title: 'Bukti Audit',
      summary: 'Bukti hanya dapat dibuka jika terhubung ke sumber nyata.',
      availability: 'Belum ada evidence tersimpan.',
    ),
    ScreenSpec(
      id: ScreenId.s17,
      path: '/audit/:id/actions',
      title: 'Tindakan Privasi',
      summary: 'Rekomendasi menunggu fakta dan sumber yang dapat diverifikasi.',
      availability: 'Belum ada rekomendasi audit.',
    ),
    ScreenSpec(
      id: ScreenId.s18,
      path: '/audit/:id/report',
      title: 'Laporan Audit',
      summary: 'Preview laporan faktual tersedia setelah sumber disimpan.',
      availability:
          'Preview faktual, PDF dan share lokal tersedia; AI nonaktif.',
    ),
    ScreenSpec(
      id: ScreenId.s19,
      path: '/history',
      title: 'Riwayat Audit',
      summary: 'Audit yang dibuat pada perangkat ini akan tercantum di sini.',
      availability: 'Riwayat lokal persisten, pencarian dan filter tersedia.',
      tab: AppTab.history,
    ),
    ScreenSpec(
      id: ScreenId.s20,
      path: '/settings',
      title: 'Pengaturan',
      summary: 'Kelola privasi, data, akun opsional, dan informasi aplikasi.',
      availability: 'Preferensi lokal dan halaman pengaturan tersedia.',
    ),
    ScreenSpec(
      id: ScreenId.s21,
      path: '/profile',
      title: 'Profil',
      summary: 'Gunakan aplikasi sebagai tamu; akun tetap opsional.',
      availability: 'Profil guest tersedia.',
      tab: AppTab.profile,
    ),
    ScreenSpec(
      id: ScreenId.s22,
      path: '/sync',
      title: 'Sinkronisasi Pilihan',
      summary:
          'Pilih data yang akan disinkronkan setelah login dan persetujuan.',
      availability: 'Sinkronisasi opt-in masuk Phase 07.',
    ),
    ScreenSpec(
      id: ScreenId.s23,
      path: '/about',
      title: 'Tentang KONSENA AI',
      summary: 'Misi, batasan interpretasi, privasi, dan informasi aplikasi.',
      availability: 'Informasi inti tersedia offline.',
    ),
    ScreenSpec(
      id: ScreenId.s24,
      path: '/audit/new',
      title: 'Audit Baru',
      summary:
          'Buat draft audit lokal dan pilih sumber yang ingin ditambahkan.',
      availability: 'Audit lokal tersimpan tanpa akun.',
      tab: AppTab.audit,
    ),
    ScreenSpec(
      id: ScreenId.s25,
      path: '/scan/document-type',
      title: 'Jenis Dokumen',
      summary: 'Pilih manual Privacy Policy, Terms, atau dokumen lain.',
      availability: 'Aktif — tidak menebak dokumen atau aplikasi terkait.',
    ),
    ScreenSpec(
      id: ScreenId.s26,
      path: '/scan/import/progress',
      title: 'Progres Impor',
      summary: 'Progres ekstraksi PDF dan OCR on-device dengan cancel/retry.',
      availability: 'Aktif — teks disimpan lokal untuk direview.',
    ),
    ScreenSpec(
      id: ScreenId.s27,
      path: '/scan/camera/gaps',
      title: 'Bagian yang Terlewat',
      summary: 'Pemeriksaan gap membutuhkan sesi LiveScan tersimpan.',
      availability: 'LiveScan masuk Phase 05.',
    ),
    ScreenSpec(
      id: ScreenId.s28,
      path: '/document/:docId/clauses',
      title: 'Dokumen dan Klausul',
      summary: 'Pembacaan manual atas paragraf dokumen dan sumbernya.',
      availability: 'Aktif — klasifikasi AI tidak aktif.',
    ),
    ScreenSpec(
      id: ScreenId.s29,
      path: '/audit/:id/compare',
      title: 'Bandingkan Izin dan Kebijakan',
      summary: 'Perbandingan belum dapat diverifikasi tanpa sumber dan engine.',
      availability: 'ConsentGap belum tersedia; tidak ada label temuan palsu.',
    ),
    ScreenSpec(
      id: ScreenId.s30,
      path: '/audit/:id/risk',
      title: 'Faktor Privasi',
      summary: 'Faktor risiko belum memiliki rubric tervalidasi; skor tidak ditampilkan.',
      availability: 'Analisis risiko belum tersedia.',
    ),
    ScreenSpec(
      id: ScreenId.s31,
      path: '/audit/:id/dark-pattern',
      title: 'Review Pola Antarmuka',
      summary:
          'Tidak ada klasifikasi atau anotasi visual yang dibuat otomatis.',
      availability: 'Deteksi pola gelap belum tersedia.',
    ),
    ScreenSpec(
      id: ScreenId.s32,
      path: '/audit/:id/actions/:actionId',
      title: 'Detail Tindakan',
      summary: 'Detail tindakan memerlukan rekomendasi bersumber.',
      availability: 'Belum ada tindakan audit.',
    ),
    ScreenSpec(
      id: ScreenId.s33,
      path: '/audit/:id/report/export',
      title: 'Ekspor Laporan',
      summary: 'Buat PDF baru dari SQLite saat dibuka atau dibagikan.',
      availability: 'Aktif — berbagi hanya melalui tindakan pengguna.',
    ),
    ScreenSpec(
      id: ScreenId.s34,
      path: '/history/:auditId',
      title: 'Detail Riwayat',
      summary:
          'Audit hanya dapat dipulihkan jika tersimpan di repository lokal.',
      availability: 'Detail dan resume audit lokal tersedia.',
    ),
    ScreenSpec(
      id: ScreenId.s35,
      path: '/scan/camera/troubleshoot',
      title: 'Bantuan Kamera',
      summary: 'Belum ada error kamera; permission tidak diminta dari halaman bantuan.',
      availability: 'Kamera masuk Phase 05; impor berkas menjadi alternatif.',
    ),
    ScreenSpec(
      id: ScreenId.s36,
      path: '/settings/data',
      title: 'Kontrol Data',
      summary: 'Lihat penjelasan penyimpanan lokal dan batas kontrol saat ini.',
      availability:
          'Ekspor audit terpilih, hapus audit dan cache lokal tersedia.',
    ),
    ScreenSpec(
      id: ScreenId.s37,
      path: '/sync/conflicts/:itemId',
      title: 'Konflik Sinkronisasi',
      summary: 'Tidak ada data cloud yang akan ditimpa atau direkonsiliasi.',
      availability: 'Sinkronisasi konflik masuk Phase 07.',
    ),
    ScreenSpec(
      id: ScreenId.s38,
      path: '/audit/:id/source-match',
      title: 'Cocokkan Sumber',
      summary: 'Pencocokan memerlukan metadata sumber yang nyata.',
      availability: 'Sumber belum tersimpan; tidak ada kecocokan otomatis.',
    ),
    ScreenSpec(
      id: ScreenId.s39,
      path: '/scan/camera/how-to',
      title: 'Panduan LiveScan',
      summary: 'Panduan menyiapkan layar laptop dan memindai secara bertanggung jawab.',
      availability: 'Panduan tersedia; capture kamera masuk Phase 05.',
    ),
  ];

  static final Map<ScreenId, ScreenSpec> byId = {
    for (final spec in screens) spec.id: spec,
  };

  static ScreenSpec get(ScreenId id) => byId[id]!;

  static String? validateParameters(
    ScreenSpec spec,
    Map<String, String> parameters,
  ) {
    for (final name in spec.parameterNames) {
      final value = parameters[name];
      if (value == null || value.isEmpty || value.length > 200) {
        return 'Parameter "$name" kosong atau terlalu panjang.';
      }
      final pattern = name == 'package'
          ? RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]*$')
          : RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]*$');
      if (!pattern.hasMatch(value)) {
        return 'Format parameter "$name" tidak valid.';
      }
    }
    return null;
  }
}
