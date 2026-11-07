import 'package:flutter/material.dart';

import '../../../theme/konsena_colors.dart';
import '../../../theme/konsena_spacing.dart';

/// A KONSENA-shaped status surface. State type is explicit so an empty result
/// cannot accidentally be presented as a network or permission failure.
enum KonsenaStateKind { loading, empty, error, denied, offline, unavailable }

class KonsenaStatePanel extends StatelessWidget {
  const KonsenaStatePanel({
    required this.kind,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  }) : assert((actionLabel == null) == (onAction == null));

  final KonsenaStateKind kind;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  IconData get _icon => switch (kind) {
    KonsenaStateKind.loading => Icons.hourglass_top_rounded,
    KonsenaStateKind.empty => Icons.inbox_outlined,
    KonsenaStateKind.error => Icons.error_outline_rounded,
    KonsenaStateKind.denied => Icons.lock_outline_rounded,
    KonsenaStateKind.offline => Icons.wifi_off_rounded,
    KonsenaStateKind.unavailable => Icons.info_outline_rounded,
  };

  Color get _color => switch (kind) {
    KonsenaStateKind.error => KonsenaColors.dangerRed,
    KonsenaStateKind.denied => KonsenaColors.warningAmber,
    _ => KonsenaColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_icon, color: _color, size: compact ? 24 : 32),
        SizedBox(height: compact ? KonsenaSpacing.xs : KonsenaSpacing.sm),
        Semantics(
          header: true,
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: KonsenaSpacing.xxs),
        Text(message, style: theme.textTheme.bodyMedium),
        if (kind == KonsenaStateKind.loading) ...[
          const SizedBox(height: KonsenaSpacing.sm),
          const LinearProgressIndicator(semanticsLabel: 'Sedang memuat'),
        ],
        if (actionLabel != null) ...[
          const SizedBox(height: KonsenaSpacing.sm),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    );

    return Semantics(
      liveRegion:
          kind == KonsenaStateKind.loading || kind == KonsenaStateKind.error,
      label: switch (kind) {
        KonsenaStateKind.loading => 'Memuat: $title. $message',
        KonsenaStateKind.error => 'Terjadi kesalahan: $title. $message',
        _ => null,
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(
          compact ? KonsenaSpacing.md : KonsenaSpacing.cardPadding,
        ),
        decoration: BoxDecoration(
          color: KonsenaColors.paleLavender,
          borderRadius: BorderRadius.circular(KonsenaRadii.card),
          border: Border.all(color: KonsenaColors.lavender),
        ),
        child: content,
      ),
    );
  }
}
