import 'dart:convert';
import 'dart:typed_data';

import 'package:android_file_picker/android_file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../../theme/konsena_spacing.dart';
import '../data/policy_document_processor.dart';
import '../domain/policy_import_models.dart';
import '../../shared/widgets/konsena_back_button.dart';
import '../../scan/presentation/scan_audit_target.dart';
import '../../shared/widgets/review_section.dart';

class PolicyImportRequest {
  const PolicyImportRequest({
    required this.auditId,
    required this.sourceId,
    required this.type,
    required this.fileName,
    required this.bytes,
    this.sourceUrl,
    this.documentVersion,
    this.pasted = false,
  });

  final String auditId;
  final String sourceId;
  final AuditSourceType type;
  final String fileName;
  final Uint8List bytes;
  final String? sourceUrl;
  final String? documentVersion;
  final bool pasted;
}

class PolicyImportPage extends StatefulWidget {
  const PolicyImportPage({
    required this.auditId,
    required this.type,
    required this.repository,
    this.sourceUrl,
    this.documentVersion,
    super.key,
  });

  final String? auditId;
  final String? type;
  final String? sourceUrl;
  final String? documentVersion;
  final AuditRepository? repository;

  @override
  State<PolicyImportPage> createState() => _PolicyImportPageState();
}

class _PolicyImportPageState extends State<PolicyImportPage> {
  final _pasteController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  AuditSourceType? get _sourceType {
    for (final type in AuditSourceType.values) {
      if (type.name == widget.type &&
          {
            AuditSourceType.privacyPolicy,
            AuditSourceType.terms,
            AuditSourceType.otherDocument,
          }.contains(type)) {
        return type;
      }
    }
    return null;
  }

