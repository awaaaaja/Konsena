import 'package:flutter/material.dart';

/// Minimal navigation shell.
///
/// Phase 01B replaces the single child with the five-tab bottom navigation and
/// the S00–S39 route map; Phase 00 only proves that nested routing works.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KONSENA AI'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: child,
    );
  }
}
