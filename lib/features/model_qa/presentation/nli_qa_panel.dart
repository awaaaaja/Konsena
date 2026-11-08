import 'package:flutter/material.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/analysis_engine.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../../theme/konsena_spacing.dart';
import '../../audit/domain/audit_snapshot.dart';
import '../../shared/widgets/review_section.dart';
import '../data/onnx_tensor_harness.dart';
import '../data/source_bound_nli_engine.dart';
import 'qa_result_summary.dart';

class NliQaPanel extends StatefulWidget {
  const NliQaPanel({
    required this.snapshot,
    required this.repository,
    super.key,
  });

  final AuditSnapshot snapshot;
  final AuditRepository repository;

  @override
  State<NliQaPanel> createState() => _NliQaPanelState();
}

class _NliQaPanelState extends State<NliQaPanel> {
  bool _optedIn = false;
  bool _busy = false;
  (String, String)? _clause, _permission;
  AnalysisResult? _result;

  Future<void> _compare() async {
    final (sourceId, segmentId) = _clause!;
    final (snapshotId, permissionName) = _permission!;
    setState(() {
      _busy = true;
      _result = null;
    });
    final result = await SourceBoundNliEngine(widget.repository).compare(
      optedIn: _optedIn,
      auditId: widget.snapshot.audit.id,
      sourceId: sourceId,
      segmentId: segmentId,
      snapshotId: snapshotId,
      permissionName: permissionName,
      sourceRevision: widget.snapshot.dataRevision,
    );
    if (mounted) {
      setState(() {
        _busy = false;
        _result = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!OnnxTensorHarness.enabled) return const SizedBox.shrink();
    final data = widget.snapshot;
    final localizations = MaterialLocalizations.of(context);
    final clauses = [
      for (final source in data.sources)
        if (SourceBoundNliEngine.isReviewedDocument(source))
          for (final segment
              in data.segments[source.id] ?? const <DocumentSegment>[])
            DropdownMenuItem(
              value: (source.id, segment.id),
              child: Text(
                '${source.originalName ?? 'Dokumen'} · Bagian ${segment.sequence + 1}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
    ];
    final permissions = [
      for (final app in data.apps)
        for (final name in app.permissions.map((p) => p.permissionName).toSet())
          DropdownMenuItem(
            value: (app.id, name),
            child: Text(
              '${app.appLabel} · ${_permissionLabel(app, name)} · ${localizations.formatShortDate(app.capturedAt.toLocal())}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
    ];

    return ReviewSection(
      icon: Icons.rule_rounded,
      title: 'Cocokkan izin dan kebijakan',
      subtitle: 'Uji coba di perangkat',
      children: [
        if (clauses.isEmpty || permissions.isEmpty)
          const Text(
            'Tambahkan catatan izin aplikasi dan satu dokumen yang sudah ditinjau.',
          )
        else ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Aktifkan bantuan AI'),
            subtitle: const Text('Berlaku untuk sesi ini.'),
            value: _optedIn,
            onChanged: _busy
                ? null
                : (value) => setState(() {
                    _optedIn = value;
                    _result = null;
                  }),
          ),
          DropdownButtonFormField<(String, String)>(
            initialValue: _clause,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.description_outlined),
              labelText: 'Bagian kebijakan',
            ),
            items: clauses,
            onChanged: _busy
                ? null
                : (value) => setState(() {
                    _clause = value;
                    _result = null;
                  }),
          ),
          const SizedBox(height: KonsenaSpacing.sm),
          DropdownButtonFormField<(String, String)>(
            initialValue: _permission,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock_outline),
              labelText: 'Izin aplikasi',
            ),
            items: permissions,
            onChanged: _busy
                ? null
                : (value) => setState(() {
                    _permission = value;
                    _result = null;
                  }),
          ),
          const SizedBox(height: KonsenaSpacing.md),
          FilledButton.icon(
            onPressed:
                _optedIn && !_busy && _clause != null && _permission != null
                ? _compare
                : null,
            icon: const Icon(Icons.compare_arrows_rounded),
            label: Text(_busy ? 'Membandingkan…' : 'Bandingkan'),
          ),
          if (_busy) const LinearProgressIndicator(),
        ],
        if (_result case final AnalysisResult result) ...[
          const SizedBox(height: KonsenaSpacing.md),
          if (result is NliSourceResult &&
              result.sourceRevision == widget.repository.revision)
            _NliResult(result: result)
          else
            Text(switch (result.reason) {
              'reviewed_clause_and_permission_required' =>
                'Pilih dokumen yang sudah ditinjau dan izin yang tercatat.',
              'source_changed_during_inference' ||
              'QA_ONLY' => 'Sumber berubah. Pilih ulang sebelum membandingkan.',
              _ => 'Pemeriksaan belum bisa dijalankan. Cek sumber dan paket model QA.',
            }),
        ],
      ],
    );
  }
}

