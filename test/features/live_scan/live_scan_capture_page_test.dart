// The camera plugin exposes this platform interface for substituting a camera.
import 'package:camera_platform_interface/camera_platform_interface.dart'; // ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/features/live_scan/presentation/live_scan_pages.dart';

class _Camera extends CameraPlatform {
  int opened = 0;
  int closed = 0;
  int captures = 0;

  @override
  Future<List<CameraDescription>> availableCameras() async => const [
    CameraDescription(
      name: 'QA camera',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    ),
  ];

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings mediaSettings,
  ) async => ++opened;

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() =>
      const Stream.empty();

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) => Stream.multi((_) {});

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) =>
      Stream.value(
        CameraInitializedEvent(
          cameraId,
          640,
          480,
          ExposureMode.auto,
          false,
          FocusMode.auto,
          false,
        ),
      );

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {}

  @override
  Widget buildPreview(int cameraId) => const SizedBox.expand();

  @override
  Future<XFile> takePicture(int cameraId) async {
    captures++;
    throw PlatformException(code: 'qa_no_picture');
  }

  @override
  Future<void> dispose(int cameraId) async {
    closed++;
  }
}

void main() {
  testWidgets('inactive scan branch releases camera and returns paused', (
    tester,
  ) async {
    const permissions = MethodChannel(
      'flutter.baseflow.com/permissions/methods',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(permissions, (_) async => 1);
    addTearDown(() => messenger.setMockMethodCallHandler(permissions, null));

    final originalCamera = CameraPlatform.instance;
    final camera = _Camera();
    CameraPlatform.instance = camera;
    addTearDown(() => CameraPlatform.instance = originalCamera);

    final visible = ValueNotifier(true);
    addTearDown(visible.dispose);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<bool>(
          valueListenable: visible,
          builder: (context, active, child) =>
              TickerMode(enabled: active, child: child!),
          child: const LiveScanCapturePage(auditId: 'audit-a'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(camera.opened, 1);
    expect(camera.captures, 1);

    visible.value = false;
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(camera.closed, 1);
    expect(camera.captures, 1);

    visible.value = true;
    await tester.pump();
    await tester.pump();
    expect(camera.opened, 2);
    expect(camera.captures, 1);
    expect(find.text('Lanjutkan'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(camera.closed, 2);
  });
}
