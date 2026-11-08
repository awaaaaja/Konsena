import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/konsena_spacing.dart';
import '../../shared/widgets/konsena_back_button.dart';

/// S23 — offline product boundaries and user-facing interpretation guidance.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const KonsenaBackButton(fallback: '/profile'),
      title: const Text('Tentang KONSENA AI'),
    ),
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
          text: 'Skor risiko dan klasifikasi pola gelap memerlukan engine yang tervalidasi.',
        ),
        const _Boundary(
          text: 'Penjelasan aplikasi bukan nasihat hukum. Periksa kebijakan sumber dan konteksnya sendiri.',
        ),
        const SizedBox(height: KonsenaSpacing.lg),
        const _ModelAvailability(),
        const SizedBox(height: KonsenaSpacing.lg),
        const Text(
          'Layar kamera, impor, sinkronisasi, dan ekspor menjelaskan ketersediaan dan cara penggunaan masing-masing fitur.',
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

class _ModelAvailability extends StatefulWidget {
  const _ModelAvailability();

  @override
  State<_ModelAvailability> createState() => _ModelAvailabilityState();
}

typedef _ModelStatus = ({String name, String reason});

class _ModelAvailabilityState extends State<_ModelAvailability> {
  late Future<List<_ModelStatus>> _models;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _models = _load(DefaultAssetBundle.of(context));
  }

  static Future<List<_ModelStatus>> _load(AssetBundle bundle) async {
    final content = await bundle.loadString('assets/models/catalog.json');
    final catalog = jsonDecode(content) as Map<String, dynamic>;
    if (catalog['schemaVersion'] != 1) {
      throw const FormatException('Unsupported model catalog version');
    }
    final models = catalog['models'] as List<dynamic>;
    return [
      for (final model in models.cast<Map<String, dynamic>>())
        (name: model['name'] as String, reason: model['reason'] as String),
    ];
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Model AI', style: Theme.of(context).textTheme.titleLarge),
      const Text('Analisis AI belum tersedia.'),
      FutureBuilder<List<_ModelStatus>>(
        future: _models,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Daftar model tidak dapat dimuat.');
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final model in snapshot.data ?? const [])
                Padding(
                  padding: const EdgeInsets.only(top: KonsenaSpacing.sm),
                  child: Text('${model.name} — ${model.reason}'),
                ),
            ],
          );
        },
      ),
    ],
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
