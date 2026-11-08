import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Coordinates are normalized against the EXIF-baked ORIGINAL, never the
/// transformed preview. Editing crop/rotation therefore cannot move evidence.
class SourceRect {
  const SourceRect(this.left, this.top, this.width, this.height);
  final double left, top, width, height;
  bool get valid =>
      [left, top, width, height].every((v) => v.isFinite) &&
      left >= 0 &&
      top >= 0 &&
      width > 0 &&
      height > 0 &&
      left + width <= 1.000001 &&
      top + height <= 1.000001;
  List<double> toJson() => [left, top, width, height];
  factory SourceRect.fromJson(List<dynamic> json) => SourceRect(
    (json[0] as num).toDouble(),
    (json[1] as num).toDouble(),
    (json[2] as num).toDouble(),
    (json[3] as num).toDouble(),
  );
}

class ManualAnnotation {
  const ManualAnnotation({
    required this.kind,
    required this.label,
    required this.rect,
  });
  final String kind, label;
  final SourceRect rect;
  static const kinds = ['setuju', 'tolak', 'checkbox', 'tujuan', 'evidence'];
  Map<String, Object> toJson() => {
    'kind': kind,
    'label': label,
    'rect': rect.toJson(),
  };
  factory ManualAnnotation.fromJson(Map<String, dynamic> json) =>
      ManualAnnotation(
        kind: json['kind'] as String,
        label: json['label'] as String,
        rect: SourceRect.fromJson(json['rect'] as List<dynamic>),
      );
}

class ScreenshotReview {
  const ScreenshotReview({
    this.crop = const SourceRect(0, 0, 1, 1),
    this.quarterTurns = 0,
    this.title = '',
    this.version = '',
    this.annotations = const [],
  });
  final SourceRect crop;
  final int quarterTurns;
  final String title, version;
  final List<ManualAnnotation> annotations;
  void validate() {
    if (!crop.valid ||
        quarterTurns < 0 ||
        quarterTurns > 3 ||
        title.length > 255 ||
        version.length > 255 ||
        annotations.length > 100 ||
        annotations.any(
          (a) =>
              !a.rect.valid ||
              !ManualAnnotation.kinds.contains(a.kind) ||
              a.label.trim().isEmpty ||
              a.label.length > 500,
        )) {
      throw ArgumentError('Invalid screenshot review');
    }
  }

  String encode() {
    validate();
    return jsonEncode({
      'schemaVersion': 1,
      'coordinateSpace': 'exif_baked_original_normalized',
      'crop': crop.toJson(),
      'quarterTurns': quarterTurns,
      'title': title,
      'version': version,
      'annotations': annotations.map((a) => a.toJson()).toList(),
    });
  }

  factory ScreenshotReview.decode(String data) {
    final json = jsonDecode(data) as Map<String, dynamic>;
    if (json['schemaVersion'] != 1 ||
        json['coordinateSpace'] != 'exif_baked_original_normalized') {
      throw const FormatException('Unsupported screenshot review');
    }
    final result = ScreenshotReview(
      crop: SourceRect.fromJson(json['crop'] as List<dynamic>),
      quarterTurns: json['quarterTurns'] as int,
      title: json['title'] as String,
      version: json['version'] as String,
      annotations: (json['annotations'] as List<dynamic>)
          .map((a) => ManualAnnotation.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
    result.validate();
    return result;
  }
}

abstract final class ScreenshotProcessor {
  static const maxBytes = 10 * 1024 * 1024;
  static img.Image decode(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const FormatException('Image size');
    }
    final decoder = img.findDecoderForData(bytes);
    if (decoder == null ||
        (decoder is! img.PngDecoder && decoder is! img.JpegDecoder)) {
      throw const FormatException('PNG/JPEG required');
    }
    final info = decoder.startDecode(bytes);
    if (info == null || info.width * info.height > 16000000) {
      throw const FormatException('Image dimensions');
    }
    final image = decoder.decodeFrame(0);
    if (image == null) throw const FormatException('Invalid image');
    return img.bakeOrientation(image);
  }

  /// Applies saved source-space geometry at the original pixel resolution.
  static img.Image transform(img.Image original, ScreenshotReview review) {
    review.validate();
    final c = review.crop;
    var image = img.copyCrop(
      original,
      x: (c.left * original.width).floor(),
      y: (c.top * original.height).floor(),
      width: (c.width * original.width).round().clamp(1, original.width),
      height: (c.height * original.height).round().clamp(1, original.height),
    );
    if (review.quarterTurns != 0) {
      image = img.copyRotate(image, angle: review.quarterTurns * 90);
    }
    return image;
  }

  static Uint8List preview(img.Image original, ScreenshotReview review) {
    var image = transform(original, review);
    if (image.width > 1200 || image.height > 1200) {
      image = image.width > image.height
          ? img.copyResize(image, width: 1200)
          : img.copyResize(image, height: 1200);
    }
    return Uint8List.fromList(img.encodePng(image));
  }
}
