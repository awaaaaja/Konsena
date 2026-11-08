import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:konsena_ai/features/consent_ui/domain/screenshot_review.dart';
import 'package:konsena_ai/features/model_qa/data/dark_pattern_input.dart';

Uint8List _fixture(int width, int height, int channels) {
  final image = img.Image(width: width, height: height, numChannels: channels);
  for (final pixel in image) {
    final x = pixel.x;
    final y = pixel.y;
    pixel.setRgba(
      (x * 17 + y * 73) & 255,
      (x * y + 11) & 255,
      ((x * 5) ^ (y * 13)) & 255,
      (x + y * 29) & 255,
    );
  }
  return img.encodePng(image);
}

void main() {
  // Reference hashes come from independently generated Pillow 12.3 RGB,
  // crop, clockwise transpose, BILINEAR resize and float32 ImageNet NCHW.
  test(
    'RGBA downsample matches reference bytes after crop and 90° rotation',
    () {
      final tensor = DarkPatternInput.encode(
        _fixture(509, 401, 4),
        const ScreenshotReview(
          crop: SourceRect(.125, .125, .75, .75),
          quarterTurns: 1,
        ),
      );
      expect(tensor.length, 3 * 224 * 224 * 4);
      expect(
        sha256.convert(tensor).toString(),
        'd653b9212f30efaaa5597414694fc92bad9562b09717516eb4c95190cf35748b',
      );
    },
  );

  test(
    'RGB upsample matches reference bytes at the right and bottom edges',
    () {
      final tensor = DarkPatternInput.encode(
        _fixture(89, 135, 3),
        const ScreenshotReview(
          crop: SourceRect(.83, .67, .17, .33),
          quarterTurns: 3,
        ),
      );
      expect(
        sha256.convert(tensor).toString(),
        '87dd2c9a50496a3490ec61cd679e61f7bb6c23b1c9470d42c2a65bcfb71b464b',
      );
    },
  );

  test('rejects non-PNG and PNG with EXIF before building a tensor', () {
    expect(
      () => DarkPatternInput.encode(Uint8List(64), const ScreenshotReview()),
      throwsFormatException,
    );
    final original = _fixture(3, 3, 3);
    final exif = ByteData(12)..setUint32(4, 0x65584966);
    final png = Uint8List.fromList([
      ...original.take(33),
      ...exif.buffer.asUint8List(),
      ...original.skip(33),
    ]);
    expect(
      () => DarkPatternInput.encode(png, const ScreenshotReview()),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'reason',
          contains('without EXIF'),
        ),
      ),
    );
  });
}
