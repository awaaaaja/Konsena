import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../policy_import/data/policy_document_processor.dart';
import '../domain/live_scan_stitcher.dart';
import '../domain/live_scan_quality.dart';
import '../../shared/widgets/konsena_back_button.dart';
import '../../scan/presentation/scan_audit_target.dart';
import '../../shared/widgets/review_section.dart';

class LiveScanTutorialPage extends StatelessWidget {
  const LiveScanTutorialPage({super.key, this.auditId, this.repository});
  final String? auditId;
  final AuditRepository? repository;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: KonsenaBackButton(fallback: scanLocation('/scan', auditId)),
      title: const Text('Panduan LiveScan'),
    ),
    body: ScanAuditTarget(
      auditId: auditId,
      repository: repository,
      path: '/scan/camera/how-to',
      focus: AuditFocus.documents,
      builder: (audit) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ScanTargetLabel(name: audit.name),
          const SizedBox(height: 12),
          ReviewSection(
            icon: Icons.document_scanner_outlined,
            title: 'Siapkan layar yang akan dipindai',
            subtitle: 'Buka dokumen di laptop atau monitor lain.',
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.center_focus_strong),
                title: Text('Arahkan kamera ke teks'),
                subtitle: Text('Jaga ponsel stabil dan hindari pantulan.'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.swipe_vertical_outlined),
                title: Text('Gulir perlahan'),
                subtitle: Text('Berhenti sebentar agar teks bisa terbaca.'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.fact_check_outlined),
                title: Text('Tinjau hasil pindai'),
                subtitle: Text(
                  'Perbaiki teks dan cek bagian yang mungkin terlewat.',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () =>
                    context.push(scanLocation('/scan/camera/setup', audit.id)),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Siapkan kamera'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class LiveScanPermissionPage extends StatefulWidget {
  const LiveScanPermissionPage({super.key, this.auditId});
  final String? auditId;

  @override
  State<LiveScanPermissionPage> createState() => _LiveScanPermissionPageState();
}

class LiveScanPermissionRecoveryPage extends StatelessWidget {
  const LiveScanPermissionRecoveryPage({super.key, this.auditId});
  final String? auditId;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: KonsenaBackButton(
        fallback: scanLocation('/scan/camera/setup', auditId),
      ),
      title: const Text('Bantuan izin kamera'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Jika izin ditolak, kamu dapat mencoba lagi dari persiapan kamera. Jika ditolak permanen, aktifkan izin Kamera melalui Pengaturan aplikasi. LiveScan berhenti saat izin tidak tersedia.',
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(scanLocation('/scan/camera/setup', auditId));
            }
          },
          child: const Text('Coba izin lagi'),
        ),
        OutlinedButton(
          onPressed: openAppSettings,
          child: const Text('Buka Pengaturan aplikasi'),
        ),
        TextButton(
          onPressed: () =>
              context.push(scanLocation('/scan/document-type', auditId)),
          child: const Text('Impor dokumen sebagai alternatif'),
        ),
      ],
    ),
  );
}

class _LiveScanPermissionPageState extends State<LiveScanPermissionPage> {
  bool _busy = false;
  String? _message;

  Future<void> _continue() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      var status = await Permission.camera.status;
      if (!status.isGranted) status = await Permission.camera.request();
      if (!mounted) return;
      if (status.isGranted) {
        context.push(scanLocation('/scan/camera/live', widget.auditId));
      } else {
        setState(
          () => _message = status.isPermanentlyDenied
              ? 'Izin kamera ditolak permanen. Buka Pengaturan untuk mengaktifkannya, atau gunakan impor dokumen.'
              : 'Izin kamera belum diberikan. Kamu dapat mencoba lagi atau menggunakan impor dokumen.',
        );
      }
    } on Object {
      if (mounted) {
        setState(
          () => _message = 'Status kamera tidak dapat diperiksa. Periksa izin perangkat lalu coba lagi.',
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
        fallback: scanLocation('/scan/camera/how-to', widget.auditId),
      ),
      title: const Text('Persiapan Kamera'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Izin kamera hanya diminta saat kamu memulai LiveScan. Kamera digunakan untuk membaca teks pada monitor secara lokal.',
        ),
        if (_message != null) ...[
          const SizedBox(height: 16),
          Text(_message!, key: const ValueKey('camera-permission-message')),
          if (_message!.contains('Pengaturan'))
            TextButton(
              onPressed: openAppSettings,
              child: const Text('Buka Pengaturan'),
            ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _busy ? null : _continue,
          child: Text(_busy ? 'Memeriksa…' : 'Minta izin dan buka kamera'),
        ),
        TextButton(
          onPressed: _busy
              ? null
              : () => context.push(
                  scanLocation('/scan/camera/troubleshoot', widget.auditId),
                ),
          child: const Text('Bantuan izin kamera'),
        ),
        if (_message != null)
          OutlinedButton.icon(
            onPressed: () => context.push(
              scanLocation('/scan/document-type', widget.auditId),
            ),
            icon: const Icon(Icons.description_outlined),
            label: const Text('Impor dokumen sebagai alternatif'),
          ),
      ],
    ),
  );
}

