import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/journey/journey_store.dart';
import '../features/home/presentation/dashboard_page.dart';
import '../features/home/presentation/home_cubit.dart';
import '../features/history/presentation/history_page.dart';
import '../features/audit/presentation/new_audit_page.dart';
import '../features/audit/presentation/audit_workspace_page.dart';
import '../features/about/presentation/about_page.dart';
import '../features/navigation/presentation/route_screen_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/privacy_setup/presentation/privacy_setup_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/scan/presentation/scan_hub_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/shared/widgets/unknown_route_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/permission_inspector/presentation/app_picker_page.dart';
import '../features/permission_inspector/presentation/app_permission_detail_page.dart';
import 'navigation/audit_draft_store.dart';
import 'navigation/konsena_tab_shell.dart';
import 'navigation/route_registry.dart';
import '../data/audit/audit_repository.dart';

/// Builds the canonical S00–S39 route graph and retained five-tab shell.
GoRouter createAppRouter({
  JourneyStore? journeyStore,
  AuditDraftStore? draftStore,
  AuditRepository? auditRepository,
  bool isAuthenticated = false,
  bool syncOptIn = false,
  String? initialLocation,
}) {
  final journey =
      journeyStore ?? InMemoryJourneyStore(JourneySnapshot.completed());
  final drafts = draftStore ?? AuditDraftStore();

  GoRoute screenRoute(ScreenSpec spec) => GoRoute(
    path: spec.path,
    name: spec.id.code,
    redirect: (context, state) {
      if ((spec.id == ScreenId.s22 || spec.id == ScreenId.s37) &&
          !(isAuthenticated && syncOptIn)) {
        return '/profile?notice=sync_requires_opt_in';
      }
      return null;
    },
    builder: (context, state) {
      if (spec.id == ScreenId.s24) {
        return NewAuditPage(
          drafts: drafts,
          repository: auditRepository,
          onAuditCreated: auditRepository == null
              ? null
              : () => context.read<HomeCubit>().loadSummary(),
        );
      }
      if (spec.id == ScreenId.s06) return const ScanHubPage();
      if (spec.id == ScreenId.s04) {
        return AppPickerPage(
          auditId: state.uri.queryParameters['auditId'],
        );
      }
      if (spec.id == ScreenId.s05) {
        final packageName = state.pathParameters['package'];
        if (packageName == null) {
          return const UnknownRoutePage(location: 'missing package');
        }
        return AppPermissionDetailPage(
          packageName: packageName,
          auditId: state.uri.queryParameters['auditId'],
          repository: auditRepository,
        );
      }
      if (spec.id == ScreenId.s19) {
        return HistoryPage(drafts: drafts, repository: auditRepository);
      }
      if (spec.id == ScreenId.s14 && auditRepository != null) {
        final auditId = state.pathParameters['id'];
        if (auditId == null) {
          return const UnknownRoutePage(location: 'missing audit id');
        }
        return AuditWorkspacePage(
          auditId: auditId,
          repository: auditRepository,
          onAuditDeleted: () => context.read<HomeCubit>().loadSummary(),
        );
      }
      if (spec.id == ScreenId.s21) {
        return ProfilePage(
          showSyncNotice:
              state.uri.queryParameters['notice'] == 'sync_requires_opt_in',
        );
      }
      if (spec.id == ScreenId.s20) return const SettingsPage();
      if (spec.id == ScreenId.s23) return const AboutPage();
      if (spec.id == ScreenId.s03) return const DashboardPage();
      if (spec.id == ScreenId.s00) return SplashScreen(store: journey);
      if (spec.id == ScreenId.s01) return OnboardingPage(store: journey);
      if (spec.id == ScreenId.s02) return PrivacySetupPage(store: journey);
      if (spec.id == ScreenId.s34) {
        return RouteScreenPage(
          spec: spec,
          parameters: state.pathParameters,
          drafts: drafts,
          auditRepository: auditRepository,
        );
      }
      return RouteScreenPage(
        spec: spec,
        parameters: state.pathParameters,
        drafts: drafts,
        queryAuditId: state.uri.queryParameters['auditId'],
        auditRepository: auditRepository,
      );
    },
  );

  List<GoRoute> routesFor(Iterable<ScreenId> ids) => [
    for (final id in ids) screenRoute(RouteRegistry.get(id)),
  ];

  return GoRouter(
    initialLocation: initialLocation ?? RouteRegistry.get(ScreenId.s00).path,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/splash'),
      screenRoute(RouteRegistry.get(ScreenId.s00)),
      screenRoute(RouteRegistry.get(ScreenId.s01)),
      screenRoute(RouteRegistry.get(ScreenId.s02)),
      GoRoute(
        path: '/account',
        name: 'accountAlias',
        redirect: (context, state) => '/profile',
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            KonsenaTabShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: routesFor(const [ScreenId.s03])),
          StatefulShellBranch(
            routes: routesFor(const [
              ScreenId.s24,
              ScreenId.s04,
              ScreenId.s05,
              ScreenId.s14,
              ScreenId.s15,
              ScreenId.s16,
              ScreenId.s17,
              ScreenId.s18,
              ScreenId.s33,
              ScreenId.s29,
              ScreenId.s30,
              ScreenId.s31,
              ScreenId.s32,
              ScreenId.s38,
            ]),
          ),
          StatefulShellBranch(
            routes: routesFor(const [
              ScreenId.s06,
              ScreenId.s07,
              ScreenId.s08,
              ScreenId.s09,
              ScreenId.s10,
              ScreenId.s11,
              ScreenId.s12,
              ScreenId.s13,
              ScreenId.s25,
              ScreenId.s26,
              ScreenId.s27,
              ScreenId.s28,
              ScreenId.s35,
              ScreenId.s39,
            ]),
          ),
          StatefulShellBranch(
            routes: routesFor(const [ScreenId.s19, ScreenId.s34]),
          ),
          StatefulShellBranch(
            routes: routesFor(const [
              ScreenId.s21,
              ScreenId.s20,
              ScreenId.s22,
              ScreenId.s23,
              ScreenId.s36,
              ScreenId.s37,
            ]),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        UnknownRoutePage(location: state.uri.toString()),
  );
}
