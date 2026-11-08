import 'package:flutter/material.dart';

import '../../../domain/audit/audit_entities.dart';

class AuditSummaryPanel extends StatelessWidget {
  const AuditSummaryPanel({
    required this.name,
    required this.sources,
    required this.snapshotCount,
    required this.updatedAt,
    super.key,
  });
  final String name;
  final List<DocumentSource> sources;
  final int snapshotCount;
  final DateTime updatedAt;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reviewed = sources
        .where((s) => s.reviewStatus == SourceReviewStatus.reviewed)
        .length;
    final items = [
      (
        Icons.android_rounded,
        'Snapshot izin',
        snapshotCount,
        'Fakta dari Android',
      ),
      (
        Icons.policy_outlined,
        'Privacy Policy',
        sources.where((s) => s.type == AuditSourceType.privacyPolicy).length,
        'Praktik data pribadi',
      ),
      (
        Icons.gavel_outlined,
        'Terms',
        sources.where((s) => s.type == AuditSourceType.terms).length,
        'Ketentuan layanan',
      ),
      (
        Icons.image_search_rounded,
        'Screenshot',
        sources.where((s) => s.type == AuditSourceType.consentUi).length,
        'Bukti antarmuka',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.fact_check_outlined,
                size: 32,
                color: colors.onPrimaryContainer,
              ),
              const SizedBox(height: 12),
              Text(name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('$reviewed dari ${sources.length} sumber sudah ditinjau'),
              Text(
                'Diperbarui ${updatedAt.toLocal().toString().split(".").first}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth >= 360 &&
                    MediaQuery.textScalerOf(context).scale(1) < 1.5
                ? 2
                : 1;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in items)
                  SizedBox(
                    width:
                        (constraints.maxWidth - 12 * (columns - 1)) / columns,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border.all(color: colors.outlineVariant),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(item.$1, color: colors.primary),
                              const Spacer(),
                              Text(
                                '${item.$3}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.$2,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            item.$3 == 0 ? 'Belum ditambahkan' : item.$4,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 20, color: colors.primary),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Sumber boleh parsial. Tinjau jenis, versi, dan aplikasi terkait sebelum membandingkan.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
