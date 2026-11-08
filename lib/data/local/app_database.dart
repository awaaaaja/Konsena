import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('AuditSessionRow')
@TableIndex(name: 'audit_sessions_updated_at_idx', columns: {#updatedAt})
class AuditSessions extends Table {
  TextColumn get id => text()();
  // Ciphertext is longer than the validated user-visible title; the repository
  // enforces the 1..60 character bound before encryption.
  TextColumn get name => text()();
  TextColumn get focus => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ApplicationSnapshotRow')
@TableIndex(name: 'application_snapshots_audit_idx', columns: {#auditId})
class ApplicationSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get auditId =>
      text().references(AuditSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get packageName => text()();
  TextColumn get appLabel => text()();
  TextColumn get versionName => text().nullable()();
  TextColumn get snapshotStatus => text()();
  TextColumn get visibilityScope => text()();
  IntColumn get androidSdk => integer()();
  DateTimeColumn get capturedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AppPermissionSnapshotRow')
@TableIndex(name: 'permission_snapshots_audit_idx', columns: {#auditId})
class AppPermissionSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get auditId =>
      text().references(AuditSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get appSnapshotId => text().nullable().references(
    ApplicationSnapshots,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get packageName => text()();
  TextColumn get permissionName => text()();
  TextColumn get permissionLabel => text().nullable()();
  TextColumn get grantStatus => text()();
  BoolColumn get granted => boolean().nullable()();
  BoolColumn get flagsAvailable =>
      boolean().withDefault(const Constant(false))();
  IntColumn get androidSdk => integer().nullable()();
  TextColumn get protectionLevel => text().nullable()();
  DateTimeColumn get capturedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DocumentSourceRow')
@TableIndex(name: 'document_sources_audit_idx', columns: {#auditId})
class DocumentSources extends Table {
  TextColumn get id => text()();
  TextColumn get auditId =>
      text().references(AuditSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  TextColumn get reviewStatus => text()();
  TextColumn get lifecycle => text()();
  TextColumn get sha256 => text().withLength(min: 64, max: 64)();
  TextColumn get localPath => text()();
  TextColumn get mediaType => text()();
  IntColumn get byteLength => integer()();
  TextColumn get originalName => text().nullable()();
  TextColumn get language => text().nullable()();
  IntColumn get provenancePage => integer().nullable()();
  IntColumn get provenanceFrame => integer().nullable()();
  TextColumn get provenanceLocator => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get documentVersion => text().nullable()();
  TextColumn get importWarnings => text().nullable()();
  DateTimeColumn get reviewedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DocumentSegmentRow')
@TableIndex(name: 'document_segments_source_idx', columns: {#sourceId})
class DocumentSegments extends Table {
  TextColumn get id => text()();
  TextColumn get sourceId =>
      text().references(DocumentSources, #id, onDelete: KeyAction.cascade)();
  IntColumn get sequence => integer()();
  TextColumn get content => text()();
  TextColumn get originalContent => text().nullable()();
  IntColumn get startOffset => integer().nullable()();
  IntColumn get endOffset => integer().nullable()();
  TextColumn get pageTextSha256 => text().nullable()();
  TextColumn get extractionMethod => text().nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get boundingBoxJson => text().nullable()();
  DateTimeColumn get editedAt => dateTime().nullable()();
  DateTimeColumn get reviewedAt => dateTime().nullable()();
  IntColumn get page => integer().nullable()();
  IntColumn get frame => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sourceId, sequence},
  ];
}

@DataClassName('ConsentUiSourceRow')
class ConsentUiSources extends Table {
  TextColumn get id => text()();
  TextColumn get sourceId => text().unique().references(
    DocumentSources,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get imageSha256 => text().withLength(min: 64, max: 64)();
  TextColumn get reviewStatus => text()();
  IntColumn get frame => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('EvidenceReferenceRow')
@TableIndex(name: 'evidence_audit_idx', columns: {#auditId})
class EvidenceReferences extends Table {
  TextColumn get id => text()();
  TextColumn get auditId =>
      text().references(AuditSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get sourceId =>
      text().references(DocumentSources, #id, onDelete: KeyAction.cascade)();
  TextColumn get segmentId => text().nullable().references(
    DocumentSegments,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get sourceSha256 => text().withLength(min: 64, max: 64)();
  TextColumn get location => text()();
  TextColumn get quote => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('UserActionRow')
@TableIndex(name: 'user_actions_audit_idx', columns: {#auditId})
class UserActions extends Table {
  TextColumn get id => text()();
  TextColumn get auditId =>
      text().references(AuditSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get sourceId => text().nullable().references(
    DocumentSources,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get actionType => text()();
  TextColumn get details => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AnalysisRunRow')
@TableIndex(name: 'analysis_runs_audit_idx', columns: {#auditId})
class AnalysisRuns extends Table {
  TextColumn get id => text()();
  TextColumn get auditId =>
      text().references(AuditSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get status => text().customConstraint(
    "NOT NULL CHECK (status IN ('unavailable', 'queued', 'running', 'failed'))",
  )();
  TextColumn get engine => text()();
  TextColumn get reason => text()();
  TextColumn get sourceIdsJson => text()();
  TextColumn get modelVersion => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ReportRecordRow')
@TableIndex(name: 'reports_audit_idx', columns: {#auditId})
class ReportRecords extends Table {
  TextColumn get id => text()();
  TextColumn get auditId =>
      text().references(AuditSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get status => text()();
  TextColumn get localPath => text().nullable()();
  TextColumn get contentSha256 => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PrivacyPreferenceRows extends Table {
  IntColumn get id => integer()();
  BoolColumn get cloudOptIn => boolean().withDefault(const Constant(false))();
  BoolColumn get analyticsOptIn =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PendingFileDeletes extends Table {
  TextColumn get id => text()();
  TextColumn get relativePath => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    AuditSessions,
    ApplicationSnapshots,
    AppPermissionSnapshots,
    DocumentSources,
    DocumentSegments,
    ConsentUiSources,
    EvidenceReferences,
    UserActions,
    AnalysisRuns,
    ReportRecords,
    PrivacyPreferenceRows,
    PendingFileDeletes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  static Future<AppDatabase> openDefault() async {
    final directory = await getApplicationSupportDirectory();
    final dbDirectory = Directory(p.join(directory.path, 'database'));
    await dbDirectory.create(recursive: true);
    return AppDatabase(
      NativeDatabase(File(p.join(dbDirectory.path, 'konsena.sqlite'))),
    );
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (m, from, to) async {
      if (from < 1) await m.createAll();
      if (from < 2) {
        await m.createTable(applicationSnapshots);
        await m.addColumn(
          appPermissionSnapshots,
          appPermissionSnapshots.appSnapshotId,
        );
        await m.addColumn(
          appPermissionSnapshots,
          appPermissionSnapshots.permissionLabel,
        );
        await m.addColumn(
          appPermissionSnapshots,
          appPermissionSnapshots.granted,
        );
        await m.addColumn(
          appPermissionSnapshots,
          appPermissionSnapshots.flagsAvailable,
        );
      }
      if (from < 3) {
        await m.addColumn(documentSources, documentSources.sourceUrl);
        await m.addColumn(documentSources, documentSources.documentVersion);
        await m.addColumn(documentSources, documentSources.importWarnings);
        await m.addColumn(documentSources, documentSources.reviewedAt);
        await m.addColumn(documentSegments, documentSegments.originalContent);
        await m.addColumn(documentSegments, documentSegments.startOffset);
        await m.addColumn(documentSegments, documentSegments.endOffset);
        await m.addColumn(documentSegments, documentSegments.pageTextSha256);
        await m.addColumn(documentSegments, documentSegments.extractionMethod);
        await m.addColumn(documentSegments, documentSegments.confidence);
        await m.addColumn(documentSegments, documentSegments.boundingBoxJson);
        await m.addColumn(documentSegments, documentSegments.editedAt);
        await m.addColumn(documentSegments, documentSegments.reviewedAt);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );
}
