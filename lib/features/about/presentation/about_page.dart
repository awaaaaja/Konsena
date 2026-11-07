import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/konsena_spacing.dart';

/// S23 — offline product boundaries and user-facing interpretation guidance.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tentang KONSENA AI')),
    body: ListView(
      padding: const EdgeInsets.all(KonsenaSpacing.lg),
      children: [
        Text(
          'Privasi yang dapat dipahami',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: KonsenaSpacing.sm),
        const Text(
          'KONSENA AI membantu meninjau izin aplikasi dan sumber kebijakan privasi secara transparan. Data lokal tidak dikirim ke cloud tanpa pilihan dan persetujuan terpisah.',
        ),
        const SizedBox(height: KonsenaSpacing.lg),
        Text('Batasan penting', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: KonsenaSpacing.xs),
        const _Boundary(
          text: 'KONSENA AI bukan antivirus dan tidak membuktikan penyalahgunaan data.',
        ),
        const _Boundary(
          text: 'Informasi izin yang diminta tidak membuktikan bagaimana izin tersebut digunakan.',
        ),
        const _Boundary(
          text: 'Status AI, skor risiko, dan klasifikasi pola gelap tidak ditampilkan sebelum engine tervalidasi tersedia.',
        ),
        const _Boundary(
          text: 'Penjelasan aplikasi bukan nasihat hukum. Periksa kebijakan sumber dan konteksnya sendiri.',
        ),
        const SizedBox(height: KonsenaSpacing.lg),
        const Text(
          'Fitur teknis kamera, impor, sinkronisasi, dan ekspor akan dijelaskan di layar masing-masing sebelum digunakan. Fitur tersebut tidak berjalan di Phase 01B.',
        ),
        const SizedBox(height: KonsenaSpacing.lg),
        OutlinedButton.icon(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.tune_rounded),
          label: const Text('Buka Pengaturan'),
        ),
      ],
    ),
  );
}

class _Boundary extends StatelessWidget {
  const _Boundary({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: KonsenaSpacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline_rounded, size: 20),
        const SizedBox(width: KonsenaSpacing.sm),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
