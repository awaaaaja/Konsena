import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Always offers an escape from child deep links, not only pushed routes.
class KonsenaBackButton extends StatelessWidget {
  const KonsenaBackButton({this.fallback = '/home', super.key});
  final String fallback;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Kembali',
    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    icon: const Icon(Icons.arrow_back_rounded),
    onPressed: () {
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        if (router.canPop()) {
          router.pop();
        } else {
          router.go(fallback);
        }
      } else {
        Navigator.of(context).maybePop();
      }
    },
  );
}
