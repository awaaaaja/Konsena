import 'package:flutter/services.dart';

import '../domain/permission_models.dart';

class MethodChannelPermissionInspector implements PermissionInspectorPlatform {
  MethodChannelPermissionInspector({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('id.konsena/permissions');

  final MethodChannel _channel;

  @override
  Future<List<VisibleApplication>> listVisibleLaunchableApps({
    bool includeSystem = false,
  }) async {
    final result = await _invoke<Map<Object?, Object?>>(
      'listVisibleLaunchableApps',
      {'includeSystem': includeSystem},
    );
    return ((result['apps'] as List<Object?>?) ?? const [])
        .whereType<Map<Object?, Object?>>()
        .map(VisibleApplication.fromMap)
        .toList(growable: false);
  }

  @override
  Future<ApplicationPermissionSnapshot> getPermissionSnapshot(
    String packageName,
  ) async => ApplicationPermissionSnapshot.fromMap(
    await _invoke('getPermissionSnapshot', {'packageName': packageName}),
  );

  @override
  Future<bool> openAppSettings(String packageName) async {
    final result = await _invoke<Map<Object?, Object?>>('openAppSettings', {
      'packageName': packageName,
    });
    return result['opened'] == true;
  }

  Future<T> _invoke<T>(String method, [Map<String, Object?>? arguments]) async {
    try {
      final result = await _channel.invokeMethod<T>(method, arguments);
      if (result == null) {
        throw const PermissionInspectorException(
          'UNKNOWN',
          'Android returned an empty result.',
        );
      }
      return result;
    } on PlatformException catch (error) {
      throw PermissionInspectorException(
        error.code,
        error.message ?? 'Android permission inspection failed.',
      );
    } on MissingPluginException {
      throw const PermissionInspectorException(
        'SDK_UNSUPPORTED',
        'Android permission inspection is unavailable on this platform.',
      );
    }
  }
}
