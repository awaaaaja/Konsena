import 'dart:math' as math;

import 'package:image/image.dart' as img;

class LiveScanQuality {
  const LiveScanQuality({required this.glareFraction, required this.sharpness});
  final double glareFraction;
  final double sharpness;

  bool get glareSuspected => glareFraction >= .18;
  bool get blurSuspected => sharpness < 12;
  String get label => glareSuspected
      ? 'Pantulan terang mungkin terdeteksi — ubah sudut/lampu.'
      : blurSuspected
      ? 'Tepi teks kurang jelas — stabilkan kamera dan fokuskan layar.'
      : 'Indikator tidak menemukan blur/glare kuat; pastikan ROI berisi teks kebijakan dan tinjau OCR.';

  /// Sampled ROI metrics, deliberately treated as guidance rather than a
  /// calibrated camera/focus confidence score. Never used to assert coverage.
  factory LiveScanQuality.measure(img.Image image) {
    const stride = 6;
    var pixels = 0;
    var highlights = 0;
    final laplacians = <double>[];
    double gray(int x, int y) {
      final pixel = image.getPixel(x, y);
      return .299 * pixel.r + .587 * pixel.g + .114 * pixel.b;
    }

    for (var y = 1; y < image.height - 1; y += stride) {
      for (var x = 1; x < image.width - 1; x += stride) {
        pixels++;
        if (gray(x, y) >= 245) highlights++;
        if (x >= 2 && x < image.width - 2 && y >= 2 && y < image.height - 2) {
          final center = gray(x, y);
          final laplacian =
              4 * center -
              gray(x - 2, y) -
              gray(x + 2, y) -
              gray(x, y - 2) -
              gray(x, y + 2);
          laplacians.add(laplacian);
        }
      }
    }
    final mean = laplacians.isEmpty
        ? 0
        : laplacians.reduce((a, b) => a + b) / laplacians.length;
    final variance = laplacians.isEmpty
        ? 0.0
        : laplacians
                  .map((value) => math.pow(value - mean, 2))
                  .reduce((a, b) => a + b) /
              laplacians.length;
    return LiveScanQuality(
      glareFraction: pixels == 0 ? 0 : highlights / pixels,
      sharpness: variance,
    );
  }
}
