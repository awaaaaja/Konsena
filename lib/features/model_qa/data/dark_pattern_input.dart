import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../consent_ui/domain/screenshot_review.dart';

/// Reproduces the training contract for 8-bit RGB/RGBA PNG screenshots.
/// Returns little-endian float32 NCHW bytes for ONNX Runtime.
abstract final class DarkPatternInput {
  static const _size = 224;
  static const _plane = _size * _size;
  static const _fixedOne = 1 << 22;
  static const _fixedHalf = _fixedOne ~/ 2;
  static const _maxSide = 8192;

  static Uint8List encode(Uint8List png, ScreenshotReview review) {
    // PNG IHDR has an 8-bit depth and RGB (2) or RGBA (6) color type.
    // Restrict QA to the decoded layouts verified against the reference.
    if (png.length < 33 ||
        png.length > ScreenshotProcessor.maxBytes ||
        png[24] != 8 ||
        (png[25] != 2 && png[25] != 6) ||
        !img.PngDecoder().isValidFile(png)) {
      throw const FormatException('QA requires an 8-bit RGB/RGBA PNG');
    }
    final header = ByteData.sublistView(png);
    if (header.getUint32(16) > _maxSide || header.getUint32(20) > _maxSide) {
      throw const FormatException('QA image dimensions');
    }
    // The shared PNG decoder does not apply EXIF orientation. Reject PNGs with
    // that metadata so QA uses the same coordinates as the saved review.
    for (var offset = 8; offset + 12 <= png.length;) {
      final length = header.getUint32(offset);
      final type = header.getUint32(offset + 4);
      offset += length + 12;
      if (offset > png.length) throw const FormatException('Truncated PNG');
      if (type == 0x65584966 || type == 0x65586966 || type == 0x6163544c) {
        throw const FormatException('QA requires a static PNG without EXIF');
      }
      if (type == 0x49454e44) break;
    }
    final original = ScreenshotProcessor.decode(png);
    final image = ScreenshotProcessor.transform(original, review);
    final horizontal = _kernels(image.width);
    final vertical = _kernels(image.height);
    final intermediate = Uint8List(image.height * _size * 3);
    final pixel = image.getPixel(0, 0);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < _size; x++) {
        final kernel = horizontal[x];
        var red = _fixedHalf;
        var green = _fixedHalf;
        var blue = _fixedHalf;
        for (var i = 0; i < kernel.weights.length; i++) {
          final p = image.getPixel(kernel.start + i, y, pixel);
          final weight = kernel.weights[i];
          red += p.r.toInt() * weight;
          green += p.g.toInt() * weight;
          blue += p.b.toInt() * weight;
        }
        final offset = (y * _size + x) * 3;
        intermediate[offset] = _clip(red);
        intermediate[offset + 1] = _clip(green);
        intermediate[offset + 2] = _clip(blue);
      }
    }

    final rgb = _normalizationTables();
    final tensor = ByteData(3 * _plane * Float32List.bytesPerElement);
    for (var y = 0; y < _size; y++) {
      final kernel = vertical[y];
      for (var x = 0; x < _size; x++) {
        for (var channel = 0; channel < 3; channel++) {
          var sum = _fixedHalf;
          var offset = (kernel.start * _size + x) * 3 + channel;
          for (final weight in kernel.weights) {
            sum += intermediate[offset] * weight;
            offset += _size * 3;
          }
          final index = channel * _plane + y * _size + x;
          tensor.setFloat32(index * 4, rgb[channel][_clip(sum)], Endian.little);
        }
      }
    }
    return tensor.buffer.asUint8List();
  }

  static int _clip(int value) => (value >> 22).clamp(0, 255);

  // Pillow's 8-bit bilinear resize uses a widened triangle when shrinking
  // and rounds to an 8-bit pixel after each separable pass.
  static List<({int start, Int32List weights})> _kernels(int inputSize) {
    final scale = inputSize / _size;
    final radius = math.max(1.0, scale);
    final inverseRadius = 1.0 / radius;
    return List.generate(_size, (index) {
      final center = (index + 0.5) * scale;
      final start = math.max(0, (center - radius + 0.5).toInt());
      final end = math.min(inputSize, (center + radius + 0.5).toInt());
      final weights = List.generate(end - start, (i) {
        final distance = ((start + i - center + 0.5) * inverseRadius).abs();
        return math.max(0.0, 1.0 - distance);
      });
      final total = weights.fold(0.0, (sum, weight) => sum + weight);
      return (
        start: start,
        weights: Int32List.fromList([
          for (final weight in weights) (weight / total * _fixedOne).round(),
        ]),
      );
    });
  }

  static List<Float32List> _normalizationTables() {
    final mean = Float32List.fromList([0.485, 0.456, 0.406]);
    final std = Float32List.fromList([0.229, 0.224, 0.225]);
    return List.generate(3, (channel) {
      final values = Float32List(256);
      for (var byte = 0; byte < values.length; byte++) {
        // NumPy's float32 divide, subtraction and final divide each round.
        values[byte] = byte / 255;
        values[byte] = values[byte] - mean[channel];
        values[byte] = values[byte] / std[channel];
      }
      return values;
    });
  }
}
