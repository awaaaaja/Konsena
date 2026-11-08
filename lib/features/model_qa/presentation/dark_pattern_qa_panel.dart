import 'package:flutter/material.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/analysis_engine.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../../theme/konsena_spacing.dart';
import '../../audit/domain/audit_snapshot.dart';
import '../../shared/widgets/review_section.dart';
import '../data/source_bound_dark_pattern.dart';
import 'qa_result_summary.dart';

class DarkPatternQaPanel extends StatefulWidget {
  const DarkPatternQaPanel({
    required this.snapshot,
    required this.repository,
    required this.source,
    super.key,
  });

  final AuditSnapshot snapshot;
  final AuditRepository repository;
  final DocumentSource? source;

  @override
  State<DarkPatternQaPanel> createState() => _DarkPatternQaPanelState();
}

class _DarkPatternQaPanelState extends State<DarkPatternQaPanel> {
  bool _optedIn = false;
  bool _busy = false;
  AnalysisResult? _result;

  Future<void> _run() async {
    final source = widget.source;
    if (!_optedIn || source == null || _busy) return;
    setState(() {
      _busy = true;
      _result = null;
    });
    final result = await SourceBoundDarkPattern(widget.repository).run(
      optedIn: _optedIn,
      auditId: widget.snapshot.audit.id,
      sourceId: source.id,
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
    final source = widget.source;
    final needsReview = !widget.snapshot.reviews.containsKey(source?.id);
    final ready =
        source != null &&
        !needsReview &&
        SourceBoundDarkPattern.isReviewedPng(source);
    return ReviewSection(
      icon: Icons.auto_awesome_outlined,
      title: 'Pemeriksaan AI',
      subtitle: 'Uji coba di perangkat',
      children: [
        if (!ready)
          Text(
            source == null
                ? 'Tambahkan screenshot yang bisa dibuka untuk mulai.'
                : needsReview
                ? 'Simpan tinjauan screenshot untuk mulai.'
                : 'Pilih screenshot PNG untuk menjalankan uji ini.',
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
          FilledButton.icon(
            onPressed: _optedIn && !_busy ? _run : null,
            icon: const Icon(Icons.manage_search_outlined),
            label: Text(_busy ? 'Memeriksa area…' : 'Periksa area ini'),
          ),
          if (_busy) const LinearProgressIndicator(),
        ],
        if (_result case final AnalysisResult result) ...[
          const SizedBox(height: KonsenaSpacing.md),
          if (result is DarkPatternQaResult &&
              widget.repository.revision == widget.snapshot.dataRevision)
            _DarkPatternResult(result: result)
          else
            Text(switch (result.reason) {
              'reviewed_screenshot_required' =>
                'Simpan tinjauan screenshot untuk mulai.',
              'source_changed_during_inference' ||
              'QA_ONLY' => 'Screenshot berubah. Periksa area yang baru.',
              'unsupported_screenshot' =>
                'Gunakan PNG statis tanpa data orientasi EXIF.',
              _ => 'Pemeriksaan belum bisa dijalankan. Cek paket model QA.',
            }),
        ],
      ],
    );
  }
}

class _DarkPatternResult extends StatelessWidget {
  const _DarkPatternResult({required this.result});

  final DarkPatternQaResult result;

  @override
  Widget build(BuildContext context) {
    final flagged = result.label == DarkPatternQaResult.labels[1];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QaResultSummary(
          icon: flagged ? Icons.flag_outlined : Icons.visibility_outlined,
          title: flagged
              ? 'Ada tampilan yang perlu dicek'
              : 'Belum terlihat tanda yang mengarahkan pilihan',
          meaning: flagged
              ? 'AI melihat tanda bahwa tampilan bisa mengarahkan pilihan pengguna.'
              : 'AI hanya memeriksa bagian gambar yang dipilih.',
          nextCheck:
              'Lihat apakah tombol Setuju dan Tolak sama-sama mudah ditemukan.',
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: const Icon(Icons.code_rounded),
          title: const Text('Detail teknis QA'),
          children: [
            SelectableText(
              'Label: ${result.label}\n'
              'Load + inferensi: ${result.elapsedMs.toStringAsFixed(0)} ms\n'
              '${[for (final (i, label) in DarkPatternQaResult.labels.indexed) "$label: ${(result.probabilities[i] * 100).toStringAsFixed(1)}%"].join("\n")}\n'
              'Audit ${result.source.auditId}\n'
              'Sumber ${result.source.id} · SHA-256 ${result.source.sha256}\n'
              'Crop sumber asli ${result.review.crop.toJson()} · rotasi ${result.review.quarterTurns * 90}°\n'
              'Tensor SHA-256 ${result.tensorSha256}\n'
              'Logit ${result.logits}\n'
              'Model ${DarkPatternQaResult.modelVersion}\n'
              '${result.createdAt.toIso8601String()}',
            ),
          ],
        ),
      ],
    );
  }
}