class LiveScanCapturePage extends StatefulWidget {
  const LiveScanCapturePage({super.key, this.auditId});
  final String? auditId;
  @override
  State<LiveScanCapturePage> createState() => _LiveScanCapturePageState();
}

class _LiveScanCapturePageState extends State<LiveScanCapturePage>
    with WidgetsBindingObserver {
  CameraController? _camera;
  final GlobalKey _previewKey = GlobalKey();
  final LiveScanStitcher _stitcher = LiveScanStitcher();
  final PolicyDocumentProcessor _ocr = PolicyDocumentProcessor();
  Timer? _timer;
  bool _capturing = false;
  bool _busy = false;
  bool _paused = true;
  bool _opening = false;
  bool _reviewing = false;
  bool _foreground = true;
  bool _visible = false;
  bool _hasOpenedCamera = false;
  Future<void>? _closingCamera;
  int _frame = 0;
  String? _error;
  String _qualityLabel =
      'Atur jarak dan fokus; indikator kualitas adalah petunjuk heuristik.';
  // A conservative, adjustable rectangular ROI in normalized preview space.
  double _left = .08, _top = .18, _right = .92, _bottom = .82;
  double get _width => _right - _left;
  double get _height => _bottom - _top;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible =
        TickerMode.valuesOf(context).enabled &&
        ModalRoute.isCurrentOf(context) != false;
    if (visible == _visible) return;
    _visible = visible;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && visible == _visible) _syncCamera();
    });
  }

  void _syncCamera() {
    if (!_foreground || !_visible) {
      unawaited(_stopCamera());
    } else {
      unawaited(_openCamera(startCapture: !_hasOpenedCamera));
    }
  }

  Future<void> _openCamera({bool startCapture = true}) async {
    if (_opening ||
        _reviewing ||
        !_foreground ||
        !_visible ||
        _camera != null) {
      return;
    }
    _opening = true;
    CameraController? pending;
    try {
      await _closingCamera;
      if (!mounted || !_foreground || !_visible || _reviewing) return;
      if (!await Permission.camera.isGranted) {
        throw StateError('Izin kamera tidak aktif.');
      }
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('Kamera tidak tersedia pada perangkat ini.');
      }
      final camera = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      pending = camera;
      await camera.initialize();
      if (!mounted || !_foreground || !_visible || _reviewing) return;
      setState(() {
        _camera = camera;
        _hasOpenedCamera = true;
        _error = null;
      });
      pending = null;
      if (startCapture) _resume();
    } on Object catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Kamera tidak dapat dibuka. Periksa izin, tutup aplikasi kamera lain, lalu coba lagi.',
        );
      }
    } finally {
      if (pending != null) await pending.dispose();
      _opening = false;
    }
  }

  void _resume() {
    if (_camera == null || _capturing) return;
    setState(() {
      _capturing = true;
      _paused = false;
    });
    _timer = Timer.periodic(
      const Duration(milliseconds: 1800),
      (_) => _captureOne(),
    );
    _captureOne();
  }

  Future<void> _captureOne() async {
    final camera = _camera;
    if (!_capturing ||
        _busy ||
        !_visible ||
        !_foreground ||
        camera == null ||
        !camera.value.isInitialized ||
        camera.value.isTakingPicture) {
      return;
    }
    _busy = true;
    String? path;
    try {
      if (!await Permission.camera.isGranted) {
        await _stopCamera();
        if (mounted) {
          setState(() => _error = 'Izin kamera dicabut. Capture dihentikan.');
        }
        return;
      }
      if (!mounted || !_capturing || !_visible || !identical(_camera, camera)) {
        return;
      }
      final picture = await camera.takePicture();
      path = picture.path;
      final bytes = await File(path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return;
      final oriented = img.bakeOrientation(decoded);
      final crop = img.copyCrop(
        oriented,
        x: (_left * oriented.width).round().clamp(0, oriented.width - 1),
        y: (_top * oriented.height).round().clamp(0, oriented.height - 1),
        width: (_width * oriented.width).round().clamp(
          1,
          oriented.width -
              (_left * oriented.width).round().clamp(0, oriented.width - 1),
        ),
        height: (_height * oriented.height).round().clamp(
          1,
          oriented.height -
              (_top * oriented.height).round().clamp(0, oriented.height - 1),
        ),
      );
      final quality = LiveScanQuality.measure(crop);
      _qualityLabel = quality.label;
      final croppedBytes = Uint8List.fromList(img.encodeJpg(crop, quality: 82));
      final recognized = await _ocr.recognizeImage(croppedBytes);
      if (!mounted ||
          !_capturing ||
          !_visible ||
          !identical(_camera, camera) ||
          recognized.text.trim().isEmpty) {
        return;
      }
      _stitcher.add(
        LiveScanObservation(
          frame: ++_frame,
          capturedAt: DateTime.now().toUtc(),
          text: recognized.text,
          roi: [_left, _top, _width, _height],
          confidence: _meanConfidence(
            recognized.blocks.map((block) => block.confidence),
          ),
        ),
      );
      setState(() {});
    } on Object {
      if (mounted && _capturing) {
        setState(
          () => _error = 'Gambar belum terbaca. Stabilkan ponsel, atau jeda lalu lanjutkan.',
        );
      }
    } finally {
      if (path != null) {
        try {
          await File(path).delete();
        } on Object {
          /* best-effort cleanup */
        }
      }
      _busy = false;
    }
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _capturing = false;
      _paused = true;
    });
  }

  Future<void> _stopCamera() async {
    final camera = _camera;
    if (camera == null) return;
    _pause();
    _camera = null;
    final closing = camera.dispose();
    _closingCamera = closing;
    try {
      await closing;
    } finally {
      _closingCamera = null;
    }
  }

  Future<void> _review(LiveScanResult result) async {
    if (_reviewing) return;
    _reviewing = true;
    try {
      await _stopCamera();
      if (!mounted) return;
      await context.push(
        scanLocation('/scan/camera/merge', widget.auditId),
        extra: result,
      );
    } finally {
      _reviewing = false;
      if (mounted) await _openCamera(startCapture: false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    final camera = _camera;
    _camera = null;
    if (camera != null) unawaited(camera.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;
    final result = _stitcher.build();
    return Scaffold(
      appBar: AppBar(
        leading: KonsenaBackButton(
          fallback: scanLocation('/scan/camera/how-to', widget.auditId),
        ),
        title: const Text('LiveScan'),
      ),
      body: _error != null && camera == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!),
                    FilledButton(
                      onPressed: _openCamera,
                      child: const Text('Coba lagi'),
                    ),
                    TextButton(
                      onPressed: () => context.push(
                        scanLocation('/scan/document-type', widget.auditId),
                      ),
                      child: const Text('Impor dokumen sebagai alternatif'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 5,
                  child: camera != null && camera.value.isInitialized
                      ? ClipRect(
                          child: Center(
                            child: CameraPreview(
                              key: _previewKey,
                              camera,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Positioned.fill(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapDown: (details) {
                                        final box =
                                            _previewKey.currentContext
                                                    ?.findRenderObject()
                                                as RenderBox?;
                                        if (box != null) {
                                          final point = box.globalToLocal(
                                            details.globalPosition,
                                          );
                                          unawaited(
                                            _focusAt(
                                              camera,
                                              Offset(
                                                (point.dx / box.size.width)
                                                    .clamp(0, 1),
                                                (point.dy / box.size.height)
                                                    .clamp(0, 1),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) => Stack(
                                        children: [
                                          Positioned(
                                            left: _left * constraints.maxWidth,
                                            top: _top * constraints.maxHeight,
                                            width:
                                                _width * constraints.maxWidth,
                                            height:
                                                _height * constraints.maxHeight,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.greenAccent,
                                                  width: 3,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Column(
                      children: [
                        const Text(
                          'ROI persegi panjang (crop lokal); ketuk teks untuk fokus.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _qualityLabel,
                          key: const ValueKey('livescan-quality'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        _roiControl(
                          'Kiri',
                          _left,
                          (v) => setState(() => _left = v.clamp(0, .25)),
                        ),
                        _roiControl(
                          'Atas',
                          _top,
                          (v) =>
                              setState(() => _top = v.clamp(0, _bottom - .2)),
                        ),
                        _roiControl(
                          'Kanan',
                          _right,
                          (v) =>
                              setState(() => _right = v.clamp(_left + .2, 1)),
                        ),
                        _roiControl(
                          'Bawah',
                          _bottom,
                          (v) =>
                              setState(() => _bottom = v.clamp(_top + .2, 1)),
                        ),
                        Text(
                          'Status: ${_paused ? 'dijeda' : 'capture lokal'} · ${result.observations.length} frame · ${result.duplicateFrameCount} duplikat · ${result.gaps.length} gap. Progres adalah segmen terambil, bukan kelengkapan dokumen.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_error != null)
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.deepOrange),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _paused ? _resume : _pause,
                                child: Text(_paused ? 'Lanjutkan' : 'Jeda'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed:
                                    result.observations.isEmpty || _reviewing
                                    ? null
                                    : () => _review(result),
                                child: const Text('Tinjau hasil'),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () async {
                            await _stopCamera();
                            if (!context.mounted) return;
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(
                                scanLocation(
                                  '/scan/camera/how-to',
                                  widget.auditId,
                                ),
                              );
                            }
                          },
                          child: const Text('Batalkan pindai'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _roiControl(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) => Row(
    children: [
      SizedBox(width: 46, child: Text(label)),
      Expanded(
        child: Slider(
          value: value.clamp(0, 1),
          min: 0,
          max: 1,
          onChanged: onChanged,
        ),
      ),
    ],
  );

  double? _meanConfidence(Iterable<double?> values) {
    final known = values.whereType<double>().toList();
    if (known.isEmpty) return null;
    return known.reduce((left, right) => left + right) / known.length;
  }

  Future<void> _focusAt(CameraController camera, Offset point) async {
    try {
      await camera.setFocusPoint(point);
    } on Object {
      if (mounted) {
        setState(
          () => _qualityLabel =
              'Fokus otomatis tidak tersedia; atur sudut/jarak dan tinjau OCR.',
        );
      }
    }
  }
}

class LiveScanMergePage extends StatefulWidget {
  const LiveScanMergePage({
    super.key,
    required this.result,
    required this.auditId,
    this.repository,
  });
  final LiveScanResult result;
  final String? auditId;
  final AuditRepository? repository;
  @override
  State<LiveScanMergePage> createState() => _LiveScanMergePageState();
}

class _LiveScanMergePageState extends State<LiveScanMergePage> {
  late final TextEditingController _text = TextEditingController(
    text: widget.result.text,
  );
  bool _busy = false;
  bool _confirmed = false;
  bool _confirmingExit = false;
  bool _allowExit = false;
  AuditSourceType? _sourceType;
  String? _sourceId;
  String? _error;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _dirty => _text.text != widget.result.text;

  Future<void> _leave() async {
    if (_busy || _confirmingExit) return;
    if (_dirty) {
      _confirmingExit = true;
      final discard = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Buang koreksi LiveScan?'),
          content: const Text(
            'Teks hasil pindai awal tetap tersedia di kamera.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Lanjut edit'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Buang koreksi'),
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
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(scanLocation('/scan/camera/how-to', widget.auditId));
    }
  }

  Future<void> _save() async {
    if (_busy || !_confirmed) return;
    final sourceType = _sourceType;
    if (sourceType == null) return;
    final auditId = widget.auditId;
    final repository = widget.repository;
    if (auditId == null || repository == null) {
      setState(
        () => _error = 'Pilih/buka audit sebelum menyimpan LiveScan. Tidak ada sumber yang disimpan.',
      );
      return;
    }
    if (_text.text.trim().isEmpty) {
      setState(() => _error = 'Tidak ada teks untuk ditinjau.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final original = _text.text.trim();
      final originalOcr = widget.result.text.trim();
      final observations = widget.result.observations
          .map(
            (o) => {
              'frame': o.frame,
              'capturedAt': o.capturedAt.toIso8601String(),
              'roi': o.roi,
              'confidence': o.confidence,
            },
          )
          .toList();
      final sourceId = _sourceId ??= (await repository.attachSource(
        auditId: auditId,
        bytes: utf8.encode(originalOcr.isEmpty ? original : originalOcr),
        type: sourceType,
        mediaType: 'text/plain',
        originalName:
            'livescan-${DateTime.now().toUtc().toIso8601String()}.txt',
        language: 'id,en',
        locator: 'LiveScan; observations=${observations.length}',
        importWarnings: widget.result.gaps.isEmpty
            ? null
            : '${widget.result.gaps.length} bagian mungkin terlewat saat LiveScan.',
      )).id;
      final hash = sha256.convert(utf8.encode(originalOcr)).toString();
      await repository.saveImportedSegments(
        sourceId: sourceId,
        reviewed: true,
        segments: [
          ImportedTextSegment(
            sequence: 0,
            text: original,
            originalText: originalOcr,
            page: 1,
            startOffset: 0,
            endOffset: originalOcr.length,
            pageTextSha256: hash,
            extractionMethod: 'live_scan_mlkit_latin',
            confidence: _meanConfidence(
              widget.result.observations.map((o) => o.confidence),
            ),
            boundingBoxJson: jsonEncode({
              'observations': observations,
              'gaps': widget.result.gaps
                  .map(
                    (g) => {
                      'afterFrame': g.afterFrame,
                      'beforeFrame': g.beforeFrame,
                    },
                  )
                  .toList(),
            }),
          ),
        ],
      );
      if (mounted) {
        context.go('/scan/review/$sourceId');
      }
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'Hasil belum tersimpan. Periksa audit lokal dan coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy && (!_dirty || _allowExit),
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && _dirty && !_allowExit) _leave();
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _busy ? null : _leave,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Kembali',
        ),
        title: const Text('Tinjau Hasil LiveScan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Periksa teks di bawah dan pilih jenis dokumen sebelum menyimpan.',
          ),
          if (widget.result.gaps.isNotEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.warning_amber),
                title: Text('Kemungkinan bagian hilang'),
                subtitle: Text(
                  'Bandingkan dengan dokumen di monitor. Pindai ulang jika ada teks yang belum masuk.',
                ),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _text,
            enabled: !_busy,
            minLines: 4,
            maxLines: 8,
            onChanged: (_) => setState(() => _confirmed = false),
            decoration: const InputDecoration(
              labelText: 'Teks yang terbaca',
              border: OutlineInputBorder(),
            ),
          ),
          DropdownButtonFormField<AuditSourceType>(
            initialValue: _sourceType,
            decoration: const InputDecoration(labelText: 'Jenis sumber'),
            items: const [
              DropdownMenuItem(
                value: AuditSourceType.terms,
                child: Text('Terms'),
              ),
              DropdownMenuItem(
                value: AuditSourceType.privacyPolicy,
                child: Text('Privacy Policy'),
              ),
              DropdownMenuItem(
                value: AuditSourceType.otherDocument,
                child: Text('Dokumen lain'),
              ),
            ],
            onChanged: _busy || _sourceId != null
                ? null
                : (value) {
                    setState(() => _sourceType = value);
                  },
          ),
          if (widget.result.gaps.isNotEmpty)
            TextButton.icon(
              onPressed: _busy
                  ? null
                  : () =>
                        context.push('/scan/camera/gaps', extra: widget.result),
              icon: const Icon(Icons.find_in_page_outlined),
              label: const Text('Periksa bagian yang mungkin terlewat'),
            ),
          CheckboxListTile(
            value: _confirmed,
            onChanged: _busy
                ? null
                : (value) => setState(() => _confirmed = value ?? false),
            title: const Text(
              'Saya sudah memeriksa teks dan bagian yang mungkin terlewat',
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy || !_confirmed || _sourceType == null
                ? null
                : _save,
            child: Text(_busy ? 'Menyimpan…' : 'Simpan hasil tinjauan'),
          ),
          TextButton(
            onPressed: _busy ? null : _leave,
            child: const Text('Kembali ke kamera'),
          ),
        ],
      ),
    ),
  );

  double? _meanConfidence(Iterable<double?> values) {
    final known = values.whereType<double>().toList();
    if (known.isEmpty) return null;
    return known.reduce((left, right) => left + right) / known.length;
  }
}

class LiveScanGapReviewPage extends StatelessWidget {
  const LiveScanGapReviewPage({super.key, required this.result});
  final LiveScanResult result;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const KonsenaBackButton(fallback: '/scan'),
      title: const Text('Periksa bagian hilang'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'KONSENA tidak mengisi teks yang tidak tertangkap. Gap di bawah menunjukkan transisi frame yang overlap-nya tidak dapat dipastikan; gunakan sebagai petunjuk review, bukan bukti pasti bagian hilang.',
        ),
        if (result.gaps.isEmpty)
          const ListTile(
            title: Text('Tidak ada gap terdeteksi otomatis'),
            subtitle: Text(
              'Ini bukan klaim bahwa seluruh dokumen sudah tercakup.',
            ),
          ),
        for (final gap in result.gaps)
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber),
              title: Text('Frame ${gap.afterFrame} → ${gap.beforeFrame}'),
              subtitle: const Text(
                'Possible missing text — scroll sedikit ke atas dan capture ulang jika perlu.',
              ),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => context.pop(),
          child: const Text('Kembali ke teks hasil'),
        ),
      ],
    ),
  );
}
