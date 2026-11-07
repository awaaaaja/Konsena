import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/audit_draft_store.dart';
import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../../theme/konsena_spacing.dart';
import '../../shared/widgets/konsena_state_panel.dart';

/// S19 — displays only sessions returned by the local repository/store.
class HistoryPage extends StatefulWidget {
  const HistoryPage({required this.drafts, this.repository, super.key});
  final AuditDraftStore drafts;
  final AuditRepository? repository;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<AuditSession>>? _sessions;
  StreamSubscription<void>? _changesSubscription;

  @override
  void initState() {
    super.initState();
    _reload();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _changesSubscription?.cancel();
      _reload();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _changesSubscription?.cancel();
    super.dispose();
  }

  void _reload() {
    final repository = widget.repository;
    if (repository != null) _sessions = repository.listSessions();
  }

  void _subscribe() {
    _changesSubscription = widget.repository?.changes.listen((_) {
      if (mounted) setState(_reload);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localRepository = widget.repository;
    if (localRepository != null) {
      return FutureBuilder<List<AuditSession>>(
        future: _sessions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Riwayat Audit')),
              body: const Center(
                child: Text('Riwayat lokal tidak dapat dimuat.'),
              ),
            );
          }
          return _buildHistory(
            context,
            snapshot.data ?? const <AuditSession>[],
          );
        },
      );
    }
    final items = widget.drafts.drafts;
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Audit')),
      body: items.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(KonsenaSpacing.lg),
              children: [
                const KonsenaStatePanel(
                  kind: KonsenaStateKind.empty,
                  title: 'Belum ada audit tersimpan',
                  message: 'Draft yang dibuat saat ini hanya bertahan selama sesi aplikasi. Penyimpanan riwayat permanen masuk Phase 02.',
                ),
                const SizedBox(height: KonsenaSpacing.md),
                FilledButton.icon(
                  onPressed: () => context.go('/audit/new'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Mulai audit'),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(KonsenaSpacing.md),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final draft = items[index];
                return Card(
                  child: ListTile(
                    title: Text(draft.name),
                    subtitle: Text('${draft.focus} · Draft sementara'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/history/${draft.id}'),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHistory(
    BuildContext context,
    List<AuditSession> items,
  ) => Scaffold(
    appBar: AppBar(title: const Text('Riwayat Audit')),
    body: items.isEmpty
        ? ListView(
            padding: const EdgeInsets.all(KonsenaSpacing.lg),
            children: [
              const KonsenaStatePanel(
                kind: KonsenaStateKind.empty,
                title: 'Belum ada audit tersimpan',
                message:
                    'Audit yang dibuat di perangkat ini akan muncul di sini.',
              ),
              const SizedBox(height: KonsenaSpacing.md),
              FilledButton.icon(
                onPressed: () => context.go('/audit/new'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Mulai audit'),
              ),
            ],
          )
        : ListView.builder(
            padding: const EdgeInsets.all(KonsenaSpacing.md),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final session = items[index];
              return Card(
                child: ListTile(
                  title: Text(session.name),
                  subtitle: Text(
                    '${_focusLabel(session.focus)} · Draft lokal · ${_date(session.updatedAt)}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/audit/${session.id}/sources'),
                ),
              );
            },
          ),
  );

  String _focusLabel(AuditFocus focus) => switch (focus) {
    AuditFocus.permissions => 'Izin aplikasi',
    AuditFocus.documents => 'Dokumen',
    AuditFocus.visual => 'Visual',
    AuditFocus.combined => 'Gabungan',
  };

  String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
