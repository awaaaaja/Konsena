import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_page.dart';
import 'app_shell.dart';

/// Phase 00 route graph: a single shell route hosting the foundation home.
///
/// Screens S00–S39 are intentionally absent — they belong to Phase 01A/01B.
/// Route *names* are already typed strings so later phases can add guarded
/// routes without renaming existing ones.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: HomePage.routePath,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: HomePage.routePath,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
        ],
      ),
    ],
  );
}
