import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/cloud_status.dart';
import '../../../core/supabase/cloud_gateway.dart';
import '../domain/home_summary_repository.dart';

/// Immutable state of the S03 dashboard.
class HomeState {
  const HomeState({
    required this.cloudStatus,
    required this.statusReason,
    required this.isAuthenticated,
    this.summary = const HomeSummary.empty(),
    this.summaryLoaded = false,
  });

  factory HomeState.fromGateway(CloudGateway gateway) => HomeState(
    cloudStatus: gateway.status,
    statusReason: gateway.statusReason,
    isAuthenticated: gateway.isAuthenticated,
  );

  final CloudStatus cloudStatus;

  /// Non-safe reason token from the gateway; safe to render in dev tooling.
  final String statusReason;

  /// Always `false` until a sign-in flow exists (Phase 07).
  final bool isAuthenticated;

  /// Numbers read from [HomeSummaryRepository] — `0` while empty/unfinished.
  final HomeSummary summary;

  /// Whether [loadSummary] completed at least once.
  final bool summaryLoaded;

  /// Guest-first invariant: without a session the user is a local guest.
  bool get isGuest => !isAuthenticated;

  /// Cloud features stay off until the gateway reports a live client.
  bool get isCloudFeatureEnabled => cloudStatus.isCloudLive;

  HomeState copyWith({
    CloudStatus? cloudStatus,
    String? statusReason,
    bool? isAuthenticated,
    HomeSummary? summary,
    bool? summaryLoaded,
  }) {
    return HomeState(
      cloudStatus: cloudStatus ?? this.cloudStatus,
      statusReason: statusReason ?? this.statusReason,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      summary: summary ?? this.summary,
      summaryLoaded: summaryLoaded ?? this.summaryLoaded,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HomeState &&
      other.cloudStatus == cloudStatus &&
      other.statusReason == statusReason &&
      other.isAuthenticated == isAuthenticated &&
      other.summary == summary &&
      other.summaryLoaded == summaryLoaded;

  @override
  int get hashCode => Object.hash(
    cloudStatus,
    statusReason,
    isAuthenticated,
    summary,
    summaryLoaded,
  );

  @override
  String toString() =>
      'HomeState(status: ${cloudStatus.label}, reason: $statusReason, '
      'authenticated: $isAuthenticated, summary: $summary)';
}

/// Reads the [CloudGateway] and the local summary into the widget tree.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._gateway, {HomeSummaryRepository? repository})
    : _repository = repository ?? const EmptyHomeSummaryRepository(),
      super(HomeState.fromGateway(_gateway));

  final CloudGateway _gateway;
  final HomeSummaryRepository _repository;

  /// Re-reads the gateway (e.g. after cloud initialization finishes).
  void refresh() => emit(
    HomeState.fromGateway(_gateway)
        .copyWith(summary: state.summary, summaryLoaded: state.summaryLoaded),
  );

  /// Loads the dashboard summary from local storage.
  ///
  /// On failure the previous state is kept and [summaryLoaded] stays `false`
  /// — the dashboard then renders its honest zero/empty state instead of
  /// invented numbers.
  Future<void> loadSummary() async {
    try {
      final summary = await _repository.load();
      emit(state.copyWith(summary: summary, summaryLoaded: true));
    } on Object {
      emit(state.copyWith(summaryLoaded: state.summaryLoaded));
    }
  }
}
