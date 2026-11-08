import 'package:flutter/material.dart';

import '../domain/screenshot_review.dart';

class RectEditValue {
  const RectEditValue(this.rect, this.kind, this.label);
  final SourceRect rect;
  final String kind, label;
}

/// Owns field controllers until the dialog's reverse animation is disposed.
class ScreenshotRectDialog extends StatefulWidget {
  const ScreenshotRectDialog({
    required this.initialRect,
    this.initialAnnotation,
    this.annotation = false,
    super.key,
  });
  final SourceRect initialRect;
  final ManualAnnotation? initialAnnotation;
  final bool annotation;
  @override
  State<ScreenshotRectDialog> createState() => _ScreenshotRectDialogState();
}

class _ScreenshotRectDialogState extends State<ScreenshotRectDialog> {
  late final fields = widget.initialRect
      .toJson()
      .map((v) => TextEditingController(text: '$v'))
      .toList();
  late final label = TextEditingController(
    text: widget.initialAnnotation?.label ?? '',
  );
  late String kind = widget.initialAnnotation?.kind ?? 'evidence';
  String? error;
  @override
  void dispose() {
    for (final c in fields) {
      c.dispose();
    }
    label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text(
      widget.annotation ? 'Anotasi pada sumber asli' : 'Crop pada sumber asli',
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Koordinat 0–1 terhadap gambar asli setelah orientasi EXIF. Anotasi tidak bergeser saat crop/rotate.',
        ),
        for (var i = 0; i < 4; i++)
          TextField(
            key: ValueKey('rect-field-$i'),
            controller: fields[i],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: ['Kiri', 'Atas', 'Lebar', 'Tinggi'][i],
            ),
          ),
        if (widget.annotation) ...[
          DropdownButton<String>(
            value: kind,
            isExpanded: true,
            items: ManualAnnotation.kinds
                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                .toList(),
            onChanged: (v) => setState(() => kind = v!),
          ),
          TextField(
            controller: label,
            maxLength: 500,
            decoration: const InputDecoration(labelText: 'Label manual'),
          ),
        ],
        if (error != null) Text(error!),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
      FilledButton(
        onPressed: () {
          final v = fields.map((f) => double.tryParse(f.text) ?? -1).toList();
          final rect = SourceRect(v[0], v[1], v[2], v[3]);
          if (!rect.valid || (widget.annotation && label.text.trim().isEmpty)) {
            setState(
              () =>
                  error = 'Gunakan koordinat valid 0–1 dan isi label anotasi.',
            );
            return;
          }
          Navigator.pop(context, RectEditValue(rect, kind, label.text.trim()));
        },
        child: const Text('Terapkan'),
      ),
    ],
  );
}
