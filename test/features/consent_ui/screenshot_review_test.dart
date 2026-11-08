import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:konsena_ai/features/consent_ui/domain/screenshot_review.dart';

void main() {
  test(
    'bounded crop and rotation preserve original-space annotation coordinates',
    () {
      final image = img.Image(width: 100, height: 80);
      final review = ScreenshotReview(
        crop: const SourceRect(.1, .2, .5, .5),
        quarterTurns: 1,
        annotations: [
          const ManualAnnotation(
            kind: 'tolak',
            label: 'Tolak',
            rect: SourceRect(.2, .3, .1, .1),
          ),
        ],
      );
      final preview = img.decodePng(
        ScreenshotProcessor.preview(image, review),
      )!;
      expect(preview.width, 40);
      expect(preview.height, 50);
      expect(
        ScreenshotReview.decode(review.encode()).annotations.single.rect
            .toJson(),
        [.2, .3, .1, .1],
      );
      expect(
        () => const ScreenshotReview(crop: SourceRect(.9, 0, .2, 1)).validate(),
        throwsArgumentError,
      );
      expect(
        () => ScreenshotProcessor.decode(Uint8List.fromList([1, 2, 3])),
        throwsFormatException,
      );
    },
  );
  test('valid PNG is decoded by signature, not extension', () {
    final png = Uint8List.fromList(
      img.encodePng(img.Image(width: 10, height: 20)),
    );
    expect(ScreenshotProcessor.decode(png).height, 20);
  });
  test(
    'reject invalid ROI, non-finite coordinates, annotation labels and schema',
    () {
      expect(const SourceRect(double.nan, 0, 1, 1).valid, isFalse);
      expect(
        () => const ScreenshotReview(quarterTurns: 4).encode(),
        throwsArgumentError,
      );
      expect(
        () => ScreenshotReview(
          annotations: [
            const ManualAnnotation(
              kind: 'AI',
              label: 'x',
              rect: SourceRect(0, 0, 1, 1),
            ),
          ],
        ).encode(),
        throwsArgumentError,
      );
      expect(
        () => ScreenshotReview.decode('{"schemaVersion":2}'),
        throwsFormatException,
      );
    },
  );
}