String _permissionLabel(ApplicationSnapshotRecord app, String name) {
  final label = app.permissions
      .where((permission) => permission.permissionName == name)
      .firstOrNull
      ?.permissionLabel
      ?.trim();
  if (label != null && label.isNotEmpty) return label;
  return switch (name) {
    'android.permission.CAMERA' => 'Kamera',
    'android.permission.RECORD_AUDIO' => 'Mikrofon',
    'android.permission.ACCESS_COARSE_LOCATION' ||
    'android.permission.ACCESS_FINE_LOCATION' => 'Lokasi',
    'android.permission.READ_CONTACTS' => 'Kontak',
    'android.permission.POST_NOTIFICATIONS' => 'Notifikasi',
    _ => name.split('.').last.replaceAll('_', ' ').toLowerCase(),
  };
}

class _NliResult extends StatelessWidget {
  const _NliResult({required this.result});

  final NliSourceResult result;

  @override
  Widget build(BuildContext context) {
    final (icon, title, meaning, nextCheck) = switch (result.label) {
      'entailment' => (
        Icons.rule_rounded,
        'Kutipan sejalan dengan izin',
        'Bagian kebijakan yang dipilih mendukung pernyataan izin yang tercatat.',
        'Buka kutipan dan cek apakah kebijakan menjelaskan tujuan izin.',
      ),
      'contradiction' => (
        Icons.flag_outlined,
        'Ada perbedaan yang perlu dicek',
        'Bagian kebijakan yang dipilih berlawanan dengan pernyataan izin yang tercatat.',
        'Baca bagian lengkap dan periksa izin pada pengaturan Android.',
      ),
      _ => (
        Icons.help_outline,
        'Hubungannya belum jelas',
        'Bagian kebijakan ini belum cukup untuk menilai izin yang dipilih.',
        'Pilih bagian yang menyebut izin atau tujuan penggunaannya.',
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${result.snapshot.appLabel} · Izin ${_permissionLabel(result.snapshot, result.permissionName)}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: KonsenaSpacing.xs),
        QaResultSummary(
          icon: icon,
          title: title,
          meaning: meaning,
          nextCheck: nextCheck,
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: const Icon(Icons.format_quote_outlined),
          title: const Text('Lihat kutipan sumber'),
          childrenPadding: const EdgeInsets.only(bottom: KonsenaSpacing.sm),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [SelectableText(result.segment.text)],
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: const Icon(Icons.code_rounded),
          title: const Text('Detail teknis QA'),
          children: [
            SelectableText(
              'Label NLI: ${result.label}\n'
              'Load + inferensi: ${result.elapsedMs.toStringAsFixed(0)} ms\n'
              '${[for (final (i, label) in SourceBoundNliEngine.labels.indexed) "$label: ${(result.probabilities[i] * 100).toStringAsFixed(1)}%"].join("\n")}\n'
              'Pernyataan: ${result.hypothesis}\n'
              'Audit ${result.source.auditId}\n'
              'Sumber ${result.source.id} · SHA-256 ${result.source.sha256}\n'
              'Segmen ${result.segment.id} · halaman ${result.segment.page ?? "unknown"} · frame ${result.segment.frame ?? "unknown"}\n'
              'Snapshot ${result.snapshot.id} · ${result.snapshot.packageName} · ${result.snapshot.capturedAt.toIso8601String()}\n'
              'Model ${result.modelVersion}\n'
              '${result.createdAt.toIso8601String()}',
            ),
          ],
        ),
      ],
    );
  }
}
