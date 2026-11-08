import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';

class AuditWorkspaceState {
  const AuditWorkspaceState({
    this.loading = true,
    this.busy = false,
    this.session,
    this.sources = const [],
    this.snapshots = const [],
    this.error,
  });

  final bool loading;
  final bool busy;
  final AuditSession? session;
  final List<DocumentSource> sources;
  final List<ApplicationSnapshotRecord> snapshots;
  final String? error;

  AuditWorkspaceState copyWith({
    bool? loading,
    bool? busy,
    AuditSession? session,
    List<DocumentSource>? sources,
    List<ApplicationSnapshotRecord>? snapshots,
    String? error,
    bool clearError = false,
    bool clearSession = false,
  }) => AuditWorkspaceState(
    loading: loading ?? this.loading,
    busy: busy ?? this.busy,
    session: clearSession ? null : session ?? this.session,
    sources: sources ?? this.sources,
    snapshots: snapshots ?? this.snapshots,
    error: clearError ? null : error ?? this.error,
  );
}

class AuditWorkspaceCubit extends Cubit<AuditWorkspaceState> {
  AuditWorkspaceCubit(this._repository, this.auditId)
    : super(const AuditWorkspaceState()) {
    _changes = _repository.changes.listen((_) => load());
  }
  StreamSubscription<void>? _changes;
  @override
  Future<void> close() async {
    await _changes?.cancel();
    await super.close();
  }

  final AuditRepository _repository;
  final String auditId;

  Future<void> load() async {
    try {
      final session = await _repository.get(auditId);
      if (isClosed) return;
      if (session == null) {
        emit(
          state.copyWith(
            loading: false,
            clearSession: true,
            sources: [],
            snapshots: [],
            error: 'Sesi audit tidak ditemukan.',
          ),
        );
        return;
      }
      final sources = await _repository.sources(auditId);
      final snapshots = await _repository.applicationSnapshots(auditId);
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          session: session,
          sources: sources,
          snapshots: snapshots,
          clearError: true,
        ),
      );
    } on Object {
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          error: 'Workspace lokal tidak dapat dibuka.',
        ),
      );
    }
  }

  Future<void> refresh() => load();

  Future<void> rename(String name) async {
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final updated = await _repository.update(id: auditId, name: name);
      emit(state.copyWith(session: updated, busy: false));
    } on Object {
      emit(
        state.copyWith(busy: false, error: 'Nama audit tidak dapat disimpan.'),
      );
    }
  }

  Future<void> setReviewed(String sourceId) async {
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await _repository.setSourceReviewStatus(
        sourceId,
        SourceReviewStatus.reviewed,
      );
      await load();
    } on Object {
      emit(
        state.copyWith(
          busy: false,
          error: 'Status review tidak dapat disimpan.',
        ),
      );
    }
    if (!isClosed) emit(state.copyWith(busy: false));
  }

  Future<void> attach({
    required List<int> bytes,
    required AuditSourceType type,
    required String mediaType,
    String? originalName,
    int? page,
    int? frame,
  }) async {
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await _repository.attachSource(
        auditId: auditId,
        bytes: bytes,
        type: type,
        mediaType: mediaType,
        originalName: originalName,
        page: page,
        frame: frame,
      );
      await load();
    } on Object {
      emit(
        state.copyWith(
          busy: false,
          error: 'Sumber tidak dapat disimpan secara lokal.',
        ),
      );
    }
    if (!isClosed) emit(state.copyWith(busy: false));
  }

  Future<void> detach(String sourceId) async {
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await _repository.detachSource(sourceId);
      await load();
    } on Object {
      emit(state.copyWith(busy: false, error: 'Sumber tidak dapat dilepas.'));
    }
    if (!isClosed) emit(state.copyWith(busy: false));
  }

  Future<bool> deleteAudit() async {
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await _repository.deleteAudit(auditId);
      emit(
        state.copyWith(
          busy: false,
          clearSession: true,
          sources: const [],
          clearError: true,
        ),
      );
      return true;
    } on Object {
      emit(
        state.copyWith(busy: false, error: 'Audit belum terhapus. Coba lagi.'),
      );
      return false;
    }
  }
}
