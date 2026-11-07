import '../config/cloud_status.dart';
import 'cloud_gateway.dart';

/// [CloudGateway] used when cloud is not configured or not enabled.
///
/// This is the default and by far the most common path: KONSENA AI is
/// guest-first and offline-first, so nothing is downloaded, uploaded or
/// authenticated. Every member is a safe no-op.
class GuestCloudGateway implements CloudGateway {
  GuestCloudGateway({required CloudStatus status, this.statusReason = 'guest'})
    : assert(
        status == CloudStatus.cloudNotConfigured ||
            status == CloudStatus.cloudDisabled,
        'GuestCloudGateway only represents not-configured / disabled states',
      ),
      _status = status;

  final CloudStatus _status;

  @override
  CloudStatus get status => _status;

  @override
  final String statusReason;

  @override
  bool get isCloudLive => false;

  @override
  bool get isAuthenticated => false;

  @override
  Future<void> initialize() async {
    // Intentionally empty: a guest must never trigger a network client.
  }
}
