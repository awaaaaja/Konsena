import 'dart:typed_data';

import 'package:android_file_picker/android_file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../scan/presentation/scan_audit_target.dart';
import '../../shared/widgets/konsena_back_button.dart';
import '../../shared/widgets/review_section.dart';
import '../domain/screenshot_review.dart';
import 'screenshot_rect_dialog.dart';

class ScreenshotImportPage extends StatefulWidget {
  const ScreenshotImportPage({this.auditId, this.repository, super.key});
  final String? auditId;
  final AuditRepository? repository;
  @override
  State<ScreenshotImportPage> createState() => _ScreenshotImportPageState();
}

class _ScreenshotImportPageState extends State<ScreenshotImportPage> {
  bool _busy = false;
  String? _error;
  Future<void> _pick() async {
    if (_busy || widget.repository == null || widget.auditId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg'],
        androidOptions: const FilePickerAndroidOptions(
          safOptions: AndroidSAFOptions(
            grant: AndroidSAFGrant.transient,
            accessMode: AndroidSAFAccessMode.readOnly,
            persistGrant: false,
          ),
        ),
      );
      if (file == null || !mounted) return;
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in file.readAsByteStream()) {
        if (bytes.length + chunk.length > ScreenshotProcessor.maxBytes) {
          throw const FormatException('Max 10 MB');
        }
        bytes.add(chunk);
      }
      final data = bytes.takeBytes();
      ScreenshotProcessor.decode(
        data,
      ); // Verify magic and dimensions before persistence.
      if (!mounted) return;
      final source = await widget.repository!.attachSource(
        auditId: widget.auditId!,
        bytes: data,
        type: AuditSourceType.consentUi,
        mediaType: data[0] == 137 ? 'image/png' : 'image/jpeg',
        originalName: file.name,
      );
      if (mounted) {
        context.push(
          '/consent-ui/review?auditId=${source.auditId}&sourceId=${source.id}',
        );
      }
    } on Object {
      if (mounted) {
        setState(
          () => _error = 'Gambar tidak dapat diimpor. Pilih PNG/JPEG maksimal 10 MB dan 16 megapiksel.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: KonsenaBackButton(
        fallback: scanLocation('/scan', widget.auditId),
      ),
      title: const Text('Impor Screenshot'),
    ),
    body: ScanAuditTarget(
      auditId: widget.auditId,
      repository: widget.repository,
      path: '/consent-ui/import',
      focus: AuditFocus.visual,
      builder: (audit) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ScanTargetLabel(name: audit.name),
          const SizedBox(height: 12),
          ReviewSection(
            icon: Icons.image_outlined,
            title: 'Pilih screenshot',
            subtitle: 'PNG atau JPEG, maksimal 10 MB.',
            children: [
              const Text(
                'Setelah memilih gambar, atur area dan tambahkan catatan.',
              ),
              if (_error != null) Text(_error!),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _pick,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(_busy ? 'Memeriksa gambar…' : 'Pilih PNG / JPEG'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class ScreenshotReviewPage extends StatefulWidget {
  const ScreenshotReviewPage({
    this.auditId,
    this.sourceId,
    this.repository,
    super.key,
  });
  final String? auditId, sourceId;
  final AuditRepository? repository;
  @override
  State<ScreenshotReviewPage> createState() => _ScreenshotReviewPageState();
}

class _ScreenshotReviewPageState extends State<ScreenshotReviewPage> {
  img.Image? _original;
  Uint8List? _preview;
  Uint8List? _originalPreview;
  SourceRect _crop = const SourceRect(0, 0, 1, 1);
  int _turns = 0;
  final _title = TextEditingController(), _version = TextEditingController();
  final List<ManualAnnotation> _annotations = [];
  List<({ScreenshotReview review, DateTime at})> _history = [];
  String? _error;
  bool _busy = false, _dirty = false, _confirmingExit = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _version.dispose();
    super.dispose();
  }

  ScreenshotReview get _review => ScreenshotReview(
    crop: _crop,
    quarterTurns: _turns,
    title: _title.text,
    version: _version.text,
    annotations: List.of(_annotations),
  );
  Future<void> _load() async {
    try {
      final repo = widget.repository;
      if (repo == null || widget.sourceId == null || widget.auditId == null) {
        throw StateError('Missing source');
      }
      final source = await repo.source(widget.sourceId!);
      if (source.auditId != widget.auditId ||
          source.type != AuditSourceType.consentUi) {
        throw StateError('Wrong association');
      }
      final bytes = await repo.readSource(source.id);
      final history = await repo.screenshotHistory(source.auditId, source.id);
      final original = ScreenshotProcessor.decode(Uint8List.fromList(bytes));
      if (!mounted) return;
      _original = original;
      _originalPreview = Uint8List.fromList(
        img.encodePng(img.copyResize(original, width: 600)),
      );
      _history = history;
      final review = history.isEmpty
          ? ScreenshotReview(title: source.originalName ?? 'Screenshot')
          : history.first.review;
      _crop = review.crop;
      _turns = review.quarterTurns;
      _title.text = review.title;
      _version.text = review.version;
      _annotations.clear();
      _annotations.addAll(review.annotations);
      _render();
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'Screenshot tidak tersedia atau tidak terkait audit ini.',
        );
      }
    }
  }

  void _render() {
    if (_original == null) return;
    setState(() => _preview = ScreenshotProcessor.preview(_original!, _review));
  }

  Future<void> _rectDialog({bool annotation = false, int? editIndex}) async {
    final current = editIndex == null ? null : _annotations[editIndex];
    final result = await showDialog<RectEditValue>(
      context: context,
      builder: (_) => ScreenshotRectDialog(
        annotation: annotation,
        initialAnnotation: current,
        initialRect:
            current?.rect ??
            (annotation ? const SourceRect(0, 0, 1, 1) : _crop),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _dirty = true;
        if (annotation) {
          final value = ManualAnnotation(
            kind: result.kind,
            label: result.label,
            rect: result.rect,
          );
          if (editIndex == null) {
            _annotations.add(value);
          } else {
            _annotations[editIndex] = value;
          }
        } else {
          _crop = result.rect;
        }
      });
      _render();
    }
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.repository!.saveScreenshotReview(
        auditId: widget.auditId!,
        sourceId: widget.sourceId!,
        review: _review,
      );
      if (mounted) {
        setState(() => _dirty = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screenshot tersimpan dan ditinjau.')),
        );
        context.go('/audit/${widget.auditId}/sources');
      }
    } on Object {
      if (mounted) {
        setState(
          () =>
              _error = 'Revisi belum tersimpan. Periksa sumber lalu coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leave() async {
    if (_busy || _confirmingExit) return;
    if (_dirty) {
      _confirmingExit = true;
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tinggalkan perubahan?'),
          content: const Text('Perubahan yang belum disimpan akan hilang.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Lanjut edit'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Buang perubahan'),
            ),
          ],
        ),
      );
      _confirmingExit = false;
      if (discard != true || !mounted) return;
      setState(() => _dirty = false);
      await WidgetsBinding.instance.endOfFrame;
    }
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(
        widget.auditId == null ? '/scan' : '/audit/${widget.auditId}/sources',
      );
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy && !_dirty,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && _dirty) _leave();
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _busy ? null : _leave,
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Review Screenshot'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_error != null) Text(_error!),
          if (_preview != null) ...[
            ReviewSection(
              icon: Icons.crop_outlined,
              title: 'Area yang diperiksa',
              subtitle: 'Atur bagian screenshot yang ingin kamu tinjau.',
              children: [
                Image.memory(
                  _preview!,
                  height: 260,
                  fit: BoxFit.contain,
                  semanticLabel: 'Pratinjau area screenshot yang dipilih',
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _rectDialog(),
                      icon: const Icon(Icons.crop),
                      label: const Text('Atur area'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () {
                              _turns = (_turns + 1) % 4;
                              _dirty = true;
                              _render();
                            },
                      icon: const Icon(Icons.rotate_right),
                      label: const Text('Putar 90°'),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () {
                              _crop = const SourceRect(0, 0, 1, 1);
                              _turns = 0;
                              _dirty = true;
                              _render();
                            },
                      child: const Text('Reset tampilan'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ReviewSection(
              icon: Icons.edit_note_outlined,
              title: 'Catatan manual',
              subtitle: 'Opsional. Tandai elemen yang ingin kamu ingat.',
              children: [
                for (var i = 0; i < _annotations.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: _busy
                        ? null
                        : () => _rectDialog(annotation: true, editIndex: i),
                    title: Text(_annotations[i].label),
                    subtitle: Text(_annotations[i].kind),
                    trailing: IconButton(
                      tooltip: 'Hapus anotasi',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              _annotations.removeAt(i);
                              _dirty = true;
                            }),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _rectDialog(annotation: true),
                  icon: const Icon(Icons.add_comment_outlined),
                  label: const Text('Tambah anotasi manual'),
                ),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Lihat gambar asli'),
                  children: [
                    Image.memory(
                      _originalPreview!,
                      height: 200,
                      fit: BoxFit.contain,
                      semanticLabel: 'Gambar asli untuk rujukan posisi anotasi',
                    ),
                  ],
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Detail sumber'),
              children: [
                TextField(
                  controller: _title,
                  enabled: !_busy,
                  maxLength: 255,
                  onChanged: (_) => setState(() => _dirty = true),
                  decoration: const InputDecoration(labelText: 'Judul sumber'),
                ),
                TextField(
                  controller: _version,
                  enabled: !_busy,
                  maxLength: 255,
                  onChanged: (_) => setState(() => _dirty = true),
                  decoration: const InputDecoration(
                    labelText: 'Versi / tanggal sumber',
                  ),
                ),
                for (final entry in _history)
                  ExpansionTile(
                    title: Text(entry.at.toLocal().toString()),
                    children: [SelectableText(entry.review.encode())],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_history.isNotEmpty && !_dirty) ...[
              const ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('Tersimpan dan ditinjau'),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/audit/${widget.auditId}/sources'),
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Buka audit'),
              ),
            ] else
              FilledButton.icon(
                onPressed: _busy ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(_busy ? 'Menyimpan…' : 'Simpan dan buka audit'),
              ),
          ] else if (_error == null)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    ),
  );
}
