import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/journey/journey_store.dart';

/// Lifecycle of the local bootstrap performed while S00 is on screen
/// (PAGE_BY_PAGE S00: `AppBootstrapState`).
enum SplashStatus {
  /// Reading local journey flags / preparing local storage.
  loading,

  /// Bootstrap finished; [SplashState.destination] holds the next route.
  ready,

  /// Bootstrap failed in a recoverable way — show Retry + diagnostics.
  failed,
}

/// Immutable S00 state.
class SplashState {
  const SplashState({required this.status, this.destination, this.diagnostic});

  factory SplashState.loading() =>
      const SplashState(status: SplashStatus.loading);

  factory SplashState.ready(String destination) =>
      SplashState(status: SplashStatus.ready, destination: destination);

  /// [diagnostic] is a short, data-free reason token (never file paths,
  /// never user content — see PAGE_BY_PAGE S00 acceptance).
  factory SplashState.failed(String diagnostic) =>
      SplashState(status: SplashStatus.failed, diagnostic: diagnostic);

  final SplashStatus status;
  final String? destination;
  final String? diagnostic;

  @override
  bool operator ==(Object other) =>
      other is SplashState &&
      other.status == status &&
      other.destination == destination &&
      other.diagnostic == diagnostic;

  @override
  int get hashCode => Object.hash(status, destination, diagnostic);
}

/// Runs the startup decision for S00.
///
/// Phase 01A scope: read the local [JourneyStore] and choose the first route.
/// Phase 01B extends the same seam with Drift schema/version checks — the
/// widget contract (loading → ready/failed) does not change.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._store) : super(SplashState.loading());

  final JourneyStore _store;

  /// Route decision table (PAGE_BY_PAGE S00):
  /// first run → S01; onboarding done → S02; both done → S03.
  static const String routeWelcome = '/welcome';
  static const String routePrivacySetup = '/privacy-setup';
  static const String routeHome = '/home';

  Future<void> start() async {
    emit(SplashState.loading());
    try {
      final snapshot = await _store.load();
      emit(SplashState.ready(_destinationFor(snapshot)));
    } on Object catch (error) {
      // Data-free reason token only: type name, no message payload.
      emit(SplashState.failed('gagal_membaca_lokal:${error.runtimeType}'));
    }
  }

  /// Re-run after a recoverable failure (Retry button).
  Future<void> retry() => start();

  String _destinationFor(JourneySnapshot snapshot) {
    if (!snapshot.onboardingSeen) return routeWelcome;
    if (!snapshot.privacySetupSeen) return routePrivacySetup;
    return routeHome;
  }
}
