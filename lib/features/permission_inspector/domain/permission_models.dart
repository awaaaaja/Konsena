enum PermissionFactStatus {
  declaredGranted('declared_granted'),
  declaredNotGranted('declared_not_granted'),
  nonRuntimeOrUnknown('non_runtime_or_unknown'),
  unavailable('unavailable');

  const PermissionFactStatus(this.code);
  final String code;

  static PermissionFactStatus fromCode(Object? code) => values.firstWhere(
    (status) => status.code == code,
    orElse: () => PermissionFactStatus.unavailable,
  );
}

class VisibleApplication {
  const VisibleApplication({
    required this.packageName,
    required this.label,
    required this.isSystem,
    this.versionName,
  });

  final String packageName;
  final String label;
  final String? versionName;
  final bool isSystem;

  factory VisibleApplication.fromMap(Map<Object?, Object?> map) =>
      VisibleApplication(
        packageName: map['packageName'] as String,
        label: map['label'] as String? ?? map['packageName'] as String,
        versionName: map['versionName'] as String?,
        isSystem: map['isSystem'] as bool? ?? false,
      );
}

class PermissionFact {
  const PermissionFact({
    required this.name,
    required this.status,
    required this.flagsAvailable,
    this.label,
    this.granted,
    this.protectionLevel,
  });

  final String name;
  final String? label;
  final bool? granted;
  final PermissionFactStatus status;
  final int? protectionLevel;
  final bool flagsAvailable;

  factory PermissionFact.fromMap(Map<Object?, Object?> map) => PermissionFact(
    name: map['name'] as String,
    label: map['label'] as String?,
    granted: map['granted'] as bool?,
    status: PermissionFactStatus.fromCode(map['statusCode']),
    protectionLevel: map['protectionLevel'] as int?,
    flagsAvailable: map['flagsAvailable'] as bool? ?? false,
  );
}

class ApplicationPermissionSnapshot {
  const ApplicationPermissionSnapshot({
    required this.packageName,
    required this.label,
    required this.permissions,
    required this.capturedAt,
    required this.androidSdk,
    required this.visibilityScope,
    required this.snapshotStatus,
    this.versionName,
  });

  final String packageName;
  final String label;
  final String? versionName;
  final List<PermissionFact> permissions;
  final DateTime capturedAt;
  final int androidSdk;
  final String visibilityScope;
  final String snapshotStatus;

  factory ApplicationPermissionSnapshot.fromMap(Map<Object?, Object?> map) =>
      ApplicationPermissionSnapshot(
        packageName: map['packageName'] as String,
        label: map['label'] as String? ?? map['packageName'] as String,
        versionName: map['versionName'] as String?,
        permissions: ((map['permissions'] as List<Object?>?) ?? const [])
            .whereType<Map<Object?, Object?>>()
            .map(PermissionFact.fromMap)
            .toList(growable: false),
        capturedAt: DateTime.parse(map['capturedAt'] as String).toUtc(),
        androidSdk: map['androidSdk'] as int,
        visibilityScope: map['visibilityScope'] as String? ?? 'unknown',
        snapshotStatus: map['snapshotStatus'] as String? ?? 'available',
      );
}

abstract interface class PermissionInspectorPlatform {
  Future<List<VisibleApplication>> listVisibleLaunchableApps({
    bool includeSystem = false,
  });

  Future<ApplicationPermissionSnapshot> getPermissionSnapshot(
    String packageName,
  );

  Future<bool> openAppSettings(String packageName);
}

class PermissionInspectorException implements Exception {
  const PermissionInspectorException(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => 'PermissionInspectorException($code): $message';
}
