import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../model_qa/data/onnx_tensor_harness.dart';
import '../../model_qa/presentation/nli_qa_panel.dart';
import '../../report/data/audit_pdf_export.dart';
import '../../shared/widgets/konsena_back_button.dart';
import '../domain/audit_snapshot.dart';
import 'interface_review_content.dart';

/// Detail pages for source facts, evidence and an opt-in debug experiment.
class AuditDetailPage extends StatefulWidget {
  const AuditDetailPage({
    required this.auditId,
    required this.mode,
    required this.repository,
    this.itemId,
    super.key,
  });
  final String auditId, mode;
  final String? itemId;
  final AuditRepository repository;
  @override
  State<AuditDetailPage> createState() => _AuditDetailPageState();
}

class _AuditDetailPageState extends State<AuditDetailPage> {
  StreamSubscription<void>? _changes;
  @override
  void initState() {
    super.initState();
    _changes = widget.repository.changes.listen((_) {
      if (mounted) _reload();
    });
  }

  @override
  void dispose() {
    _changes?.cancel();
    super.dispose();
  }

  late Future<AuditSnapshot> _snapshot = AuditSnapshot.load(
    widget.repository,
    widget.auditId,
  );
  bool _busy = false;
  String? _error;
  void _reload() => setState(
    () => _snapshot = AuditSnapshot.load(widget.repository, widget.auditId),
  );
  String get _parent => widget.mode == 'history'
      ? '/history'
      : '/audit/${widget.auditId}/sources';
  Widget _link(String label, String location) => ListTile(
    title: Text(label),
    trailing: const Icon(Icons.chevron_right),
    onTap: () async {
      await context.push(location);
      if (mounted) _reload();
    },
  );
  Future<void> _pdf({bool share = false}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Fresh SQLite snapshot for every export: never share a stale preview PDF.
      final snapshot = await AuditSnapshot.load(
        widget.repository,
        widget.auditId,
      );
      final bytes = await AuditPdfExport.build(snapshot);
      final current = await widget.repository.get(widget.auditId);
      if (current == null ||
          current.updatedAt != snapshot.audit.updatedAt ||
          widget.repository.revision != snapshot.dataRevision) {
        throw StateError('Audit changed while building export');
      }
      if (share) {
        await AuditPdfExport.share(bytes);
      } else if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('PDF lokal')),
              body: PdfViewer.data(bytes, sourceName: 'Laporan audit lokal'),
            ),
          ),
        );
      }
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'PDF atau berbagi tidak tersedia. Periksa sumber lalu coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: KonsenaBackButton(fallback: _parent),
      title: Text(switch (widget.mode) {
        'report' || 'export' => 'Laporan Audit',
        'evidence' => 'Bukti Audit',
        'actions' || 'action' => 'Tindakan Privasi',
        'compare' => 'Bandingkan Sumber',
        'dark-pattern' => 'Review Antarmuka',
        'history' => 'Detail Riwayat',
        'source-match' => 'Kesesuaian Sumber',
        'risk' => 'Faktor Privasi',
        _ => 'Fakta & Status Analisis',
      }),
      actions: [
        IconButton(
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
          tooltip: 'Muat ulang sumber',
        ),
      ],
    ),
    body: FutureBuilder<AuditSnapshot>(
      future: _snapshot,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data;
        if (data == null) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Audit atau sumber tidak tersedia. Data mungkin telah dihapus atau berubah.',
              ),
              _link('Kembali ke riwayat', '/history'),
              TextButton(onPressed: _reload, child: const Text('Coba lagi')),
            ],
          );
        }
        final id = widget.auditId;
        if (widget.mode == 'dark-pattern') {
          return InterfaceReviewContent(
            key: ValueKey((id, data.dataRevision)),
            snapshot: data,
            repository: widget.repository,
          );
        }
        final evidence = data.evidence
            .where((e) => e.id == widget.itemId)
            .toList();
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              data.audit.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (widget.mode != 'results')
              Text('Audit $id · ${data.audit.updatedAt.toLocal()}'),
            if (widget.mode == 'history')
              _link('Lanjutkan audit', '/audit/$id/sources'),
            const Text(
              'Ringkasan audit memuat fakta sumber dan anotasi manual.',
            ),
            if (_error != null) Text(_error!),
            if (widget.mode == 'evidence') ...[
              if (evidence.isEmpty)
                const Text(
                  'Bukti tidak tersedia, telah dihapus, atau kutipannya tidak lagi cocok dengan sumber aktif.',
                ),
              for (final e in evidence) ...[
                SelectableText(e.quote ?? 'Bukti visual / tanpa kutipan teks'),
                SelectableText(
                  'Source ${e.sourceId}\nHash ${e.sourceSha256}\n${e.location}',
                ),
                if (data.sources.any(
                  (s) =>
                      s.id == e.sourceId && s.type == AuditSourceType.consentUi,
                ))
                  FutureBuilder<List<int>>(
                    future: widget.repository.readSource(e.sourceId),
                    builder: (context, image) => image.data == null
                        ? const Text('Memuat sumber gambar…')
                        : Image.memory(
                            Uint8List.fromList(image.data!),
                            height: 350,
                            fit: BoxFit.contain,
                          ),
                  ),
                _link(
                  'Buka sumber',
                  data.sources.any(
                        (s) =>
                            s.id == e.sourceId &&
                            s.type == AuditSourceType.consentUi,
                      )
                      ? '/consent-ui/review?auditId=$id&sourceId=${e.sourceId}'
                      : '/scan/review/${e.sourceId}',
                ),
              ],
            ] else if (widget.mode == 'report' || widget.mode == 'export') ...[
              const Text(
                'Preview dibuat dari SQLite saat ini. PDF selalu diregenerasi saat dibuka/dibagikan. Laporan memuat teks audit; raw file dan gambar tidak dilampirkan.',
              ),
              FilledButton(
                onPressed: _busy ? null : _pdf,
                child: const Text('Buat dan buka PDF'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => _pdf(share: true),
                child: const Text('Bagikan PDF melalui Android'),
              ),
              OutlinedButton(
                onPressed: () async {
                  try {
                    await AuditPdfExport.clearCache();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cache ekspor aplikasi dibersihkan.'),
                        ),
                      );
                    }
                  } on Object {
                    if (mounted) {
                      setState(() => _error = 'Cache belum dapat dibersihkan.');
                    }
                  }
                },
                child: const Text('Bersihkan cache ekspor'),
              ),
              const Text(
                'Salinan yang sudah dibagikan tidak dapat dihapus dari aplikasi penerima oleh KONSENA.',
              ),
              for (final line in data.reportLines) SelectableText(line),
            ] else ...[
              if (data.sources.isEmpty && data.apps.isEmpty)
                const Text(
                  'Bukti belum mencukupi. Tambahkan sumber terlebih dahulu.',
                ),
              if (widget.mode == 'results' && OnnxTensorHarness.enabled)
                NliQaPanel(
                  key: ValueKey((id, data.dataRevision)),
                  snapshot: data,
                  repository: widget.repository,
                )
              else
                const Text('Analisis otomatis belum tersedia di build ini.'),
              if (widget.mode == 'results') ...[
                const SizedBox(height: 16),
                Text(
                  'Sumber audit',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              if (widget.mode == 'compare' || widget.mode == 'source-match')
                const Text(
                  'Association audit dipilih pengguna; kesamaan tanggal/versi bukan bukti dokumen berlaku untuk package ini. Metadata kosong ditampilkan unknown.',
                ),
              for (final app in data.apps) ...[
                _link(
                  '${app.appLabel} · ${app.packageName} · versi ${app.versionName ?? "unknown"}',
                  '/audit/apps/${app.packageName}?auditId=$id',
                ),
                Text(
                  'Snapshot historis ${app.capturedAt.toLocal()} · ${app.snapshotStatus}',
                ),
                for (final p in app.permissions)
                  Text('${p.permissionName}: ${p.grantStatus}'),
              ],
              for (final source in data.sources) ...[
                _link(
                  '${source.type.name} · ${source.originalName ?? source.id}',
                  source.type == AuditSourceType.consentUi
                      ? '/consent-ui/review?auditId=$id&sourceId=${source.id}'
                      : '/scan/review/${source.id}',
                ),
                Text(
                  'Versi: ${source.documentVersion ?? "unknown"} · ${source.createdAt.toLocal()} · ${source.reviewStatus.name}',
                ),
                if (data.unavailableSources.contains(source.id))
                  const Text(
                    'MISSING / CORRUPT — sumber tidak dapat dibuka; bukan bukti aktif.',
                  ),
                if (source.type == AuditSourceType.consentUi) ...[
                  for (final a in data.reviews[source.id]?.annotations ?? [])
                    Text(
                      'ANOTASI MANUAL: ${a.kind} · ${a.label} · ROI asli ${a.rect.toJson()}',
                    ),
                ],
                for (final segment
                    in data.segments[source.id] ?? <DocumentSegment>[])
                  ExpansionTile(
                    title: Text(
                      'Klausul ${segment.sequence + 1} · halaman ${segment.page ?? "unknown"} / frame ${segment.frame ?? "unknown"}',
                    ),
                    children: [
                      SelectableText(segment.text),
                      Text(
                        'Metode ${segment.extractionMethod ?? "unknown"}; ROI ${segment.boundingBoxJson ?? "unknown"}',
                      ),
                      if (segment.editedAt != null)
                        SelectableText(
                          'Koreksi pengguna ${segment.editedAt}: asli ${segment.originalText}',
                        ),
                      TextButton(
                        onPressed: () async {
                          try {
                            await widget.repository.addEvidence(
                              auditId: id,
                              sourceId: source.id,
                              sourceSha256: source.sha256,
                              segmentId: segment.id,
                              quote: segment.text,
                              location:
                                  'page=${segment.page};frame=${segment.frame};roi=${segment.boundingBoxJson};at=${DateTime.now().toUtc().toIso8601String()}',
                            );
                            _reload();
                          } on Object {
                            if (mounted) {
                              setState(
                                () => _error = 'Kutipan tidak cocok atau sumber berubah. Muat ulang.',
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Simpan kutipan persis sebagai evidence',
                        ),
                      ),
                    ],
                  ),
              ],
              for (final e in data.evidence)
                _link(
                  'Bukti ${e.quote == null ? "visual" : "kutipan"} ${e.id}',
                  '/audit/$id/evidence/${e.id}',
                ),
              _link('Kelola / koreksi / hapus sumber', '/audit/$id/sources'),
              _link(
                'Tindakan netral: periksa izin & baca sumber',
                '/audit/$id/actions',
              ),
              _link('Bandingkan versi sumber', '/audit/$id/compare'),
              _link('Review antarmuka', '/audit/$id/dark-pattern'),
              _link('Preview / ekspor laporan', '/audit/$id/report'),
            ],
          ],
        );
      },
    ),
  );
}
