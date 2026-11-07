import 'package:get_it/get_it.dart';

import '../core/config/app_config.dart';
import '../core/config/cloud_status.dart';
import '../core/supabase/cloud_gateway.dart';
import '../core/supabase/guest_cloud_gateway.dart';
import '../core/supabase/supabase_cloud_gateway.dart';

/// Minimal service locator for Phase 00.
///
/// Constructor injection is preferred inside features; this graph only wires
/// the process-wide singletons (config + cloud gateway) and is kept small on
/// purpose — Phase 01A+ registers its own dependencies here. Widgets receive
/// their [CloudGateway] by constructor instead of reaching into the locator.
final GetIt getIt = GetIt.instance;

/// Builds the [CloudGateway] that matches [config] without touching the
/// network. Split out so tests can assert the guest/cloud decision table
/// directly.
CloudGateway buildCloudGateway(
  AppConfig config, {
  SupabaseInitializer? initializer,
}) {
  final evaluation = config.evaluate();
  switch (evaluation.status) {
    case CloudStatus.cloudNotConfigured:
    case CloudStatus.cloudDisabled:
      return GuestCloudGateway(
        status: evaluation.status,
        statusReason: evaluation.reason,
      );
    case CloudStatus.cloudConfigured:
    case CloudStatus.cloudInitialized:
    case CloudStatus.cloudError:
      return SupabaseCloudGateway(config: config, initializer: initializer);
  }
}

/// Registers [AppConfig], the [CloudGateway] and feature controllers, then
/// initializes the gateway.
///
/// Never throws: when cloud is missing or disabled the app continues in guest
/// mode with [CloudStatus.cloudNotConfigured] / [CloudStatus.cloudDisabled].
Future<void> setupDependencies({
  AppConfig? config,
  SupabaseInitializer? initializer,
}) async {
  final effectiveConfig = config ?? AppConfig.fromEnvironment();

  if (getIt.isRegistered<AppConfig>()) {
    await getIt.reset();
  }

  getIt.registerSingleton<AppConfig>(effectiveConfig);

  final gateway = buildCloudGateway(effectiveConfig, initializer: initializer);
  getIt.registerSingleton<CloudGateway>(gateway);
  await gateway.initialize();
}
