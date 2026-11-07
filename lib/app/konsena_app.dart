import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/journey/journey_store.dart';
import 'navigation/audit_draft_store.dart';
import '../core/supabase/cloud_gateway.dart';
import '../data/audit/audit_repository.dart';
import '../features/home/domain/home_summary_repository.dart';
import '../features/home/data/local_home_summary_repository.dart';
import '../features/home/presentation/home_cubit.dart';
import 'app_router.dart';
import '../theme/konsena_theme.dart';

/// Root widget of KONSENA AI.
///
/// The [CloudGateway] is injected rather than read from the service locator so
/// widget tests can drive both branches (guest vs configured) without any
/// network or plugin channel. [journeyStore] and [summaryRepository] are
/// injected for the same reason: S00 routing and S03 numbers must be
/// deterministic in tests.
class KonsenaApp extends StatefulWidget {
  const KonsenaApp({
    super.key,
    required this.cloudGateway,
    this.journeyStore,
    this.summaryRepository,
    this.draftStore,
    this.auditRepository,
    this.router,
  });

  final CloudGateway cloudGateway;

  /// Local journey flags (S00 route decision, S01/S02 completion).
  ///
  /// Defaults to an in-memory store whose journey is already completed —
  /// the production entry point (`main()`) always passes a
  /// [PreferencesJourneyStore] so a real first launch shows S01.
  final JourneyStore? journeyStore;

  /// Summary source for S03; defaults to the initial empty (zero) state.
  final HomeSummaryRepository? summaryRepository;

  /// Local draft seam, retained by all route branches for this app lifetime.
  final AuditDraftStore? draftStore;

  /// Production local repository; null only in focused route/widget tests.
  final AuditRepository? auditRepository;

  /// Test seam; when null the app owns and disposes its own router.
  final GoRouter? router;

  @override
  State<KonsenaApp> createState() => _KonsenaAppState();
}

class _KonsenaAppState extends State<KonsenaApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router =
        widget.router ??
        createAppRouter(
          journeyStore:
              widget.journeyStore ??
              InMemoryJourneyStore(JourneySnapshot.completed()),
          draftStore: widget.draftStore,
          auditRepository: widget.auditRepository,
        );
  }

  @override
  void dispose() {
    if (widget.router == null) {
      _router.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => HomeCubit(
        widget.cloudGateway,
        repository:
            widget.summaryRepository ??
            (widget.auditRepository == null
                ? null
                : LocalHomeSummaryRepository(widget.auditRepository!)),
      ),
      child: MaterialApp.router(
        title: 'KONSENA AI',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        // Light palette is mandatory (DESIGN_SYSTEM §1); dark mode is a
        // separate QA gate and is not enabled here.
        theme: KonsenaTheme.light(),
        themeMode: ThemeMode.light,
      ),
    );
  }
}
