import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:konsena_ai/features/live_scan/domain/live_scan_quality.dart';

void main() {
  test(
    'quality metrics flag highlight glare and low-detail blur heuristically',
    () {
      final white = img.Image(width: 96, height: 96, numChannels: 3)
        ..clear(img.ColorRgb8(255, 255, 255));
      final glare = LiveScanQuality.measure(white);
      expect(glare.glareSuspected, isTrue);

      final flat = img.Image(width: 96, height: 96, numChannels: 3)
        ..clear(img.ColorRgb8(120, 120, 120));
      final blur = LiveScanQuality.measure(flat);
      expect(blur.blurSuspected, isTrue);
      expect(glare.label, contains('sudut'));
    },
  );
}
