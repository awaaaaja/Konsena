enum AuditStatus { draft, inProgress, complete, deleted }

enum AuditFocus { permissions, documents, visual, combined }

enum AuditSourceType {
  androidPermission,
  privacyPolicy,
  terms,
  otherDocument,
  consentUi,
}

enum SourceReviewStatus { pending, needsReview, reviewed, unavailable }

enum SourceLifecycle { active, detached, pendingDelete }

enum AnalysisStatus { unavailable, queued, running, failed, succeeded }

class AuditSession {
  const AuditSession({
    required this.id,
    required this.name,
    required this.focus,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final AuditFocus focus;
  final AuditStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

class AppPermissionSnapshot {
  const AppPermissionSnapshot({
    required this.id,
    required this.auditId,
    required this.packageName,
    required this.permissionName,
    required this.grantStatus,
    required this.capturedAt,
    this.androidSdk,
    this.protectionLevel,
    this.permissionLabel,
    this.granted,
    this.flagsAvailable = false,
  });

  final String id;
  final String auditId;
  final String packageName;
  final String permissionName;
  final String grantStatus;
  final DateTime capturedAt;
  final int? androidSdk;
  final String? protectionLevel;
  final String? permissionLabel;
  final bool? granted;
  final bool flagsAvailable;
}

class ApplicationSnapshotRecord {
  const ApplicationSnapshotRecord({
    required this.id,
    required this.auditId,
    required this.packageName,
    required this.appLabel,
    required this.permissions,
    required this.snapshotStatus,
    required this.visibilityScope,
    required this.androidSdk,
    required this.capturedAt,
    this.versionName,
  });

  final String id;
  final String auditId;
  final String packageName;
  final String appLabel;
  final String? versionName;
  final List<AppPermissionSnapshot> permissions;
  final String snapshotStatus;
  final String visibilityScope;
  final int androidSdk;
  final DateTime capturedAt;
}

class DocumentSource {
  const DocumentSource({
    required this.id,
    required this.auditId,
    required this.type,
    required this.reviewStatus,
    required this.lifecycle,
    required this.sha256,
    required this.localPath,
    required this.mediaType,
    required this.byteLength,
    required this.createdAt,
    required this.updatedAt,
    this.originalName,
    this.language,
    this.provenancePage,
    this.provenanceFrame,
    this.provenanceLocator,
    this.sourceUrl,
    this.documentVersion,
    this.importWarnings,
    this.reviewedAt,
  });

  final String id;
  final String auditId;
  final AuditSourceType type;
  final SourceReviewStatus reviewStatus;
  final SourceLifecycle lifecycle;
  final String sha256;
  final String localPath;
  final String mediaType;
  final int byteLength;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? originalName;
  final String? language;
  final int? provenancePage;
  final int? provenanceFrame;
  final String? provenanceLocator;
  final String? sourceUrl;
  final String? documentVersion;
  final String? importWarnings;
  final DateTime? reviewedAt;
}

class DocumentSegment {
  const DocumentSegment({
    required this.id,
    required this.sourceId,
    required this.sequence,
    required this.text,
    this.page,
    this.frame,
    this.originalText,
    this.startOffset,
    this.endOffset,
    this.pageTextSha256,
    this.extractionMethod,
    this.confidence,
    this.boundingBoxJson,
    this.editedAt,
    this.reviewedAt,
  });

  final String id;
  final String sourceId;
  final int sequence;
  final String text;
  final int? page;
  final int? frame;
  final String? originalText;
  final int? startOffset;
  final int? endOffset;
  final String? pageTextSha256;
  final String? extractionMethod;
  final double? confidence;
  final String? boundingBoxJson;
  final DateTime? editedAt;
  final DateTime? reviewedAt;
}

class ImportedTextSegment {
  const ImportedTextSegment({
    required this.sequence,
    required this.text,
    required this.originalText,
    required this.page,
    required this.startOffset,
    required this.endOffset,
    required this.pageTextSha256,
    required this.extractionMethod,
    this.confidence,
    this.boundingBoxJson,
  });

  final int sequence;
  final String text;
  final String originalText;
  final int page;

  /// UTF-16 code-unit offsets into the page's original extracted text.
  final int startOffset;
  final int endOffset;
  final String pageTextSha256;
  final String extractionMethod;
  final double? confidence;
  final String? boundingBoxJson;
}

class ConsentUiSource {
  const ConsentUiSource({
    required this.id,
    required this.sourceId,
    required this.imageSha256,
    required this.reviewStatus,
    this.frame,
  });

  final String id;
  final String sourceId;
  final String imageSha256;
  final SourceReviewStatus reviewStatus;
  final int? frame;
}

class EvidenceReference {
  const EvidenceReference({
    required this.id,
    required this.auditId,
    required this.sourceId,
    required this.sourceSha256,
    required this.location,
    this.segmentId,
    this.quote,
  });

  final String id;
  final String auditId;
  final String sourceId;
  final String sourceSha256;
  final String location;
  final String? segmentId;
  final String? quote;
}

class UserAction {
  const UserAction({
    required this.id,
    required this.auditId,
    required this.actionType,
    required this.createdAt,
    this.sourceId,
    this.details,
  });

  final String id;
  final String auditId;
  final String actionType;
  final DateTime createdAt;
  final String? sourceId;
  final String? details;
}

class AnalysisRun {
  const AnalysisRun({
    required this.id,
    required this.auditId,
    required this.status,
    required this.engine,
    required this.reason,
    required this.sourceIds,
    required this.createdAt,
    this.modelVersion,
    this.finishedAt,
  });

  final String id;
  final String auditId;
  final AnalysisStatus status;
  final String engine;
  final String reason;
  final List<String> sourceIds;
  final DateTime createdAt;
  final DateTime? finishedAt;
  final String? modelVersion;
}

class ReportRecord {
  const ReportRecord({
    required this.id,
    required this.auditId,
    required this.status,
    required this.createdAt,
    this.localPath,
    this.contentSha256,
  });

  final String id;
  final String auditId;
  final String status;
  final DateTime createdAt;
  final String? localPath;
  final String? contentSha256;
}

class PrivacyPreferences {
  const PrivacyPreferences({
    required this.id,
    required this.cloudOptIn,
    required this.analyticsOptIn,
    required this.updatedAt,
  });

  final int id;
  final bool cloudOptIn;
  final bool analyticsOptIn;
  final DateTime updatedAt;

  factory PrivacyPreferences.safeDefault() => PrivacyPreferences(
    id: 1,
    cloudOptIn: false,
    analyticsOptIn: false,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );
}
