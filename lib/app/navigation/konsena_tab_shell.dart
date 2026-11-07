import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/konsena_colors.dart';

/// Persistent five-branch Material navigation. Branch stacks and widget state
/// are retained by `StatefulShellRoute.indexedStack` while users switch tabs.
class KonsenaTabShell extends StatelessWidget {
  const KonsenaTabShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const labels = [
    'Beranda',
    'Audit Baru',
    'Pindai',
    'Riwayat',
    'Profil',
  ];

  static const _icons = [
    Icons.home_outlined,
    Icons.assignment_outlined,
    Icons.document_scanner_outlined,
    Icons.history_rounded,
    Icons.person_outline_rounded,
  ];

  static const _selectedIcons = [
    Icons.home_rounded,
    Icons.assignment_rounded,
    Icons.document_scanner_rounded,
    Icons.history_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.3;
        final useWrappingNavigation = constraints.maxWidth < 360 || largeText;
        if (!useWrappingNavigation) {
          return NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              for (var index = 0; index < labels.length; index++)
                NavigationDestination(
                  icon: Icon(_icons[index]),
                  selectedIcon: Icon(
                    _selectedIcons[index],
                    size: index == 2 ? 28 : 24,
                  ),
                  label: labels[index],
                ),
            ],
            indicatorColor: KonsenaColors.softLilac,
            onDestinationSelected: navigationShell.goBranch,
          );
        }

        Widget destination(int index) => Semantics(
          button: true,
          selected: index == navigationShell.currentIndex,
          label: labels[index],
          onTap: () => navigationShell.goBranch(index),
          child: ExcludeSemantics(
            child: InkWell(
              onTap: () => navigationShell.goBranch(index),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 64),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        index == navigationShell.currentIndex
                            ? _selectedIcons[index]
                            : _icons[index],
                        color: index == navigationShell.currentIndex
                            ? KonsenaColors.primary
                            : KonsenaColors.textSecondary,
                        size: index == 2 ? 28 : 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: index == navigationShell.currentIndex
                              ? KonsenaColors.primary
                              : KonsenaColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        return SafeArea(
          top: false,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: largeText
                ? Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      for (var index = 0; index < labels.length; index++)
                        SizedBox(
                          width: constraints.maxWidth / 3,
                          child: destination(index),
                        ),
                    ],
                  )
                : Row(
                    children: [
                      for (var index = 0; index < labels.length; index++)
                        Expanded(child: destination(index)),
                    ],
                  ),
          ),
        );
      },
    ),
  );
}
