import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/cloud_status.dart';
import 'home_cubit.dart';

/// Phase 00 foundation shell.
///
/// Deliberately *not* any of the S00–S39 product screens (Phase 01A/01B).
/// It exists to prove the bootstrap end-to-end: guest mode, cloud status and
/// the config contract are visible and testable without a Supabase project.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String routePath = '/';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('KONSENA AI', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Asisten analisis persetujuan dan perlindungan privasi digital',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _StatusCard(state: state),
              const SizedBox(height: 24),
              Text('Mode pengguna', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(
                state.isGuest
                    ? 'Tamu (offline) — tidak ada sesi autentikasi. '
                          'Semua data diproses dan disimpan hanya di perangkat ini.'
                    : 'Tersambung ke akun Supabase.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Text('Status cloud', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(
                state.cloudStatus.displayText,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Detail teknis: ${state.statusReason}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              Text(
                'Sinkronisasi cloud bersifat opt-in dan nonaktif secara bawaan. '
                'Unggahan bukti/OCR baru tersedia mulai Phase 07 setelah '
                'persetujuan eksplisit.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final live = state.isCloudFeatureEnabled;
    final color = live
        ? const Color(0xFF36C77B) // Success Green (DESIGN_SYSTEM.md)
        : const Color(0xFF5A3DAD); // Royal Violet (DESIGN_SYSTEM.md)

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE6FB), // Pale Lavender
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4BDD6)), // Lavender
      ),
      child: Row(
        children: [
          Icon(live ? Icons.cloud_done : Icons.cloud_off, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  live ? 'Cloud tersambung' : 'Cloud tidak aktif',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(state.cloudStatus.displayText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
