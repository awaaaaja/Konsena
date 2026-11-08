import 'dart:io';

import 'package:image/image.dart' as img;

/// Synthetic authored consent screenshot, not a real app or legal finding.
void main(List<String> args) {
  if (args.length != 1) throw ArgumentError('Output PNG path required');
  final image = img.Image(width: 720, height: 960);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));
  img.drawString(
    image,
    'SYNTHETIC QA FIXTURE',
    font: img.arial48,
    x: 25,
    y: 30,
    color: img.ColorRgb8(0, 0, 0),
  );
  img.drawString(
    image,
    'Optional consent',
    font: img.arial48,
    x: 30,
    y: 220,
    color: img.ColorRgb8(0, 0, 0),
  );
  img.drawString(
    image,
    'No real personal data',
    font: img.arial24,
    x: 30,
    y: 340,
    color: img.ColorRgb8(0, 0, 0),
  );
  img.fillRect(
    image,
    x1: 30,
    y1: 600,
    x2: 330,
    y2: 730,
    color: img.ColorRgb8(210, 190, 250),
  );
  img.fillRect(
    image,
    x1: 370,
    y1: 600,
    x2: 680,
    y2: 730,
    color: img.ColorRgb8(220, 220, 220),
  );
  img.drawString(
    image,
    'Accept',
    font: img.arial48,
    x: 60,
    y: 640,
    color: img.ColorRgb8(0, 0, 0),
  );
  img.drawString(
    image,
    'Reject',
    font: img.arial48,
    x: 400,
    y: 640,
    color: img.ColorRgb8(0, 0, 0),
  );
  File(args.single).writeAsBytesSync(img.encodePng(image));
}
