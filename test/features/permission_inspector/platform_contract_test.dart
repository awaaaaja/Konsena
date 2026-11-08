import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/features/permission_inspector/data/method_channel_permission_inspector.dart';
import 'package:konsena_ai/features/permission_inspector/domain/permission_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/permission_inspector');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'channel maps launcher apps, permission facts, timestamp and settings',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'listVisibleLaunchableApps':
            expect(call.arguments, {'includeSystem': false});
            return {
              'apps': [
                {
                  'packageName': 'com.example.shop',
                  'label': 'Shop',
                  'versionName': '2.0',
                  'isSystem': false,
                },
              ],
              'visibilityScope': 'launcher_query',
              'capturedAt': '2026-11-08T10:00:00.000Z',
              'androidSdk': 36,
            };
          case 'getPermissionSnapshot':
            expect(call.arguments, {'packageName': 'com.example.shop'});
            return {
              'packageName': 'com.example.shop',
              'label': 'Shop',
              'versionName': '2.0',
              'permissions': [
                {
                  'name': 'android.permission.CAMERA',
                  'label': 'Camera',
                  'granted': false,
                  'statusCode': 'declared_not_granted',
                  'protectionLevel': 1,
                  'flagsAvailable': true,
                },
                {
                  'name': 'com.example.UNKNOWN',
                  'label': null,
                  'granted': null,
                  'statusCode': 'unavailable',
                  'protectionLevel': null,
                  'flagsAvailable': false,
                },
              ],
              'capturedAt': '2026-11-08T10:00:00.000Z',
              'androidSdk': 36,
              'visibilityScope': 'launcher_query',
              'snapshotStatus': 'available',
            };
          case 'openAppSettings':
            expect(call.arguments, {'packageName': 'com.example.shop'});
            return {'opened': true, 'fallbackUsed': false};
          default:
            fail('Unexpected channel method ${call.method}');
        }
      });

      final inspector = MethodChannelPermissionInspector(channel: channel);
      final apps = await inspector.listVisibleLaunchableApps();
      expect(apps.single.packageName, 'com.example.shop');
      expect(apps.single.label, 'Shop');
      final snapshot = await inspector.getPermissionSnapshot(
        'com.example.shop',
      );
      expect(snapshot.androidSdk, 36);
      expect(snapshot.capturedAt, DateTime.utc(2026, 11, 8, 10));
      expect(snapshot.permissions.first.status.code, 'declared_not_granted');
      expect(snapshot.permissions.last.status.code, 'unavailable');
      expect(snapshot.permissions.last.granted, isNull);
      expect(await inspector.openAppSettings('com.example.shop'), isTrue);
    },
  );

  test('channel preserves structured native error codes', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(
        code: 'NOT_VISIBLE',
        message: 'Package is outside launcher scope',
      );
    });
    final inspector = MethodChannelPermissionInspector(channel: channel);
    await expectLater(
      inspector.getPermissionSnapshot('com.example.hidden'),
      throwsA(
        isA<PermissionInspectorException>().having(
          (error) => error.code,
          'code',
          'NOT_VISIBLE',
        ),
      ),
    );
  });
}
