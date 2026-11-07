import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/cloud_status.dart';
import '../../../core/supabase/cloud_gateway.dart';

/// Immutable state of the Phase 00 home shell.
class HomeState {
  const HomeState({
    required this.cloudStatus,
    required this.statusReason,
    required this.isAuthenticated,
  });

  factory HomeState.fromGateway(CloudGateway gateway) => HomeState(
    cloudStatus: gateway.status,
    statusReason: gateway.statusReason,
    isAuthenticated: gateway.isAuthenticated,
  );

  final CloudStatus cloudStatus;

  /// Non-safe reason token from the gateway; safe to render in dev tooling.
  final String statusReason;

  /// Always `false` in Phase 00 — there is no sign-in flow yet.
  final bool isAuthenticated;

  /// Guest-first invariant: without a session the user is a local guest.
  bool get isGuest => !isAuthenticated;

  /// Cloud features stay off until the gateway reports a live client.
  bool get isCloudFeatureEnabled => cloudStatus.isCloudLive;

  @override
  bool operator ==(Object other) =>
      other is HomeState &&
      other.cloudStatus == cloudStatus &&
      other.statusReason == statusReason &&
      other.isAuthenticated == isAuthenticated;

  @override
  int get hashCode => Object.hash(cloudStatus, statusReason, isAuthenticated);

  @override
  String toString() =>
      'HomeState(status: ${cloudStatus.label}, reason: $statusReason, '
      'authenticated: $isAuthenticated)';
}

/// Reads the [CloudGateway] into the widget tree.
///
/// Phase 00 has no write/stream actions, so this Cubit only mirrors the
/// gateway once at construction; later phases add sync events here.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._gateway) : super(HomeState.fromGateway(_gateway));

  final CloudGateway _gateway;

  /// Re-reads the gateway (e.g. after cloud initialization finishes).
  void refresh() => emit(HomeState.fromGateway(_gateway));
}
