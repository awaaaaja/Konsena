import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/audit_draft_store.dart';
import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../../theme/konsena_colors.dart';
import '../../../theme/konsena_spacing.dart';
import '../../../theme/konsena_typography.dart';
import '../../shared/widgets/konsena_buttons.dart';

/// S24 — local-first draft wizard.
class NewAuditPage extends StatefulWidget {
  const NewAuditPage({
    this.drafts,
    this.repository,
    this.onAuditCreated,
    super.key,
  }) : assert(drafts != null || repository != null);

  final AuditDraftStore? drafts;
  final AuditRepository? repository;
  final VoidCallback? onAuditCreated;

  @override
  State<NewAuditPage> createState() => _NewAuditPageState();
}

class _NewAuditPageState extends State<NewAuditPage> {
  final _nameController = TextEditingController();
  String _focus = 'Gabungan';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create(void Function(String id) navigate) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = widget.repository;
      final id = repo == null
          ? widget.drafts!.create(name: _nameController.text, focus: _focus).id
          : (await repo.create(
              name: _nameController.text,
              focus: switch (_focus) {
                'Izin aplikasi' => AuditFocus.permissions,
                'Dokumen' => AuditFocus.documents,
                'Visual' => AuditFocus.visual,
                _ => AuditFocus.combined,
              },
            )).id;
      if (!mounted) return;
      widget.onAuditCreated?.call();
      navigate(id);
    } on Object {
      if (mounted) {
        setState(() => _error = 'Audit belum dapat disimpan di perangkat ini.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Audit Baru')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(KonsenaSpacing.lg),
            children: [
              Text(
                'Mulai dari sumber yang kamu punya',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: KonsenaSpacing.xs),
              Text(
                'Nama dan fokus boleh diubah nanti. Kamu tidak perlu menyiapkan semua sumber sekarang.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: KonsenaSpacing.lg),
              TextField(
                key: const ValueKey('audit-name-field'),
                controller: _nameController,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Nama audit (opsional)',
                  hintText: 'Contoh: Tinjau aplikasi belanja',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: KonsenaSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _focus,
                decoration: const InputDecoration(
                  labelText: 'Fokus audit',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Izin aplikasi',
                    child: Text('Izin aplikasi'),
                  ),
                  DropdownMenuItem(value: 'Dokumen', child: Text('Dokumen')),
                  DropdownMenuItem(value: 'Visual', child: Text('Visual')),
                  DropdownMenuItem(value: 'Gabungan', child: Text('Gabungan')),
                ],
                onChanged: (value) => setState(() => _focus = value ?? _focus),
              ),
              const SizedBox(height: KonsenaSpacing.md),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: KonsenaSpacing.sm),
              ],
              KonsenaPrimaryButton(
                label: 'Buat audit dan pilih aplikasi',
                icon: Icons.apps_rounded,
                onPressed: _busy
                    ? null
                    : () => _create((id) {
                        context.push('/audit/apps?auditId=$id');
                      }),
              ),
              const SizedBox(height: KonsenaSpacing.sm),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _create((id) {
                        context.push('/audit/$id/sources');
                      }),
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Gunakan workspace tanpa aplikasi'),
              ),
              const SizedBox(height: KonsenaSpacing.sm),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _create((id) {
                        context.push('/scan?auditId=$id');
                      }),
                icon: const Icon(Icons.document_scanner_outlined),
                label: const Text('Pindai atau impor sumber'),
              ),
              const SizedBox(height: KonsenaSpacing.md),
              const _DraftNotice(),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DraftNotice extends StatelessWidget {
  const _DraftNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(KonsenaSpacing.md),
    decoration: BoxDecoration(
      color: KonsenaColors.paleLavender,
      borderRadius: BorderRadius.circular(KonsenaRadii.card),
    ),
    child: Text(
      'Nama audit dan file sumber disimpan terenkripsi di perangkat. Belum ada hasil atau skor analisis yang dibuat.',
      style: KonsenaTypography.style(
        fontSize: 13,
        color: KonsenaColors.textSecondary,
      ),
    ),
  );
}
