import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/features/permission_inspector/domain/permission_models.dart';
import 'package:konsena_ai/features/permission_inspector/presentation/app_permission_detail_page.dart';
import 'package:konsena_ai/features/permission_inspector/presentation/app_picker_page.dart';

void main() {
  testWidgets('S04 discloses launcher visibility and searches visible apps', (
    tester,
  ) async {
    final inspector = _FakeInspector([
      const VisibleApplication(
        packageName: 'com.example.shop',
        label: 'Shop Example',
        versionName: '1.2',
        isSystem: false,
      ),
      const VisibleApplication(
        packageName: 'com.example.music',
        label: 'Music Player',
        versionName: '4.0',
        isSystem: false,
      ),
    ]);
    await tester.pumpWidget(
      MaterialApp(home: AppPickerPage(auditId: null, inspector: inspector)),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('bukan daftar semua aplikasi'), findsOneWidget);
    expect(find.text('Shop Example'), findsOneWidget);
    expect(find.text('Music Player'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'music');
    await tester.pumpAndSettle();
    expect(find.text('Music Player'), findsOneWidget);
    expect(find.text('Shop Example'), findsNothing);
    expect(inspector.listCalls, 1);
  });

  testWidgets('S04 empty result is not described as no installed apps', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppPickerPage(auditId: null, inspector: _FakeInspector([])),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('tidak membuktikan perangkat'), findsOneWidget);
  });

  testWidgets('S05 shows fact statuses and opens OS settings on user action', (
    tester,
  ) async {
    final inspector = _FakeInspector(const [])..snapshot = _sampleSnapshot();
    await tester.pumpWidget(
      MaterialApp(
        home: AppPermissionDetailPage(
          packageName: 'com.example.shop',
          inspector: inspector,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Diberikan'), findsOneWidget);
    expect(find.text('Belum diberikan'), findsOneWidget);
    expect(find.text('Tidak tersedia'), findsOneWidget);
    expect(find.textContaining('bukan pelacakan penggunaan'), findsOneWidget);
    await tester.tap(find.text('Buka Settings Android'));
    await tester.pumpAndSettle();
    expect(inspector.settingsCalls, 1);
  });
}

ApplicationPermissionSnapshot _sampleSnapshot() =>
    ApplicationPermissionSnapshot(
      packageName: 'com.example.shop',
      label: 'Shop Example',
      versionName: '1.2',
      permissions: const [
        PermissionFact(
          name: 'android.permission.INTERNET',
          label: 'Internet',
          granted: true,
          status: PermissionFactStatus.declaredGranted,
          flagsAvailable: true,
        ),
        PermissionFact(
          name: 'android.permission.CAMERA',
          label: 'Camera',
          granted: false,
          status: PermissionFactStatus.declaredNotGranted,
          flagsAvailable: true,
        ),
        PermissionFact(
          name: 'com.example.permission.UNKNOWN',
          granted: null,
          status: PermissionFactStatus.unavailable,
          flagsAvailable: false,
        ),
      ],
      capturedAt: DateTime.utc(2026, 11, 8),
      androidSdk: 36,
      visibilityScope: 'launcher_query',
      snapshotStatus: 'available',
    );

class _FakeInspector implements PermissionInspectorPlatform {
  _FakeInspector(this.apps);

  final List<VisibleApplication> apps;
  int listCalls = 0;
  int settingsCalls = 0;
  ApplicationPermissionSnapshot? snapshot;

  @override
  Future<List<VisibleApplication>> listVisibleLaunchableApps({
    bool includeSystem = false,
  }) async {
    listCalls++;
    return apps;
  }

  @override
  Future<ApplicationPermissionSnapshot> getPermissionSnapshot(
    String packageName,
  ) async => snapshot ?? _sampleSnapshot();

  @override
  Future<bool> openAppSettings(String packageName) async {
    settingsCalls++;
    return true;
  }
}
