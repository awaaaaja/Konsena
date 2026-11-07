import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/konsena_spacing.dart';

/// Recovery for genuinely unknown or malformed URLs; never an empty 404.
class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({required this.location, super.key});
  final String location;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tautan tidak dapat dibuka')),
    body: Padding(
      padding: const EdgeInsets.all(KonsenaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.link_off_rounded, size: 40),
          const SizedBox(height: KonsenaSpacing.md),
          Text(
            'Rute ini tidak terdaftar di indeks S00–S39.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: KonsenaSpacing.xs),
          Text('Tautan: $location'),
          const SizedBox(height: KonsenaSpacing.lg),
          FilledButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_outlined),
            label: const Text('Ke Beranda'),
          ),
          const SizedBox(height: KonsenaSpacing.xs),
          OutlinedButton.icon(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person_outline_rounded),
            label: const Text('Ke Profil guest'),
          ),
        ],
      ),
    ),
  );
}