  Future<void> _pickFile() async {
    if (_busy) return;
    final auditId = widget.auditId;
    final type = _sourceType;
    if (auditId == null || widget.repository == null || type == null) {
      setState(
        () =>
            _error = 'Buka impor dari workspace audit dan pilih jenis dokumen.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: 'Pilih Privacy Policy atau Terms',
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'txt'],
        androidOptions: const FilePickerAndroidOptions(
          safOptions: AndroidSAFOptions(
            grant: AndroidSAFGrant.transient,
            accessMode: AndroidSAFAccessMode.readOnly,
            persistGrant: false,
          ),
        ),
      );
      if (file == null || !mounted) return;
      final name = file.name;
      final extension = name.split('.').last.toLowerCase();
      final limit = extension == 'pdf'
          ? PolicyDocumentProcessor.maxPdfBytes
          : (extension == 'jpg' || extension == 'jpeg' || extension == 'png')
          ? PolicyDocumentProcessor.maxImageBytes
          : PolicyDocumentProcessor.maxTextBytes;
      final bytes = await _readCapped(file, limit);
      if (!mounted) return;
      final source = await widget.repository!.attachSource(
        auditId: auditId,
        bytes: bytes,
        type: type,
        mediaType: _mediaTypeForName(name),
        originalName: name,
        language: 'id,en',
        sourceUrl: _optional(widget.sourceUrl),
        documentVersion: _optional(widget.documentVersion),
      );
      if (!mounted) return;
      context.push(
        '/scan/import/progress',
        extra: PolicyImportRequest(
          auditId: auditId,
          sourceId: source.id,
          type: type,
          fileName: name,
          bytes: bytes,
          sourceUrl: _optional(widget.sourceUrl),
          documentVersion: _optional(widget.documentVersion),
        ),
      );
    } on PolicyImportException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'Berkas tidak dapat dibaca. Periksa akses SAF lalu pilih ulang.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Uint8List> _readCapped(PlatformFile file, int limit) async {
    final reportedLength = await file.length();
    if (reportedLength != null && reportedLength > limit) {
      throw const PolicyImportException(
        'oversize',
        'Berkas melebihi batas ukuran format ini.',
      );
    }
    final builder = BytesBuilder(copy: false);
    var count = 0;
    await for (final chunk in file.readAsByteStream()) {
      count += chunk.length;
      if (count > limit) {
        throw const PolicyImportException(
          'oversize',
          'Berkas melebihi batas ukuran format ini.',
        );
      }
      builder.add(chunk);
    }
    if (count == 0) {
      throw const PolicyImportException(
        'empty',
        'Berkas kosong atau sudah tidak dapat dibaca.',
      );
    }
    return builder.takeBytes();
  }

  Future<void> _paste() async {
    if (_busy) return;
    final auditId = widget.auditId;
    final type = _sourceType;
    if (auditId == null || widget.repository == null || type == null) {
      setState(
        () =>
            _error = 'Buka impor dari workspace audit dan pilih jenis dokumen.',
      );
      return;
    }
    if (_pasteController.text.trim().isEmpty) {
      setState(
        () => _error = 'Tempel teks yang ingin ditinjau terlebih dahulu.',
      );
      return;
    }
    final bytes = Uint8List.fromList(utf8.encode(_pasteController.text));
    if (bytes.length > PolicyDocumentProcessor.maxTextBytes) {
      setState(
        () => _error =
            'Teks melebihi batas 5 MB. Ringkas teks atau pilih berkas TXT.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final source = await widget.repository!.attachSource(
        auditId: auditId,
        bytes: bytes,
        type: type,
        mediaType: 'text/plain; charset=utf-8',
        originalName: 'Teks tempel',
        language: 'id,en',
        sourceUrl: _optional(widget.sourceUrl),
        documentVersion: _optional(widget.documentVersion),
      );
      if (!mounted) return;
      context.push(
        '/scan/import/progress',
        extra: PolicyImportRequest(
          auditId: auditId,
          sourceId: source.id,
          type: type,
          fileName: 'Teks tempel',
          bytes: bytes,
          sourceUrl: _optional(widget.sourceUrl),
          documentVersion: _optional(widget.documentVersion),
          pasted: true,
        ),
      );
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'Teks belum tersimpan. Periksa batas ukuran lalu coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = _sourceType;
    final destination = scanLocation('/scan/document-type', widget.auditId);
    return Scaffold(
      appBar: AppBar(
        leading: KonsenaBackButton(fallback: destination),
        title: const Text('Impor Dokumen'),
      ),
      body: widget.auditId == null || type == null
          ? ListView(
              padding: const EdgeInsets.all(KonsenaSpacing.lg),
              children: [
                ReviewSection(
                  icon: Icons.description_outlined,
                  title: 'Siapkan tujuan impor',
                  subtitle: 'Pilih audit dan jenis dokumen sebelum mengimpor.',
                  children: [
                    FilledButton(
                      onPressed: () => context.replace(destination),
                      child: const Text('Pilih audit dan jenis dokumen'),
                    ),
                  ],
                ),
              ],
            )
          : ScanAuditTarget(
              auditId: widget.auditId,
              repository: widget.repository,
              path: '/scan/document-type',
              focus: AuditFocus.documents,
              builder: (audit) => ListView(
                padding: const EdgeInsets.all(KonsenaSpacing.lg),
                children: [
                  ScanTargetLabel(name: audit.name),
                  Text('Jenis: ${_sourceLabel(type)}'),
                  const SizedBox(height: KonsenaSpacing.md),
                  if (_error case final message?) ...[
                    Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: KonsenaSpacing.sm),
                  ],
                  ReviewSection(
                    icon: Icons.attach_file_rounded,
                    title: 'Pilih file',
                    subtitle: 'PDF hingga 25 MB atau 100 halaman. Gambar hingga 15 MB. TXT hingga 5 MB.',
                    children: [
                      FilledButton.icon(
                        onPressed: _busy ? null : _pickFile,
                        icon: const Icon(Icons.folder_open_outlined),
                        label: Text(
                          _busy
                              ? 'Menyiapkan sumber…'
                              : 'Pilih PDF, JPG, PNG, atau TXT',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KonsenaSpacing.md),
                  ReviewSection(
                    icon: Icons.content_paste_outlined,
                    title: 'Tempel teks',
                    subtitle: 'Teks dan hasil ekstraksi bisa ditinjau sebelum digunakan.',
                    children: [
                      TextField(
                        controller: _pasteController,
                        enabled: !_busy,
                        minLines: 3,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          labelText: 'Teks dokumen',
                          helperText: 'Maksimum 5 MB',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: KonsenaSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _paste,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Proses teks tempel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class PolicyImportProgressPage extends StatefulWidget {
  const PolicyImportProgressPage({
    required this.request,
    required this.repository,
    super.key,
  });
  final PolicyImportRequest? request;
  final AuditRepository? repository;

  @override
  State<PolicyImportProgressPage> createState() =>
      _PolicyImportProgressPageState();
}

class _PolicyImportProgressPageState extends State<PolicyImportProgressPage> {
  final _processor = PolicyDocumentProcessor();
  PolicyImportCancellationToken _cancel = PolicyImportCancellationToken();
  PolicyImportProgress _progress = const PolicyImportProgress(
    completed: 0,
    total: 0,
  );
  String? _error;
  bool _busy = true;
  String? _password;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void dispose() {
    _cancel.cancel();
    super.dispose();
  }

  Future<void> _run() async {
    if (!mounted) return;
    _cancel = PolicyImportCancellationToken();
    final request = widget.request;
    final repository = widget.repository;
    if (request == null || repository == null) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Permintaan impor tidak tersedia. Pilih kembali berkas.';
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _busy = true;
        _error = null;
      });
    }
    try {
      final result = request.pasted
          ? await _processor.processPastedText(
              text: utf8.decode(request.bytes),
              cancellation: _cancel,
            )
          : await _processor.processFile(
              bytes: request.bytes,
              fileName: request.fileName,
              cancellation: _cancel,
              pdfPassword: _password,
              onProgress: (progress) {
                if (mounted) setState(() => _progress = progress);
              },
            );
      _cancel.throwIfCancelled();
      await repository.updateImportWarnings(
        sourceId: request.sourceId,
        warnings: result.warnings,
      );
      await repository.saveImportedSegments(
        sourceId: request.sourceId,
        segments: result.segments,
        reviewed: false,
      );
      if (mounted) context.go('/scan/review/${request.sourceId}');
    } on PolicyImportCancelled {
      if (mounted) {
        setState(() {
          _error = 'Impor dibatalkan. Sumber terenkripsi tetap tersedia; tekan coba lagi untuk melanjutkan.';
        });
      }
    } on PolicyImportException catch (error) {
      if (error.code == 'password' && mounted) {
        final password = await _askPassword();
        if (password != null && mounted) {
          setState(() => _password = password);
          await _run();
          return;
        }
      }
      if (mounted) setState(() => _error = error.message);
    } on Object {
      if (mounted) {
        setState(
          () =>
              _error = 'Impor gagal disimpan. Coba ulangi; sumber tetap lokal.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askPassword() async {
    var password = '';
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('PDF dilindungi kata sandi'),
        content: TextField(
          onChanged: (value) => password = value,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Kata sandi PDF'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, password),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: KonsenaBackButton(
        fallback: scanLocation('/scan/document-type', widget.request?.auditId),
      ),
      title: const Text('Progres Impor'),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(KonsenaSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_busy) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: KonsenaSpacing.md),
              Text(
                widget.request?.fileName ?? 'Dokumen',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: KonsenaSpacing.xs),
              Text(
                _progress.total == 0
                    ? 'Menyiapkan ekstraksi lokal…'
                    : 'Halaman ${_progress.completed} dari ${_progress.total}',
              ),
              if (_progress.total > 0)
                LinearProgressIndicator(value: _progress.fraction),
              TextButton(
                onPressed: () => _cancel.cancel(),
                child: const Text('Batalkan'),
              ),
            ] else ...[
              Text(_error ?? 'Impor selesai.', textAlign: TextAlign.center),
              if (_error != null) ...[
                const SizedBox(height: KonsenaSpacing.md),
                FilledButton(onPressed: _run, child: const Text('Coba lagi')),
                TextButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(
                        scanLocation(
                          '/scan/document-type',
                          widget.request?.auditId,
                        ),
                      );
                    }
                  },
                  child: const Text('Kembali ke impor'),
                ),
                if (widget.request case final request?)
                  TextButton(
                    onPressed: () =>
                        context.go('/audit/${request.auditId}/sources'),
                    child: const Text('Buka audit'),
                  ),
              ],
            ],
          ],
        ),
      ),
    ),
  );
}

class PolicyDocumentTypePage extends StatefulWidget {
  const PolicyDocumentTypePage({
    required this.auditId,
    this.repository,
    super.key,
  });
  final String? auditId;
  final AuditRepository? repository;

  @override
  State<PolicyDocumentTypePage> createState() => _PolicyDocumentTypePageState();
}

class _PolicyDocumentTypePageState extends State<PolicyDocumentTypePage> {
  AuditSourceType? _type;
  final _url = TextEditingController();
  final _version = TextEditingController();

  @override
  void dispose() {
    _url.dispose();
    _version.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: KonsenaBackButton(
        fallback: scanLocation('/scan', widget.auditId),
      ),
      title: const Text('Jenis Dokumen'),
    ),
    body: ScanAuditTarget(
      auditId: widget.auditId,
      repository: widget.repository,
      path: '/scan/document-type',
      focus: AuditFocus.documents,
      builder: (audit) => ListView(
        padding: const EdgeInsets.all(KonsenaSpacing.lg),
        children: [
          ScanTargetLabel(name: audit.name),
          const SizedBox(height: KonsenaSpacing.md),
          ReviewSection(
            icon: Icons.description_outlined,
            title: 'Jenis dokumen',
            subtitle: 'Pilih jenis yang sesuai dengan sumbermu.',
            children: [
              RadioGroup<AuditSourceType>(
                groupValue: _type,
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
                child: Column(
                  children: [
                    for (final entry in const [
                      (AuditSourceType.privacyPolicy, 'Privacy Policy'),
                      (AuditSourceType.terms, 'Terms of Service'),
                      (
                        AuditSourceType.otherDocument,
                        'Dokumen lain / belum tahu',
                      ),
                    ])
                      RadioListTile<AuditSourceType>(
                        contentPadding: EdgeInsets.zero,
                        value: entry.$1,
                        title: Text(entry.$2),
                      ),
                  ],
                ),
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Tambahkan detail sumber'),
                children: [
                  TextField(
                    controller: _url,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'URL sumber (opsional)',
                    ),
                  ),
                  TextField(
                    controller: _version,
                    decoration: const InputDecoration(
                      labelText: 'Versi / tanggal (opsional)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KonsenaSpacing.sm),
              FilledButton.icon(
                onPressed: _type == null
                    ? null
                    : () => context.push(
                        Uri(
                          path: '/scan/import',
                          queryParameters: {
                            'auditId': audit.id,
                            'type': _type!.name,
                            if (_url.text.trim().isNotEmpty)
                              'url': _url.text.trim(),
                            if (_version.text.trim().isNotEmpty)
                              'version': _version.text.trim(),
                          },
                        ).toString(),
                      ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Lanjut ke impor'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class PolicyReviewPage extends StatefulWidget {
  const PolicyReviewPage({
    required this.sourceId,
    required this.repository,
    super.key,
  });
  final String? sourceId;
  final AuditRepository? repository;

  @override
  State<PolicyReviewPage> createState() => _PolicyReviewPageState();
}

class _PolicyReviewPageState extends State<PolicyReviewPage> {
  final _processor = PolicyDocumentProcessor();
  bool _loading = true;
  bool _saving = false;
  bool _confirmingExit = false;
  bool _allowExit = false;
  String? _error;
  DocumentSource? _source;
  List<DocumentSegment> _segments = [];
  final Map<String, TextEditingController> _controllers = {};

  bool get _saved =>
      _source?.reviewStatus == SourceReviewStatus.reviewed &&
      _segments.isNotEmpty &&
      _segments.every(
        (segment) =>
            segment.reviewedAt != null &&
            _controllers[segment.id]?.text == segment.text,
      );

  bool get _dirty => _segments.any(
    (segment) => _controllers[segment.id]?.text != segment.text,
  );

  String get _auditPath =>
      _source == null ? '/scan' : '/audit/${_source!.auditId}/sources';

  Future<void> _leave({String? destination}) async {
    if (_saving || _confirmingExit) return;
    if (_dirty) {
      _confirmingExit = true;
      final discard = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Buang perubahan teks?'),
          content: const Text('Simpan koreksi jika ingin melanjutkan nanti.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Lanjut edit'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Buang perubahan'),
            ),
          ],
        ),
      );
      _confirmingExit = false;
      if (!mounted || discard != true) return;
      setState(() => _allowExit = true);
      await WidgetsBinding.instance.endOfFrame;
    }
    if (!mounted) return;
    if (destination != null) {
      context.go(destination);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(_auditPath);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final id = widget.sourceId;
      final repo = widget.repository;
      if (id == null || repo == null) throw StateError('missing source');
      final source = await repo.source(id);
      final segments = await repo.documentSegments(id);
      if (!mounted) return;
      for (final segment in segments) {
        final controller = _controllers.putIfAbsent(
          segment.id,
          () => TextEditingController(text: segment.text),
        );
        if (controller.text != segment.text) controller.text = segment.text;
      }
      setState(() {
        _source = source;
        _segments = segments;
        _loading = false;
        _error = null;
      });
    } on Object {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Dokumen tidak ditemukan atau tidak dapat dibaca.';
        });
      }
    }
  }

  Future<void> _save() async {
    final id = widget.sourceId;
    final repo = widget.repository;
    if (id == null || repo == null || _saving || _saved) return;
    if (_segments.any((segment) {
      final text = _controllers[segment.id]!.text;
      return text.trim().isEmpty || text.length > 100000;
    })) {
      setState(() => _error = 'Periksa isi dan panjang setiap paragraf.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      for (final segment in _segments) {
        await repo.updateImportedSegment(
          sourceId: id,
          segmentId: segment.id,
          text: _controllers[segment.id]!.text,
          reviewed: true,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koreksi dan status review tersimpan di perangkat.'),
        ),
      );
      await _load();
    } on Object {
      if (mounted) {
        setState(
          () => _error = 'Perubahan belum tersimpan. Periksa setiap paragraf lalu coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resumeImport() async {
    final id = widget.sourceId;
    final repo = widget.repository;
    final source = _source;
    if (id == null || repo == null || source == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final bytes = Uint8List.fromList(await repo.readSource(id));
      final cancellation = PolicyImportCancellationToken();
      final pasted = source.originalName == 'Teks tempel';
      final result = pasted
          ? await _processor.processPastedText(
              text: utf8.decode(bytes),
              cancellation: cancellation,
            )
          : await _processor.processFile(
              bytes: bytes,
              fileName: source.originalName ?? 'dokumen',
              cancellation: cancellation,
            );
      await repo.updateImportWarnings(sourceId: id, warnings: result.warnings);
      await repo.saveImportedSegments(
        sourceId: id,
        segments: result.segments,
        reviewed: false,
      );
      await _load();
    } on PolicyImportException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on Object {
      if (mounted) {
        setState(
          () => _error = 'Sumber terenkripsi tidak dapat diproses ulang. Impor ulang atau masukkan teks manual.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final source = _source;
    final saved = _saved;
    return PopScope(
      canPop: !_saving && (!_dirty || _allowExit),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _dirty && !_allowExit) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Kembali',
            onPressed: _saving ? null : _leave,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Review Teks'),
        ),
        body: source == null
            ? Center(child: Text(_error ?? 'Sumber tidak tersedia.'))
            : ListView(
                padding: const EdgeInsets.all(KonsenaSpacing.lg),
                children: [
                  Text(
                    source.originalName ?? 'Dokumen',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(_sourceLabel(source.type)),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Detail sumber'),
                    children: [
                      ListTile(
                        title: const Text('SHA-256'),
                        subtitle: SelectableText(source.sha256),
                      ),
                      if (source.sourceUrl case final url?)
                        ListTile(title: const Text('URL'), subtitle: Text(url)),
                      if (source.documentVersion case final version?)
                        ListTile(
                          title: const Text('Versi'),
                          subtitle: Text(version),
                        ),
                    ],
                  ),
                  if (source.importWarnings != null) ...[
                    const SizedBox(height: KonsenaSpacing.sm),
                    Text(
                      source.importWarnings!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    Text(
                      source.reviewStatus == SourceReviewStatus.reviewed
                          ? 'Teks telah ditinjau pengguna; ini bukan analisis hukum.'
                          : 'OCR belum terverifikasi. Periksa teks sebelum menandai review selesai.',
                    ),
                  ],
                  const SizedBox(height: KonsenaSpacing.md),
                  if (_segments.isEmpty) ...[
                    const Text(
                      'Belum ada paragraf tersimpan. Sumber asli terenkripsi dapat diproses ulang.',
                    ),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _resumeImport,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Lanjutkan dari sumber tersimpan'),
                    ),
                  ],
                  for (final segment in _segments)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(KonsenaSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halaman ${segment.page ?? 1} · ${segment.extractionMethod ?? 'teks'} · posisi ${segment.startOffset ?? 0}–${segment.endOffset ?? 0}',
                            ),
                            if (segment.confidence != null)
                              Text(
                                'Confidence OCR: ${(segment.confidence! * 100).toStringAsFixed(0)}%',
                              ),
                            TextField(
                              controller: _controllers[segment.id],
                              enabled: !_saving,
                              onChanged: (_) => setState(() => _error = null),
                              minLines: 2,
                              maxLines: 8,
                              decoration: const InputDecoration(
                                labelText: 'Paragraf untuk ditinjau',
                              ),
                            ),
                            Text(
                              'Hash halaman ${segment.pageTextSha256?.substring(0, 12) ?? 'tidak tersedia'}…',
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_error != null)
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: _saving || saved || _segments.isEmpty
                        ? null
                        : _save,
                    icon: Icon(saved ? Icons.check : Icons.save_outlined),
                    label: Text(
                      _saving
                          ? 'Menyimpan…'
                          : saved
                          ? 'Tersimpan dan ditinjau'
                          : 'Simpan koreksi dan tandai ditinjau',
                    ),
                  ),
                  const SizedBox(height: KonsenaSpacing.xs),
                  OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () => _leave(destination: _auditPath),
                    icon: const Icon(Icons.folder_open_outlined),
                    label: Text(saved ? 'Buka audit' : 'Kembali ke audit'),
                  ),
                  if (saved)
                    OutlinedButton.icon(
                      onPressed: _saving
                          ? null
                          : () => context.push(
                              scanLocation('/scan', source.auditId),
                            ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Tambah sumber lain'),
                    ),
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => _leave(
                            destination: '/document/${source.id}/clauses',
                          ),
                    child: const Text('Baca dokumen'),
                  ),
                ],
              ),
      ),
    );
  }
}

class PolicyDocumentReadPage extends StatelessWidget {
  const PolicyDocumentReadPage({
    required this.sourceId,
    required this.repository,
    super.key,
  });
  final String? sourceId;
  final AuditRepository? repository;

  @override
  Widget build(BuildContext context) => FutureBuilder<DocumentSource>(
    future: sourceId == null || repository == null
        ? Future.error(StateError('missing source'))
        : repository!.source(sourceId!),
    builder: (context, sourceSnapshot) {
      if (sourceSnapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final source = sourceSnapshot.data;
      if (source == null || repository == null || sourceId == null) {
        return Scaffold(
          appBar: AppBar(
            leading: const KonsenaBackButton(fallback: '/scan'),
            title: const Text('Dokumen dan Klausul'),
          ),
          body: Center(child: Text('Dokumen tidak tersedia.')),
        );
      }
      return FutureBuilder<List<DocumentSegment>>(
        future: repository!.documentSegments(sourceId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final segments = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              leading: const KonsenaBackButton(fallback: '/scan'),
              title: const Text('Dokumen dan Klausul'),
            ),
            body: segments == null
                ? const Center(child: Text('Dokumen tidak tersedia.'))
                : ListView(
                    padding: const EdgeInsets.all(KonsenaSpacing.lg),
                    children: [
                      Text(
                        '${_sourceLabel(source.type)} · ${source.originalName ?? 'Dokumen'}',
                      ),
                      if (source.sourceUrl != null)
                        Text('Sumber: ${source.sourceUrl}'),
                      const Text(
                        'Pembacaan manual saja. Tidak ada klasifikasi atau analisis AI.',
                      ),
                      for (final segment in segments)
                        Card(
                          child: ListTile(
                            title: Text('Halaman ${segment.page ?? 1}'),
                            subtitle: Text(segment.text),
                            trailing: IconButton(
                              tooltip: 'Simpan kutipan sebagai bukti',
                              icon: const Icon(Icons.bookmark_add_outlined),
                              onPressed: () async {
                                try {
                                  await repository!.addEvidence(
                                    auditId: source.auditId,
                                    sourceId: source.id,
                                    sourceSha256: source.sha256,
                                    segmentId: segment.id,
                                    location:
                                        'page:${segment.page ?? 1};offset:${segment.startOffset ?? 0}-${segment.endOffset ?? 0};pageTextSha256:${segment.pageTextSha256 ?? ''}',
                                    quote: segment.text,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Kutipan ditautkan ke sumber dan hash dokumen.',
                                        ),
                                      ),
                                    );
                                  }
                                } on Object {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Kutipan belum dapat disimpan. Coba lagi.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      TextButton(
                        onPressed: () =>
                            context.go('/scan/review/${source.id}'),
                        child: const Text('Koreksi hasil ekstraksi'),
                      ),
                    ],
                  ),
          );
        },
      );
    },
  );
}

String _sourceLabel(AuditSourceType? type) => switch (type) {
  AuditSourceType.privacyPolicy => 'Privacy Policy',
  AuditSourceType.terms => 'Terms of Service',
  AuditSourceType.otherDocument => 'Dokumen lain',
  _ => 'Jenis belum dipilih',
};

String? _optional(String? value) =>
    value == null || value.trim().isEmpty ? null : value.trim();

String _mediaTypeForName(String name) =>
    switch (name.split('.').last.toLowerCase()) {
      'pdf' => 'application/pdf',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'txt' => 'text/plain; charset=utf-8',
      _ => 'application/octet-stream',
    };
