import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/audit/analysis_engine.dart';
import '../../domain/audit/audit_entities.dart';
import '../../features/consent_ui/domain/screenshot_review.dart';
import '../local/app_database.dart';
import 'local_source_file_store.dart';
import 'local_data_cipher.dart';

class AuditRepository {
  AuditRepository({
    required AppDatabase database,
    required this._files,
    required LocalDataCipher cipher,
    Uuid? uuid,
    DateTime Function()? clock,
    Future<void> Function()? beforeDelete,
  }) : _db = database,
       // ignore: prefer_initializing_formals
       _cipher = cipher,
       _uuid = uuid ?? const Uuid(),
       _clock = clock ?? DateTime.now,
       // ignore: prefer_initializing_formals
       _beforeDelete = beforeDelete;

  final AppDatabase _db;
  final LocalSourceFileStore _files;
  final LocalDataCipher _cipher;
  final Uuid _uuid;
  final DateTime Function() _clock;
  final Future<void> Function()? _beforeDelete;
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );
  Future<void> _tail = Future<void>.value();
  int _revision = 0;
  int get revision => _revision;

  Stream<void> get changes => _changes.stream;

  void _notifyChanged() {
    _revision++;
    if (!_changes.isClosed) _changes.add(null);
  }

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<AuditSession> create({
    String name = '',
    AuditFocus focus = AuditFocus.combined,
  }) => _serial(() async {
    final now = _clock().toUtc();
    final cleanName = name.trim().isEmpty ? 'Audit baru' : name.trim();
    if (cleanName.length > 60) {
      throw ArgumentError.value(name, 'name', 'maximum 60 characters');
    }
    final row = AuditSessionsCompanion.insert(
      id: _uuid.v4(),
      name: await _cipher.encryptText(cleanName),
      focus: focus.name,
      status: AuditStatus.draft.name,
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.auditSessions).insert(row);
    _notifyChanged();
    return _session(
      await (_db.select(
        _db.auditSessions,
      )..where((t) => t.id.equals(row.id.value))).getSingle(),
    );
  });

  Future<AuditSession?> get(String id) => _serial(() async {
    final row = await (_db.select(
      _db.auditSessions,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : await _session(row);
  });

  Future<List<AuditSession>> listSessions() => _serial(() async {
    final rows =
        await (_db.select(_db.auditSessions)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
            .get();
    return Future.wait(rows.map(_session));
  });

  Future<AuditSession> update({
    required String id,
    String? name,
    AuditFocus? focus,
  }) => _serial(() async {
    if (name != null && name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name');
    }
    if (name != null && name.trim().length > 60) {
      throw ArgumentError.value(name, 'name');
    }
    final count =
        await (_db.update(
          _db.auditSessions,
        )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).write(
          AuditSessionsCompanion(
            name: name == null
                ? const Value.absent()
                : Value(await _cipher.encryptText(name.trim())),
            focus: focus == null ? const Value.absent() : Value(focus.name),
            updatedAt: Value(_clock().toUtc()),
          ),
        );
    if (count != 1) throw AuditNotFoundException();
    _notifyChanged();
    return _session(
      await (_db.select(
        _db.auditSessions,
      )..where((t) => t.id.equals(id))).getSingle(),
    );
  });

  Future<void> setSourceReviewStatus(
    String sourceId,
    SourceReviewStatus status,
  ) => _serial(() async {
    final source =
        await (_db.select(_db.documentSources)..where(
              (t) =>
                  t.id.equals(sourceId) &
                  t.lifecycle.equals(SourceLifecycle.active.name),
            ))
            .getSingleOrNull();
    if (source == null) throw SourceNotFoundException();
    final now = _clock().toUtc();
    final count =
        await (_db.update(_db.documentSources)..where(
              (t) =>
                  t.id.equals(sourceId) &
                  t.lifecycle.equals(SourceLifecycle.active.name),
            ))
            .write(
              DocumentSourcesCompanion(
                reviewStatus: Value(status.name),
                updatedAt: Value(now),
              ),
            );
    if (count != 1) throw SourceNotFoundException();
    await (_db.update(_db.auditSessions)
          ..where((t) => t.id.equals(source.auditId)))
        .write(AuditSessionsCompanion(updatedAt: Value(now)));
    _notifyChanged();
  });

  Future<DocumentSource> attachSource({
    required String auditId,
    required List<int> bytes,
    required AuditSourceType type,
    required String mediaType,
    String? originalName,
    String? language,
    int? page,
    int? frame,
    String? locator,
    String? sourceUrl,
    String? documentVersion,
    String? importWarnings,
  }) => _serial(() async {
    final audit =
        await (_db.select(_db.auditSessions)
              ..where((t) => t.id.equals(auditId) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (audit == null) throw AuditNotFoundException();
    if (bytes.isEmpty) throw ArgumentError.value(bytes.length, 'bytes');
    if (bytes.length > 25 * 1024 * 1024) {
      throw ArgumentError.value(
        bytes.length,
        'bytes',
        'maximum source size is 25 MB',
      );
    }
    if (originalName != null && originalName.length > 255) {
      throw ArgumentError.value(originalName, 'originalName');
    }
    final id = _uuid.v4();
    final file = await _files.write(bytes, id: id);
    final now = _clock().toUtc();
    try {
      await _db.transaction(() async {
        await _db
            .into(_db.documentSources)
            .insert(
              DocumentSourcesCompanion.insert(
                id: id,
                auditId: auditId,
                type: type.name,
                reviewStatus: SourceReviewStatus.pending.name,
                lifecycle: SourceLifecycle.active.name,
                sha256: file.sha256,
                localPath: file.relativePath,
                mediaType: mediaType,
                byteLength: file.byteLength,
                originalName: Value(
                  originalName == null
                      ? null
                      : await _cipher.encryptText(originalName),
                ),
                language: Value(language),
                provenancePage: Value(page),
                provenanceFrame: Value(frame),
                provenanceLocator: Value(
                  locator == null ? null : await _cipher.encryptText(locator),
                ),
                sourceUrl: Value(
                  sourceUrl == null
                      ? null
                      : await _cipher.encryptText(sourceUrl),
                ),
                documentVersion: Value(
                  documentVersion == null
                      ? null
                      : await _cipher.encryptText(documentVersion),
                ),
                importWarnings: Value(
                  importWarnings == null
                      ? null
                      : await _cipher.encryptText(importWarnings),
                ),
                createdAt: now,
                updatedAt: now,
              ),
            );
        if (type == AuditSourceType.consentUi) {
          await _db
              .into(_db.consentUiSources)
              .insert(
                ConsentUiSourcesCompanion.insert(
                  id: _uuid.v4(),
                  sourceId: id,
                  imageSha256: file.sha256,
                  reviewStatus: SourceReviewStatus.pending.name,
                  frame: Value(frame),
                ),
              );
        }
        await (_db.update(_db.auditSessions)
              ..where((t) => t.id.equals(auditId)))
            .write(AuditSessionsCompanion(updatedAt: Value(now)));
      });
    } on Object {
      await _files.delete(file.relativePath);
      rethrow;
    }
    _notifyChanged();
    final row = await (_db.select(
      _db.documentSources,
    )..where((t) => t.id.equals(id))).getSingle();
    return _source(row);
  });

  Future<List<DocumentSource>> sources(String auditId) => _serial(() async {
    final rows =
        await (_db.select(_db.documentSources)
              ..where(
                (t) =>
                    t.auditId.equals(auditId) &
                    t.lifecycle.equals(SourceLifecycle.active.name),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    return Future.wait(rows.map(_source));
  });

  Future<DocumentSource> source(String sourceId) => _serial(() async {
    final row =
        await (_db.select(_db.documentSources)..where(
              (t) =>
                  t.id.equals(sourceId) &
                  t.lifecycle.equals(SourceLifecycle.active.name),
            ))
            .getSingleOrNull();
    if (row == null) throw SourceNotFoundException();
    return _source(row);
  });

  Future<void> updateImportWarnings({
    required String sourceId,
    required List<String> warnings,
  }) => _serial(() async {
    final source =
        await (_db.select(_db.documentSources)..where(
              (t) =>
                  t.id.equals(sourceId) &
                  t.lifecycle.equals(SourceLifecycle.active.name),
            ))
            .getSingleOrNull();
    if (source == null) throw SourceNotFoundException();
    final now = _clock().toUtc();
    await (_db.update(
      _db.documentSources,
    )..where((t) => t.id.equals(sourceId))).write(
      DocumentSourcesCompanion(
        importWarnings: Value(
          warnings.isEmpty
              ? null
              : await _cipher.encryptText(warnings.join('\n')),
        ),
        updatedAt: Value(now),
      ),
    );
    _notifyChanged();
  });

  Future<List<DocumentSegment>> documentSegments(String sourceId) =>
      _serial(() async {
        final rows =
            await (_db.select(_db.documentSegments)
                  ..where((t) => t.sourceId.equals(sourceId))
                  ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
                .get();
        return Future.wait(rows.map(_documentSegment));
      });

  /// Replaces a source's extracted paragraphs atomically. Repeating the same
  /// import result is idempotent: callers retain the original source ID/hash.
  Future<void> saveImportedSegments({
    required String sourceId,
    required List<ImportedTextSegment> segments,
    required bool reviewed,
  }) => _serial(() async {
    final source =
        await (_db.select(_db.documentSources)..where(
              (t) =>
                  t.id.equals(sourceId) &
                  t.lifecycle.equals(SourceLifecycle.active.name),
            ))
            .getSingleOrNull();
    if (source == null) throw SourceNotFoundException();
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      if (segment.sequence != i ||
          segment.page < 1 ||
          segment.startOffset < 0 ||
          segment.endOffset < segment.startOffset ||
          segment.text.trim().isEmpty ||
          !RegExp(r'^[0-9a-f]{64}$').hasMatch(segment.pageTextSha256)) {
        throw ArgumentError('Invalid imported segment provenance');
      }
    }
    final alreadySaved =
        await (_db.select(_db.documentSegments)
              ..where((t) => t.sourceId.equals(sourceId))
              ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
            .get();
    if (alreadySaved.isNotEmpty) {
      final sameImport = alreadySaved.length == segments.length;
      if (sameImport) {
        for (var index = 0; index < segments.length; index++) {
          final stored = alreadySaved[index];
          final incoming = segments[index];
          if (stored.sequence != incoming.sequence ||
              stored.page != incoming.page ||
              stored.startOffset != incoming.startOffset ||
              stored.endOffset != incoming.endOffset ||
              stored.pageTextSha256 != incoming.pageTextSha256 ||
              stored.extractionMethod != incoming.extractionMethod ||
              await _cipher.decryptText(
                    stored.originalContent ?? stored.content,
                  ) !=
                  incoming.originalText) {
            throw StateError('Source already contains a different extraction');
          }
        }
        return;
      }
      throw StateError('Source already contains a different extraction');
    }
    final now = _clock().toUtc();
    await _db.transaction(() async {
      await (_db.delete(
        _db.documentSegments,
      )..where((t) => t.sourceId.equals(sourceId))).go();
      for (final segment in segments) {
        await _db
            .into(_db.documentSegments)
            .insert(
              DocumentSegmentsCompanion.insert(
                id: _uuid.v4(),
                sourceId: sourceId,
                sequence: segment.sequence,
                content: await _cipher.encryptText(segment.text),
                originalContent: Value(
                  await _cipher.encryptText(segment.originalText),
                ),
                startOffset: Value(segment.startOffset),
                endOffset: Value(segment.endOffset),
                pageTextSha256: Value(segment.pageTextSha256),
                extractionMethod: Value(segment.extractionMethod),
                confidence: Value(segment.confidence),
                boundingBoxJson: Value(
                  segment.boundingBoxJson == null
                      ? null
                      : await _cipher.encryptText(segment.boundingBoxJson!),
                ),
                page: Value(segment.page),
                editedAt: const Value.absent(),
                reviewedAt: Value(reviewed ? now : null),
              ),
            );
      }
      await (_db.update(
        _db.documentSources,
      )..where((t) => t.id.equals(sourceId))).write(
        DocumentSourcesCompanion(
          reviewStatus: Value(
            reviewed
                ? SourceReviewStatus.reviewed.name
                : SourceReviewStatus.needsReview.name,
          ),
          reviewedAt: Value(reviewed ? now : null),
          updatedAt: Value(now),
        ),
      );
      await (_db.update(_db.auditSessions)
            ..where((t) => t.id.equals(source.auditId)))
          .write(AuditSessionsCompanion(updatedAt: Value(now)));
    });
    _notifyChanged();
  });

  Future<void> updateImportedSegment({
    required String sourceId,
    required String segmentId,
    required String text,
    required bool reviewed,
  }) => _serial(() async {
    if (text.trim().isEmpty || text.length > 100000) {
      throw ArgumentError.value(text, 'text');
    }
    final row =
        await (_db.select(_db.documentSegments)..where(
              (t) => t.id.equals(segmentId) & t.sourceId.equals(sourceId),
            ))
            .getSingleOrNull();
    if (row == null) throw SourceNotFoundException();
    final now = _clock().toUtc();
    final changed = text != await _cipher.decryptText(row.content);
    await (_db.update(_db.documentSegments)
          ..where((t) => t.id.equals(segmentId) & t.sourceId.equals(sourceId)))
        .write(
          DocumentSegmentsCompanion(
            content: Value(await _cipher.encryptText(text)),
            editedAt: Value(changed ? now : row.editedAt),
            reviewedAt: Value(reviewed ? now : null),
          ),
        );
    await (_db.update(
      _db.documentSources,
    )..where((t) => t.id.equals(sourceId))).write(
      DocumentSourcesCompanion(
        reviewStatus: Value(
          reviewed
              ? SourceReviewStatus.reviewed.name
              : SourceReviewStatus.needsReview.name,
        ),
        reviewedAt: Value(reviewed ? now : null),
        updatedAt: Value(now),
      ),
    );
    final source = await (_db.select(
      _db.documentSources,
    )..where((t) => t.id.equals(sourceId))).getSingle();
    await (_db.update(_db.auditSessions)
          ..where((t) => t.id.equals(source.auditId)))
        .write(AuditSessionsCompanion(updatedAt: Value(now)));
    _notifyChanged();
  });

  Future<List<int>> readSource(String sourceId) => _serial(() async {
    final row =
        await (_db.select(_db.documentSources)..where(
              (t) =>
                  t.id.equals(sourceId) &
                  t.lifecycle.equals(SourceLifecycle.active.name),
            ))
            .getSingleOrNull();
    if (row == null) throw SourceNotFoundException();
    return _files.read(row.localPath, expectedSha256: row.sha256);
  });

  Future<void> addSegment({
    required String sourceId,
    required int sequence,
    required String text,
    int? page,
    int? frame,
  }) => _serial(() async {
    if (sequence < 0 || text.trim().isEmpty) {
      throw ArgumentError('Invalid segment');
    }
    final source =
        await (_db.select(_db.documentSources)..where(
              (t) =>
                  t.id.equals(sourceId) &
                  t.lifecycle.equals(SourceLifecycle.active.name),
            ))
            .getSingleOrNull();
    if (source == null) throw SourceNotFoundException();
    await _db
        .into(_db.documentSegments)
        .insert(
          DocumentSegmentsCompanion.insert(
            id: _uuid.v4(),
            sourceId: sourceId,
            sequence: sequence,
            content: await _cipher.encryptText(text),
            page: Value(page),
            frame: Value(frame),
          ),
        );
    _notifyChanged();
  });

  Future<void> addEvidence({
    required String auditId,
    required String sourceId,
    required String sourceSha256,
    required String location,
    String? segmentId,
    String? quote,
  }) => _serial(() async {
    final source =
        await (_db.select(_db.documentSources)..where(
              (t) =>
                  t.id.equals(sourceId) &
                  t.auditId.equals(auditId) &
                  t.lifecycle.equals(SourceLifecycle.active.name),
            ))
            .getSingleOrNull();
    if (source == null) throw SourceNotFoundException();
    if (source.sha256 != sourceSha256) throw SourceFileIntegrityException();
    await _files.read(source.localPath, expectedSha256: source.sha256);
    if (segmentId != null) {
      final segment =
          await (_db.select(_db.documentSegments)..where(
                (t) => t.id.equals(segmentId) & t.sourceId.equals(sourceId),
              ))
              .getSingleOrNull();
      if (segment == null) throw ArgumentError.value(segmentId, 'segmentId');
      if (quote != null &&
          !((await _cipher.decryptText(segment.content)).contains(quote))) {
        throw ArgumentError(
          'Quote must match the current source segment exactly',
        );
      }
    } else if (quote != null) {
      throw ArgumentError('A quote requires a source segment');
    }
    await _db
        .into(_db.evidenceReferences)
        .insert(
          EvidenceReferencesCompanion.insert(
            id: _uuid.v4(),
            auditId: auditId,
            sourceId: sourceId,
            sourceSha256: sourceSha256,
            location: await _cipher.encryptText(location),
            segmentId: Value(segmentId),
            quote: Value(
              quote == null ? null : await _cipher.encryptText(quote),
            ),
          ),
        );
    await (_db.update(_db.auditSessions)..where((t) => t.id.equals(auditId)))
        .write(AuditSessionsCompanion(updatedAt: Value(_clock().toUtc())));
    _notifyChanged();
  });

  Future<List<EvidenceReference>> evidence(String auditId) => _serial(() async {
    await _requireActiveAudit(auditId);
    final rows = await (_db.select(
      _db.evidenceReferences,
    )..where((t) => t.auditId.equals(auditId))).get();
    final result = <EvidenceReference>[];
    final available = <String, bool>{};
    for (final row in rows) {
      final source =
          await (_db.select(_db.documentSources)..where(
                (t) =>
                    t.id.equals(row.sourceId) &
                    t.auditId.equals(auditId) &
                    t.lifecycle.equals(SourceLifecycle.active.name),
              ))
              .getSingleOrNull();
      if (source == null || source.sha256 != row.sourceSha256) continue;
      if (!available.containsKey(source.id)) {
        try {
          await _files.read(source.localPath, expectedSha256: source.sha256);
          available[source.id] = true;
        } on Object {
          available[source.id] = false;
        }
      }
      if (available[source.id] != true) continue;
      final quote = row.quote == null
          ? null
          : await _cipher.decryptText(row.quote!);
      if (row.segmentId != null) {
        final segment =
            await (_db.select(_db.documentSegments)..where(
                  (t) =>
                      t.id.equals(row.segmentId!) &
                      t.sourceId.equals(row.sourceId),
                ))
                .getSingleOrNull();
        if (segment == null ||
            (quote != null &&
                !(await _cipher.decryptText(segment.content))
                    .contains(quote))) {
          continue;
        }
      }
      // Legacy Phase 02 locations were plaintext. New locations are encrypted.
      final location = row.location.startsWith('enc:')
          ? await _cipher.decryptText(row.location)
          : row.location;
      result.add(
        EvidenceReference(
          id: row.id,
          auditId: auditId,
          sourceId: row.sourceId,
          sourceSha256: row.sourceSha256,
          location: location,
          segmentId: row.segmentId,
          quote: quote,
        ),
      );
    }
    return result;
  });

  /// Append-only encrypted revisions, associated to a source in this audit.
  /// No database migration is needed: schema v3 user_actions is the edit journal.
  Future<void> saveScreenshotReview({
    required String auditId,
    required String sourceId,
    required ScreenshotReview review,
  }) => _serial(() async {
    review.validate();
    await _requireActiveAudit(auditId);
    final row =
        await (_db.select(_db.documentSources)..where(
              (t) =>
                  t.id.equals(sourceId) &
                  t.auditId.equals(auditId) &
                  t.type.equals(AuditSourceType.consentUi.name) &
                  t.lifecycle.equals(SourceLifecycle.active.name),
            ))
            .getSingleOrNull();
    if (row == null) throw SourceNotFoundException();
    final now = _clock().toUtc();
    await _db.transaction(() async {
      await _db
          .into(_db.userActions)
          .insert(
            UserActionsCompanion.insert(
              id: _uuid.v4(),
              auditId: auditId,
              sourceId: Value(sourceId),
              actionType: 'screenshot_revision_v1',
              details: Value(await _cipher.encryptText(review.encode())),
              createdAt: now,
            ),
          );
      await (_db.delete(
        _db.evidenceReferences,
      )..where((t) => t.sourceId.equals(sourceId) & t.segmentId.isNull())).go();
      for (final annotation in review.annotations) {
        await _db
            .into(_db.evidenceReferences)
            .insert(
              EvidenceReferencesCompanion.insert(
                id: _uuid.v4(),
                auditId: auditId,
                sourceId: sourceId,
                sourceSha256: row.sha256,
                location: await _cipher.encryptText(
                  jsonEncode({
                    'kind': 'manual_annotation',
                    'at': now.toIso8601String(),
                    'coordinateSpace': 'exif_baked_original_normalized',
                    ...annotation.toJson(),
                  }),
                ),
              ),
            );
      }
      await (_db.update(
        _db.documentSources,
      )..where((t) => t.id.equals(sourceId))).write(
        DocumentSourcesCompanion(
          originalName: Value(await _cipher.encryptText(review.title)),
          documentVersion: Value(await _cipher.encryptText(review.version)),
          reviewStatus: Value(SourceReviewStatus.reviewed.name),
          reviewedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await (_db.update(_db.auditSessions)..where((t) => t.id.equals(auditId)))
          .write(AuditSessionsCompanion(updatedAt: Value(now)));
    });
    _notifyChanged();
  });

  Future<List<({ScreenshotReview review, DateTime at})>> screenshotHistory(
    String auditId,
    String sourceId,
  ) => _serial(() async {
    final source =
        await (_db.select(_db.documentSources)..where(
              (t) =>
                  t.id.equals(sourceId) &
                  t.auditId.equals(auditId) &
                  t.lifecycle.equals(SourceLifecycle.active.name),
            ))
            .getSingleOrNull();
    if (source == null) throw SourceNotFoundException();
    final rows =
        await (_db.select(_db.userActions)
              ..where(
                (t) =>
                    t.sourceId.equals(sourceId) &
                    t.auditId.equals(auditId) &
                    t.actionType.equals('screenshot_revision_v1'),
              )
              ..orderBy([
                (t) => OrderingTerm.desc(t.createdAt),
                (t) => OrderingTerm.desc(t.rowId),
              ]))
            .get();
    return Future.wait(
      rows.map(
        (r) async => (
          review: ScreenshotReview.decode(
            await _cipher.decryptText(r.details!),
          ),
          at: r.createdAt.toUtc(),
        ),
      ),
    );
  });

  Future<void> addPermissionSnapshot(AppPermissionSnapshot snapshot) =>
      _serial(() async {
        _requireUuid(snapshot.id, 'snapshot.id');
        await _requireActiveAudit(snapshot.auditId);
        await _db
            .into(_db.appPermissionSnapshots)
            .insert(
              AppPermissionSnapshotsCompanion.insert(
                id: snapshot.id,
                auditId: snapshot.auditId,
                packageName: await _cipher.encryptText(snapshot.packageName),
                permissionName: await _cipher.encryptText(
                  snapshot.permissionName,
                ),
                permissionLabel: Value(
                  snapshot.permissionLabel == null
                      ? null
                      : await _cipher.encryptText(snapshot.permissionLabel!),
                ),
                grantStatus: await _cipher.encryptText(snapshot.grantStatus),
                granted: Value(snapshot.granted),
                flagsAvailable: Value(snapshot.flagsAvailable),
                androidSdk: Value(snapshot.androidSdk),
                protectionLevel: Value(
                  snapshot.protectionLevel == null
                      ? null
                      : await _cipher.encryptText(snapshot.protectionLevel!),
                ),
                capturedAt: snapshot.capturedAt.toUtc(),
              ),
            );
      });

  Future<ApplicationSnapshotRecord> saveApplicationSnapshot({
    required String auditId,
    required String packageName,
    required String appLabel,
    required String? versionName,
    required String snapshotStatus,
    required String visibilityScope,
    required int androidSdk,
    required DateTime capturedAt,
    required List<AppPermissionSnapshot> permissions,
  }) => _serial(() async {
    _requireUuid(auditId, 'auditId');
    await _requireActiveAudit(auditId);
    final snapshotId = _uuid.v4();
    final capturedAtUtc = capturedAt.toUtc();
    await _db.transaction(() async {
      await _db
          .into(_db.applicationSnapshots)
          .insert(
            ApplicationSnapshotsCompanion.insert(
              id: snapshotId,
              auditId: auditId,
              packageName: await _cipher.encryptText(packageName),
              appLabel: await _cipher.encryptText(appLabel),
              versionName: Value(
                versionName == null
                    ? null
                    : await _cipher.encryptText(versionName),
              ),
              snapshotStatus: snapshotStatus,
              visibilityScope: visibilityScope,
              androidSdk: androidSdk,
              capturedAt: capturedAtUtc,
            ),
          );
      for (final permission in permissions) {
        await _db
            .into(_db.appPermissionSnapshots)
            .insert(
              AppPermissionSnapshotsCompanion.insert(
                id: _uuid.v4(),
                auditId: auditId,
                appSnapshotId: Value(snapshotId),
                packageName: await _cipher.encryptText(packageName),
                permissionName: await _cipher.encryptText(
                  permission.permissionName,
                ),
                permissionLabel: Value(
                  permission.permissionLabel == null
                      ? null
                      : await _cipher.encryptText(permission.permissionLabel!),
                ),
                grantStatus: await _cipher.encryptText(permission.grantStatus),
                granted: Value(permission.granted),
                flagsAvailable: Value(permission.flagsAvailable),
                androidSdk: Value(androidSdk),
                protectionLevel: Value(
                  permission.protectionLevel == null
                      ? null
                      : await _cipher.encryptText(permission.protectionLevel!),
                ),
                capturedAt: capturedAtUtc,
              ),
            );
      }
    });
    await (_db.update(_db.auditSessions)..where((t) => t.id.equals(auditId)))
        .write(AuditSessionsCompanion(updatedAt: Value(_clock().toUtc())));
    _notifyChanged();
    return ApplicationSnapshotRecord(
      id: snapshotId,
      auditId: auditId,
      packageName: packageName,
      appLabel: appLabel,
      versionName: versionName,
      permissions: permissions,
      snapshotStatus: snapshotStatus,
      visibilityScope: visibilityScope,
      androidSdk: androidSdk,
      capturedAt: capturedAtUtc,
    );
  });

  Future<List<ApplicationSnapshotRecord>> applicationSnapshots(
    String auditId,
  ) => _serial(() async {
    final rows =
        await (_db.select(_db.applicationSnapshots)
              ..where((t) => t.auditId.equals(auditId))
              ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]))
            .get();
    return Future.wait(
      rows.map((row) async {
        final permissionRows =
            await (_db.select(_db.appPermissionSnapshots)
                  ..where((t) => t.appSnapshotId.equals(row.id))
                  ..orderBy([(t) => OrderingTerm.asc(t.permissionName)]))
                .get();
        return ApplicationSnapshotRecord(
          id: row.id,
          auditId: row.auditId,
          packageName: await _cipher.decryptText(row.packageName),
          appLabel: await _cipher.decryptText(row.appLabel),
          versionName: row.versionName == null
              ? null
              : await _cipher.decryptText(row.versionName!),
          permissions: await Future.wait(
            permissionRows.map(
              (permission) async => AppPermissionSnapshot(
                id: permission.id,
                auditId: permission.auditId,
                packageName: await _cipher.decryptText(permission.packageName),
                permissionName: await _cipher.decryptText(
                  permission.permissionName,
                ),
                grantStatus: await _cipher.decryptText(permission.grantStatus),
                androidSdk: permission.androidSdk,
                protectionLevel: permission.protectionLevel == null
                    ? null
                    : await _cipher.decryptText(permission.protectionLevel!),
                permissionLabel: permission.permissionLabel == null
                    ? null
                    : await _cipher.decryptText(permission.permissionLabel!),
                granted: permission.granted,
                flagsAvailable: permission.flagsAvailable,
                capturedAt: permission.capturedAt.toUtc(),
              ),
            ),
          ),
          snapshotStatus: row.snapshotStatus,
          visibilityScope: row.visibilityScope,
          androidSdk: row.androidSdk,
          capturedAt: row.capturedAt.toUtc(),
        );
      }),
    );
  });

  Future<List<AppPermissionSnapshot>> permissionSnapshots(String auditId) =>
      _serial(() async {
        final rows =
            await (_db.select(_db.appPermissionSnapshots)
                  ..where((t) => t.auditId.equals(auditId))
                  ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]))
                .get();
        return Future.wait(
          rows.map(
            (row) async => AppPermissionSnapshot(
              id: row.id,
              auditId: row.auditId,
              packageName: await _cipher.decryptText(row.packageName),
              permissionName: await _cipher.decryptText(row.permissionName),
              grantStatus: await _cipher.decryptText(row.grantStatus),
              androidSdk: row.androidSdk,
              protectionLevel: row.protectionLevel == null
                  ? null
                  : await _cipher.decryptText(row.protectionLevel!),
              capturedAt: row.capturedAt.toUtc(),
            ),
          ),
        );
      });

  Future<void> addConsentUiSource(ConsentUiSource source) => _serial(() async {
    _requireUuid(source.id, 'source.id');
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(source.imageSha256)) {
      throw ArgumentError.value(source.imageSha256, 'imageSha256');
    }
    final storedSource =
        await (_db.select(_db.documentSources)..where(
              (t) =>
                  t.id.equals(source.sourceId) &
                  t.sha256.equals(source.imageSha256),
            ))
            .getSingleOrNull();
    if (storedSource == null ||
        storedSource.type != AuditSourceType.consentUi.name ||
        storedSource.lifecycle != SourceLifecycle.active.name) {
      throw SourceNotFoundException();
    }
    await _db
        .into(_db.consentUiSources)
        .insert(
          ConsentUiSourcesCompanion.insert(
            id: source.id,
            sourceId: source.sourceId,
            imageSha256: source.imageSha256,
            reviewStatus: source.reviewStatus.name,
            frame: Value(source.frame),
          ),
        );
  });

  Future<void> recordUserAction(UserAction action) => _serial(() async {
    _requireUuid(action.id, 'action.id');
    await _requireActiveAudit(action.auditId);
    if (action.sourceId != null) {
      final source =
          await (_db.select(_db.documentSources)..where(
                (t) =>
                    t.id.equals(action.sourceId!) &
                    t.auditId.equals(action.auditId) &
                    t.lifecycle.equals(SourceLifecycle.active.name),
              ))
              .getSingleOrNull();
      if (source == null) throw SourceNotFoundException();
    }
    await _db
        .into(_db.userActions)
        .insert(
          UserActionsCompanion.insert(
            id: action.id,
            auditId: action.auditId,
            sourceId: Value(action.sourceId),
            actionType: action.actionType,
            details: Value(
              action.details == null
                  ? null
                  : await _cipher.encryptText(action.details!),
            ),
            createdAt: action.createdAt.toUtc(),
          ),
        );
  });

  Future<void> addReport(ReportRecord report) => _serial(() async {
    _requireUuid(report.id, 'report.id');
    await _requireActiveAudit(report.auditId);
    await _db
        .into(_db.reportRecords)
        .insert(
          ReportRecordsCompanion.insert(
            id: report.id,
            auditId: report.auditId,
            status: report.status,
            localPath: Value(report.localPath),
            contentSha256: Value(report.contentSha256),
            createdAt: report.createdAt.toUtc(),
          ),
        );
  });

  Future<PrivacyPreferences> privacyPreferences() => _serial(() async {
    final existing = await (_db.select(
      _db.privacyPreferenceRows,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (existing != null) return _preferences(existing);
    final defaults = PrivacyPreferences.safeDefault();
    final now = _clock().toUtc();
    await _db
        .into(_db.privacyPreferenceRows)
        .insert(
          PrivacyPreferenceRowsCompanion.insert(
            id: const Value(1),
            cloudOptIn: const Value(false),
            analyticsOptIn: const Value(false),
            updatedAt: now,
          ),
        );
    return PrivacyPreferences(
      id: defaults.id,
      cloudOptIn: false,
      analyticsOptIn: false,
      updatedAt: now,
    );
  });

  Future<PrivacyPreferences> updatePrivacyPreferences({
    required bool cloudOptIn,
    required bool analyticsOptIn,
  }) => _serial(() async {
    final now = _clock().toUtc();
    await _db
        .into(_db.privacyPreferenceRows)
        .insertOnConflictUpdate(
          PrivacyPreferenceRowsCompanion.insert(
            id: const Value(1),
            cloudOptIn: Value(cloudOptIn),
            analyticsOptIn: Value(analyticsOptIn),
            updatedAt: now,
          ),
        );
    return PrivacyPreferences(
      id: 1,
      cloudOptIn: cloudOptIn,
      analyticsOptIn: analyticsOptIn,
      updatedAt: now,
    );
  });

  /// Synchronizes existing SharedPreferences journey keys into the durable
  /// privacy row. This preserves user choices and safe false defaults.
  Future<void> migratePrivacyPreferences({
    required bool cloudOptIn,
    required bool analyticsOptIn,
  }) => _serial(() async {
    await _db
        .into(_db.privacyPreferenceRows)
        .insertOnConflictUpdate(
          PrivacyPreferenceRowsCompanion.insert(
            id: const Value(1),
            cloudOptIn: Value(cloudOptIn),
            analyticsOptIn: Value(analyticsOptIn),
            updatedAt: _clock().toUtc(),
          ),
        );
  });

  Future<void> detachSource(String sourceId) => _serial(() async {
    await _beforeDelete?.call();
    final row = await (_db.select(
      _db.documentSources,
    )..where((t) => t.id.equals(sourceId))).getSingleOrNull();
    if (row == null) return;
    await _db.transaction(() async {
      await _db
          .into(_db.pendingFileDeletes)
          .insertOnConflictUpdate(
            PendingFileDeletesCompanion.insert(
              id: row.id,
              relativePath: row.localPath,
              createdAt: _clock().toUtc(),
            ),
          );
      // Source-specific revision content must not survive as a detached action.
      await (_db.delete(
        _db.userActions,
      )..where((t) => t.sourceId.equals(sourceId))).go();
      await (_db.update(
        _db.documentSources,
      )..where((t) => t.id.equals(sourceId))).write(
        DocumentSourcesCompanion(
          lifecycle: Value(SourceLifecycle.pendingDelete.name),
        ),
      );
      await (_db.update(_db.auditSessions)
            ..where((t) => t.id.equals(row.auditId)))
          .write(AuditSessionsCompanion(updatedAt: Value(_clock().toUtc())));
    });
    _notifyChanged();
    await _cleanupPendingFileDeletes();
  });

  Future<void> deleteAudit(String auditId) => _serial(() async {
    await _beforeDelete?.call();
    await _db.transaction(() async {
      final audit =
          await (_db.select(_db.auditSessions)
                ..where((t) => t.id.equals(auditId) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (audit == null) return;
      final sources = await (_db.select(
        _db.documentSources,
      )..where((t) => t.auditId.equals(auditId))).get();
      for (final source in sources) {
        await _db
            .into(_db.pendingFileDeletes)
            .insertOnConflictUpdate(
              PendingFileDeletesCompanion.insert(
                id: source.id,
                relativePath: source.localPath,
                createdAt: _clock().toUtc(),
              ),
            );
      }
      await (_db.update(
        _db.auditSessions,
      )..where((t) => t.id.equals(auditId))).write(
        AuditSessionsCompanion(
          status: Value(AuditStatus.deleted.name),
          name: Value(await _cipher.encryptText('Audit dihapus')),
          focus: Value(AuditFocus.combined.name),
          deletedAt: Value(_clock().toUtc()),
          updatedAt: Value(_clock().toUtc()),
        ),
      );
      // Keep the root tombstone for deleted-ID detection. Remove logical children
      // in the same transaction; source rows cascade their segments and UI refs.
      await (_db.delete(
        _db.appPermissionSnapshots,
      )..where((t) => t.auditId.equals(auditId))).go();
      await (_db.delete(
        _db.applicationSnapshots,
      )..where((t) => t.auditId.equals(auditId))).go();
      await (_db.delete(
        _db.evidenceReferences,
      )..where((t) => t.auditId.equals(auditId))).go();
      await (_db.delete(
        _db.userActions,
      )..where((t) => t.auditId.equals(auditId))).go();
      await (_db.delete(
        _db.analysisRuns,
      )..where((t) => t.auditId.equals(auditId))).go();
      await (_db.delete(
        _db.reportRecords,
      )..where((t) => t.auditId.equals(auditId))).go();
      await (_db.delete(
        _db.documentSources,
      )..where((t) => t.auditId.equals(auditId))).go();
    });
    _notifyChanged();
    await _cleanupPendingFileDeletes();
  });

  Future<int> sessionCount() => _serial(
    () async =>
        await (_db.selectOnly(_db.auditSessions)
              ..addColumns([_db.auditSessions.id.count()])
              ..where(_db.auditSessions.deletedAt.isNull()))
            .map((row) => row.read(_db.auditSessions.id.count())!)
            .getSingle(),
  );

  Future<int> sourceCount(String auditId) => _serial(
    () async =>
        await (_db.select(_db.documentSources)..where(
              (t) =>
                  t.auditId.equals(auditId) &
                  t.lifecycle.equals(SourceLifecycle.active.name),
            ))
            .get()
            .then((rows) => rows.length),
  );

  Future<void> addUnavailableAnalysis({
    required String auditId,
    required List<String> sourceIds,
  }) => _serial(() async {
    await _requireActiveAudit(auditId);
    for (final sourceId in sourceIds) {
      final source =
          await (_db.select(_db.documentSources)..where(
                (t) =>
                    t.id.equals(sourceId) &
                    t.auditId.equals(auditId) &
                    t.lifecycle.equals(SourceLifecycle.active.name),
              ))
              .getSingleOrNull();
      if (source == null) throw SourceNotFoundException();
    }
    final run = const UnavailableAnalysisEngine().unavailableRun(
      id: _uuid.v4(),
      auditId: auditId,
      sourceIds: sourceIds,
      now: _clock().toUtc(),
    );
    await _db
        .into(_db.analysisRuns)
        .insert(
          AnalysisRunsCompanion.insert(
            id: run.id,
            auditId: run.auditId,
            status: run.status.name,
            engine: run.engine,
            reason: run.reason,
            sourceIdsJson: jsonEncode(run.sourceIds),
            createdAt: run.createdAt,
          ),
        );
  });

  Future<void> recoverFileLifecycle() => _serial(() async {
    await _cleanupPendingFileDeletes();
    await _files.removeTemporaryFiles();
    final rows = await (_db.select(
      _db.documentSources,
    )..where((t) => t.lifecycle.equals(SourceLifecycle.active.name))).get();
    final referenced = rows.map((r) => r.localPath).toSet();
    for (final path in await _files.listStoredRelativePaths()) {
      if (!referenced.contains(path)) await _files.delete(path);
    }
  });

  Future<void> _cleanupPendingFileDeletes() async {
    final pending = await _db.select(_db.pendingFileDeletes).get();
    for (final item in pending) {
      await _files.delete(item.relativePath);
      await (_db.delete(
        _db.pendingFileDeletes,
      )..where((t) => t.id.equals(item.id))).go();
      await (_db.delete(
        _db.documentSources,
      )..where((t) => t.id.equals(item.id))).go();
    }
  }

  Future<AuditSession> _session(AuditSessionRow row) async => AuditSession(
    id: row.id,
    name: await _cipher.decryptText(row.name),
    focus: AuditFocus.values.byName(row.focus),
    status: AuditStatus.values.byName(row.status),
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
    deletedAt: row.deletedAt?.toUtc(),
  );

  Future<DocumentSource> _source(DocumentSourceRow row) async => DocumentSource(
    id: row.id,
    auditId: row.auditId,
    type: AuditSourceType.values.byName(row.type),
    reviewStatus: SourceReviewStatus.values.byName(row.reviewStatus),
    lifecycle: SourceLifecycle.values.byName(row.lifecycle),
    sha256: row.sha256,
    localPath: row.localPath,
    mediaType: row.mediaType,
    byteLength: row.byteLength,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
    originalName: row.originalName == null
        ? null
        : await _cipher.decryptText(row.originalName!),
    language: row.language,
    provenancePage: row.provenancePage,
    provenanceFrame: row.provenanceFrame,
    provenanceLocator: row.provenanceLocator == null
        ? null
        : await _cipher.decryptText(row.provenanceLocator!),
    sourceUrl: row.sourceUrl == null
        ? null
        : await _cipher.decryptText(row.sourceUrl!),
    documentVersion: row.documentVersion == null
        ? null
        : await _cipher.decryptText(row.documentVersion!),
    importWarnings: row.importWarnings == null
        ? null
        : await _cipher.decryptText(row.importWarnings!),
    reviewedAt: row.reviewedAt?.toUtc(),
  );

  Future<DocumentSegment> _documentSegment(DocumentSegmentRow row) async =>
      DocumentSegment(
        id: row.id,
        sourceId: row.sourceId,
        sequence: row.sequence,
        text: await _cipher.decryptText(row.content),
        page: row.page,
        frame: row.frame,
        originalText: row.originalContent == null
            ? null
            : await _cipher.decryptText(row.originalContent!),
        startOffset: row.startOffset,
        endOffset: row.endOffset,
        pageTextSha256: row.pageTextSha256,
        extractionMethod: row.extractionMethod,
        confidence: row.confidence,
        boundingBoxJson: row.boundingBoxJson == null
            ? null
            : await _cipher.decryptText(row.boundingBoxJson!),
        editedAt: row.editedAt?.toUtc(),
        reviewedAt: row.reviewedAt?.toUtc(),
      );

  PrivacyPreferences _preferences(PrivacyPreferenceRow row) =>
      PrivacyPreferences(
        id: row.id,
        cloudOptIn: row.cloudOptIn,
        analyticsOptIn: row.analyticsOptIn,
        updatedAt: row.updatedAt.toUtc(),
      );

  void _requireUuid(String value, String field) {
    if (!RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    ).hasMatch(value)) {
      throw ArgumentError.value(value, field, 'must be a UUID');
    }
  }

  Future<void> _requireActiveAudit(String auditId) async {
    final audit =
        await (_db.select(_db.auditSessions)
              ..where((t) => t.id.equals(auditId) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (audit == null) throw AuditNotFoundException();
  }
}

class AuditNotFoundException implements Exception {}

class SourceNotFoundException implements Exception {}
