import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../../theme/konsena_spacing.dart';
import '../../consent_ui/domain/screenshot_review.dart';
import '../../model_qa/data/onnx_tensor_harness.dart';
import '../../model_qa/presentation/dark_pattern_qa_panel.dart';
import '../../shared/widgets/review_section.dart';
import '../domain/audit_snapshot.dart';

class InterfaceReviewContent extends StatefulWidget {
  const InterfaceReviewContent({
    required this.snapshot,
    required this.repository,
    super.key,
  });

  final AuditSnapshot snapshot;
  final AuditRepository repository;

  @override
  State<InterfaceReviewContent> createState() => _InterfaceReviewContentState();
}

class _InterfaceReviewContentState extends State<InterfaceReviewContent> {
  late final _sources = widget.snapshot.sources
      .where((source) => source.type == AuditSourceType.consentUi)
      .toList();
  late DocumentSource? _selected =
      _sources.where(_available).firstOrNull ?? _sources.firstOrNull;
  late Future<Uint8List>? _preview = _loadPreview(_selected);

  bool _available(DocumentSource source) =>
      !widget.snapshot.unavailableSources.contains(source.id);

  Future<Uint8List>? _loadPreview(DocumentSource? source) {
    if (source == null || !_available(source)) return null;
    return _readPreview(source.id);
  }

  Future<Uint8List> _readPreview(String id) async {
    final bytes = Uint8List.fromList(await widget.repository.readSource(id));
    final review = widget.snapshot.reviews[id] ?? const ScreenshotReview();
    return compute(
      (input) => ScreenshotProcessor.preview(
        ScreenshotProcessor.decode(input.bytes),
        input.review,
      ),
      (bytes: bytes, review: review),
    );
  }

  String _name(DocumentSource source) {
    final title = source.originalName?.trim();
    return title != null && title.isNotEmpty
        ? title
        : 'Screenshot ${_sources.indexOf(source) + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final audit = widget.snapshot.audit;
    final source = _selected;
    final available = source != null && _available(source);
    final review = widget.snapshot.reviews[source?.id];
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(KonsenaSpacing.md),
      children: [
        Text(audit.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: KonsenaSpacing.md),
        ReviewSection(
          icon: Icons.image_outlined,
          title: 'Screenshot',
          subtitle: source == null
              ? 'Tambahkan gambar layar persetujuan.'
              : 'Tentukan area yang ingin diperiksa.',
          children: [
            if (_sources.length > 1)
              DropdownButtonFormField<DocumentSource>(
                initialValue: source,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Pilih screenshot',
                ),
                items: [
                  for (final item in _sources)
                    DropdownMenuItem(
                      value: item,
                      child: Text(_name(item), overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) => setState(() {
                  _selected = value;
                  _preview = _loadPreview(value);
                }),
              ),
            if (source != null) ...[
              if (_sources.length == 1)
                Text(_name(source), style: theme.textTheme.titleSmall),
              const SizedBox(height: KonsenaSpacing.xs),
              if (available)
                FutureBuilder<Uint8List>(
                  key: ValueKey(source.id),
                  future: _preview,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Pratinjau tidak dapat dimuat.');
                    }
                    if (snapshot.data case final bytes?) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              KonsenaRadii.tile,
                            ),
                            child: ColoredBox(
                              color: theme.colorScheme.surfaceContainerLow,
                              child: Image.memory(
                                bytes,
                                height: 210,
                                fit: BoxFit.contain,
                                semanticLabel: review == null
                                    ? 'Screenshot asli'
                                    : 'Area screenshot yang diperiksa',
                              ),
                            ),
                          ),
                          Text(
                            review == null
                                ? 'Screenshot asli'
                                : 'Area yang diperiksa',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                )
              else
                const Text(
                  'File screenshot tidak dapat dibuka. Tambahkan ulang jika diperlukan.',
                ),
              if (available) ...[
                const SizedBox(height: KonsenaSpacing.sm),
                FilledButton.tonalIcon(
                  onPressed: () => context.push(
                    '/consent-ui/review?auditId=${audit.id}&sourceId=${source.id}',
                  ),
                  icon: const Icon(Icons.crop_rounded),
                  label: const Text('Atur area dan catatan'),
                ),
              ],
            ],
            OutlinedButton.icon(
              onPressed: () =>
                  context.push('/consent-ui/import?auditId=${audit.id}'),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Tambah screenshot'),
            ),
          ],
        ),
        const SizedBox(height: KonsenaSpacing.md),
        if (OnnxTensorHarness.enabled)
          DarkPatternQaPanel(
            key: ValueKey(source?.id),
            snapshot: widget.snapshot,
            repository: widget.repository,
            source: available ? source : null,
          )
        else
          const ReviewSection(
            icon: Icons.auto_awesome_outlined,
            title: 'Pemeriksaan AI',
            subtitle: 'Belum tersedia di build ini.',
            children: [],
          ),
        const SizedBox(height: KonsenaSpacing.md),
        ReviewSection(
          icon: Icons.edit_note_rounded,
          title: 'Catatan manual',
          children: [
            if (!available || review == null || review.annotations.isEmpty)
              const Text('Belum ada catatan pada screenshot ini.'),
            if (available && review != null)
              for (final annotation in review.annotations)
                Padding(
                  padding: const EdgeInsets.only(bottom: KonsenaSpacing.xs),
                  child: _AnnotationRow(annotation: annotation),
                ),
          ],
        ),
      ],
    );
  }
}

class _AnnotationRow extends StatelessWidget {
  const _AnnotationRow({required this.annotation});

  final ManualAnnotation annotation;

  @override
  Widget build(BuildContext context) {
    final (icon, title) = switch (annotation.kind) {
      'setuju' => (Icons.check_circle_outline, 'Tombol setuju'),
      'tolak' => (Icons.cancel_outlined, 'Tombol tolak'),
      'checkbox' => (Icons.check_box_outlined, 'Kotak centang'),
      'tujuan' => (Icons.info_outline, 'Tujuan'),
      _ => (Icons.push_pin_outlined, 'Bukti visual'),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: KonsenaSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(annotation.label),
            ],
          ),
        ),
      ],
    );
  }
}
