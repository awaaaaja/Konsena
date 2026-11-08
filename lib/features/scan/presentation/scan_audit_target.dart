import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../../theme/konsena_spacing.dart';
import '../../shared/widgets/review_section.dart';

String scanLocation(String path, String? auditId) => auditId == null
    ? path
    : Uri(path: path, queryParameters: {'auditId': auditId}).toString();

class ScanAuditTarget extends StatefulWidget {
  const ScanAuditTarget({
    required this.auditId,
    required this.repository,
    required this.path,
    required this.focus,
    required this.builder,
    super.key,
  });

  final String? auditId;
  final AuditRepository? repository;
  final String path;
  final AuditFocus focus;
  final Widget Function(AuditSession audit) builder;

  @override
  State<ScanAuditTarget> createState() => _ScanAuditTargetState();
}

class _ScanAuditTargetState extends State<ScanAuditTarget> {
  late Future<AuditSession?> _target = _loadTarget();
  late Future<List<AuditSession>>? _audits = widget.repository?.listSessions();
  final _name = TextEditingController();
  bool _creating = false;
  bool _showForm = false;
  String? _error;

  Future<AuditSession?> _loadTarget() async {
    final id = widget.auditId;
    return id == null ? null : widget.repository?.get(id);
  }

  @override
  void didUpdateWidget(covariant ScanAuditTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.auditId != widget.auditId ||
        oldWidget.repository != widget.repository) {
      _target = _loadTarget();
      _audits = widget.repository?.listSessions();
      _showForm = false;
      _error = null;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _select(String id) => context.replace(scanLocation(widget.path, id));

  Future<void> _create() async {
    final repo = widget.repository;
    if (_creating || repo == null) return;
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final audit = await repo.create(name: _name.text, focus: widget.focus);
      if (mounted) _select(audit.id);
    } on Object {
      if (mounted) {
        setState(() => _error = 'Audit belum dapat dibuat. Coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AuditSession?>(
    future: _target,
    builder: (context, snapshot) {
      if (widget.auditId != null &&
          snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.data case final audit?) return widget.builder(audit);
      return ListView(
        padding: const EdgeInsets.all(KonsenaSpacing.lg),
        children: [
          ReviewSection(
            icon: _showForm
                ? Icons.create_new_folder_outlined
                : Icons.folder_open_outlined,
            title: _showForm ? 'Buat audit tujuan' : 'Pilih audit tujuan',
            subtitle: _showForm
                ? 'Audit ini akan menyimpan sumber yang kamu tambahkan.'
                : widget.auditId == null
                ? 'Sumber akan disimpan di audit yang kamu pilih.'
                : 'Audit ini tidak tersedia. Pilih audit lain.',
            children: [
              if (_showForm) ...[
                TextField(
                  controller: _name,
                  enabled: !_creating,
                  maxLength: 60,
                  decoration: const InputDecoration(
                    labelText: 'Nama audit (opsional)',
                  ),
                ),
                if (_error != null) Text(_error!),
                FilledButton(
                  onPressed: _creating ? null : _create,
                  child: Text(
                    _creating ? 'Membuat audit…' : 'Buat dan lanjutkan',
                  ),
                ),
                TextButton(
                  onPressed: _creating
                      ? null
                      : () => setState(() => _showForm = false),
                  child: const Text('Kembali ke daftar audit'),
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: widget.repository == null
                      ? () => context.push('/audit/new')
                      : () => setState(() => _showForm = true),
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: const Text('Buat audit baru'),
                ),
                const SizedBox(height: KonsenaSpacing.sm),
                FutureBuilder<List<AuditSession>>(
                  future: _audits,
                  builder: (context, audits) {
                    if (audits.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    if (audits.hasError) {
                      return TextButton.icon(
                        onPressed: () => setState(() {
                          _audits = widget.repository?.listSessions();
                        }),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Muat ulang daftar audit'),
                      );
                    }
                    final items = audits.data ?? const <AuditSession>[];
                    if (items.isEmpty) {
                      return const Text('Belum ada audit tersimpan.');
                    }
                    return Column(
                      children: [
                        for (final audit in items)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.folder_outlined),
                            title: Text(audit.name),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _select(audit.id),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      );
    },
  );
}

class ScanTargetLabel extends StatelessWidget {
  const ScanTargetLabel({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.folder_outlined),
    title: const Text('Audit tujuan'),
    subtitle: Text(name),
  );
}
