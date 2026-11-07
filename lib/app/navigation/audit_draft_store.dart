/// Temporary, in-memory draft seam used by the Phase 01B navigation shell.
///
/// Phase 02 replaces this with durable local storage. No draft content is
/// uploaded, and the store never fabricates audit findings.
class AuditDraft {
  const AuditDraft({
    required this.id,
    required this.name,
    required this.focus,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String focus;
  final DateTime createdAt;
}

class AuditDraftStore {
  final Map<String, AuditDraft> _drafts = {};
  int _nextId = 1;

  List<AuditDraft> get drafts => List.unmodifiable(
    _drafts.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  AuditDraft? get latest => drafts.isEmpty ? null : drafts.first;

  bool contains(String id) => _drafts.containsKey(id);

  AuditDraft create({String name = '', String focus = 'Gabungan'}) {
    final id = 'draft_${_nextId++}';
    final draft = AuditDraft(
      id: id,
      name: name.trim().isEmpty ? 'Audit baru' : name.trim(),
      focus: focus,
      createdAt: DateTime.now(),
    );
    _drafts[id] = draft;
    return draft;
  }
}
