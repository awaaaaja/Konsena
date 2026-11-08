// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AuditSessionsTable extends AuditSessions
    with TableInfo<$AuditSessionsTable, AuditSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _focusMeta = const VerificationMeta('focus');
  @override
  late final GeneratedColumn<String> focus = GeneratedColumn<String>(
    'focus',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    focus,
    status,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('focus')) {
      context.handle(
        _focusMeta,
        focus.isAcceptableOrUnknown(data['focus']!, _focusMeta),
      );
    } else if (isInserting) {
      context.missing(_focusMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      focus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}focus'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AuditSessionsTable createAlias(String alias) {
    return $AuditSessionsTable(attachedDatabase, alias);
  }
}

class AuditSessionRow extends DataClass implements Insertable<AuditSessionRow> {
  final String id;
  final String name;
  final String focus;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const AuditSessionRow({
    required this.id,
    required this.name,
    required this.focus,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['focus'] = Variable<String>(focus);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AuditSessionsCompanion toCompanion(bool nullToAbsent) {
    return AuditSessionsCompanion(
      id: Value(id),
      name: Value(name),
      focus: Value(focus),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AuditSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditSessionRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      focus: serializer.fromJson<String>(json['focus']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'focus': serializer.toJson<String>(focus),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AuditSessionRow copyWith({
    String? id,
    String? name,
    String? focus,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AuditSessionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    focus: focus ?? this.focus,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AuditSessionRow copyWithCompanion(AuditSessionsCompanion data) {
    return AuditSessionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      focus: data.focus.present ? data.focus.value : this.focus,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditSessionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('focus: $focus, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, focus, status, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditSessionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.focus == this.focus &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AuditSessionsCompanion extends UpdateCompanion<AuditSessionRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> focus;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const AuditSessionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.focus = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditSessionsCompanion.insert({
    required String id,
    required String name,
    required String focus,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       focus = Value(focus),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AuditSessionRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? focus,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (focus != null) 'focus': focus,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? focus,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return AuditSessionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      focus: focus ?? this.focus,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (focus.present) {
      map['focus'] = Variable<String>(focus.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditSessionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('focus: $focus, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApplicationSnapshotsTable extends ApplicationSnapshots
    with TableInfo<$ApplicationSnapshotsTable, ApplicationSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApplicationSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
    'audit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audit_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appLabelMeta = const VerificationMeta(
    'appLabel',
  );
  @override
  late final GeneratedColumn<String> appLabel = GeneratedColumn<String>(
    'app_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionNameMeta = const VerificationMeta(
    'versionName',
  );
  @override
  late final GeneratedColumn<String> versionName = GeneratedColumn<String>(
    'version_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snapshotStatusMeta = const VerificationMeta(
    'snapshotStatus',
  );
  @override
  late final GeneratedColumn<String> snapshotStatus = GeneratedColumn<String>(
    'snapshot_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visibilityScopeMeta = const VerificationMeta(
    'visibilityScope',
  );
  @override
  late final GeneratedColumn<String> visibilityScope = GeneratedColumn<String>(
    'visibility_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _androidSdkMeta = const VerificationMeta(
    'androidSdk',
  );
  @override
  late final GeneratedColumn<int> androidSdk = GeneratedColumn<int>(
    'android_sdk',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    auditId,
    packageName,
    appLabel,
    versionName,
    snapshotStatus,
    visibilityScope,
    androidSdk,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'application_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApplicationSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    } else if (isInserting) {
      context.missing(_auditIdMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_label')) {
      context.handle(
        _appLabelMeta,
        appLabel.isAcceptableOrUnknown(data['app_label']!, _appLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_appLabelMeta);
    }
    if (data.containsKey('version_name')) {
      context.handle(
        _versionNameMeta,
        versionName.isAcceptableOrUnknown(
          data['version_name']!,
          _versionNameMeta,
        ),
      );
    }
    if (data.containsKey('snapshot_status')) {
      context.handle(
        _snapshotStatusMeta,
        snapshotStatus.isAcceptableOrUnknown(
          data['snapshot_status']!,
          _snapshotStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotStatusMeta);
    }
    if (data.containsKey('visibility_scope')) {
      context.handle(
        _visibilityScopeMeta,
        visibilityScope.isAcceptableOrUnknown(
          data['visibility_scope']!,
          _visibilityScopeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_visibilityScopeMeta);
    }
    if (data.containsKey('android_sdk')) {
      context.handle(
        _androidSdkMeta,
        androidSdk.isAcceptableOrUnknown(data['android_sdk']!, _androidSdkMeta),
      );
    } else if (isInserting) {
      context.missing(_androidSdkMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ApplicationSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApplicationSnapshotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      appLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_label'],
      )!,
      versionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_name'],
      ),
      snapshotStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_status'],
      )!,
      visibilityScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility_scope'],
      )!,
      androidSdk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}android_sdk'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
    );
  }

  @override
  $ApplicationSnapshotsTable createAlias(String alias) {
    return $ApplicationSnapshotsTable(attachedDatabase, alias);
  }
}

class ApplicationSnapshotRow extends DataClass
    implements Insertable<ApplicationSnapshotRow> {
  final String id;
  final String auditId;
  final String packageName;
  final String appLabel;
  final String? versionName;
  final String snapshotStatus;
  final String visibilityScope;
  final int androidSdk;
  final DateTime capturedAt;
  const ApplicationSnapshotRow({
    required this.id,
    required this.auditId,
    required this.packageName,
    required this.appLabel,
    this.versionName,
    required this.snapshotStatus,
    required this.visibilityScope,
    required this.androidSdk,
    required this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['audit_id'] = Variable<String>(auditId);
    map['package_name'] = Variable<String>(packageName);
    map['app_label'] = Variable<String>(appLabel);
    if (!nullToAbsent || versionName != null) {
      map['version_name'] = Variable<String>(versionName);
    }
    map['snapshot_status'] = Variable<String>(snapshotStatus);
    map['visibility_scope'] = Variable<String>(visibilityScope);
    map['android_sdk'] = Variable<int>(androidSdk);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    return map;
  }

  ApplicationSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return ApplicationSnapshotsCompanion(
      id: Value(id),
      auditId: Value(auditId),
      packageName: Value(packageName),
      appLabel: Value(appLabel),
      versionName: versionName == null && nullToAbsent
          ? const Value.absent()
          : Value(versionName),
      snapshotStatus: Value(snapshotStatus),
      visibilityScope: Value(visibilityScope),
      androidSdk: Value(androidSdk),
      capturedAt: Value(capturedAt),
    );
  }

  factory ApplicationSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApplicationSnapshotRow(
      id: serializer.fromJson<String>(json['id']),
      auditId: serializer.fromJson<String>(json['auditId']),
      packageName: serializer.fromJson<String>(json['packageName']),
      appLabel: serializer.fromJson<String>(json['appLabel']),
      versionName: serializer.fromJson<String?>(json['versionName']),
      snapshotStatus: serializer.fromJson<String>(json['snapshotStatus']),
      visibilityScope: serializer.fromJson<String>(json['visibilityScope']),
      androidSdk: serializer.fromJson<int>(json['androidSdk']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'auditId': serializer.toJson<String>(auditId),
      'packageName': serializer.toJson<String>(packageName),
      'appLabel': serializer.toJson<String>(appLabel),
      'versionName': serializer.toJson<String?>(versionName),
      'snapshotStatus': serializer.toJson<String>(snapshotStatus),
      'visibilityScope': serializer.toJson<String>(visibilityScope),
      'androidSdk': serializer.toJson<int>(androidSdk),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
    };
  }

  ApplicationSnapshotRow copyWith({
    String? id,
    String? auditId,
    String? packageName,
    String? appLabel,
    Value<String?> versionName = const Value.absent(),
    String? snapshotStatus,
    String? visibilityScope,
    int? androidSdk,
    DateTime? capturedAt,
  }) => ApplicationSnapshotRow(
    id: id ?? this.id,
    auditId: auditId ?? this.auditId,
    packageName: packageName ?? this.packageName,
    appLabel: appLabel ?? this.appLabel,
    versionName: versionName.present ? versionName.value : this.versionName,
    snapshotStatus: snapshotStatus ?? this.snapshotStatus,
    visibilityScope: visibilityScope ?? this.visibilityScope,
    androidSdk: androidSdk ?? this.androidSdk,
    capturedAt: capturedAt ?? this.capturedAt,
  );
  ApplicationSnapshotRow copyWithCompanion(ApplicationSnapshotsCompanion data) {
    return ApplicationSnapshotRow(
      id: data.id.present ? data.id.value : this.id,
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      appLabel: data.appLabel.present ? data.appLabel.value : this.appLabel,
      versionName: data.versionName.present
          ? data.versionName.value
          : this.versionName,
      snapshotStatus: data.snapshotStatus.present
          ? data.snapshotStatus.value
          : this.snapshotStatus,
      visibilityScope: data.visibilityScope.present
          ? data.visibilityScope.value
          : this.visibilityScope,
      androidSdk: data.androidSdk.present
          ? data.androidSdk.value
          : this.androidSdk,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApplicationSnapshotRow(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('packageName: $packageName, ')
          ..write('appLabel: $appLabel, ')
          ..write('versionName: $versionName, ')
          ..write('snapshotStatus: $snapshotStatus, ')
          ..write('visibilityScope: $visibilityScope, ')
          ..write('androidSdk: $androidSdk, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    auditId,
    packageName,
    appLabel,
    versionName,
    snapshotStatus,
    visibilityScope,
    androidSdk,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApplicationSnapshotRow &&
          other.id == this.id &&
          other.auditId == this.auditId &&
          other.packageName == this.packageName &&
          other.appLabel == this.appLabel &&
          other.versionName == this.versionName &&
          other.snapshotStatus == this.snapshotStatus &&
          other.visibilityScope == this.visibilityScope &&
          other.androidSdk == this.androidSdk &&
          other.capturedAt == this.capturedAt);
}

class ApplicationSnapshotsCompanion
    extends UpdateCompanion<ApplicationSnapshotRow> {
  final Value<String> id;
  final Value<String> auditId;
  final Value<String> packageName;
  final Value<String> appLabel;
  final Value<String?> versionName;
  final Value<String> snapshotStatus;
  final Value<String> visibilityScope;
  final Value<int> androidSdk;
  final Value<DateTime> capturedAt;
  final Value<int> rowid;
  const ApplicationSnapshotsCompanion({
    this.id = const Value.absent(),
    this.auditId = const Value.absent(),
    this.packageName = const Value.absent(),
    this.appLabel = const Value.absent(),
    this.versionName = const Value.absent(),
    this.snapshotStatus = const Value.absent(),
    this.visibilityScope = const Value.absent(),
    this.androidSdk = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApplicationSnapshotsCompanion.insert({
    required String id,
    required String auditId,
    required String packageName,
    required String appLabel,
    this.versionName = const Value.absent(),
    required String snapshotStatus,
    required String visibilityScope,
    required int androidSdk,
    required DateTime capturedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       auditId = Value(auditId),
       packageName = Value(packageName),
       appLabel = Value(appLabel),
       snapshotStatus = Value(snapshotStatus),
       visibilityScope = Value(visibilityScope),
       androidSdk = Value(androidSdk),
       capturedAt = Value(capturedAt);
  static Insertable<ApplicationSnapshotRow> custom({
    Expression<String>? id,
    Expression<String>? auditId,
    Expression<String>? packageName,
    Expression<String>? appLabel,
    Expression<String>? versionName,
    Expression<String>? snapshotStatus,
    Expression<String>? visibilityScope,
    Expression<int>? androidSdk,
    Expression<DateTime>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (auditId != null) 'audit_id': auditId,
      if (packageName != null) 'package_name': packageName,
      if (appLabel != null) 'app_label': appLabel,
      if (versionName != null) 'version_name': versionName,
      if (snapshotStatus != null) 'snapshot_status': snapshotStatus,
      if (visibilityScope != null) 'visibility_scope': visibilityScope,
      if (androidSdk != null) 'android_sdk': androidSdk,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApplicationSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? auditId,
    Value<String>? packageName,
    Value<String>? appLabel,
    Value<String?>? versionName,
    Value<String>? snapshotStatus,
    Value<String>? visibilityScope,
    Value<int>? androidSdk,
    Value<DateTime>? capturedAt,
    Value<int>? rowid,
  }) {
    return ApplicationSnapshotsCompanion(
      id: id ?? this.id,
      auditId: auditId ?? this.auditId,
      packageName: packageName ?? this.packageName,
      appLabel: appLabel ?? this.appLabel,
      versionName: versionName ?? this.versionName,
      snapshotStatus: snapshotStatus ?? this.snapshotStatus,
      visibilityScope: visibilityScope ?? this.visibilityScope,
      androidSdk: androidSdk ?? this.androidSdk,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appLabel.present) {
      map['app_label'] = Variable<String>(appLabel.value);
    }
    if (versionName.present) {
      map['version_name'] = Variable<String>(versionName.value);
    }
    if (snapshotStatus.present) {
      map['snapshot_status'] = Variable<String>(snapshotStatus.value);
    }
    if (visibilityScope.present) {
      map['visibility_scope'] = Variable<String>(visibilityScope.value);
    }
    if (androidSdk.present) {
      map['android_sdk'] = Variable<int>(androidSdk.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApplicationSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('packageName: $packageName, ')
          ..write('appLabel: $appLabel, ')
          ..write('versionName: $versionName, ')
          ..write('snapshotStatus: $snapshotStatus, ')
          ..write('visibilityScope: $visibilityScope, ')
          ..write('androidSdk: $androidSdk, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPermissionSnapshotsTable extends AppPermissionSnapshots
    with TableInfo<$AppPermissionSnapshotsTable, AppPermissionSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPermissionSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
    'audit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audit_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _appSnapshotIdMeta = const VerificationMeta(
    'appSnapshotId',
  );
  @override
  late final GeneratedColumn<String> appSnapshotId = GeneratedColumn<String>(
    'app_snapshot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES application_snapshots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionNameMeta = const VerificationMeta(
    'permissionName',
  );
  @override
  late final GeneratedColumn<String> permissionName = GeneratedColumn<String>(
    'permission_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionLabelMeta = const VerificationMeta(
    'permissionLabel',
  );
  @override
  late final GeneratedColumn<String> permissionLabel = GeneratedColumn<String>(
    'permission_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grantStatusMeta = const VerificationMeta(
    'grantStatus',
  );
  @override
  late final GeneratedColumn<String> grantStatus = GeneratedColumn<String>(
    'grant_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grantedMeta = const VerificationMeta(
    'granted',
  );
  @override
  late final GeneratedColumn<bool> granted = GeneratedColumn<bool>(
    'granted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("granted" IN (0, 1))',
    ),
  );
  static const VerificationMeta _flagsAvailableMeta = const VerificationMeta(
    'flagsAvailable',
  );
  @override
  late final GeneratedColumn<bool> flagsAvailable = GeneratedColumn<bool>(
    'flags_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("flags_available" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _androidSdkMeta = const VerificationMeta(
    'androidSdk',
  );
  @override
  late final GeneratedColumn<int> androidSdk = GeneratedColumn<int>(
    'android_sdk',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _protectionLevelMeta = const VerificationMeta(
    'protectionLevel',
  );
  @override
  late final GeneratedColumn<String> protectionLevel = GeneratedColumn<String>(
    'protection_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    auditId,
    appSnapshotId,
    packageName,
    permissionName,
    permissionLabel,
    grantStatus,
    granted,
    flagsAvailable,
    androidSdk,
    protectionLevel,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_permission_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPermissionSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    } else if (isInserting) {
      context.missing(_auditIdMeta);
    }
    if (data.containsKey('app_snapshot_id')) {
      context.handle(
        _appSnapshotIdMeta,
        appSnapshotId.isAcceptableOrUnknown(
          data['app_snapshot_id']!,
          _appSnapshotIdMeta,
        ),
      );
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('permission_name')) {
      context.handle(
        _permissionNameMeta,
        permissionName.isAcceptableOrUnknown(
          data['permission_name']!,
          _permissionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_permissionNameMeta);
    }
    if (data.containsKey('permission_label')) {
      context.handle(
        _permissionLabelMeta,
        permissionLabel.isAcceptableOrUnknown(
          data['permission_label']!,
          _permissionLabelMeta,
        ),
      );
    }
    if (data.containsKey('grant_status')) {
      context.handle(
        _grantStatusMeta,
        grantStatus.isAcceptableOrUnknown(
          data['grant_status']!,
          _grantStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grantStatusMeta);
    }
    if (data.containsKey('granted')) {
      context.handle(
        _grantedMeta,
        granted.isAcceptableOrUnknown(data['granted']!, _grantedMeta),
      );
    }
    if (data.containsKey('flags_available')) {
      context.handle(
        _flagsAvailableMeta,
        flagsAvailable.isAcceptableOrUnknown(
          data['flags_available']!,
          _flagsAvailableMeta,
        ),
      );
    }
    if (data.containsKey('android_sdk')) {
      context.handle(
        _androidSdkMeta,
        androidSdk.isAcceptableOrUnknown(data['android_sdk']!, _androidSdkMeta),
      );
    }
    if (data.containsKey('protection_level')) {
      context.handle(
        _protectionLevelMeta,
        protectionLevel.isAcceptableOrUnknown(
          data['protection_level']!,
          _protectionLevelMeta,
        ),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppPermissionSnapshotRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPermissionSnapshotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_id'],
      )!,
      appSnapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_snapshot_id'],
      ),
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      permissionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission_name'],
      )!,
      permissionLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission_label'],
      ),
      grantStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grant_status'],
      )!,
      granted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}granted'],
      ),
      flagsAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}flags_available'],
      )!,
      androidSdk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}android_sdk'],
      ),
      protectionLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protection_level'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
    );
  }

  @override
  $AppPermissionSnapshotsTable createAlias(String alias) {
    return $AppPermissionSnapshotsTable(attachedDatabase, alias);
  }
}

class AppPermissionSnapshotRow extends DataClass
    implements Insertable<AppPermissionSnapshotRow> {
  final String id;
  final String auditId;
  final String? appSnapshotId;
  final String packageName;
  final String permissionName;
  final String? permissionLabel;
  final String grantStatus;
  final bool? granted;
  final bool flagsAvailable;
  final int? androidSdk;
  final String? protectionLevel;
  final DateTime capturedAt;
  const AppPermissionSnapshotRow({
    required this.id,
    required this.auditId,
    this.appSnapshotId,
    required this.packageName,
    required this.permissionName,
    this.permissionLabel,
    required this.grantStatus,
    this.granted,
    required this.flagsAvailable,
    this.androidSdk,
    this.protectionLevel,
    required this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['audit_id'] = Variable<String>(auditId);
    if (!nullToAbsent || appSnapshotId != null) {
      map['app_snapshot_id'] = Variable<String>(appSnapshotId);
    }
    map['package_name'] = Variable<String>(packageName);
    map['permission_name'] = Variable<String>(permissionName);
    if (!nullToAbsent || permissionLabel != null) {
      map['permission_label'] = Variable<String>(permissionLabel);
    }
    map['grant_status'] = Variable<String>(grantStatus);
    if (!nullToAbsent || granted != null) {
      map['granted'] = Variable<bool>(granted);
    }
    map['flags_available'] = Variable<bool>(flagsAvailable);
    if (!nullToAbsent || androidSdk != null) {
      map['android_sdk'] = Variable<int>(androidSdk);
    }
    if (!nullToAbsent || protectionLevel != null) {
      map['protection_level'] = Variable<String>(protectionLevel);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    return map;
  }

  AppPermissionSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return AppPermissionSnapshotsCompanion(
      id: Value(id),
      auditId: Value(auditId),
      appSnapshotId: appSnapshotId == null && nullToAbsent
          ? const Value.absent()
          : Value(appSnapshotId),
      packageName: Value(packageName),
      permissionName: Value(permissionName),
      permissionLabel: permissionLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(permissionLabel),
      grantStatus: Value(grantStatus),
      granted: granted == null && nullToAbsent
          ? const Value.absent()
          : Value(granted),
      flagsAvailable: Value(flagsAvailable),
      androidSdk: androidSdk == null && nullToAbsent
          ? const Value.absent()
          : Value(androidSdk),
      protectionLevel: protectionLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(protectionLevel),
      capturedAt: Value(capturedAt),
    );
  }

  factory AppPermissionSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPermissionSnapshotRow(
      id: serializer.fromJson<String>(json['id']),
      auditId: serializer.fromJson<String>(json['auditId']),
      appSnapshotId: serializer.fromJson<String?>(json['appSnapshotId']),
      packageName: serializer.fromJson<String>(json['packageName']),
      permissionName: serializer.fromJson<String>(json['permissionName']),
      permissionLabel: serializer.fromJson<String?>(json['permissionLabel']),
      grantStatus: serializer.fromJson<String>(json['grantStatus']),
      granted: serializer.fromJson<bool?>(json['granted']),
      flagsAvailable: serializer.fromJson<bool>(json['flagsAvailable']),
      androidSdk: serializer.fromJson<int?>(json['androidSdk']),
      protectionLevel: serializer.fromJson<String?>(json['protectionLevel']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'auditId': serializer.toJson<String>(auditId),
      'appSnapshotId': serializer.toJson<String?>(appSnapshotId),
      'packageName': serializer.toJson<String>(packageName),
      'permissionName': serializer.toJson<String>(permissionName),
      'permissionLabel': serializer.toJson<String?>(permissionLabel),
      'grantStatus': serializer.toJson<String>(grantStatus),
      'granted': serializer.toJson<bool?>(granted),
      'flagsAvailable': serializer.toJson<bool>(flagsAvailable),
      'androidSdk': serializer.toJson<int?>(androidSdk),
      'protectionLevel': serializer.toJson<String?>(protectionLevel),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
    };
  }

  AppPermissionSnapshotRow copyWith({
    String? id,
    String? auditId,
    Value<String?> appSnapshotId = const Value.absent(),
    String? packageName,
    String? permissionName,
    Value<String?> permissionLabel = const Value.absent(),
    String? grantStatus,
    Value<bool?> granted = const Value.absent(),
    bool? flagsAvailable,
    Value<int?> androidSdk = const Value.absent(),
    Value<String?> protectionLevel = const Value.absent(),
    DateTime? capturedAt,
  }) => AppPermissionSnapshotRow(
    id: id ?? this.id,
    auditId: auditId ?? this.auditId,
    appSnapshotId: appSnapshotId.present
        ? appSnapshotId.value
        : this.appSnapshotId,
    packageName: packageName ?? this.packageName,
    permissionName: permissionName ?? this.permissionName,
    permissionLabel: permissionLabel.present
        ? permissionLabel.value
        : this.permissionLabel,
    grantStatus: grantStatus ?? this.grantStatus,
    granted: granted.present ? granted.value : this.granted,
    flagsAvailable: flagsAvailable ?? this.flagsAvailable,
    androidSdk: androidSdk.present ? androidSdk.value : this.androidSdk,
    protectionLevel: protectionLevel.present
        ? protectionLevel.value
        : this.protectionLevel,
    capturedAt: capturedAt ?? this.capturedAt,
  );
  AppPermissionSnapshotRow copyWithCompanion(
    AppPermissionSnapshotsCompanion data,
  ) {
    return AppPermissionSnapshotRow(
      id: data.id.present ? data.id.value : this.id,
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      appSnapshotId: data.appSnapshotId.present
          ? data.appSnapshotId.value
          : this.appSnapshotId,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      permissionName: data.permissionName.present
          ? data.permissionName.value
          : this.permissionName,
      permissionLabel: data.permissionLabel.present
          ? data.permissionLabel.value
          : this.permissionLabel,
      grantStatus: data.grantStatus.present
          ? data.grantStatus.value
          : this.grantStatus,
      granted: data.granted.present ? data.granted.value : this.granted,
      flagsAvailable: data.flagsAvailable.present
          ? data.flagsAvailable.value
          : this.flagsAvailable,
      androidSdk: data.androidSdk.present
          ? data.androidSdk.value
          : this.androidSdk,
      protectionLevel: data.protectionLevel.present
          ? data.protectionLevel.value
          : this.protectionLevel,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPermissionSnapshotRow(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('appSnapshotId: $appSnapshotId, ')
          ..write('packageName: $packageName, ')
          ..write('permissionName: $permissionName, ')
          ..write('permissionLabel: $permissionLabel, ')
          ..write('grantStatus: $grantStatus, ')
          ..write('granted: $granted, ')
          ..write('flagsAvailable: $flagsAvailable, ')
          ..write('androidSdk: $androidSdk, ')
          ..write('protectionLevel: $protectionLevel, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    auditId,
    appSnapshotId,
    packageName,
    permissionName,
    permissionLabel,
    grantStatus,
    granted,
    flagsAvailable,
    androidSdk,
    protectionLevel,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPermissionSnapshotRow &&
          other.id == this.id &&
          other.auditId == this.auditId &&
          other.appSnapshotId == this.appSnapshotId &&
          other.packageName == this.packageName &&
          other.permissionName == this.permissionName &&
          other.permissionLabel == this.permissionLabel &&
          other.grantStatus == this.grantStatus &&
          other.granted == this.granted &&
          other.flagsAvailable == this.flagsAvailable &&
          other.androidSdk == this.androidSdk &&
          other.protectionLevel == this.protectionLevel &&
          other.capturedAt == this.capturedAt);
}

class AppPermissionSnapshotsCompanion
    extends UpdateCompanion<AppPermissionSnapshotRow> {
  final Value<String> id;
  final Value<String> auditId;
  final Value<String?> appSnapshotId;
  final Value<String> packageName;
  final Value<String> permissionName;
  final Value<String?> permissionLabel;
  final Value<String> grantStatus;
  final Value<bool?> granted;
  final Value<bool> flagsAvailable;
  final Value<int?> androidSdk;
  final Value<String?> protectionLevel;
  final Value<DateTime> capturedAt;
  final Value<int> rowid;
  const AppPermissionSnapshotsCompanion({
    this.id = const Value.absent(),
    this.auditId = const Value.absent(),
    this.appSnapshotId = const Value.absent(),
    this.packageName = const Value.absent(),
    this.permissionName = const Value.absent(),
    this.permissionLabel = const Value.absent(),
    this.grantStatus = const Value.absent(),
    this.granted = const Value.absent(),
    this.flagsAvailable = const Value.absent(),
    this.androidSdk = const Value.absent(),
    this.protectionLevel = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPermissionSnapshotsCompanion.insert({
    required String id,
    required String auditId,
    this.appSnapshotId = const Value.absent(),
    required String packageName,
    required String permissionName,
    this.permissionLabel = const Value.absent(),
    required String grantStatus,
    this.granted = const Value.absent(),
    this.flagsAvailable = const Value.absent(),
    this.androidSdk = const Value.absent(),
    this.protectionLevel = const Value.absent(),
    required DateTime capturedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       auditId = Value(auditId),
       packageName = Value(packageName),
       permissionName = Value(permissionName),
       grantStatus = Value(grantStatus),
       capturedAt = Value(capturedAt);
  static Insertable<AppPermissionSnapshotRow> custom({
    Expression<String>? id,
    Expression<String>? auditId,
    Expression<String>? appSnapshotId,
    Expression<String>? packageName,
    Expression<String>? permissionName,
    Expression<String>? permissionLabel,
    Expression<String>? grantStatus,
    Expression<bool>? granted,
    Expression<bool>? flagsAvailable,
    Expression<int>? androidSdk,
    Expression<String>? protectionLevel,
    Expression<DateTime>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (auditId != null) 'audit_id': auditId,
      if (appSnapshotId != null) 'app_snapshot_id': appSnapshotId,
      if (packageName != null) 'package_name': packageName,
      if (permissionName != null) 'permission_name': permissionName,
      if (permissionLabel != null) 'permission_label': permissionLabel,
      if (grantStatus != null) 'grant_status': grantStatus,
      if (granted != null) 'granted': granted,
      if (flagsAvailable != null) 'flags_available': flagsAvailable,
      if (androidSdk != null) 'android_sdk': androidSdk,
      if (protectionLevel != null) 'protection_level': protectionLevel,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPermissionSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? auditId,
    Value<String?>? appSnapshotId,
    Value<String>? packageName,
    Value<String>? permissionName,
    Value<String?>? permissionLabel,
    Value<String>? grantStatus,
    Value<bool?>? granted,
    Value<bool>? flagsAvailable,
    Value<int?>? androidSdk,
    Value<String?>? protectionLevel,
    Value<DateTime>? capturedAt,
    Value<int>? rowid,
  }) {
    return AppPermissionSnapshotsCompanion(
      id: id ?? this.id,
      auditId: auditId ?? this.auditId,
      appSnapshotId: appSnapshotId ?? this.appSnapshotId,
      packageName: packageName ?? this.packageName,
      permissionName: permissionName ?? this.permissionName,
      permissionLabel: permissionLabel ?? this.permissionLabel,
      grantStatus: grantStatus ?? this.grantStatus,
      granted: granted ?? this.granted,
      flagsAvailable: flagsAvailable ?? this.flagsAvailable,
      androidSdk: androidSdk ?? this.androidSdk,
      protectionLevel: protectionLevel ?? this.protectionLevel,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (appSnapshotId.present) {
      map['app_snapshot_id'] = Variable<String>(appSnapshotId.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (permissionName.present) {
      map['permission_name'] = Variable<String>(permissionName.value);
    }
    if (permissionLabel.present) {
      map['permission_label'] = Variable<String>(permissionLabel.value);
    }
    if (grantStatus.present) {
      map['grant_status'] = Variable<String>(grantStatus.value);
    }
    if (granted.present) {
      map['granted'] = Variable<bool>(granted.value);
    }
    if (flagsAvailable.present) {
      map['flags_available'] = Variable<bool>(flagsAvailable.value);
    }
    if (androidSdk.present) {
      map['android_sdk'] = Variable<int>(androidSdk.value);
    }
    if (protectionLevel.present) {
      map['protection_level'] = Variable<String>(protectionLevel.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPermissionSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('appSnapshotId: $appSnapshotId, ')
          ..write('packageName: $packageName, ')
          ..write('permissionName: $permissionName, ')
          ..write('permissionLabel: $permissionLabel, ')
          ..write('grantStatus: $grantStatus, ')
          ..write('granted: $granted, ')
          ..write('flagsAvailable: $flagsAvailable, ')
          ..write('androidSdk: $androidSdk, ')
          ..write('protectionLevel: $protectionLevel, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentSourcesTable extends DocumentSources
    with TableInfo<$DocumentSourcesTable, DocumentSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
    'audit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audit_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lifecycleMeta = const VerificationMeta(
    'lifecycle',
  );
  @override
  late final GeneratedColumn<String> lifecycle = GeneratedColumn<String>(
    'lifecycle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 64,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteLengthMeta = const VerificationMeta(
    'byteLength',
  );
  @override
  late final GeneratedColumn<int> byteLength = GeneratedColumn<int>(
    'byte_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _provenancePageMeta = const VerificationMeta(
    'provenancePage',
  );
  @override
  late final GeneratedColumn<int> provenancePage = GeneratedColumn<int>(
    'provenance_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _provenanceFrameMeta = const VerificationMeta(
    'provenanceFrame',
  );
  @override
  late final GeneratedColumn<int> provenanceFrame = GeneratedColumn<int>(
    'provenance_frame',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _provenanceLocatorMeta = const VerificationMeta(
    'provenanceLocator',
  );
  @override
  late final GeneratedColumn<String> provenanceLocator =
      GeneratedColumn<String>(
        'provenance_locator',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentVersionMeta = const VerificationMeta(
    'documentVersion',
  );
  @override
  late final GeneratedColumn<String> documentVersion = GeneratedColumn<String>(
    'document_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importWarningsMeta = const VerificationMeta(
    'importWarnings',
  );
  @override
  late final GeneratedColumn<String> importWarnings = GeneratedColumn<String>(
    'import_warnings',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    auditId,
    type,
    reviewStatus,
    lifecycle,
    sha256,
    localPath,
    mediaType,
    byteLength,
    originalName,
    language,
    provenancePage,
    provenanceFrame,
    provenanceLocator,
    sourceUrl,
    documentVersion,
    importWarnings,
    reviewedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentSourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    } else if (isInserting) {
      context.missing(_auditIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewStatusMeta);
    }
    if (data.containsKey('lifecycle')) {
      context.handle(
        _lifecycleMeta,
        lifecycle.isAcceptableOrUnknown(data['lifecycle']!, _lifecycleMeta),
      );
    } else if (isInserting) {
      context.missing(_lifecycleMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('byte_length')) {
      context.handle(
        _byteLengthMeta,
        byteLength.isAcceptableOrUnknown(data['byte_length']!, _byteLengthMeta),
      );
    } else if (isInserting) {
      context.missing(_byteLengthMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('provenance_page')) {
      context.handle(
        _provenancePageMeta,
        provenancePage.isAcceptableOrUnknown(
          data['provenance_page']!,
          _provenancePageMeta,
        ),
      );
    }
    if (data.containsKey('provenance_frame')) {
      context.handle(
        _provenanceFrameMeta,
        provenanceFrame.isAcceptableOrUnknown(
          data['provenance_frame']!,
          _provenanceFrameMeta,
        ),
      );
    }
    if (data.containsKey('provenance_locator')) {
      context.handle(
        _provenanceLocatorMeta,
        provenanceLocator.isAcceptableOrUnknown(
          data['provenance_locator']!,
          _provenanceLocatorMeta,
        ),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('document_version')) {
      context.handle(
        _documentVersionMeta,
        documentVersion.isAcceptableOrUnknown(
          data['document_version']!,
          _documentVersionMeta,
        ),
      );
    }
    if (data.containsKey('import_warnings')) {
      context.handle(
        _importWarningsMeta,
        importWarnings.isAcceptableOrUnknown(
          data['import_warnings']!,
          _importWarningsMeta,
        ),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentSourceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      lifecycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      byteLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_length'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      provenancePage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}provenance_page'],
      ),
      provenanceFrame: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}provenance_frame'],
      ),
      provenanceLocator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provenance_locator'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      documentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_version'],
      ),
      importWarnings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_warnings'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DocumentSourcesTable createAlias(String alias) {
    return $DocumentSourcesTable(attachedDatabase, alias);
  }
}

class DocumentSourceRow extends DataClass
    implements Insertable<DocumentSourceRow> {
  final String id;
  final String auditId;
  final String type;
  final String reviewStatus;
  final String lifecycle;
  final String sha256;
  final String localPath;
  final String mediaType;
  final int byteLength;
  final String? originalName;
  final String? language;
  final int? provenancePage;
  final int? provenanceFrame;
  final String? provenanceLocator;
  final String? sourceUrl;
  final String? documentVersion;
  final String? importWarnings;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DocumentSourceRow({
    required this.id,
    required this.auditId,
    required this.type,
    required this.reviewStatus,
    required this.lifecycle,
    required this.sha256,
    required this.localPath,
    required this.mediaType,
    required this.byteLength,
    this.originalName,
    this.language,
    this.provenancePage,
    this.provenanceFrame,
    this.provenanceLocator,
    this.sourceUrl,
    this.documentVersion,
    this.importWarnings,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['audit_id'] = Variable<String>(auditId);
    map['type'] = Variable<String>(type);
    map['review_status'] = Variable<String>(reviewStatus);
    map['lifecycle'] = Variable<String>(lifecycle);
    map['sha256'] = Variable<String>(sha256);
    map['local_path'] = Variable<String>(localPath);
    map['media_type'] = Variable<String>(mediaType);
    map['byte_length'] = Variable<int>(byteLength);
    if (!nullToAbsent || originalName != null) {
      map['original_name'] = Variable<String>(originalName);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || provenancePage != null) {
      map['provenance_page'] = Variable<int>(provenancePage);
    }
    if (!nullToAbsent || provenanceFrame != null) {
      map['provenance_frame'] = Variable<int>(provenanceFrame);
    }
    if (!nullToAbsent || provenanceLocator != null) {
      map['provenance_locator'] = Variable<String>(provenanceLocator);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || documentVersion != null) {
      map['document_version'] = Variable<String>(documentVersion);
    }
    if (!nullToAbsent || importWarnings != null) {
      map['import_warnings'] = Variable<String>(importWarnings);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DocumentSourcesCompanion toCompanion(bool nullToAbsent) {
    return DocumentSourcesCompanion(
      id: Value(id),
      auditId: Value(auditId),
      type: Value(type),
      reviewStatus: Value(reviewStatus),
      lifecycle: Value(lifecycle),
      sha256: Value(sha256),
      localPath: Value(localPath),
      mediaType: Value(mediaType),
      byteLength: Value(byteLength),
      originalName: originalName == null && nullToAbsent
          ? const Value.absent()
          : Value(originalName),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      provenancePage: provenancePage == null && nullToAbsent
          ? const Value.absent()
          : Value(provenancePage),
      provenanceFrame: provenanceFrame == null && nullToAbsent
          ? const Value.absent()
          : Value(provenanceFrame),
      provenanceLocator: provenanceLocator == null && nullToAbsent
          ? const Value.absent()
          : Value(provenanceLocator),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      documentVersion: documentVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(documentVersion),
      importWarnings: importWarnings == null && nullToAbsent
          ? const Value.absent()
          : Value(importWarnings),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DocumentSourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentSourceRow(
      id: serializer.fromJson<String>(json['id']),
      auditId: serializer.fromJson<String>(json['auditId']),
      type: serializer.fromJson<String>(json['type']),
      reviewStatus: serializer.fromJson<String>(json['reviewStatus']),
      lifecycle: serializer.fromJson<String>(json['lifecycle']),
      sha256: serializer.fromJson<String>(json['sha256']),
      localPath: serializer.fromJson<String>(json['localPath']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      byteLength: serializer.fromJson<int>(json['byteLength']),
      originalName: serializer.fromJson<String?>(json['originalName']),
      language: serializer.fromJson<String?>(json['language']),
      provenancePage: serializer.fromJson<int?>(json['provenancePage']),
      provenanceFrame: serializer.fromJson<int?>(json['provenanceFrame']),
      provenanceLocator: serializer.fromJson<String?>(
        json['provenanceLocator'],
      ),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      documentVersion: serializer.fromJson<String?>(json['documentVersion']),
      importWarnings: serializer.fromJson<String?>(json['importWarnings']),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'auditId': serializer.toJson<String>(auditId),
      'type': serializer.toJson<String>(type),
      'reviewStatus': serializer.toJson<String>(reviewStatus),
      'lifecycle': serializer.toJson<String>(lifecycle),
      'sha256': serializer.toJson<String>(sha256),
      'localPath': serializer.toJson<String>(localPath),
      'mediaType': serializer.toJson<String>(mediaType),
      'byteLength': serializer.toJson<int>(byteLength),
      'originalName': serializer.toJson<String?>(originalName),
      'language': serializer.toJson<String?>(language),
      'provenancePage': serializer.toJson<int?>(provenancePage),
      'provenanceFrame': serializer.toJson<int?>(provenanceFrame),
      'provenanceLocator': serializer.toJson<String?>(provenanceLocator),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'documentVersion': serializer.toJson<String?>(documentVersion),
      'importWarnings': serializer.toJson<String?>(importWarnings),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DocumentSourceRow copyWith({
    String? id,
    String? auditId,
    String? type,
    String? reviewStatus,
    String? lifecycle,
    String? sha256,
    String? localPath,
    String? mediaType,
    int? byteLength,
    Value<String?> originalName = const Value.absent(),
    Value<String?> language = const Value.absent(),
    Value<int?> provenancePage = const Value.absent(),
    Value<int?> provenanceFrame = const Value.absent(),
    Value<String?> provenanceLocator = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<String?> documentVersion = const Value.absent(),
    Value<String?> importWarnings = const Value.absent(),
    Value<DateTime?> reviewedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DocumentSourceRow(
    id: id ?? this.id,
    auditId: auditId ?? this.auditId,
    type: type ?? this.type,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    lifecycle: lifecycle ?? this.lifecycle,
    sha256: sha256 ?? this.sha256,
    localPath: localPath ?? this.localPath,
    mediaType: mediaType ?? this.mediaType,
    byteLength: byteLength ?? this.byteLength,
    originalName: originalName.present ? originalName.value : this.originalName,
    language: language.present ? language.value : this.language,
    provenancePage: provenancePage.present
        ? provenancePage.value
        : this.provenancePage,
    provenanceFrame: provenanceFrame.present
        ? provenanceFrame.value
        : this.provenanceFrame,
    provenanceLocator: provenanceLocator.present
        ? provenanceLocator.value
        : this.provenanceLocator,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    documentVersion: documentVersion.present
        ? documentVersion.value
        : this.documentVersion,
    importWarnings: importWarnings.present
        ? importWarnings.value
        : this.importWarnings,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DocumentSourceRow copyWithCompanion(DocumentSourcesCompanion data) {
    return DocumentSourceRow(
      id: data.id.present ? data.id.value : this.id,
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      type: data.type.present ? data.type.value : this.type,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      lifecycle: data.lifecycle.present ? data.lifecycle.value : this.lifecycle,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      byteLength: data.byteLength.present
          ? data.byteLength.value
          : this.byteLength,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
      language: data.language.present ? data.language.value : this.language,
      provenancePage: data.provenancePage.present
          ? data.provenancePage.value
          : this.provenancePage,
      provenanceFrame: data.provenanceFrame.present
          ? data.provenanceFrame.value
          : this.provenanceFrame,
      provenanceLocator: data.provenanceLocator.present
          ? data.provenanceLocator.value
          : this.provenanceLocator,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      documentVersion: data.documentVersion.present
          ? data.documentVersion.value
          : this.documentVersion,
      importWarnings: data.importWarnings.present
          ? data.importWarnings.value
          : this.importWarnings,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentSourceRow(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('type: $type, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('sha256: $sha256, ')
          ..write('localPath: $localPath, ')
          ..write('mediaType: $mediaType, ')
          ..write('byteLength: $byteLength, ')
          ..write('originalName: $originalName, ')
          ..write('language: $language, ')
          ..write('provenancePage: $provenancePage, ')
          ..write('provenanceFrame: $provenanceFrame, ')
          ..write('provenanceLocator: $provenanceLocator, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('documentVersion: $documentVersion, ')
          ..write('importWarnings: $importWarnings, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    auditId,
    type,
    reviewStatus,
    lifecycle,
    sha256,
    localPath,
    mediaType,
    byteLength,
    originalName,
    language,
    provenancePage,
    provenanceFrame,
    provenanceLocator,
    sourceUrl,
    documentVersion,
    importWarnings,
    reviewedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentSourceRow &&
          other.id == this.id &&
          other.auditId == this.auditId &&
          other.type == this.type &&
          other.reviewStatus == this.reviewStatus &&
          other.lifecycle == this.lifecycle &&
          other.sha256 == this.sha256 &&
          other.localPath == this.localPath &&
          other.mediaType == this.mediaType &&
          other.byteLength == this.byteLength &&
          other.originalName == this.originalName &&
          other.language == this.language &&
          other.provenancePage == this.provenancePage &&
          other.provenanceFrame == this.provenanceFrame &&
          other.provenanceLocator == this.provenanceLocator &&
          other.sourceUrl == this.sourceUrl &&
          other.documentVersion == this.documentVersion &&
          other.importWarnings == this.importWarnings &&
          other.reviewedAt == this.reviewedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DocumentSourcesCompanion extends UpdateCompanion<DocumentSourceRow> {
  final Value<String> id;
  final Value<String> auditId;
  final Value<String> type;
  final Value<String> reviewStatus;
  final Value<String> lifecycle;
  final Value<String> sha256;
  final Value<String> localPath;
  final Value<String> mediaType;
  final Value<int> byteLength;
  final Value<String?> originalName;
  final Value<String?> language;
  final Value<int?> provenancePage;
  final Value<int?> provenanceFrame;
  final Value<String?> provenanceLocator;
  final Value<String?> sourceUrl;
  final Value<String?> documentVersion;
  final Value<String?> importWarnings;
  final Value<DateTime?> reviewedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DocumentSourcesCompanion({
    this.id = const Value.absent(),
    this.auditId = const Value.absent(),
    this.type = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.localPath = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.byteLength = const Value.absent(),
    this.originalName = const Value.absent(),
    this.language = const Value.absent(),
    this.provenancePage = const Value.absent(),
    this.provenanceFrame = const Value.absent(),
    this.provenanceLocator = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.documentVersion = const Value.absent(),
    this.importWarnings = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentSourcesCompanion.insert({
    required String id,
    required String auditId,
    required String type,
    required String reviewStatus,
    required String lifecycle,
    required String sha256,
    required String localPath,
    required String mediaType,
    required int byteLength,
    this.originalName = const Value.absent(),
    this.language = const Value.absent(),
    this.provenancePage = const Value.absent(),
    this.provenanceFrame = const Value.absent(),
    this.provenanceLocator = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.documentVersion = const Value.absent(),
    this.importWarnings = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       auditId = Value(auditId),
       type = Value(type),
       reviewStatus = Value(reviewStatus),
       lifecycle = Value(lifecycle),
       sha256 = Value(sha256),
       localPath = Value(localPath),
       mediaType = Value(mediaType),
       byteLength = Value(byteLength),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DocumentSourceRow> custom({
    Expression<String>? id,
    Expression<String>? auditId,
    Expression<String>? type,
    Expression<String>? reviewStatus,
    Expression<String>? lifecycle,
    Expression<String>? sha256,
    Expression<String>? localPath,
    Expression<String>? mediaType,
    Expression<int>? byteLength,
    Expression<String>? originalName,
    Expression<String>? language,
    Expression<int>? provenancePage,
    Expression<int>? provenanceFrame,
    Expression<String>? provenanceLocator,
    Expression<String>? sourceUrl,
    Expression<String>? documentVersion,
    Expression<String>? importWarnings,
    Expression<DateTime>? reviewedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (auditId != null) 'audit_id': auditId,
      if (type != null) 'type': type,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (sha256 != null) 'sha256': sha256,
      if (localPath != null) 'local_path': localPath,
      if (mediaType != null) 'media_type': mediaType,
      if (byteLength != null) 'byte_length': byteLength,
      if (originalName != null) 'original_name': originalName,
      if (language != null) 'language': language,
      if (provenancePage != null) 'provenance_page': provenancePage,
      if (provenanceFrame != null) 'provenance_frame': provenanceFrame,
      if (provenanceLocator != null) 'provenance_locator': provenanceLocator,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (documentVersion != null) 'document_version': documentVersion,
      if (importWarnings != null) 'import_warnings': importWarnings,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentSourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? auditId,
    Value<String>? type,
    Value<String>? reviewStatus,
    Value<String>? lifecycle,
    Value<String>? sha256,
    Value<String>? localPath,
    Value<String>? mediaType,
    Value<int>? byteLength,
    Value<String?>? originalName,
    Value<String?>? language,
    Value<int?>? provenancePage,
    Value<int?>? provenanceFrame,
    Value<String?>? provenanceLocator,
    Value<String?>? sourceUrl,
    Value<String?>? documentVersion,
    Value<String?>? importWarnings,
    Value<DateTime?>? reviewedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DocumentSourcesCompanion(
      id: id ?? this.id,
      auditId: auditId ?? this.auditId,
      type: type ?? this.type,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      lifecycle: lifecycle ?? this.lifecycle,
      sha256: sha256 ?? this.sha256,
      localPath: localPath ?? this.localPath,
      mediaType: mediaType ?? this.mediaType,
      byteLength: byteLength ?? this.byteLength,
      originalName: originalName ?? this.originalName,
      language: language ?? this.language,
      provenancePage: provenancePage ?? this.provenancePage,
      provenanceFrame: provenanceFrame ?? this.provenanceFrame,
      provenanceLocator: provenanceLocator ?? this.provenanceLocator,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      documentVersion: documentVersion ?? this.documentVersion,
      importWarnings: importWarnings ?? this.importWarnings,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (lifecycle.present) {
      map['lifecycle'] = Variable<String>(lifecycle.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (byteLength.present) {
      map['byte_length'] = Variable<int>(byteLength.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (provenancePage.present) {
      map['provenance_page'] = Variable<int>(provenancePage.value);
    }
    if (provenanceFrame.present) {
      map['provenance_frame'] = Variable<int>(provenanceFrame.value);
    }
    if (provenanceLocator.present) {
      map['provenance_locator'] = Variable<String>(provenanceLocator.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (documentVersion.present) {
      map['document_version'] = Variable<String>(documentVersion.value);
    }
    if (importWarnings.present) {
      map['import_warnings'] = Variable<String>(importWarnings.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentSourcesCompanion(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('type: $type, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('sha256: $sha256, ')
          ..write('localPath: $localPath, ')
          ..write('mediaType: $mediaType, ')
          ..write('byteLength: $byteLength, ')
          ..write('originalName: $originalName, ')
          ..write('language: $language, ')
          ..write('provenancePage: $provenancePage, ')
          ..write('provenanceFrame: $provenanceFrame, ')
          ..write('provenanceLocator: $provenanceLocator, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('documentVersion: $documentVersion, ')
          ..write('importWarnings: $importWarnings, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentSegmentsTable extends DocumentSegments
    with TableInfo<$DocumentSegmentsTable, DocumentSegmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document_sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalContentMeta = const VerificationMeta(
    'originalContent',
  );
  @override
  late final GeneratedColumn<String> originalContent = GeneratedColumn<String>(
    'original_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startOffsetMeta = const VerificationMeta(
    'startOffset',
  );
  @override
  late final GeneratedColumn<int> startOffset = GeneratedColumn<int>(
    'start_offset',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endOffsetMeta = const VerificationMeta(
    'endOffset',
  );
  @override
  late final GeneratedColumn<int> endOffset = GeneratedColumn<int>(
    'end_offset',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageTextSha256Meta = const VerificationMeta(
    'pageTextSha256',
  );
  @override
  late final GeneratedColumn<String> pageTextSha256 = GeneratedColumn<String>(
    'page_text_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extractionMethodMeta = const VerificationMeta(
    'extractionMethod',
  );
  @override
  late final GeneratedColumn<String> extractionMethod = GeneratedColumn<String>(
    'extraction_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boundingBoxJsonMeta = const VerificationMeta(
    'boundingBoxJson',
  );
  @override
  late final GeneratedColumn<String> boundingBoxJson = GeneratedColumn<String>(
    'bounding_box_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frameMeta = const VerificationMeta('frame');
  @override
  late final GeneratedColumn<int> frame = GeneratedColumn<int>(
    'frame',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    sequence,
    content,
    originalContent,
    startOffset,
    endOffset,
    pageTextSha256,
    extractionMethod,
    confidence,
    boundingBoxJson,
    editedAt,
    reviewedAt,
    page,
    frame,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentSegmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('original_content')) {
      context.handle(
        _originalContentMeta,
        originalContent.isAcceptableOrUnknown(
          data['original_content']!,
          _originalContentMeta,
        ),
      );
    }
    if (data.containsKey('start_offset')) {
      context.handle(
        _startOffsetMeta,
        startOffset.isAcceptableOrUnknown(
          data['start_offset']!,
          _startOffsetMeta,
        ),
      );
    }
    if (data.containsKey('end_offset')) {
      context.handle(
        _endOffsetMeta,
        endOffset.isAcceptableOrUnknown(data['end_offset']!, _endOffsetMeta),
      );
    }
    if (data.containsKey('page_text_sha256')) {
      context.handle(
        _pageTextSha256Meta,
        pageTextSha256.isAcceptableOrUnknown(
          data['page_text_sha256']!,
          _pageTextSha256Meta,
        ),
      );
    }
    if (data.containsKey('extraction_method')) {
      context.handle(
        _extractionMethodMeta,
        extractionMethod.isAcceptableOrUnknown(
          data['extraction_method']!,
          _extractionMethodMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('bounding_box_json')) {
      context.handle(
        _boundingBoxJsonMeta,
        boundingBoxJson.isAcceptableOrUnknown(
          data['bounding_box_json']!,
          _boundingBoxJsonMeta,
        ),
      );
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    }
    if (data.containsKey('frame')) {
      context.handle(
        _frameMeta,
        frame.isAcceptableOrUnknown(data['frame']!, _frameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceId, sequence},
  ];
  @override
  DocumentSegmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentSegmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      originalContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_content'],
      ),
      startOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_offset'],
      ),
      endOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_offset'],
      ),
      pageTextSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_text_sha256'],
      ),
      extractionMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extraction_method'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      boundingBoxJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bounding_box_json'],
      ),
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edited_at'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      ),
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      ),
      frame: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frame'],
      ),
    );
  }

  @override
  $DocumentSegmentsTable createAlias(String alias) {
    return $DocumentSegmentsTable(attachedDatabase, alias);
  }
}

class DocumentSegmentRow extends DataClass
    implements Insertable<DocumentSegmentRow> {
  final String id;
  final String sourceId;
  final int sequence;
  final String content;
  final String? originalContent;
  final int? startOffset;
  final int? endOffset;
  final String? pageTextSha256;
  final String? extractionMethod;
  final double? confidence;
  final String? boundingBoxJson;
  final DateTime? editedAt;
  final DateTime? reviewedAt;
  final int? page;
  final int? frame;
  const DocumentSegmentRow({
    required this.id,
    required this.sourceId,
    required this.sequence,
    required this.content,
    this.originalContent,
    this.startOffset,
    this.endOffset,
    this.pageTextSha256,
    this.extractionMethod,
    this.confidence,
    this.boundingBoxJson,
    this.editedAt,
    this.reviewedAt,
    this.page,
    this.frame,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['sequence'] = Variable<int>(sequence);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || originalContent != null) {
      map['original_content'] = Variable<String>(originalContent);
    }
    if (!nullToAbsent || startOffset != null) {
      map['start_offset'] = Variable<int>(startOffset);
    }
    if (!nullToAbsent || endOffset != null) {
      map['end_offset'] = Variable<int>(endOffset);
    }
    if (!nullToAbsent || pageTextSha256 != null) {
      map['page_text_sha256'] = Variable<String>(pageTextSha256);
    }
    if (!nullToAbsent || extractionMethod != null) {
      map['extraction_method'] = Variable<String>(extractionMethod);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || boundingBoxJson != null) {
      map['bounding_box_json'] = Variable<String>(boundingBoxJson);
    }
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<DateTime>(editedAt);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    if (!nullToAbsent || page != null) {
      map['page'] = Variable<int>(page);
    }
    if (!nullToAbsent || frame != null) {
      map['frame'] = Variable<int>(frame);
    }
    return map;
  }

  DocumentSegmentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentSegmentsCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      sequence: Value(sequence),
      content: Value(content),
      originalContent: originalContent == null && nullToAbsent
          ? const Value.absent()
          : Value(originalContent),
      startOffset: startOffset == null && nullToAbsent
          ? const Value.absent()
          : Value(startOffset),
      endOffset: endOffset == null && nullToAbsent
          ? const Value.absent()
          : Value(endOffset),
      pageTextSha256: pageTextSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(pageTextSha256),
      extractionMethod: extractionMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(extractionMethod),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      boundingBoxJson: boundingBoxJson == null && nullToAbsent
          ? const Value.absent()
          : Value(boundingBoxJson),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
      page: page == null && nullToAbsent ? const Value.absent() : Value(page),
      frame: frame == null && nullToAbsent
          ? const Value.absent()
          : Value(frame),
    );
  }

  factory DocumentSegmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentSegmentRow(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      content: serializer.fromJson<String>(json['content']),
      originalContent: serializer.fromJson<String?>(json['originalContent']),
      startOffset: serializer.fromJson<int?>(json['startOffset']),
      endOffset: serializer.fromJson<int?>(json['endOffset']),
      pageTextSha256: serializer.fromJson<String?>(json['pageTextSha256']),
      extractionMethod: serializer.fromJson<String?>(json['extractionMethod']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      boundingBoxJson: serializer.fromJson<String?>(json['boundingBoxJson']),
      editedAt: serializer.fromJson<DateTime?>(json['editedAt']),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
      page: serializer.fromJson<int?>(json['page']),
      frame: serializer.fromJson<int?>(json['frame']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'sequence': serializer.toJson<int>(sequence),
      'content': serializer.toJson<String>(content),
      'originalContent': serializer.toJson<String?>(originalContent),
      'startOffset': serializer.toJson<int?>(startOffset),
      'endOffset': serializer.toJson<int?>(endOffset),
      'pageTextSha256': serializer.toJson<String?>(pageTextSha256),
      'extractionMethod': serializer.toJson<String?>(extractionMethod),
      'confidence': serializer.toJson<double?>(confidence),
      'boundingBoxJson': serializer.toJson<String?>(boundingBoxJson),
      'editedAt': serializer.toJson<DateTime?>(editedAt),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
      'page': serializer.toJson<int?>(page),
      'frame': serializer.toJson<int?>(frame),
    };
  }

  DocumentSegmentRow copyWith({
    String? id,
    String? sourceId,
    int? sequence,
    String? content,
    Value<String?> originalContent = const Value.absent(),
    Value<int?> startOffset = const Value.absent(),
    Value<int?> endOffset = const Value.absent(),
    Value<String?> pageTextSha256 = const Value.absent(),
    Value<String?> extractionMethod = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    Value<String?> boundingBoxJson = const Value.absent(),
    Value<DateTime?> editedAt = const Value.absent(),
    Value<DateTime?> reviewedAt = const Value.absent(),
    Value<int?> page = const Value.absent(),
    Value<int?> frame = const Value.absent(),
  }) => DocumentSegmentRow(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    sequence: sequence ?? this.sequence,
    content: content ?? this.content,
    originalContent: originalContent.present
        ? originalContent.value
        : this.originalContent,
    startOffset: startOffset.present ? startOffset.value : this.startOffset,
    endOffset: endOffset.present ? endOffset.value : this.endOffset,
    pageTextSha256: pageTextSha256.present
        ? pageTextSha256.value
        : this.pageTextSha256,
    extractionMethod: extractionMethod.present
        ? extractionMethod.value
        : this.extractionMethod,
    confidence: confidence.present ? confidence.value : this.confidence,
    boundingBoxJson: boundingBoxJson.present
        ? boundingBoxJson.value
        : this.boundingBoxJson,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
    page: page.present ? page.value : this.page,
    frame: frame.present ? frame.value : this.frame,
  );
  DocumentSegmentRow copyWithCompanion(DocumentSegmentsCompanion data) {
    return DocumentSegmentRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      content: data.content.present ? data.content.value : this.content,
      originalContent: data.originalContent.present
          ? data.originalContent.value
          : this.originalContent,
      startOffset: data.startOffset.present
          ? data.startOffset.value
          : this.startOffset,
      endOffset: data.endOffset.present ? data.endOffset.value : this.endOffset,
      pageTextSha256: data.pageTextSha256.present
          ? data.pageTextSha256.value
          : this.pageTextSha256,
      extractionMethod: data.extractionMethod.present
          ? data.extractionMethod.value
          : this.extractionMethod,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      boundingBoxJson: data.boundingBoxJson.present
          ? data.boundingBoxJson.value
          : this.boundingBoxJson,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      page: data.page.present ? data.page.value : this.page,
      frame: data.frame.present ? data.frame.value : this.frame,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentSegmentRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('sequence: $sequence, ')
          ..write('content: $content, ')
          ..write('originalContent: $originalContent, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset, ')
          ..write('pageTextSha256: $pageTextSha256, ')
          ..write('extractionMethod: $extractionMethod, ')
          ..write('confidence: $confidence, ')
          ..write('boundingBoxJson: $boundingBoxJson, ')
          ..write('editedAt: $editedAt, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('page: $page, ')
          ..write('frame: $frame')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    sequence,
    content,
    originalContent,
    startOffset,
    endOffset,
    pageTextSha256,
    extractionMethod,
    confidence,
    boundingBoxJson,
    editedAt,
    reviewedAt,
    page,
    frame,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentSegmentRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.sequence == this.sequence &&
          other.content == this.content &&
          other.originalContent == this.originalContent &&
          other.startOffset == this.startOffset &&
          other.endOffset == this.endOffset &&
          other.pageTextSha256 == this.pageTextSha256 &&
          other.extractionMethod == this.extractionMethod &&
          other.confidence == this.confidence &&
          other.boundingBoxJson == this.boundingBoxJson &&
          other.editedAt == this.editedAt &&
          other.reviewedAt == this.reviewedAt &&
          other.page == this.page &&
          other.frame == this.frame);
}

class DocumentSegmentsCompanion extends UpdateCompanion<DocumentSegmentRow> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<int> sequence;
  final Value<String> content;
  final Value<String?> originalContent;
  final Value<int?> startOffset;
  final Value<int?> endOffset;
  final Value<String?> pageTextSha256;
  final Value<String?> extractionMethod;
  final Value<double?> confidence;
  final Value<String?> boundingBoxJson;
  final Value<DateTime?> editedAt;
  final Value<DateTime?> reviewedAt;
  final Value<int?> page;
  final Value<int?> frame;
  final Value<int> rowid;
  const DocumentSegmentsCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.content = const Value.absent(),
    this.originalContent = const Value.absent(),
    this.startOffset = const Value.absent(),
    this.endOffset = const Value.absent(),
    this.pageTextSha256 = const Value.absent(),
    this.extractionMethod = const Value.absent(),
    this.confidence = const Value.absent(),
    this.boundingBoxJson = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.page = const Value.absent(),
    this.frame = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentSegmentsCompanion.insert({
    required String id,
    required String sourceId,
    required int sequence,
    required String content,
    this.originalContent = const Value.absent(),
    this.startOffset = const Value.absent(),
    this.endOffset = const Value.absent(),
    this.pageTextSha256 = const Value.absent(),
    this.extractionMethod = const Value.absent(),
    this.confidence = const Value.absent(),
    this.boundingBoxJson = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.page = const Value.absent(),
    this.frame = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       sequence = Value(sequence),
       content = Value(content);
  static Insertable<DocumentSegmentRow> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<int>? sequence,
    Expression<String>? content,
    Expression<String>? originalContent,
    Expression<int>? startOffset,
    Expression<int>? endOffset,
    Expression<String>? pageTextSha256,
    Expression<String>? extractionMethod,
    Expression<double>? confidence,
    Expression<String>? boundingBoxJson,
    Expression<DateTime>? editedAt,
    Expression<DateTime>? reviewedAt,
    Expression<int>? page,
    Expression<int>? frame,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (sequence != null) 'sequence': sequence,
      if (content != null) 'content': content,
      if (originalContent != null) 'original_content': originalContent,
      if (startOffset != null) 'start_offset': startOffset,
      if (endOffset != null) 'end_offset': endOffset,
      if (pageTextSha256 != null) 'page_text_sha256': pageTextSha256,
      if (extractionMethod != null) 'extraction_method': extractionMethod,
      if (confidence != null) 'confidence': confidence,
      if (boundingBoxJson != null) 'bounding_box_json': boundingBoxJson,
      if (editedAt != null) 'edited_at': editedAt,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (page != null) 'page': page,
      if (frame != null) 'frame': frame,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentSegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<int>? sequence,
    Value<String>? content,
    Value<String?>? originalContent,
    Value<int?>? startOffset,
    Value<int?>? endOffset,
    Value<String?>? pageTextSha256,
    Value<String?>? extractionMethod,
    Value<double?>? confidence,
    Value<String?>? boundingBoxJson,
    Value<DateTime?>? editedAt,
    Value<DateTime?>? reviewedAt,
    Value<int?>? page,
    Value<int?>? frame,
    Value<int>? rowid,
  }) {
    return DocumentSegmentsCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      sequence: sequence ?? this.sequence,
      content: content ?? this.content,
      originalContent: originalContent ?? this.originalContent,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      pageTextSha256: pageTextSha256 ?? this.pageTextSha256,
      extractionMethod: extractionMethod ?? this.extractionMethod,
      confidence: confidence ?? this.confidence,
      boundingBoxJson: boundingBoxJson ?? this.boundingBoxJson,
      editedAt: editedAt ?? this.editedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      page: page ?? this.page,
      frame: frame ?? this.frame,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (originalContent.present) {
      map['original_content'] = Variable<String>(originalContent.value);
    }
    if (startOffset.present) {
      map['start_offset'] = Variable<int>(startOffset.value);
    }
    if (endOffset.present) {
      map['end_offset'] = Variable<int>(endOffset.value);
    }
    if (pageTextSha256.present) {
      map['page_text_sha256'] = Variable<String>(pageTextSha256.value);
    }
    if (extractionMethod.present) {
      map['extraction_method'] = Variable<String>(extractionMethod.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (boundingBoxJson.present) {
      map['bounding_box_json'] = Variable<String>(boundingBoxJson.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (frame.present) {
      map['frame'] = Variable<int>(frame.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('sequence: $sequence, ')
          ..write('content: $content, ')
          ..write('originalContent: $originalContent, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset, ')
          ..write('pageTextSha256: $pageTextSha256, ')
          ..write('extractionMethod: $extractionMethod, ')
          ..write('confidence: $confidence, ')
          ..write('boundingBoxJson: $boundingBoxJson, ')
          ..write('editedAt: $editedAt, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('page: $page, ')
          ..write('frame: $frame, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConsentUiSourcesTable extends ConsentUiSources
    with TableInfo<$ConsentUiSourcesTable, ConsentUiSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsentUiSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES document_sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _imageSha256Meta = const VerificationMeta(
    'imageSha256',
  );
  @override
  late final GeneratedColumn<String> imageSha256 = GeneratedColumn<String>(
    'image_sha256',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 64,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frameMeta = const VerificationMeta('frame');
  @override
  late final GeneratedColumn<int> frame = GeneratedColumn<int>(
    'frame',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    imageSha256,
    reviewStatus,
    frame,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consent_ui_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConsentUiSourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('image_sha256')) {
      context.handle(
        _imageSha256Meta,
        imageSha256.isAcceptableOrUnknown(
          data['image_sha256']!,
          _imageSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_imageSha256Meta);
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewStatusMeta);
    }
    if (data.containsKey('frame')) {
      context.handle(
        _frameMeta,
        frame.isAcceptableOrUnknown(data['frame']!, _frameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConsentUiSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConsentUiSourceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      imageSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_sha256'],
      )!,
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      frame: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frame'],
      ),
    );
  }

  @override
  $ConsentUiSourcesTable createAlias(String alias) {
    return $ConsentUiSourcesTable(attachedDatabase, alias);
  }
}

class ConsentUiSourceRow extends DataClass
    implements Insertable<ConsentUiSourceRow> {
  final String id;
  final String sourceId;
  final String imageSha256;
  final String reviewStatus;
  final int? frame;
  const ConsentUiSourceRow({
    required this.id,
    required this.sourceId,
    required this.imageSha256,
    required this.reviewStatus,
    this.frame,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['image_sha256'] = Variable<String>(imageSha256);
    map['review_status'] = Variable<String>(reviewStatus);
    if (!nullToAbsent || frame != null) {
      map['frame'] = Variable<int>(frame);
    }
    return map;
  }

  ConsentUiSourcesCompanion toCompanion(bool nullToAbsent) {
    return ConsentUiSourcesCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      imageSha256: Value(imageSha256),
      reviewStatus: Value(reviewStatus),
      frame: frame == null && nullToAbsent
          ? const Value.absent()
          : Value(frame),
    );
  }

  factory ConsentUiSourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConsentUiSourceRow(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      imageSha256: serializer.fromJson<String>(json['imageSha256']),
      reviewStatus: serializer.fromJson<String>(json['reviewStatus']),
      frame: serializer.fromJson<int?>(json['frame']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'imageSha256': serializer.toJson<String>(imageSha256),
      'reviewStatus': serializer.toJson<String>(reviewStatus),
      'frame': serializer.toJson<int?>(frame),
    };
  }

  ConsentUiSourceRow copyWith({
    String? id,
    String? sourceId,
    String? imageSha256,
    String? reviewStatus,
    Value<int?> frame = const Value.absent(),
  }) => ConsentUiSourceRow(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    imageSha256: imageSha256 ?? this.imageSha256,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    frame: frame.present ? frame.value : this.frame,
  );
  ConsentUiSourceRow copyWithCompanion(ConsentUiSourcesCompanion data) {
    return ConsentUiSourceRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      imageSha256: data.imageSha256.present
          ? data.imageSha256.value
          : this.imageSha256,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      frame: data.frame.present ? data.frame.value : this.frame,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConsentUiSourceRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('imageSha256: $imageSha256, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('frame: $frame')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sourceId, imageSha256, reviewStatus, frame);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsentUiSourceRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.imageSha256 == this.imageSha256 &&
          other.reviewStatus == this.reviewStatus &&
          other.frame == this.frame);
}

class ConsentUiSourcesCompanion extends UpdateCompanion<ConsentUiSourceRow> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String> imageSha256;
  final Value<String> reviewStatus;
  final Value<int?> frame;
  final Value<int> rowid;
  const ConsentUiSourcesCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.imageSha256 = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.frame = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsentUiSourcesCompanion.insert({
    required String id,
    required String sourceId,
    required String imageSha256,
    required String reviewStatus,
    this.frame = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       imageSha256 = Value(imageSha256),
       reviewStatus = Value(reviewStatus);
  static Insertable<ConsentUiSourceRow> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? imageSha256,
    Expression<String>? reviewStatus,
    Expression<int>? frame,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (imageSha256 != null) 'image_sha256': imageSha256,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (frame != null) 'frame': frame,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsentUiSourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<String>? imageSha256,
    Value<String>? reviewStatus,
    Value<int?>? frame,
    Value<int>? rowid,
  }) {
    return ConsentUiSourcesCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      imageSha256: imageSha256 ?? this.imageSha256,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      frame: frame ?? this.frame,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (imageSha256.present) {
      map['image_sha256'] = Variable<String>(imageSha256.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (frame.present) {
      map['frame'] = Variable<int>(frame.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsentUiSourcesCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('imageSha256: $imageSha256, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('frame: $frame, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EvidenceReferencesTable extends EvidenceReferences
    with TableInfo<$EvidenceReferencesTable, EvidenceReferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidenceReferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
    'audit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audit_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document_sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _segmentIdMeta = const VerificationMeta(
    'segmentId',
  );
  @override
  late final GeneratedColumn<String> segmentId = GeneratedColumn<String>(
    'segment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document_segments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceSha256Meta = const VerificationMeta(
    'sourceSha256',
  );
  @override
  late final GeneratedColumn<String> sourceSha256 = GeneratedColumn<String>(
    'source_sha256',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 64,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteMeta = const VerificationMeta('quote');
  @override
  late final GeneratedColumn<String> quote = GeneratedColumn<String>(
    'quote',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    auditId,
    sourceId,
    segmentId,
    sourceSha256,
    location,
    quote,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidence_references';
  @override
  VerificationContext validateIntegrity(
    Insertable<EvidenceReferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    } else if (isInserting) {
      context.missing(_auditIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('segment_id')) {
      context.handle(
        _segmentIdMeta,
        segmentId.isAcceptableOrUnknown(data['segment_id']!, _segmentIdMeta),
      );
    }
    if (data.containsKey('source_sha256')) {
      context.handle(
        _sourceSha256Meta,
        sourceSha256.isAcceptableOrUnknown(
          data['source_sha256']!,
          _sourceSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceSha256Meta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('quote')) {
      context.handle(
        _quoteMeta,
        quote.isAcceptableOrUnknown(data['quote']!, _quoteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EvidenceReferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvidenceReferenceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      segmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segment_id'],
      ),
      sourceSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_sha256'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      quote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote'],
      ),
    );
  }

  @override
  $EvidenceReferencesTable createAlias(String alias) {
    return $EvidenceReferencesTable(attachedDatabase, alias);
  }
}

class EvidenceReferenceRow extends DataClass
    implements Insertable<EvidenceReferenceRow> {
  final String id;
  final String auditId;
  final String sourceId;
  final String? segmentId;
  final String sourceSha256;
  final String location;
  final String? quote;
  const EvidenceReferenceRow({
    required this.id,
    required this.auditId,
    required this.sourceId,
    this.segmentId,
    required this.sourceSha256,
    required this.location,
    this.quote,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['audit_id'] = Variable<String>(auditId);
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || segmentId != null) {
      map['segment_id'] = Variable<String>(segmentId);
    }
    map['source_sha256'] = Variable<String>(sourceSha256);
    map['location'] = Variable<String>(location);
    if (!nullToAbsent || quote != null) {
      map['quote'] = Variable<String>(quote);
    }
    return map;
  }

  EvidenceReferencesCompanion toCompanion(bool nullToAbsent) {
    return EvidenceReferencesCompanion(
      id: Value(id),
      auditId: Value(auditId),
      sourceId: Value(sourceId),
      segmentId: segmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(segmentId),
      sourceSha256: Value(sourceSha256),
      location: Value(location),
      quote: quote == null && nullToAbsent
          ? const Value.absent()
          : Value(quote),
    );
  }

  factory EvidenceReferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvidenceReferenceRow(
      id: serializer.fromJson<String>(json['id']),
      auditId: serializer.fromJson<String>(json['auditId']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      segmentId: serializer.fromJson<String?>(json['segmentId']),
      sourceSha256: serializer.fromJson<String>(json['sourceSha256']),
      location: serializer.fromJson<String>(json['location']),
      quote: serializer.fromJson<String?>(json['quote']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'auditId': serializer.toJson<String>(auditId),
      'sourceId': serializer.toJson<String>(sourceId),
      'segmentId': serializer.toJson<String?>(segmentId),
      'sourceSha256': serializer.toJson<String>(sourceSha256),
      'location': serializer.toJson<String>(location),
      'quote': serializer.toJson<String?>(quote),
    };
  }

  EvidenceReferenceRow copyWith({
    String? id,
    String? auditId,
    String? sourceId,
    Value<String?> segmentId = const Value.absent(),
    String? sourceSha256,
    String? location,
    Value<String?> quote = const Value.absent(),
  }) => EvidenceReferenceRow(
    id: id ?? this.id,
    auditId: auditId ?? this.auditId,
    sourceId: sourceId ?? this.sourceId,
    segmentId: segmentId.present ? segmentId.value : this.segmentId,
    sourceSha256: sourceSha256 ?? this.sourceSha256,
    location: location ?? this.location,
    quote: quote.present ? quote.value : this.quote,
  );
  EvidenceReferenceRow copyWithCompanion(EvidenceReferencesCompanion data) {
    return EvidenceReferenceRow(
      id: data.id.present ? data.id.value : this.id,
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      segmentId: data.segmentId.present ? data.segmentId.value : this.segmentId,
      sourceSha256: data.sourceSha256.present
          ? data.sourceSha256.value
          : this.sourceSha256,
      location: data.location.present ? data.location.value : this.location,
      quote: data.quote.present ? data.quote.value : this.quote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceReferenceRow(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('sourceId: $sourceId, ')
          ..write('segmentId: $segmentId, ')
          ..write('sourceSha256: $sourceSha256, ')
          ..write('location: $location, ')
          ..write('quote: $quote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    auditId,
    sourceId,
    segmentId,
    sourceSha256,
    location,
    quote,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvidenceReferenceRow &&
          other.id == this.id &&
          other.auditId == this.auditId &&
          other.sourceId == this.sourceId &&
          other.segmentId == this.segmentId &&
          other.sourceSha256 == this.sourceSha256 &&
          other.location == this.location &&
          other.quote == this.quote);
}

class EvidenceReferencesCompanion
    extends UpdateCompanion<EvidenceReferenceRow> {
  final Value<String> id;
  final Value<String> auditId;
  final Value<String> sourceId;
  final Value<String?> segmentId;
  final Value<String> sourceSha256;
  final Value<String> location;
  final Value<String?> quote;
  final Value<int> rowid;
  const EvidenceReferencesCompanion({
    this.id = const Value.absent(),
    this.auditId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.segmentId = const Value.absent(),
    this.sourceSha256 = const Value.absent(),
    this.location = const Value.absent(),
    this.quote = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EvidenceReferencesCompanion.insert({
    required String id,
    required String auditId,
    required String sourceId,
    this.segmentId = const Value.absent(),
    required String sourceSha256,
    required String location,
    this.quote = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       auditId = Value(auditId),
       sourceId = Value(sourceId),
       sourceSha256 = Value(sourceSha256),
       location = Value(location);
  static Insertable<EvidenceReferenceRow> custom({
    Expression<String>? id,
    Expression<String>? auditId,
    Expression<String>? sourceId,
    Expression<String>? segmentId,
    Expression<String>? sourceSha256,
    Expression<String>? location,
    Expression<String>? quote,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (auditId != null) 'audit_id': auditId,
      if (sourceId != null) 'source_id': sourceId,
      if (segmentId != null) 'segment_id': segmentId,
      if (sourceSha256 != null) 'source_sha256': sourceSha256,
      if (location != null) 'location': location,
      if (quote != null) 'quote': quote,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EvidenceReferencesCompanion copyWith({
    Value<String>? id,
    Value<String>? auditId,
    Value<String>? sourceId,
    Value<String?>? segmentId,
    Value<String>? sourceSha256,
    Value<String>? location,
    Value<String?>? quote,
    Value<int>? rowid,
  }) {
    return EvidenceReferencesCompanion(
      id: id ?? this.id,
      auditId: auditId ?? this.auditId,
      sourceId: sourceId ?? this.sourceId,
      segmentId: segmentId ?? this.segmentId,
      sourceSha256: sourceSha256 ?? this.sourceSha256,
      location: location ?? this.location,
      quote: quote ?? this.quote,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (segmentId.present) {
      map['segment_id'] = Variable<String>(segmentId.value);
    }
    if (sourceSha256.present) {
      map['source_sha256'] = Variable<String>(sourceSha256.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (quote.present) {
      map['quote'] = Variable<String>(quote.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceReferencesCompanion(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('sourceId: $sourceId, ')
          ..write('segmentId: $segmentId, ')
          ..write('sourceSha256: $sourceSha256, ')
          ..write('location: $location, ')
          ..write('quote: $quote, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserActionsTable extends UserActions
    with TableInfo<$UserActionsTable, UserActionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
    'audit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audit_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document_sources (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    auditId,
    sourceId,
    actionType,
    details,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserActionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    } else if (isInserting) {
      context.missing(_auditIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserActionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserActionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserActionsTable createAlias(String alias) {
    return $UserActionsTable(attachedDatabase, alias);
  }
}

class UserActionRow extends DataClass implements Insertable<UserActionRow> {
  final String id;
  final String auditId;
  final String? sourceId;
  final String actionType;
  final String? details;
  final DateTime createdAt;
  const UserActionRow({
    required this.id,
    required this.auditId,
    this.sourceId,
    required this.actionType,
    this.details,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['audit_id'] = Variable<String>(auditId);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['action_type'] = Variable<String>(actionType);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserActionsCompanion toCompanion(bool nullToAbsent) {
    return UserActionsCompanion(
      id: Value(id),
      auditId: Value(auditId),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      actionType: Value(actionType),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      createdAt: Value(createdAt),
    );
  }

  factory UserActionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserActionRow(
      id: serializer.fromJson<String>(json['id']),
      auditId: serializer.fromJson<String>(json['auditId']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      actionType: serializer.fromJson<String>(json['actionType']),
      details: serializer.fromJson<String?>(json['details']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'auditId': serializer.toJson<String>(auditId),
      'sourceId': serializer.toJson<String?>(sourceId),
      'actionType': serializer.toJson<String>(actionType),
      'details': serializer.toJson<String?>(details),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserActionRow copyWith({
    String? id,
    String? auditId,
    Value<String?> sourceId = const Value.absent(),
    String? actionType,
    Value<String?> details = const Value.absent(),
    DateTime? createdAt,
  }) => UserActionRow(
    id: id ?? this.id,
    auditId: auditId ?? this.auditId,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    actionType: actionType ?? this.actionType,
    details: details.present ? details.value : this.details,
    createdAt: createdAt ?? this.createdAt,
  );
  UserActionRow copyWithCompanion(UserActionsCompanion data) {
    return UserActionRow(
      id: data.id.present ? data.id.value : this.id,
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      details: data.details.present ? data.details.value : this.details,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserActionRow(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('sourceId: $sourceId, ')
          ..write('actionType: $actionType, ')
          ..write('details: $details, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, auditId, sourceId, actionType, details, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserActionRow &&
          other.id == this.id &&
          other.auditId == this.auditId &&
          other.sourceId == this.sourceId &&
          other.actionType == this.actionType &&
          other.details == this.details &&
          other.createdAt == this.createdAt);
}

class UserActionsCompanion extends UpdateCompanion<UserActionRow> {
  final Value<String> id;
  final Value<String> auditId;
  final Value<String?> sourceId;
  final Value<String> actionType;
  final Value<String?> details;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserActionsCompanion({
    this.id = const Value.absent(),
    this.auditId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.actionType = const Value.absent(),
    this.details = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserActionsCompanion.insert({
    required String id,
    required String auditId,
    this.sourceId = const Value.absent(),
    required String actionType,
    this.details = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       auditId = Value(auditId),
       actionType = Value(actionType),
       createdAt = Value(createdAt);
  static Insertable<UserActionRow> custom({
    Expression<String>? id,
    Expression<String>? auditId,
    Expression<String>? sourceId,
    Expression<String>? actionType,
    Expression<String>? details,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (auditId != null) 'audit_id': auditId,
      if (sourceId != null) 'source_id': sourceId,
      if (actionType != null) 'action_type': actionType,
      if (details != null) 'details': details,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserActionsCompanion copyWith({
    Value<String>? id,
    Value<String>? auditId,
    Value<String?>? sourceId,
    Value<String>? actionType,
    Value<String?>? details,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UserActionsCompanion(
      id: id ?? this.id,
      auditId: auditId ?? this.auditId,
      sourceId: sourceId ?? this.sourceId,
      actionType: actionType ?? this.actionType,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserActionsCompanion(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('sourceId: $sourceId, ')
          ..write('actionType: $actionType, ')
          ..write('details: $details, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnalysisRunsTable extends AnalysisRuns
    with TableInfo<$AnalysisRunsTable, AnalysisRunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalysisRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
    'audit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audit_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (status IN (\'unavailable\', \'queued\', \'running\', \'failed\'))',
  );
  static const VerificationMeta _engineMeta = const VerificationMeta('engine');
  @override
  late final GeneratedColumn<String> engine = GeneratedColumn<String>(
    'engine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdsJsonMeta = const VerificationMeta(
    'sourceIdsJson',
  );
  @override
  late final GeneratedColumn<String> sourceIdsJson = GeneratedColumn<String>(
    'source_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    auditId,
    status,
    engine,
    reason,
    sourceIdsJson,
    modelVersion,
    createdAt,
    finishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analysis_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnalysisRunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    } else if (isInserting) {
      context.missing(_auditIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('engine')) {
      context.handle(
        _engineMeta,
        engine.isAcceptableOrUnknown(data['engine']!, _engineMeta),
      );
    } else if (isInserting) {
      context.missing(_engineMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('source_ids_json')) {
      context.handle(
        _sourceIdsJsonMeta,
        sourceIdsJson.isAcceptableOrUnknown(
          data['source_ids_json']!,
          _sourceIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceIdsJsonMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnalysisRunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalysisRunRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      engine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      sourceIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ids_json'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
    );
  }

  @override
  $AnalysisRunsTable createAlias(String alias) {
    return $AnalysisRunsTable(attachedDatabase, alias);
  }
}

class AnalysisRunRow extends DataClass implements Insertable<AnalysisRunRow> {
  final String id;
  final String auditId;
  final String status;
  final String engine;
  final String reason;
  final String sourceIdsJson;
  final String? modelVersion;
  final DateTime createdAt;
  final DateTime? finishedAt;
  const AnalysisRunRow({
    required this.id,
    required this.auditId,
    required this.status,
    required this.engine,
    required this.reason,
    required this.sourceIdsJson,
    this.modelVersion,
    required this.createdAt,
    this.finishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['audit_id'] = Variable<String>(auditId);
    map['status'] = Variable<String>(status);
    map['engine'] = Variable<String>(engine);
    map['reason'] = Variable<String>(reason);
    map['source_ids_json'] = Variable<String>(sourceIdsJson);
    if (!nullToAbsent || modelVersion != null) {
      map['model_version'] = Variable<String>(modelVersion);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    return map;
  }

  AnalysisRunsCompanion toCompanion(bool nullToAbsent) {
    return AnalysisRunsCompanion(
      id: Value(id),
      auditId: Value(auditId),
      status: Value(status),
      engine: Value(engine),
      reason: Value(reason),
      sourceIdsJson: Value(sourceIdsJson),
      modelVersion: modelVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(modelVersion),
      createdAt: Value(createdAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
    );
  }

  factory AnalysisRunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalysisRunRow(
      id: serializer.fromJson<String>(json['id']),
      auditId: serializer.fromJson<String>(json['auditId']),
      status: serializer.fromJson<String>(json['status']),
      engine: serializer.fromJson<String>(json['engine']),
      reason: serializer.fromJson<String>(json['reason']),
      sourceIdsJson: serializer.fromJson<String>(json['sourceIdsJson']),
      modelVersion: serializer.fromJson<String?>(json['modelVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'auditId': serializer.toJson<String>(auditId),
      'status': serializer.toJson<String>(status),
      'engine': serializer.toJson<String>(engine),
      'reason': serializer.toJson<String>(reason),
      'sourceIdsJson': serializer.toJson<String>(sourceIdsJson),
      'modelVersion': serializer.toJson<String?>(modelVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
    };
  }

  AnalysisRunRow copyWith({
    String? id,
    String? auditId,
    String? status,
    String? engine,
    String? reason,
    String? sourceIdsJson,
    Value<String?> modelVersion = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> finishedAt = const Value.absent(),
  }) => AnalysisRunRow(
    id: id ?? this.id,
    auditId: auditId ?? this.auditId,
    status: status ?? this.status,
    engine: engine ?? this.engine,
    reason: reason ?? this.reason,
    sourceIdsJson: sourceIdsJson ?? this.sourceIdsJson,
    modelVersion: modelVersion.present ? modelVersion.value : this.modelVersion,
    createdAt: createdAt ?? this.createdAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
  );
  AnalysisRunRow copyWithCompanion(AnalysisRunsCompanion data) {
    return AnalysisRunRow(
      id: data.id.present ? data.id.value : this.id,
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      status: data.status.present ? data.status.value : this.status,
      engine: data.engine.present ? data.engine.value : this.engine,
      reason: data.reason.present ? data.reason.value : this.reason,
      sourceIdsJson: data.sourceIdsJson.present
          ? data.sourceIdsJson.value
          : this.sourceIdsJson,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalysisRunRow(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('status: $status, ')
          ..write('engine: $engine, ')
          ..write('reason: $reason, ')
          ..write('sourceIdsJson: $sourceIdsJson, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    auditId,
    status,
    engine,
    reason,
    sourceIdsJson,
    modelVersion,
    createdAt,
    finishedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalysisRunRow &&
          other.id == this.id &&
          other.auditId == this.auditId &&
          other.status == this.status &&
          other.engine == this.engine &&
          other.reason == this.reason &&
          other.sourceIdsJson == this.sourceIdsJson &&
          other.modelVersion == this.modelVersion &&
          other.createdAt == this.createdAt &&
          other.finishedAt == this.finishedAt);
}

class AnalysisRunsCompanion extends UpdateCompanion<AnalysisRunRow> {
  final Value<String> id;
  final Value<String> auditId;
  final Value<String> status;
  final Value<String> engine;
  final Value<String> reason;
  final Value<String> sourceIdsJson;
  final Value<String?> modelVersion;
  final Value<DateTime> createdAt;
  final Value<DateTime?> finishedAt;
  final Value<int> rowid;
  const AnalysisRunsCompanion({
    this.id = const Value.absent(),
    this.auditId = const Value.absent(),
    this.status = const Value.absent(),
    this.engine = const Value.absent(),
    this.reason = const Value.absent(),
    this.sourceIdsJson = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnalysisRunsCompanion.insert({
    required String id,
    required String auditId,
    required String status,
    required String engine,
    required String reason,
    required String sourceIdsJson,
    this.modelVersion = const Value.absent(),
    required DateTime createdAt,
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       auditId = Value(auditId),
       status = Value(status),
       engine = Value(engine),
       reason = Value(reason),
       sourceIdsJson = Value(sourceIdsJson),
       createdAt = Value(createdAt);
  static Insertable<AnalysisRunRow> custom({
    Expression<String>? id,
    Expression<String>? auditId,
    Expression<String>? status,
    Expression<String>? engine,
    Expression<String>? reason,
    Expression<String>? sourceIdsJson,
    Expression<String>? modelVersion,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (auditId != null) 'audit_id': auditId,
      if (status != null) 'status': status,
      if (engine != null) 'engine': engine,
      if (reason != null) 'reason': reason,
      if (sourceIdsJson != null) 'source_ids_json': sourceIdsJson,
      if (modelVersion != null) 'model_version': modelVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnalysisRunsCompanion copyWith({
    Value<String>? id,
    Value<String>? auditId,
    Value<String>? status,
    Value<String>? engine,
    Value<String>? reason,
    Value<String>? sourceIdsJson,
    Value<String?>? modelVersion,
    Value<DateTime>? createdAt,
    Value<DateTime?>? finishedAt,
    Value<int>? rowid,
  }) {
    return AnalysisRunsCompanion(
      id: id ?? this.id,
      auditId: auditId ?? this.auditId,
      status: status ?? this.status,
      engine: engine ?? this.engine,
      reason: reason ?? this.reason,
      sourceIdsJson: sourceIdsJson ?? this.sourceIdsJson,
      modelVersion: modelVersion ?? this.modelVersion,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (engine.present) {
      map['engine'] = Variable<String>(engine.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (sourceIdsJson.present) {
      map['source_ids_json'] = Variable<String>(sourceIdsJson.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalysisRunsCompanion(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('status: $status, ')
          ..write('engine: $engine, ')
          ..write('reason: $reason, ')
          ..write('sourceIdsJson: $sourceIdsJson, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReportRecordsTable extends ReportRecords
    with TableInfo<$ReportRecordsTable, ReportRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
    'audit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audit_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentSha256Meta = const VerificationMeta(
    'contentSha256',
  );
  @override
  late final GeneratedColumn<String> contentSha256 = GeneratedColumn<String>(
    'content_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    auditId,
    status,
    localPath,
    contentSha256,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'report_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReportRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    } else if (isInserting) {
      context.missing(_auditIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('content_sha256')) {
      context.handle(
        _contentSha256Meta,
        contentSha256.isAcceptableOrUnknown(
          data['content_sha256']!,
          _contentSha256Meta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      contentSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_sha256'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReportRecordsTable createAlias(String alias) {
    return $ReportRecordsTable(attachedDatabase, alias);
  }
}

class ReportRecordRow extends DataClass implements Insertable<ReportRecordRow> {
  final String id;
  final String auditId;
  final String status;
  final String? localPath;
  final String? contentSha256;
  final DateTime createdAt;
  const ReportRecordRow({
    required this.id,
    required this.auditId,
    required this.status,
    this.localPath,
    this.contentSha256,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['audit_id'] = Variable<String>(auditId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || contentSha256 != null) {
      map['content_sha256'] = Variable<String>(contentSha256);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReportRecordsCompanion toCompanion(bool nullToAbsent) {
    return ReportRecordsCompanion(
      id: Value(id),
      auditId: Value(auditId),
      status: Value(status),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      contentSha256: contentSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(contentSha256),
      createdAt: Value(createdAt),
    );
  }

  factory ReportRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportRecordRow(
      id: serializer.fromJson<String>(json['id']),
      auditId: serializer.fromJson<String>(json['auditId']),
      status: serializer.fromJson<String>(json['status']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      contentSha256: serializer.fromJson<String?>(json['contentSha256']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'auditId': serializer.toJson<String>(auditId),
      'status': serializer.toJson<String>(status),
      'localPath': serializer.toJson<String?>(localPath),
      'contentSha256': serializer.toJson<String?>(contentSha256),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReportRecordRow copyWith({
    String? id,
    String? auditId,
    String? status,
    Value<String?> localPath = const Value.absent(),
    Value<String?> contentSha256 = const Value.absent(),
    DateTime? createdAt,
  }) => ReportRecordRow(
    id: id ?? this.id,
    auditId: auditId ?? this.auditId,
    status: status ?? this.status,
    localPath: localPath.present ? localPath.value : this.localPath,
    contentSha256: contentSha256.present
        ? contentSha256.value
        : this.contentSha256,
    createdAt: createdAt ?? this.createdAt,
  );
  ReportRecordRow copyWithCompanion(ReportRecordsCompanion data) {
    return ReportRecordRow(
      id: data.id.present ? data.id.value : this.id,
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      status: data.status.present ? data.status.value : this.status,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      contentSha256: data.contentSha256.present
          ? data.contentSha256.value
          : this.contentSha256,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportRecordRow(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('status: $status, ')
          ..write('localPath: $localPath, ')
          ..write('contentSha256: $contentSha256, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, auditId, status, localPath, contentSha256, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportRecordRow &&
          other.id == this.id &&
          other.auditId == this.auditId &&
          other.status == this.status &&
          other.localPath == this.localPath &&
          other.contentSha256 == this.contentSha256 &&
          other.createdAt == this.createdAt);
}

class ReportRecordsCompanion extends UpdateCompanion<ReportRecordRow> {
  final Value<String> id;
  final Value<String> auditId;
  final Value<String> status;
  final Value<String?> localPath;
  final Value<String?> contentSha256;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReportRecordsCompanion({
    this.id = const Value.absent(),
    this.auditId = const Value.absent(),
    this.status = const Value.absent(),
    this.localPath = const Value.absent(),
    this.contentSha256 = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReportRecordsCompanion.insert({
    required String id,
    required String auditId,
    required String status,
    this.localPath = const Value.absent(),
    this.contentSha256 = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       auditId = Value(auditId),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<ReportRecordRow> custom({
    Expression<String>? id,
    Expression<String>? auditId,
    Expression<String>? status,
    Expression<String>? localPath,
    Expression<String>? contentSha256,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (auditId != null) 'audit_id': auditId,
      if (status != null) 'status': status,
      if (localPath != null) 'local_path': localPath,
      if (contentSha256 != null) 'content_sha256': contentSha256,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReportRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? auditId,
    Value<String>? status,
    Value<String?>? localPath,
    Value<String?>? contentSha256,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReportRecordsCompanion(
      id: id ?? this.id,
      auditId: auditId ?? this.auditId,
      status: status ?? this.status,
      localPath: localPath ?? this.localPath,
      contentSha256: contentSha256 ?? this.contentSha256,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (contentSha256.present) {
      map['content_sha256'] = Variable<String>(contentSha256.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportRecordsCompanion(')
          ..write('id: $id, ')
          ..write('auditId: $auditId, ')
          ..write('status: $status, ')
          ..write('localPath: $localPath, ')
          ..write('contentSha256: $contentSha256, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrivacyPreferenceRowsTable extends PrivacyPreferenceRows
    with TableInfo<$PrivacyPreferenceRowsTable, PrivacyPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrivacyPreferenceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cloudOptInMeta = const VerificationMeta(
    'cloudOptIn',
  );
  @override
  late final GeneratedColumn<bool> cloudOptIn = GeneratedColumn<bool>(
    'cloud_opt_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cloud_opt_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _analyticsOptInMeta = const VerificationMeta(
    'analyticsOptIn',
  );
  @override
  late final GeneratedColumn<bool> analyticsOptIn = GeneratedColumn<bool>(
    'analytics_opt_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("analytics_opt_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudOptIn,
    analyticsOptIn,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'privacy_preference_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrivacyPreferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_opt_in')) {
      context.handle(
        _cloudOptInMeta,
        cloudOptIn.isAcceptableOrUnknown(
          data['cloud_opt_in']!,
          _cloudOptInMeta,
        ),
      );
    }
    if (data.containsKey('analytics_opt_in')) {
      context.handle(
        _analyticsOptInMeta,
        analyticsOptIn.isAcceptableOrUnknown(
          data['analytics_opt_in']!,
          _analyticsOptInMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrivacyPreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrivacyPreferenceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cloudOptIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cloud_opt_in'],
      )!,
      analyticsOptIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}analytics_opt_in'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PrivacyPreferenceRowsTable createAlias(String alias) {
    return $PrivacyPreferenceRowsTable(attachedDatabase, alias);
  }
}

class PrivacyPreferenceRow extends DataClass
    implements Insertable<PrivacyPreferenceRow> {
  final int id;
  final bool cloudOptIn;
  final bool analyticsOptIn;
  final DateTime updatedAt;
  const PrivacyPreferenceRow({
    required this.id,
    required this.cloudOptIn,
    required this.analyticsOptIn,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cloud_opt_in'] = Variable<bool>(cloudOptIn);
    map['analytics_opt_in'] = Variable<bool>(analyticsOptIn);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PrivacyPreferenceRowsCompanion toCompanion(bool nullToAbsent) {
    return PrivacyPreferenceRowsCompanion(
      id: Value(id),
      cloudOptIn: Value(cloudOptIn),
      analyticsOptIn: Value(analyticsOptIn),
      updatedAt: Value(updatedAt),
    );
  }

  factory PrivacyPreferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrivacyPreferenceRow(
      id: serializer.fromJson<int>(json['id']),
      cloudOptIn: serializer.fromJson<bool>(json['cloudOptIn']),
      analyticsOptIn: serializer.fromJson<bool>(json['analyticsOptIn']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudOptIn': serializer.toJson<bool>(cloudOptIn),
      'analyticsOptIn': serializer.toJson<bool>(analyticsOptIn),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PrivacyPreferenceRow copyWith({
    int? id,
    bool? cloudOptIn,
    bool? analyticsOptIn,
    DateTime? updatedAt,
  }) => PrivacyPreferenceRow(
    id: id ?? this.id,
    cloudOptIn: cloudOptIn ?? this.cloudOptIn,
    analyticsOptIn: analyticsOptIn ?? this.analyticsOptIn,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PrivacyPreferenceRow copyWithCompanion(PrivacyPreferenceRowsCompanion data) {
    return PrivacyPreferenceRow(
      id: data.id.present ? data.id.value : this.id,
      cloudOptIn: data.cloudOptIn.present
          ? data.cloudOptIn.value
          : this.cloudOptIn,
      analyticsOptIn: data.analyticsOptIn.present
          ? data.analyticsOptIn.value
          : this.analyticsOptIn,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrivacyPreferenceRow(')
          ..write('id: $id, ')
          ..write('cloudOptIn: $cloudOptIn, ')
          ..write('analyticsOptIn: $analyticsOptIn, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cloudOptIn, analyticsOptIn, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrivacyPreferenceRow &&
          other.id == this.id &&
          other.cloudOptIn == this.cloudOptIn &&
          other.analyticsOptIn == this.analyticsOptIn &&
          other.updatedAt == this.updatedAt);
}

class PrivacyPreferenceRowsCompanion
    extends UpdateCompanion<PrivacyPreferenceRow> {
  final Value<int> id;
  final Value<bool> cloudOptIn;
  final Value<bool> analyticsOptIn;
  final Value<DateTime> updatedAt;
  const PrivacyPreferenceRowsCompanion({
    this.id = const Value.absent(),
    this.cloudOptIn = const Value.absent(),
    this.analyticsOptIn = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PrivacyPreferenceRowsCompanion.insert({
    this.id = const Value.absent(),
    this.cloudOptIn = const Value.absent(),
    this.analyticsOptIn = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<PrivacyPreferenceRow> custom({
    Expression<int>? id,
    Expression<bool>? cloudOptIn,
    Expression<bool>? analyticsOptIn,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudOptIn != null) 'cloud_opt_in': cloudOptIn,
      if (analyticsOptIn != null) 'analytics_opt_in': analyticsOptIn,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PrivacyPreferenceRowsCompanion copyWith({
    Value<int>? id,
    Value<bool>? cloudOptIn,
    Value<bool>? analyticsOptIn,
    Value<DateTime>? updatedAt,
  }) {
    return PrivacyPreferenceRowsCompanion(
      id: id ?? this.id,
      cloudOptIn: cloudOptIn ?? this.cloudOptIn,
      analyticsOptIn: analyticsOptIn ?? this.analyticsOptIn,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudOptIn.present) {
      map['cloud_opt_in'] = Variable<bool>(cloudOptIn.value);
    }
    if (analyticsOptIn.present) {
      map['analytics_opt_in'] = Variable<bool>(analyticsOptIn.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrivacyPreferenceRowsCompanion(')
          ..write('id: $id, ')
          ..write('cloudOptIn: $cloudOptIn, ')
          ..write('analyticsOptIn: $analyticsOptIn, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PendingFileDeletesTable extends PendingFileDeletes
    with TableInfo<$PendingFileDeletesTable, PendingFileDelete> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingFileDeletesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, relativePath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_file_deletes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingFileDelete> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingFileDelete map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingFileDelete(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingFileDeletesTable createAlias(String alias) {
    return $PendingFileDeletesTable(attachedDatabase, alias);
  }
}

class PendingFileDelete extends DataClass
    implements Insertable<PendingFileDelete> {
  final String id;
  final String relativePath;
  final DateTime createdAt;
  const PendingFileDelete({
    required this.id,
    required this.relativePath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['relative_path'] = Variable<String>(relativePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingFileDeletesCompanion toCompanion(bool nullToAbsent) {
    return PendingFileDeletesCompanion(
      id: Value(id),
      relativePath: Value(relativePath),
      createdAt: Value(createdAt),
    );
  }

  factory PendingFileDelete.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingFileDelete(
      id: serializer.fromJson<String>(json['id']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'relativePath': serializer.toJson<String>(relativePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingFileDelete copyWith({
    String? id,
    String? relativePath,
    DateTime? createdAt,
  }) => PendingFileDelete(
    id: id ?? this.id,
    relativePath: relativePath ?? this.relativePath,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingFileDelete copyWithCompanion(PendingFileDeletesCompanion data) {
    return PendingFileDelete(
      id: data.id.present ? data.id.value : this.id,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingFileDelete(')
          ..write('id: $id, ')
          ..write('relativePath: $relativePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, relativePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingFileDelete &&
          other.id == this.id &&
          other.relativePath == this.relativePath &&
          other.createdAt == this.createdAt);
}

class PendingFileDeletesCompanion extends UpdateCompanion<PendingFileDelete> {
  final Value<String> id;
  final Value<String> relativePath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PendingFileDeletesCompanion({
    this.id = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingFileDeletesCompanion.insert({
    required String id,
    required String relativePath,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       relativePath = Value(relativePath),
       createdAt = Value(createdAt);
  static Insertable<PendingFileDelete> custom({
    Expression<String>? id,
    Expression<String>? relativePath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (relativePath != null) 'relative_path': relativePath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingFileDeletesCompanion copyWith({
    Value<String>? id,
    Value<String>? relativePath,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PendingFileDeletesCompanion(
      id: id ?? this.id,
      relativePath: relativePath ?? this.relativePath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingFileDeletesCompanion(')
          ..write('id: $id, ')
          ..write('relativePath: $relativePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AuditSessionsTable auditSessions = $AuditSessionsTable(this);
  late final $ApplicationSnapshotsTable applicationSnapshots =
      $ApplicationSnapshotsTable(this);
  late final $AppPermissionSnapshotsTable appPermissionSnapshots =
      $AppPermissionSnapshotsTable(this);
  late final $DocumentSourcesTable documentSources = $DocumentSourcesTable(
    this,
  );
  late final $DocumentSegmentsTable documentSegments = $DocumentSegmentsTable(
    this,
  );
  late final $ConsentUiSourcesTable consentUiSources = $ConsentUiSourcesTable(
    this,
  );
  late final $EvidenceReferencesTable evidenceReferences =
      $EvidenceReferencesTable(this);
  late final $UserActionsTable userActions = $UserActionsTable(this);
  late final $AnalysisRunsTable analysisRuns = $AnalysisRunsTable(this);
  late final $ReportRecordsTable reportRecords = $ReportRecordsTable(this);
  late final $PrivacyPreferenceRowsTable privacyPreferenceRows =
      $PrivacyPreferenceRowsTable(this);
  late final $PendingFileDeletesTable pendingFileDeletes =
      $PendingFileDeletesTable(this);
  late final Index auditSessionsUpdatedAtIdx = Index(
    'audit_sessions_updated_at_idx',
    'CREATE INDEX audit_sessions_updated_at_idx ON audit_sessions (updated_at)',
  );
  late final Index applicationSnapshotsAuditIdx = Index(
    'application_snapshots_audit_idx',
    'CREATE INDEX application_snapshots_audit_idx ON application_snapshots (audit_id)',
  );
  late final Index permissionSnapshotsAuditIdx = Index(
    'permission_snapshots_audit_idx',
    'CREATE INDEX permission_snapshots_audit_idx ON app_permission_snapshots (audit_id)',
  );
  late final Index documentSourcesAuditIdx = Index(
    'document_sources_audit_idx',
    'CREATE INDEX document_sources_audit_idx ON document_sources (audit_id)',
  );
  late final Index documentSegmentsSourceIdx = Index(
    'document_segments_source_idx',
    'CREATE INDEX document_segments_source_idx ON document_segments (source_id)',
  );
  late final Index evidenceAuditIdx = Index(
    'evidence_audit_idx',
    'CREATE INDEX evidence_audit_idx ON evidence_references (audit_id)',
  );
  late final Index userActionsAuditIdx = Index(
    'user_actions_audit_idx',
    'CREATE INDEX user_actions_audit_idx ON user_actions (audit_id)',
  );
  late final Index analysisRunsAuditIdx = Index(
    'analysis_runs_audit_idx',
    'CREATE INDEX analysis_runs_audit_idx ON analysis_runs (audit_id)',
  );
  late final Index reportsAuditIdx = Index(
    'reports_audit_idx',
    'CREATE INDEX reports_audit_idx ON report_records (audit_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    auditSessions,
    applicationSnapshots,
    appPermissionSnapshots,
    documentSources,
    documentSegments,
    consentUiSources,
    evidenceReferences,
    userActions,
    analysisRuns,
    reportRecords,
    privacyPreferenceRows,
    pendingFileDeletes,
    auditSessionsUpdatedAtIdx,
    applicationSnapshotsAuditIdx,
    permissionSnapshotsAuditIdx,
    documentSourcesAuditIdx,
    documentSegmentsSourceIdx,
    evidenceAuditIdx,
    userActionsAuditIdx,
    analysisRunsAuditIdx,
    reportsAuditIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audit_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('application_snapshots', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audit_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('app_permission_snapshots', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'application_snapshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('app_permission_snapshots', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audit_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_sources', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'document_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_segments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'document_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('consent_ui_sources', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audit_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evidence_references', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'document_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evidence_references', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'document_segments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evidence_references', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audit_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_actions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'document_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_actions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audit_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('analysis_runs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audit_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('report_records', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AuditSessionsTableCreateCompanionBuilder =
    AuditSessionsCompanion Function({
      required String id,
      required String name,
      required String focus,
      required String status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$AuditSessionsTableUpdateCompanionBuilder =
    AuditSessionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> focus,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$AuditSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AuditSessionsTable, AuditSessionRow> {
  $$AuditSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ApplicationSnapshotsTable,
    List<ApplicationSnapshotRow>
  >
  _applicationSnapshotsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.applicationSnapshots,
        aliasName: 'audit_sessions__id__application_snapshots__audit_id',
      );

  $$ApplicationSnapshotsTableProcessedTableManager
  get applicationSnapshotsRefs {
    final manager = $$ApplicationSnapshotsTableTableManager(
      $_db,
      $_db.applicationSnapshots,
    ).filter((f) => f.auditId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _applicationSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AppPermissionSnapshotsTable,
    List<AppPermissionSnapshotRow>
  >
  _appPermissionSnapshotsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.appPermissionSnapshots,
        aliasName: 'audit_sessions__id__app_permission_snapshots__audit_id',
      );

  $$AppPermissionSnapshotsTableProcessedTableManager
  get appPermissionSnapshotsRefs {
    final manager = $$AppPermissionSnapshotsTableTableManager(
      $_db,
      $_db.appPermissionSnapshots,
    ).filter((f) => f.auditId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _appPermissionSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentSourcesTable, List<DocumentSourceRow>>
  _documentSourcesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.documentSources,
    aliasName: 'audit_sessions__id__document_sources__audit_id',
  );

  $$DocumentSourcesTableProcessedTableManager get documentSourcesRefs {
    final manager = $$DocumentSourcesTableTableManager(
      $_db,
      $_db.documentSources,
    ).filter((f) => f.auditId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _documentSourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EvidenceReferencesTable,
    List<EvidenceReferenceRow>
  >
  _evidenceReferencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.evidenceReferences,
        aliasName: 'audit_sessions__id__evidence_references__audit_id',
      );

  $$EvidenceReferencesTableProcessedTableManager get evidenceReferencesRefs {
    final manager = $$EvidenceReferencesTableTableManager(
      $_db,
      $_db.evidenceReferences,
    ).filter((f) => f.auditId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _evidenceReferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserActionsTable, List<UserActionRow>>
  _userActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userActions,
    aliasName: 'audit_sessions__id__user_actions__audit_id',
  );

  $$UserActionsTableProcessedTableManager get userActionsRefs {
    final manager = $$UserActionsTableTableManager(
      $_db,
      $_db.userActions,
    ).filter((f) => f.auditId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userActionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AnalysisRunsTable, List<AnalysisRunRow>>
  _analysisRunsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.analysisRuns,
    aliasName: 'audit_sessions__id__analysis_runs__audit_id',
  );

  $$AnalysisRunsTableProcessedTableManager get analysisRunsRefs {
    final manager = $$AnalysisRunsTableTableManager(
      $_db,
      $_db.analysisRuns,
    ).filter((f) => f.auditId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_analysisRunsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReportRecordsTable, List<ReportRecordRow>>
  _reportRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reportRecords,
    aliasName: 'audit_sessions__id__report_records__audit_id',
  );

  $$ReportRecordsTableProcessedTableManager get reportRecordsRefs {
    final manager = $$ReportRecordsTableTableManager(
      $_db,
      $_db.reportRecords,
    ).filter((f) => f.auditId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reportRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AuditSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditSessionsTable> {
  $$AuditSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> applicationSnapshotsRefs(
    Expression<bool> Function($$ApplicationSnapshotsTableFilterComposer f) f,
  ) {
    final $$ApplicationSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.applicationSnapshots,
      getReferencedColumn: (t) => t.auditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApplicationSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.applicationSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> appPermissionSnapshotsRefs(
    Expression<bool> Function($$AppPermissionSnapshotsTableFilterComposer f) f,
  ) {
    final $$AppPermissionSnapshotsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.appPermissionSnapshots,
          getReferencedColumn: (t) => t.auditId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AppPermissionSnapshotsTableFilterComposer(
                $db: $db,
                $table: $db.appPermissionSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> documentSourcesRefs(
    Expression<bool> Function($$DocumentSourcesTableFilterComposer f) f,
  ) {
    final $$DocumentSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.auditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableFilterComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> evidenceReferencesRefs(
    Expression<bool> Function($$EvidenceReferencesTableFilterComposer f) f,
  ) {
    final $$EvidenceReferencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceReferences,
      getReferencedColumn: (t) => t.auditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceReferencesTableFilterComposer(
            $db: $db,
            $table: $db.evidenceReferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userActionsRefs(
    Expression<bool> Function($$UserActionsTableFilterComposer f) f,
  ) {
    final $$UserActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userActions,
      getReferencedColumn: (t) => t.auditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserActionsTableFilterComposer(
            $db: $db,
            $table: $db.userActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> analysisRunsRefs(
    Expression<bool> Function($$AnalysisRunsTableFilterComposer f) f,
  ) {
    final $$AnalysisRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.analysisRuns,
      getReferencedColumn: (t) => t.auditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnalysisRunsTableFilterComposer(
            $db: $db,
            $table: $db.analysisRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reportRecordsRefs(
    Expression<bool> Function($$ReportRecordsTableFilterComposer f) f,
  ) {
    final $$ReportRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reportRecords,
      getReferencedColumn: (t) => t.auditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReportRecordsTableFilterComposer(
            $db: $db,
            $table: $db.reportRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AuditSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditSessionsTable> {
  $$AuditSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditSessionsTable> {
  $$AuditSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get focus =>
      $composableBuilder(column: $table.focus, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> applicationSnapshotsRefs<T extends Object>(
    Expression<T> Function($$ApplicationSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$ApplicationSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.applicationSnapshots,
          getReferencedColumn: (t) => t.auditId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ApplicationSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.applicationSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> appPermissionSnapshotsRefs<T extends Object>(
    Expression<T> Function($$AppPermissionSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$AppPermissionSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.appPermissionSnapshots,
          getReferencedColumn: (t) => t.auditId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AppPermissionSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.appPermissionSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> documentSourcesRefs<T extends Object>(
    Expression<T> Function($$DocumentSourcesTableAnnotationComposer a) f,
  ) {
    final $$DocumentSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.auditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> evidenceReferencesRefs<T extends Object>(
    Expression<T> Function($$EvidenceReferencesTableAnnotationComposer a) f,
  ) {
    final $$EvidenceReferencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.evidenceReferences,
          getReferencedColumn: (t) => t.auditId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EvidenceReferencesTableAnnotationComposer(
                $db: $db,
                $table: $db.evidenceReferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> userActionsRefs<T extends Object>(
    Expression<T> Function($$UserActionsTableAnnotationComposer a) f,
  ) {
    final $$UserActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userActions,
      getReferencedColumn: (t) => t.auditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.userActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> analysisRunsRefs<T extends Object>(
    Expression<T> Function($$AnalysisRunsTableAnnotationComposer a) f,
  ) {
    final $$AnalysisRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.analysisRuns,
      getReferencedColumn: (t) => t.auditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnalysisRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.analysisRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reportRecordsRefs<T extends Object>(
    Expression<T> Function($$ReportRecordsTableAnnotationComposer a) f,
  ) {
    final $$ReportRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reportRecords,
      getReferencedColumn: (t) => t.auditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReportRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.reportRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AuditSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditSessionsTable,
          AuditSessionRow,
          $$AuditSessionsTableFilterComposer,
          $$AuditSessionsTableOrderingComposer,
          $$AuditSessionsTableAnnotationComposer,
          $$AuditSessionsTableCreateCompanionBuilder,
          $$AuditSessionsTableUpdateCompanionBuilder,
          (AuditSessionRow, $$AuditSessionsTableReferences),
          AuditSessionRow,
          PrefetchHooks Function({
            bool applicationSnapshotsRefs,
            bool appPermissionSnapshotsRefs,
            bool documentSourcesRefs,
            bool evidenceReferencesRefs,
            bool userActionsRefs,
            bool analysisRunsRefs,
            bool reportRecordsRefs,
          })
        > {
  $$AuditSessionsTableTableManager(_$AppDatabase db, $AuditSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> focus = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditSessionsCompanion(
                id: id,
                name: name,
                focus: focus,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String focus,
                required String status,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditSessionsCompanion.insert(
                id: id,
                name: name,
                focus: focus,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditSessionsTable, AuditSessionRow>(table),
                  $$AuditSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                applicationSnapshotsRefs = false,
                appPermissionSnapshotsRefs = false,
                documentSourcesRefs = false,
                evidenceReferencesRefs = false,
                userActionsRefs = false,
                analysisRunsRefs = false,
                reportRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (applicationSnapshotsRefs) db.applicationSnapshots,
                    if (appPermissionSnapshotsRefs) db.appPermissionSnapshots,
                    if (documentSourcesRefs) db.documentSources,
                    if (evidenceReferencesRefs) db.evidenceReferences,
                    if (userActionsRefs) db.userActions,
                    if (analysisRunsRefs) db.analysisRuns,
                    if (reportRecordsRefs) db.reportRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (applicationSnapshotsRefs)
                        await $_getPrefetchedDataByColumns<
                          AuditSessionRow,
                          $AuditSessionsTable,
                          ApplicationSnapshotRow,
                          $ApplicationSnapshotsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AuditSessionsTableReferences
                              ._applicationSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AuditSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).applicationSnapshotsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'audit_id',
                          typedResults: items,
                        ),
                      if (appPermissionSnapshotsRefs)
                        await $_getPrefetchedDataByColumns<
                          AuditSessionRow,
                          $AuditSessionsTable,
                          AppPermissionSnapshotRow,
                          $AppPermissionSnapshotsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AuditSessionsTableReferences
                              ._appPermissionSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AuditSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).appPermissionSnapshotsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'audit_id',
                          typedResults: items,
                        ),
                      if (documentSourcesRefs)
                        await $_getPrefetchedDataByColumns<
                          AuditSessionRow,
                          $AuditSessionsTable,
                          DocumentSourceRow,
                          $DocumentSourcesTable
                        >(
                          currentTable: table,
                          referencedTable: $$AuditSessionsTableReferences
                              ._documentSourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AuditSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentSourcesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'audit_id',
                          typedResults: items,
                        ),
                      if (evidenceReferencesRefs)
                        await $_getPrefetchedDataByColumns<
                          AuditSessionRow,
                          $AuditSessionsTable,
                          EvidenceReferenceRow,
                          $EvidenceReferencesTable
                        >(
                          currentTable: table,
                          referencedTable: $$AuditSessionsTableReferences
                              ._evidenceReferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AuditSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).evidenceReferencesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'audit_id',
                          typedResults: items,
                        ),
                      if (userActionsRefs)
                        await $_getPrefetchedDataByColumns<
                          AuditSessionRow,
                          $AuditSessionsTable,
                          UserActionRow,
                          $UserActionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AuditSessionsTableReferences
                              ._userActionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AuditSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).userActionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'audit_id',
                          typedResults: items,
                        ),
                      if (analysisRunsRefs)
                        await $_getPrefetchedDataByColumns<
                          AuditSessionRow,
                          $AuditSessionsTable,
                          AnalysisRunRow,
                          $AnalysisRunsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AuditSessionsTableReferences
                              ._analysisRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AuditSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).analysisRunsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'audit_id',
                          typedResults: items,
                        ),
                      if (reportRecordsRefs)
                        await $_getPrefetchedDataByColumns<
                          AuditSessionRow,
                          $AuditSessionsTable,
                          ReportRecordRow,
                          $ReportRecordsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AuditSessionsTableReferences
                              ._reportRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AuditSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).reportRecordsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'audit_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AuditSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditSessionsTable,
      AuditSessionRow,
      $$AuditSessionsTableFilterComposer,
      $$AuditSessionsTableOrderingComposer,
      $$AuditSessionsTableAnnotationComposer,
      $$AuditSessionsTableCreateCompanionBuilder,
      $$AuditSessionsTableUpdateCompanionBuilder,
      (AuditSessionRow, $$AuditSessionsTableReferences),
      AuditSessionRow,
      PrefetchHooks Function({
        bool applicationSnapshotsRefs,
        bool appPermissionSnapshotsRefs,
        bool documentSourcesRefs,
        bool evidenceReferencesRefs,
        bool userActionsRefs,
        bool analysisRunsRefs,
        bool reportRecordsRefs,
      })
    >;
typedef $$ApplicationSnapshotsTableCreateCompanionBuilder =
    ApplicationSnapshotsCompanion Function({
      required String id,
      required String auditId,
      required String packageName,
      required String appLabel,
      Value<String?> versionName,
      required String snapshotStatus,
      required String visibilityScope,
      required int androidSdk,
      required DateTime capturedAt,
      Value<int> rowid,
    });
typedef $$ApplicationSnapshotsTableUpdateCompanionBuilder =
    ApplicationSnapshotsCompanion Function({
      Value<String> id,
      Value<String> auditId,
      Value<String> packageName,
      Value<String> appLabel,
      Value<String?> versionName,
      Value<String> snapshotStatus,
      Value<String> visibilityScope,
      Value<int> androidSdk,
      Value<DateTime> capturedAt,
      Value<int> rowid,
    });

final class $$ApplicationSnapshotsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ApplicationSnapshotsTable,
          ApplicationSnapshotRow
        > {
  $$ApplicationSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AuditSessionsTable _auditIdTable(_$AppDatabase db) => db.auditSessions
      .createAlias('application_snapshots__audit_id__audit_sessions__id');

  $$AuditSessionsTableProcessedTableManager get auditId {
    final $_column = $_itemColumn<String>('audit_id')!;

    final manager = $$AuditSessionsTableTableManager(
      $_db,
      $_db.auditSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_auditIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $AppPermissionSnapshotsTable,
    List<AppPermissionSnapshotRow>
  >
  _appPermissionSnapshotsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.appPermissionSnapshots,
    aliasName:
        'application_snapshots__id__app_permission_snapshots__app_snapshot_id',
  );

  $$AppPermissionSnapshotsTableProcessedTableManager
  get appPermissionSnapshotsRefs {
    final manager = $$AppPermissionSnapshotsTableTableManager(
      $_db,
      $_db.appPermissionSnapshots,
    ).filter((f) => f.appSnapshotId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _appPermissionSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ApplicationSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $ApplicationSnapshotsTable> {
  $$ApplicationSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appLabel => $composableBuilder(
    column: $table.appLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionName => $composableBuilder(
    column: $table.versionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotStatus => $composableBuilder(
    column: $table.snapshotStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibilityScope => $composableBuilder(
    column: $table.visibilityScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get androidSdk => $composableBuilder(
    column: $table.androidSdk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AuditSessionsTableFilterComposer get auditId {
    final $$AuditSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableFilterComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> appPermissionSnapshotsRefs(
    Expression<bool> Function($$AppPermissionSnapshotsTableFilterComposer f) f,
  ) {
    final $$AppPermissionSnapshotsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.appPermissionSnapshots,
          getReferencedColumn: (t) => t.appSnapshotId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AppPermissionSnapshotsTableFilterComposer(
                $db: $db,
                $table: $db.appPermissionSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ApplicationSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $ApplicationSnapshotsTable> {
  $$ApplicationSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appLabel => $composableBuilder(
    column: $table.appLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionName => $composableBuilder(
    column: $table.versionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotStatus => $composableBuilder(
    column: $table.snapshotStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibilityScope => $composableBuilder(
    column: $table.visibilityScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get androidSdk => $composableBuilder(
    column: $table.androidSdk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AuditSessionsTableOrderingComposer get auditId {
    final $$AuditSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ApplicationSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApplicationSnapshotsTable> {
  $$ApplicationSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appLabel =>
      $composableBuilder(column: $table.appLabel, builder: (column) => column);

  GeneratedColumn<String> get versionName => $composableBuilder(
    column: $table.versionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapshotStatus => $composableBuilder(
    column: $table.snapshotStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visibilityScope => $composableBuilder(
    column: $table.visibilityScope,
    builder: (column) => column,
  );

  GeneratedColumn<int> get androidSdk => $composableBuilder(
    column: $table.androidSdk,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  $$AuditSessionsTableAnnotationComposer get auditId {
    final $$AuditSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> appPermissionSnapshotsRefs<T extends Object>(
    Expression<T> Function($$AppPermissionSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$AppPermissionSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.appPermissionSnapshots,
          getReferencedColumn: (t) => t.appSnapshotId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AppPermissionSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.appPermissionSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ApplicationSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApplicationSnapshotsTable,
          ApplicationSnapshotRow,
          $$ApplicationSnapshotsTableFilterComposer,
          $$ApplicationSnapshotsTableOrderingComposer,
          $$ApplicationSnapshotsTableAnnotationComposer,
          $$ApplicationSnapshotsTableCreateCompanionBuilder,
          $$ApplicationSnapshotsTableUpdateCompanionBuilder,
          (ApplicationSnapshotRow, $$ApplicationSnapshotsTableReferences),
          ApplicationSnapshotRow,
          PrefetchHooks Function({
            bool auditId,
            bool appPermissionSnapshotsRefs,
          })
        > {
  $$ApplicationSnapshotsTableTableManager(
    _$AppDatabase db,
    $ApplicationSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApplicationSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApplicationSnapshotsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ApplicationSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> auditId = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> appLabel = const Value.absent(),
                Value<String?> versionName = const Value.absent(),
                Value<String> snapshotStatus = const Value.absent(),
                Value<String> visibilityScope = const Value.absent(),
                Value<int> androidSdk = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApplicationSnapshotsCompanion(
                id: id,
                auditId: auditId,
                packageName: packageName,
                appLabel: appLabel,
                versionName: versionName,
                snapshotStatus: snapshotStatus,
                visibilityScope: visibilityScope,
                androidSdk: androidSdk,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String auditId,
                required String packageName,
                required String appLabel,
                Value<String?> versionName = const Value.absent(),
                required String snapshotStatus,
                required String visibilityScope,
                required int androidSdk,
                required DateTime capturedAt,
                Value<int> rowid = const Value.absent(),
              }) => ApplicationSnapshotsCompanion.insert(
                id: id,
                auditId: auditId,
                packageName: packageName,
                appLabel: appLabel,
                versionName: versionName,
                snapshotStatus: snapshotStatus,
                visibilityScope: visibilityScope,
                androidSdk: androidSdk,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ApplicationSnapshotsTable,
                    ApplicationSnapshotRow
                  >(table),
                  $$ApplicationSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({auditId = false, appPermissionSnapshotsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (appPermissionSnapshotsRefs) db.appPermissionSnapshots,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (auditId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.auditId,
                            referencedTable:
                                $$ApplicationSnapshotsTableReferences
                                    ._auditIdTable(db),
                            referencedColumn:
                                $$ApplicationSnapshotsTableReferences
                                    ._auditIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (appPermissionSnapshotsRefs)
                        await $_getPrefetchedDataByColumns<
                          ApplicationSnapshotRow,
                          $ApplicationSnapshotsTable,
                          AppPermissionSnapshotRow,
                          $AppPermissionSnapshotsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ApplicationSnapshotsTableReferences
                              ._appPermissionSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ApplicationSnapshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).appPermissionSnapshotsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'app_snapshot_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ApplicationSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApplicationSnapshotsTable,
      ApplicationSnapshotRow,
      $$ApplicationSnapshotsTableFilterComposer,
      $$ApplicationSnapshotsTableOrderingComposer,
      $$ApplicationSnapshotsTableAnnotationComposer,
      $$ApplicationSnapshotsTableCreateCompanionBuilder,
      $$ApplicationSnapshotsTableUpdateCompanionBuilder,
      (ApplicationSnapshotRow, $$ApplicationSnapshotsTableReferences),
      ApplicationSnapshotRow,
      PrefetchHooks Function({bool auditId, bool appPermissionSnapshotsRefs})
    >;
typedef $$AppPermissionSnapshotsTableCreateCompanionBuilder =
    AppPermissionSnapshotsCompanion Function({
      required String id,
      required String auditId,
      Value<String?> appSnapshotId,
      required String packageName,
      required String permissionName,
      Value<String?> permissionLabel,
      required String grantStatus,
      Value<bool?> granted,
      Value<bool> flagsAvailable,
      Value<int?> androidSdk,
      Value<String?> protectionLevel,
      required DateTime capturedAt,
      Value<int> rowid,
    });
typedef $$AppPermissionSnapshotsTableUpdateCompanionBuilder =
    AppPermissionSnapshotsCompanion Function({
      Value<String> id,
      Value<String> auditId,
      Value<String?> appSnapshotId,
      Value<String> packageName,
      Value<String> permissionName,
      Value<String?> permissionLabel,
      Value<String> grantStatus,
      Value<bool?> granted,
      Value<bool> flagsAvailable,
      Value<int?> androidSdk,
      Value<String?> protectionLevel,
      Value<DateTime> capturedAt,
      Value<int> rowid,
    });

final class $$AppPermissionSnapshotsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AppPermissionSnapshotsTable,
          AppPermissionSnapshotRow
        > {
  $$AppPermissionSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AuditSessionsTable _auditIdTable(_$AppDatabase db) => db.auditSessions
      .createAlias('app_permission_snapshots__audit_id__audit_sessions__id');

  $$AuditSessionsTableProcessedTableManager get auditId {
    final $_column = $_itemColumn<String>('audit_id')!;

    final manager = $$AuditSessionsTableTableManager(
      $_db,
      $_db.auditSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_auditIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ApplicationSnapshotsTable _appSnapshotIdTable(_$AppDatabase db) =>
      db.applicationSnapshots.createAlias(
        'app_permission_snapshots__app_snapshot_id__application_snapshots__id',
      );

  $$ApplicationSnapshotsTableProcessedTableManager? get appSnapshotId {
    final $_column = $_itemColumn<String>('app_snapshot_id');
    if ($_column == null) return null;
    final manager = $$ApplicationSnapshotsTableTableManager(
      $_db,
      $_db.applicationSnapshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_appSnapshotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AppPermissionSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $AppPermissionSnapshotsTable> {
  $$AppPermissionSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissionName => $composableBuilder(
    column: $table.permissionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissionLabel => $composableBuilder(
    column: $table.permissionLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grantStatus => $composableBuilder(
    column: $table.grantStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get granted => $composableBuilder(
    column: $table.granted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get flagsAvailable => $composableBuilder(
    column: $table.flagsAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get androidSdk => $composableBuilder(
    column: $table.androidSdk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protectionLevel => $composableBuilder(
    column: $table.protectionLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AuditSessionsTableFilterComposer get auditId {
    final $$AuditSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableFilterComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ApplicationSnapshotsTableFilterComposer get appSnapshotId {
    final $$ApplicationSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appSnapshotId,
      referencedTable: $db.applicationSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApplicationSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.applicationSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppPermissionSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPermissionSnapshotsTable> {
  $$AppPermissionSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissionName => $composableBuilder(
    column: $table.permissionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissionLabel => $composableBuilder(
    column: $table.permissionLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grantStatus => $composableBuilder(
    column: $table.grantStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get granted => $composableBuilder(
    column: $table.granted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get flagsAvailable => $composableBuilder(
    column: $table.flagsAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get androidSdk => $composableBuilder(
    column: $table.androidSdk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protectionLevel => $composableBuilder(
    column: $table.protectionLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AuditSessionsTableOrderingComposer get auditId {
    final $$AuditSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ApplicationSnapshotsTableOrderingComposer get appSnapshotId {
    final $$ApplicationSnapshotsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.appSnapshotId,
          referencedTable: $db.applicationSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ApplicationSnapshotsTableOrderingComposer(
                $db: $db,
                $table: $db.applicationSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AppPermissionSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPermissionSnapshotsTable> {
  $$AppPermissionSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get permissionName => $composableBuilder(
    column: $table.permissionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get permissionLabel => $composableBuilder(
    column: $table.permissionLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grantStatus => $composableBuilder(
    column: $table.grantStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get granted =>
      $composableBuilder(column: $table.granted, builder: (column) => column);

  GeneratedColumn<bool> get flagsAvailable => $composableBuilder(
    column: $table.flagsAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get androidSdk => $composableBuilder(
    column: $table.androidSdk,
    builder: (column) => column,
  );

  GeneratedColumn<String> get protectionLevel => $composableBuilder(
    column: $table.protectionLevel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  $$AuditSessionsTableAnnotationComposer get auditId {
    final $$AuditSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ApplicationSnapshotsTableAnnotationComposer get appSnapshotId {
    final $$ApplicationSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.appSnapshotId,
          referencedTable: $db.applicationSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ApplicationSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.applicationSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AppPermissionSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPermissionSnapshotsTable,
          AppPermissionSnapshotRow,
          $$AppPermissionSnapshotsTableFilterComposer,
          $$AppPermissionSnapshotsTableOrderingComposer,
          $$AppPermissionSnapshotsTableAnnotationComposer,
          $$AppPermissionSnapshotsTableCreateCompanionBuilder,
          $$AppPermissionSnapshotsTableUpdateCompanionBuilder,
          (AppPermissionSnapshotRow, $$AppPermissionSnapshotsTableReferences),
          AppPermissionSnapshotRow,
          PrefetchHooks Function({bool auditId, bool appSnapshotId})
        > {
  $$AppPermissionSnapshotsTableTableManager(
    _$AppDatabase db,
    $AppPermissionSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPermissionSnapshotsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AppPermissionSnapshotsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AppPermissionSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> auditId = const Value.absent(),
                Value<String?> appSnapshotId = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> permissionName = const Value.absent(),
                Value<String?> permissionLabel = const Value.absent(),
                Value<String> grantStatus = const Value.absent(),
                Value<bool?> granted = const Value.absent(),
                Value<bool> flagsAvailable = const Value.absent(),
                Value<int?> androidSdk = const Value.absent(),
                Value<String?> protectionLevel = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppPermissionSnapshotsCompanion(
                id: id,
                auditId: auditId,
                appSnapshotId: appSnapshotId,
                packageName: packageName,
                permissionName: permissionName,
                permissionLabel: permissionLabel,
                grantStatus: grantStatus,
                granted: granted,
                flagsAvailable: flagsAvailable,
                androidSdk: androidSdk,
                protectionLevel: protectionLevel,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String auditId,
                Value<String?> appSnapshotId = const Value.absent(),
                required String packageName,
                required String permissionName,
                Value<String?> permissionLabel = const Value.absent(),
                required String grantStatus,
                Value<bool?> granted = const Value.absent(),
                Value<bool> flagsAvailable = const Value.absent(),
                Value<int?> androidSdk = const Value.absent(),
                Value<String?> protectionLevel = const Value.absent(),
                required DateTime capturedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppPermissionSnapshotsCompanion.insert(
                id: id,
                auditId: auditId,
                appSnapshotId: appSnapshotId,
                packageName: packageName,
                permissionName: permissionName,
                permissionLabel: permissionLabel,
                grantStatus: grantStatus,
                granted: granted,
                flagsAvailable: flagsAvailable,
                androidSdk: androidSdk,
                protectionLevel: protectionLevel,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $AppPermissionSnapshotsTable,
                    AppPermissionSnapshotRow
                  >(table),
                  $$AppPermissionSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({auditId = false, appSnapshotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (auditId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.auditId,
                        referencedTable: $$AppPermissionSnapshotsTableReferences
                            ._auditIdTable(db),
                        referencedColumn:
                            $$AppPermissionSnapshotsTableReferences
                                ._auditIdTable(db)
                                .id,
                      ) as T;
                    }
                    if (appSnapshotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.appSnapshotId,
                        referencedTable: $$AppPermissionSnapshotsTableReferences
                            ._appSnapshotIdTable(db),
                        referencedColumn:
                            $$AppPermissionSnapshotsTableReferences
                                ._appSnapshotIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AppPermissionSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPermissionSnapshotsTable,
      AppPermissionSnapshotRow,
      $$AppPermissionSnapshotsTableFilterComposer,
      $$AppPermissionSnapshotsTableOrderingComposer,
      $$AppPermissionSnapshotsTableAnnotationComposer,
      $$AppPermissionSnapshotsTableCreateCompanionBuilder,
      $$AppPermissionSnapshotsTableUpdateCompanionBuilder,
      (AppPermissionSnapshotRow, $$AppPermissionSnapshotsTableReferences),
      AppPermissionSnapshotRow,
      PrefetchHooks Function({bool auditId, bool appSnapshotId})
    >;
typedef $$DocumentSourcesTableCreateCompanionBuilder =
    DocumentSourcesCompanion Function({
      required String id,
      required String auditId,
      required String type,
      required String reviewStatus,
      required String lifecycle,
      required String sha256,
      required String localPath,
      required String mediaType,
      required int byteLength,
      Value<String?> originalName,
      Value<String?> language,
      Value<int?> provenancePage,
      Value<int?> provenanceFrame,
      Value<String?> provenanceLocator,
      Value<String?> sourceUrl,
      Value<String?> documentVersion,
      Value<String?> importWarnings,
      Value<DateTime?> reviewedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DocumentSourcesTableUpdateCompanionBuilder =
    DocumentSourcesCompanion Function({
      Value<String> id,
      Value<String> auditId,
      Value<String> type,
      Value<String> reviewStatus,
      Value<String> lifecycle,
      Value<String> sha256,
      Value<String> localPath,
      Value<String> mediaType,
      Value<int> byteLength,
      Value<String?> originalName,
      Value<String?> language,
      Value<int?> provenancePage,
      Value<int?> provenanceFrame,
      Value<String?> provenanceLocator,
      Value<String?> sourceUrl,
      Value<String?> documentVersion,
      Value<String?> importWarnings,
      Value<DateTime?> reviewedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DocumentSourcesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DocumentSourcesTable,
          DocumentSourceRow
        > {
  $$DocumentSourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AuditSessionsTable _auditIdTable(_$AppDatabase db) => db.auditSessions
      .createAlias('document_sources__audit_id__audit_sessions__id');

  $$AuditSessionsTableProcessedTableManager get auditId {
    final $_column = $_itemColumn<String>('audit_id')!;

    final manager = $$AuditSessionsTableTableManager(
      $_db,
      $_db.auditSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_auditIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DocumentSegmentsTable, List<DocumentSegmentRow>>
  _documentSegmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.documentSegments,
    aliasName: 'document_sources__id__document_segments__source_id',
  );

  $$DocumentSegmentsTableProcessedTableManager get documentSegmentsRefs {
    final manager = $$DocumentSegmentsTableTableManager(
      $_db,
      $_db.documentSegments,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _documentSegmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConsentUiSourcesTable, List<ConsentUiSourceRow>>
  _consentUiSourcesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.consentUiSources,
    aliasName: 'document_sources__id__consent_ui_sources__source_id',
  );

  $$ConsentUiSourcesTableProcessedTableManager get consentUiSourcesRefs {
    final manager = $$ConsentUiSourcesTableTableManager(
      $_db,
      $_db.consentUiSources,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _consentUiSourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EvidenceReferencesTable,
    List<EvidenceReferenceRow>
  >
  _evidenceReferencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.evidenceReferences,
        aliasName: 'document_sources__id__evidence_references__source_id',
      );

  $$EvidenceReferencesTableProcessedTableManager get evidenceReferencesRefs {
    final manager = $$EvidenceReferencesTableTableManager(
      $_db,
      $_db.evidenceReferences,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _evidenceReferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserActionsTable, List<UserActionRow>>
  _userActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userActions,
    aliasName: 'document_sources__id__user_actions__source_id',
  );

  $$UserActionsTableProcessedTableManager get userActionsRefs {
    final manager = $$UserActionsTableTableManager(
      $_db,
      $_db.userActions,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userActionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentSourcesTable> {
  $$DocumentSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get provenancePage => $composableBuilder(
    column: $table.provenancePage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get provenanceFrame => $composableBuilder(
    column: $table.provenanceFrame,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provenanceLocator => $composableBuilder(
    column: $table.provenanceLocator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentVersion => $composableBuilder(
    column: $table.documentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importWarnings => $composableBuilder(
    column: $table.importWarnings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AuditSessionsTableFilterComposer get auditId {
    final $$AuditSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableFilterComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> documentSegmentsRefs(
    Expression<bool> Function($$DocumentSegmentsTableFilterComposer f) f,
  ) {
    final $$DocumentSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentSegments,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.documentSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> consentUiSourcesRefs(
    Expression<bool> Function($$ConsentUiSourcesTableFilterComposer f) f,
  ) {
    final $$ConsentUiSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.consentUiSources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsentUiSourcesTableFilterComposer(
            $db: $db,
            $table: $db.consentUiSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> evidenceReferencesRefs(
    Expression<bool> Function($$EvidenceReferencesTableFilterComposer f) f,
  ) {
    final $$EvidenceReferencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceReferences,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceReferencesTableFilterComposer(
            $db: $db,
            $table: $db.evidenceReferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userActionsRefs(
    Expression<bool> Function($$UserActionsTableFilterComposer f) f,
  ) {
    final $$UserActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userActions,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserActionsTableFilterComposer(
            $db: $db,
            $table: $db.userActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentSourcesTable> {
  $$DocumentSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get provenancePage => $composableBuilder(
    column: $table.provenancePage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get provenanceFrame => $composableBuilder(
    column: $table.provenanceFrame,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provenanceLocator => $composableBuilder(
    column: $table.provenanceLocator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentVersion => $composableBuilder(
    column: $table.documentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importWarnings => $composableBuilder(
    column: $table.importWarnings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AuditSessionsTableOrderingComposer get auditId {
    final $$AuditSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentSourcesTable> {
  $$DocumentSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycle =>
      $composableBuilder(column: $table.lifecycle, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get provenancePage => $composableBuilder(
    column: $table.provenancePage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get provenanceFrame => $composableBuilder(
    column: $table.provenanceFrame,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provenanceLocator => $composableBuilder(
    column: $table.provenanceLocator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get documentVersion => $composableBuilder(
    column: $table.documentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get importWarnings => $composableBuilder(
    column: $table.importWarnings,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AuditSessionsTableAnnotationComposer get auditId {
    final $$AuditSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> documentSegmentsRefs<T extends Object>(
    Expression<T> Function($$DocumentSegmentsTableAnnotationComposer a) f,
  ) {
    final $$DocumentSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentSegments,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documentSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> consentUiSourcesRefs<T extends Object>(
    Expression<T> Function($$ConsentUiSourcesTableAnnotationComposer a) f,
  ) {
    final $$ConsentUiSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.consentUiSources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsentUiSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.consentUiSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> evidenceReferencesRefs<T extends Object>(
    Expression<T> Function($$EvidenceReferencesTableAnnotationComposer a) f,
  ) {
    final $$EvidenceReferencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.evidenceReferences,
          getReferencedColumn: (t) => t.sourceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EvidenceReferencesTableAnnotationComposer(
                $db: $db,
                $table: $db.evidenceReferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> userActionsRefs<T extends Object>(
    Expression<T> Function($$UserActionsTableAnnotationComposer a) f,
  ) {
    final $$UserActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userActions,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.userActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentSourcesTable,
          DocumentSourceRow,
          $$DocumentSourcesTableFilterComposer,
          $$DocumentSourcesTableOrderingComposer,
          $$DocumentSourcesTableAnnotationComposer,
          $$DocumentSourcesTableCreateCompanionBuilder,
          $$DocumentSourcesTableUpdateCompanionBuilder,
          (DocumentSourceRow, $$DocumentSourcesTableReferences),
          DocumentSourceRow,
          PrefetchHooks Function({
            bool auditId,
            bool documentSegmentsRefs,
            bool consentUiSourcesRefs,
            bool evidenceReferencesRefs,
            bool userActionsRefs,
          })
        > {
  $$DocumentSourcesTableTableManager(
    _$AppDatabase db,
    $DocumentSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> auditId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<String> lifecycle = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<int> byteLength = const Value.absent(),
                Value<String?> originalName = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<int?> provenancePage = const Value.absent(),
                Value<int?> provenanceFrame = const Value.absent(),
                Value<String?> provenanceLocator = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> documentVersion = const Value.absent(),
                Value<String?> importWarnings = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentSourcesCompanion(
                id: id,
                auditId: auditId,
                type: type,
                reviewStatus: reviewStatus,
                lifecycle: lifecycle,
                sha256: sha256,
                localPath: localPath,
                mediaType: mediaType,
                byteLength: byteLength,
                originalName: originalName,
                language: language,
                provenancePage: provenancePage,
                provenanceFrame: provenanceFrame,
                provenanceLocator: provenanceLocator,
                sourceUrl: sourceUrl,
                documentVersion: documentVersion,
                importWarnings: importWarnings,
                reviewedAt: reviewedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String auditId,
                required String type,
                required String reviewStatus,
                required String lifecycle,
                required String sha256,
                required String localPath,
                required String mediaType,
                required int byteLength,
                Value<String?> originalName = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<int?> provenancePage = const Value.absent(),
                Value<int?> provenanceFrame = const Value.absent(),
                Value<String?> provenanceLocator = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> documentVersion = const Value.absent(),
                Value<String?> importWarnings = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DocumentSourcesCompanion.insert(
                id: id,
                auditId: auditId,
                type: type,
                reviewStatus: reviewStatus,
                lifecycle: lifecycle,
                sha256: sha256,
                localPath: localPath,
                mediaType: mediaType,
                byteLength: byteLength,
                originalName: originalName,
                language: language,
                provenancePage: provenancePage,
                provenanceFrame: provenanceFrame,
                provenanceLocator: provenanceLocator,
                sourceUrl: sourceUrl,
                documentVersion: documentVersion,
                importWarnings: importWarnings,
                reviewedAt: reviewedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentSourcesTable, DocumentSourceRow>(table),
                  $$DocumentSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                auditId = false,
                documentSegmentsRefs = false,
                consentUiSourcesRefs = false,
                evidenceReferencesRefs = false,
                userActionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (documentSegmentsRefs) db.documentSegments,
                    if (consentUiSourcesRefs) db.consentUiSources,
                    if (evidenceReferencesRefs) db.evidenceReferences,
                    if (userActionsRefs) db.userActions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (auditId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.auditId,
                            referencedTable: $$DocumentSourcesTableReferences
                                ._auditIdTable(db),
                            referencedColumn: $$DocumentSourcesTableReferences
                                ._auditIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (documentSegmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          DocumentSourceRow,
                          $DocumentSourcesTable,
                          DocumentSegmentRow,
                          $DocumentSegmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentSourcesTableReferences
                              ._documentSegmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).documentSegmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'source_id',
                          typedResults: items,
                        ),
                      if (consentUiSourcesRefs)
                        await $_getPrefetchedDataByColumns<
                          DocumentSourceRow,
                          $DocumentSourcesTable,
                          ConsentUiSourceRow,
                          $ConsentUiSourcesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentSourcesTableReferences
                              ._consentUiSourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).consentUiSourcesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'source_id',
                          typedResults: items,
                        ),
                      if (evidenceReferencesRefs)
                        await $_getPrefetchedDataByColumns<
                          DocumentSourceRow,
                          $DocumentSourcesTable,
                          EvidenceReferenceRow,
                          $EvidenceReferencesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentSourcesTableReferences
                              ._evidenceReferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).evidenceReferencesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'source_id',
                          typedResults: items,
                        ),
                      if (userActionsRefs)
                        await $_getPrefetchedDataByColumns<
                          DocumentSourceRow,
                          $DocumentSourcesTable,
                          UserActionRow,
                          $UserActionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentSourcesTableReferences
                              ._userActionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).userActionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'source_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentSourcesTable,
      DocumentSourceRow,
      $$DocumentSourcesTableFilterComposer,
      $$DocumentSourcesTableOrderingComposer,
      $$DocumentSourcesTableAnnotationComposer,
      $$DocumentSourcesTableCreateCompanionBuilder,
      $$DocumentSourcesTableUpdateCompanionBuilder,
      (DocumentSourceRow, $$DocumentSourcesTableReferences),
      DocumentSourceRow,
      PrefetchHooks Function({
        bool auditId,
        bool documentSegmentsRefs,
        bool consentUiSourcesRefs,
        bool evidenceReferencesRefs,
        bool userActionsRefs,
      })
    >;
typedef $$DocumentSegmentsTableCreateCompanionBuilder =
    DocumentSegmentsCompanion Function({
      required String id,
      required String sourceId,
      required int sequence,
      required String content,
      Value<String?> originalContent,
      Value<int?> startOffset,
      Value<int?> endOffset,
      Value<String?> pageTextSha256,
      Value<String?> extractionMethod,
      Value<double?> confidence,
      Value<String?> boundingBoxJson,
      Value<DateTime?> editedAt,
      Value<DateTime?> reviewedAt,
      Value<int?> page,
      Value<int?> frame,
      Value<int> rowid,
    });
typedef $$DocumentSegmentsTableUpdateCompanionBuilder =
    DocumentSegmentsCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<int> sequence,
      Value<String> content,
      Value<String?> originalContent,
      Value<int?> startOffset,
      Value<int?> endOffset,
      Value<String?> pageTextSha256,
      Value<String?> extractionMethod,
      Value<double?> confidence,
      Value<String?> boundingBoxJson,
      Value<DateTime?> editedAt,
      Value<DateTime?> reviewedAt,
      Value<int?> page,
      Value<int?> frame,
      Value<int> rowid,
    });

final class $$DocumentSegmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DocumentSegmentsTable,
          DocumentSegmentRow
        > {
  $$DocumentSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentSourcesTable _sourceIdTable(_$AppDatabase db) => db
      .documentSources
      .createAlias('document_segments__source_id__document_sources__id');

  $$DocumentSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$DocumentSourcesTableTableManager(
      $_db,
      $_db.documentSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $EvidenceReferencesTable,
    List<EvidenceReferenceRow>
  >
  _evidenceReferencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.evidenceReferences,
        aliasName: 'document_segments__id__evidence_references__segment_id',
      );

  $$EvidenceReferencesTableProcessedTableManager get evidenceReferencesRefs {
    final manager = $$EvidenceReferencesTableTableManager(
      $_db,
      $_db.evidenceReferences,
    ).filter((f) => f.segmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _evidenceReferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentSegmentsTable> {
  $$DocumentSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalContent => $composableBuilder(
    column: $table.originalContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageTextSha256 => $composableBuilder(
    column: $table.pageTextSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractionMethod => $composableBuilder(
    column: $table.extractionMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boundingBoxJson => $composableBuilder(
    column: $table.boundingBoxJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frame => $composableBuilder(
    column: $table.frame,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentSourcesTableFilterComposer get sourceId {
    final $$DocumentSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableFilterComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> evidenceReferencesRefs(
    Expression<bool> Function($$EvidenceReferencesTableFilterComposer f) f,
  ) {
    final $$EvidenceReferencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceReferences,
      getReferencedColumn: (t) => t.segmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceReferencesTableFilterComposer(
            $db: $db,
            $table: $db.evidenceReferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentSegmentsTable> {
  $$DocumentSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalContent => $composableBuilder(
    column: $table.originalContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageTextSha256 => $composableBuilder(
    column: $table.pageTextSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractionMethod => $composableBuilder(
    column: $table.extractionMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boundingBoxJson => $composableBuilder(
    column: $table.boundingBoxJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frame => $composableBuilder(
    column: $table.frame,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentSourcesTableOrderingComposer get sourceId {
    final $$DocumentSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentSegmentsTable> {
  $$DocumentSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get originalContent => $composableBuilder(
    column: $table.originalContent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endOffset =>
      $composableBuilder(column: $table.endOffset, builder: (column) => column);

  GeneratedColumn<String> get pageTextSha256 => $composableBuilder(
    column: $table.pageTextSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extractionMethod => $composableBuilder(
    column: $table.extractionMethod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get boundingBoxJson => $composableBuilder(
    column: $table.boundingBoxJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get frame =>
      $composableBuilder(column: $table.frame, builder: (column) => column);

  $$DocumentSourcesTableAnnotationComposer get sourceId {
    final $$DocumentSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> evidenceReferencesRefs<T extends Object>(
    Expression<T> Function($$EvidenceReferencesTableAnnotationComposer a) f,
  ) {
    final $$EvidenceReferencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.evidenceReferences,
          getReferencedColumn: (t) => t.segmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EvidenceReferencesTableAnnotationComposer(
                $db: $db,
                $table: $db.evidenceReferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DocumentSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentSegmentsTable,
          DocumentSegmentRow,
          $$DocumentSegmentsTableFilterComposer,
          $$DocumentSegmentsTableOrderingComposer,
          $$DocumentSegmentsTableAnnotationComposer,
          $$DocumentSegmentsTableCreateCompanionBuilder,
          $$DocumentSegmentsTableUpdateCompanionBuilder,
          (DocumentSegmentRow, $$DocumentSegmentsTableReferences),
          DocumentSegmentRow,
          PrefetchHooks Function({bool sourceId, bool evidenceReferencesRefs})
        > {
  $$DocumentSegmentsTableTableManager(
    _$AppDatabase db,
    $DocumentSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> originalContent = const Value.absent(),
                Value<int?> startOffset = const Value.absent(),
                Value<int?> endOffset = const Value.absent(),
                Value<String?> pageTextSha256 = const Value.absent(),
                Value<String?> extractionMethod = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> boundingBoxJson = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<int?> page = const Value.absent(),
                Value<int?> frame = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentSegmentsCompanion(
                id: id,
                sourceId: sourceId,
                sequence: sequence,
                content: content,
                originalContent: originalContent,
                startOffset: startOffset,
                endOffset: endOffset,
                pageTextSha256: pageTextSha256,
                extractionMethod: extractionMethod,
                confidence: confidence,
                boundingBoxJson: boundingBoxJson,
                editedAt: editedAt,
                reviewedAt: reviewedAt,
                page: page,
                frame: frame,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceId,
                required int sequence,
                required String content,
                Value<String?> originalContent = const Value.absent(),
                Value<int?> startOffset = const Value.absent(),
                Value<int?> endOffset = const Value.absent(),
                Value<String?> pageTextSha256 = const Value.absent(),
                Value<String?> extractionMethod = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> boundingBoxJson = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<int?> page = const Value.absent(),
                Value<int?> frame = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentSegmentsCompanion.insert(
                id: id,
                sourceId: sourceId,
                sequence: sequence,
                content: content,
                originalContent: originalContent,
                startOffset: startOffset,
                endOffset: endOffset,
                pageTextSha256: pageTextSha256,
                extractionMethod: extractionMethod,
                confidence: confidence,
                boundingBoxJson: boundingBoxJson,
                editedAt: editedAt,
                reviewedAt: reviewedAt,
                page: page,
                frame: frame,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentSegmentsTable, DocumentSegmentRow>(
                    table,
                  ),
                  $$DocumentSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sourceId = false, evidenceReferencesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (evidenceReferencesRefs) db.evidenceReferences,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sourceId,
                            referencedTable: $$DocumentSegmentsTableReferences
                                ._sourceIdTable(db),
                            referencedColumn: $$DocumentSegmentsTableReferences
                                ._sourceIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (evidenceReferencesRefs)
                        await $_getPrefetchedDataByColumns<
                          DocumentSegmentRow,
                          $DocumentSegmentsTable,
                          EvidenceReferenceRow,
                          $EvidenceReferencesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentSegmentsTableReferences
                              ._evidenceReferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentSegmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).evidenceReferencesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'segment_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentSegmentsTable,
      DocumentSegmentRow,
      $$DocumentSegmentsTableFilterComposer,
      $$DocumentSegmentsTableOrderingComposer,
      $$DocumentSegmentsTableAnnotationComposer,
      $$DocumentSegmentsTableCreateCompanionBuilder,
      $$DocumentSegmentsTableUpdateCompanionBuilder,
      (DocumentSegmentRow, $$DocumentSegmentsTableReferences),
      DocumentSegmentRow,
      PrefetchHooks Function({bool sourceId, bool evidenceReferencesRefs})
    >;
typedef $$ConsentUiSourcesTableCreateCompanionBuilder =
    ConsentUiSourcesCompanion Function({
      required String id,
      required String sourceId,
      required String imageSha256,
      required String reviewStatus,
      Value<int?> frame,
      Value<int> rowid,
    });
typedef $$ConsentUiSourcesTableUpdateCompanionBuilder =
    ConsentUiSourcesCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<String> imageSha256,
      Value<String> reviewStatus,
      Value<int?> frame,
      Value<int> rowid,
    });

final class $$ConsentUiSourcesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ConsentUiSourcesTable,
          ConsentUiSourceRow
        > {
  $$ConsentUiSourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentSourcesTable _sourceIdTable(_$AppDatabase db) => db
      .documentSources
      .createAlias('consent_ui_sources__source_id__document_sources__id');

  $$DocumentSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$DocumentSourcesTableTableManager(
      $_db,
      $_db.documentSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConsentUiSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $ConsentUiSourcesTable> {
  $$ConsentUiSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageSha256 => $composableBuilder(
    column: $table.imageSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frame => $composableBuilder(
    column: $table.frame,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentSourcesTableFilterComposer get sourceId {
    final $$DocumentSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableFilterComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConsentUiSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsentUiSourcesTable> {
  $$ConsentUiSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageSha256 => $composableBuilder(
    column: $table.imageSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frame => $composableBuilder(
    column: $table.frame,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentSourcesTableOrderingComposer get sourceId {
    final $$DocumentSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConsentUiSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsentUiSourcesTable> {
  $$ConsentUiSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imageSha256 => $composableBuilder(
    column: $table.imageSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frame =>
      $composableBuilder(column: $table.frame, builder: (column) => column);

  $$DocumentSourcesTableAnnotationComposer get sourceId {
    final $$DocumentSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConsentUiSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConsentUiSourcesTable,
          ConsentUiSourceRow,
          $$ConsentUiSourcesTableFilterComposer,
          $$ConsentUiSourcesTableOrderingComposer,
          $$ConsentUiSourcesTableAnnotationComposer,
          $$ConsentUiSourcesTableCreateCompanionBuilder,
          $$ConsentUiSourcesTableUpdateCompanionBuilder,
          (ConsentUiSourceRow, $$ConsentUiSourcesTableReferences),
          ConsentUiSourceRow,
          PrefetchHooks Function({bool sourceId})
        > {
  $$ConsentUiSourcesTableTableManager(
    _$AppDatabase db,
    $ConsentUiSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsentUiSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsentUiSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsentUiSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> imageSha256 = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<int?> frame = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsentUiSourcesCompanion(
                id: id,
                sourceId: sourceId,
                imageSha256: imageSha256,
                reviewStatus: reviewStatus,
                frame: frame,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceId,
                required String imageSha256,
                required String reviewStatus,
                Value<int?> frame = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsentUiSourcesCompanion.insert(
                id: id,
                sourceId: sourceId,
                imageSha256: imageSha256,
                reviewStatus: reviewStatus,
                frame: frame,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConsentUiSourcesTable, ConsentUiSourceRow>(
                    table,
                  ),
                  $$ConsentUiSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$ConsentUiSourcesTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$ConsentUiSourcesTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ConsentUiSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConsentUiSourcesTable,
      ConsentUiSourceRow,
      $$ConsentUiSourcesTableFilterComposer,
      $$ConsentUiSourcesTableOrderingComposer,
      $$ConsentUiSourcesTableAnnotationComposer,
      $$ConsentUiSourcesTableCreateCompanionBuilder,
      $$ConsentUiSourcesTableUpdateCompanionBuilder,
      (ConsentUiSourceRow, $$ConsentUiSourcesTableReferences),
      ConsentUiSourceRow,
      PrefetchHooks Function({bool sourceId})
    >;
typedef $$EvidenceReferencesTableCreateCompanionBuilder =
    EvidenceReferencesCompanion Function({
      required String id,
      required String auditId,
      required String sourceId,
      Value<String?> segmentId,
      required String sourceSha256,
      required String location,
      Value<String?> quote,
      Value<int> rowid,
    });
typedef $$EvidenceReferencesTableUpdateCompanionBuilder =
    EvidenceReferencesCompanion Function({
      Value<String> id,
      Value<String> auditId,
      Value<String> sourceId,
      Value<String?> segmentId,
      Value<String> sourceSha256,
      Value<String> location,
      Value<String?> quote,
      Value<int> rowid,
    });

final class $$EvidenceReferencesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EvidenceReferencesTable,
          EvidenceReferenceRow
        > {
  $$EvidenceReferencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AuditSessionsTable _auditIdTable(_$AppDatabase db) => db.auditSessions
      .createAlias('evidence_references__audit_id__audit_sessions__id');

  $$AuditSessionsTableProcessedTableManager get auditId {
    final $_column = $_itemColumn<String>('audit_id')!;

    final manager = $$AuditSessionsTableTableManager(
      $_db,
      $_db.auditSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_auditIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DocumentSourcesTable _sourceIdTable(_$AppDatabase db) => db
      .documentSources
      .createAlias('evidence_references__source_id__document_sources__id');

  $$DocumentSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$DocumentSourcesTableTableManager(
      $_db,
      $_db.documentSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DocumentSegmentsTable _segmentIdTable(_$AppDatabase db) => db
      .documentSegments
      .createAlias('evidence_references__segment_id__document_segments__id');

  $$DocumentSegmentsTableProcessedTableManager? get segmentId {
    final $_column = $_itemColumn<String>('segment_id');
    if ($_column == null) return null;
    final manager = $$DocumentSegmentsTableTableManager(
      $_db,
      $_db.documentSegments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_segmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EvidenceReferencesTableFilterComposer
    extends Composer<_$AppDatabase, $EvidenceReferencesTable> {
  $$EvidenceReferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceSha256 => $composableBuilder(
    column: $table.sourceSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => ColumnFilters(column),
  );

  $$AuditSessionsTableFilterComposer get auditId {
    final $$AuditSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableFilterComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentSourcesTableFilterComposer get sourceId {
    final $$DocumentSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableFilterComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentSegmentsTableFilterComposer get segmentId {
    final $$DocumentSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.documentSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.documentSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenceReferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $EvidenceReferencesTable> {
  $$EvidenceReferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceSha256 => $composableBuilder(
    column: $table.sourceSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => ColumnOrderings(column),
  );

  $$AuditSessionsTableOrderingComposer get auditId {
    final $$AuditSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentSourcesTableOrderingComposer get sourceId {
    final $$DocumentSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentSegmentsTableOrderingComposer get segmentId {
    final $$DocumentSegmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.documentSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSegmentsTableOrderingComposer(
            $db: $db,
            $table: $db.documentSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenceReferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvidenceReferencesTable> {
  $$EvidenceReferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceSha256 => $composableBuilder(
    column: $table.sourceSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get quote =>
      $composableBuilder(column: $table.quote, builder: (column) => column);

  $$AuditSessionsTableAnnotationComposer get auditId {
    final $$AuditSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentSourcesTableAnnotationComposer get sourceId {
    final $$DocumentSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentSegmentsTableAnnotationComposer get segmentId {
    final $$DocumentSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.documentSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documentSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenceReferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EvidenceReferencesTable,
          EvidenceReferenceRow,
          $$EvidenceReferencesTableFilterComposer,
          $$EvidenceReferencesTableOrderingComposer,
          $$EvidenceReferencesTableAnnotationComposer,
          $$EvidenceReferencesTableCreateCompanionBuilder,
          $$EvidenceReferencesTableUpdateCompanionBuilder,
          (EvidenceReferenceRow, $$EvidenceReferencesTableReferences),
          EvidenceReferenceRow,
          PrefetchHooks Function({bool auditId, bool sourceId, bool segmentId})
        > {
  $$EvidenceReferencesTableTableManager(
    _$AppDatabase db,
    $EvidenceReferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidenceReferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidenceReferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidenceReferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> auditId = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String?> segmentId = const Value.absent(),
                Value<String> sourceSha256 = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String?> quote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvidenceReferencesCompanion(
                id: id,
                auditId: auditId,
                sourceId: sourceId,
                segmentId: segmentId,
                sourceSha256: sourceSha256,
                location: location,
                quote: quote,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String auditId,
                required String sourceId,
                Value<String?> segmentId = const Value.absent(),
                required String sourceSha256,
                required String location,
                Value<String?> quote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvidenceReferencesCompanion.insert(
                id: id,
                auditId: auditId,
                sourceId: sourceId,
                segmentId: segmentId,
                sourceSha256: sourceSha256,
                location: location,
                quote: quote,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EvidenceReferencesTable, EvidenceReferenceRow>(
                    table,
                  ),
                  $$EvidenceReferencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({auditId = false, sourceId = false, segmentId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (auditId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.auditId,
                            referencedTable: $$EvidenceReferencesTableReferences
                                ._auditIdTable(db),
                            referencedColumn:
                                $$EvidenceReferencesTableReferences
                                    ._auditIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (sourceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sourceId,
                            referencedTable: $$EvidenceReferencesTableReferences
                                ._sourceIdTable(db),
                            referencedColumn:
                                $$EvidenceReferencesTableReferences
                                    ._sourceIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (segmentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.segmentId,
                            referencedTable: $$EvidenceReferencesTableReferences
                                ._segmentIdTable(db),
                            referencedColumn:
                                $$EvidenceReferencesTableReferences
                                    ._segmentIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$EvidenceReferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EvidenceReferencesTable,
      EvidenceReferenceRow,
      $$EvidenceReferencesTableFilterComposer,
      $$EvidenceReferencesTableOrderingComposer,
      $$EvidenceReferencesTableAnnotationComposer,
      $$EvidenceReferencesTableCreateCompanionBuilder,
      $$EvidenceReferencesTableUpdateCompanionBuilder,
      (EvidenceReferenceRow, $$EvidenceReferencesTableReferences),
      EvidenceReferenceRow,
      PrefetchHooks Function({bool auditId, bool sourceId, bool segmentId})
    >;
typedef $$UserActionsTableCreateCompanionBuilder =
    UserActionsCompanion Function({
      required String id,
      required String auditId,
      Value<String?> sourceId,
      required String actionType,
      Value<String?> details,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$UserActionsTableUpdateCompanionBuilder =
    UserActionsCompanion Function({
      Value<String> id,
      Value<String> auditId,
      Value<String?> sourceId,
      Value<String> actionType,
      Value<String?> details,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$UserActionsTableReferences
    extends BaseReferences<_$AppDatabase, $UserActionsTable, UserActionRow> {
  $$UserActionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AuditSessionsTable _auditIdTable(_$AppDatabase db) => db.auditSessions
      .createAlias('user_actions__audit_id__audit_sessions__id');

  $$AuditSessionsTableProcessedTableManager get auditId {
    final $_column = $_itemColumn<String>('audit_id')!;

    final manager = $$AuditSessionsTableTableManager(
      $_db,
      $_db.auditSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_auditIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DocumentSourcesTable _sourceIdTable(_$AppDatabase db) => db
      .documentSources
      .createAlias('user_actions__source_id__document_sources__id');

  $$DocumentSourcesTableProcessedTableManager? get sourceId {
    final $_column = $_itemColumn<String>('source_id');
    if ($_column == null) return null;
    final manager = $$DocumentSourcesTableTableManager(
      $_db,
      $_db.documentSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserActionsTableFilterComposer
    extends Composer<_$AppDatabase, $UserActionsTable> {
  $$UserActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AuditSessionsTableFilterComposer get auditId {
    final $$AuditSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableFilterComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentSourcesTableFilterComposer get sourceId {
    final $$DocumentSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableFilterComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserActionsTable> {
  $$UserActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AuditSessionsTableOrderingComposer get auditId {
    final $$AuditSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentSourcesTableOrderingComposer get sourceId {
    final $$DocumentSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserActionsTable> {
  $$UserActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AuditSessionsTableAnnotationComposer get auditId {
    final $$AuditSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentSourcesTableAnnotationComposer get sourceId {
    final $$DocumentSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.documentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.documentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserActionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserActionsTable,
          UserActionRow,
          $$UserActionsTableFilterComposer,
          $$UserActionsTableOrderingComposer,
          $$UserActionsTableAnnotationComposer,
          $$UserActionsTableCreateCompanionBuilder,
          $$UserActionsTableUpdateCompanionBuilder,
          (UserActionRow, $$UserActionsTableReferences),
          UserActionRow,
          PrefetchHooks Function({bool auditId, bool sourceId})
        > {
  $$UserActionsTableTableManager(_$AppDatabase db, $UserActionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> auditId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserActionsCompanion(
                id: id,
                auditId: auditId,
                sourceId: sourceId,
                actionType: actionType,
                details: details,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String auditId,
                Value<String?> sourceId = const Value.absent(),
                required String actionType,
                Value<String?> details = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UserActionsCompanion.insert(
                id: id,
                auditId: auditId,
                sourceId: sourceId,
                actionType: actionType,
                details: details,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserActionsTable, UserActionRow>(table),
                  $$UserActionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({auditId = false, sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (auditId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.auditId,
                        referencedTable: $$UserActionsTableReferences
                            ._auditIdTable(db),
                        referencedColumn: $$UserActionsTableReferences
                            ._auditIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$UserActionsTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$UserActionsTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserActionsTable,
      UserActionRow,
      $$UserActionsTableFilterComposer,
      $$UserActionsTableOrderingComposer,
      $$UserActionsTableAnnotationComposer,
      $$UserActionsTableCreateCompanionBuilder,
      $$UserActionsTableUpdateCompanionBuilder,
      (UserActionRow, $$UserActionsTableReferences),
      UserActionRow,
      PrefetchHooks Function({bool auditId, bool sourceId})
    >;
typedef $$AnalysisRunsTableCreateCompanionBuilder =
    AnalysisRunsCompanion Function({
      required String id,
      required String auditId,
      required String status,
      required String engine,
      required String reason,
      required String sourceIdsJson,
      Value<String?> modelVersion,
      required DateTime createdAt,
      Value<DateTime?> finishedAt,
      Value<int> rowid,
    });
typedef $$AnalysisRunsTableUpdateCompanionBuilder =
    AnalysisRunsCompanion Function({
      Value<String> id,
      Value<String> auditId,
      Value<String> status,
      Value<String> engine,
      Value<String> reason,
      Value<String> sourceIdsJson,
      Value<String?> modelVersion,
      Value<DateTime> createdAt,
      Value<DateTime?> finishedAt,
      Value<int> rowid,
    });

final class $$AnalysisRunsTableReferences
    extends BaseReferences<_$AppDatabase, $AnalysisRunsTable, AnalysisRunRow> {
  $$AnalysisRunsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AuditSessionsTable _auditIdTable(_$AppDatabase db) => db.auditSessions
      .createAlias('analysis_runs__audit_id__audit_sessions__id');

  $$AuditSessionsTableProcessedTableManager get auditId {
    final $_column = $_itemColumn<String>('audit_id')!;

    final manager = $$AuditSessionsTableTableManager(
      $_db,
      $_db.auditSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_auditIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnalysisRunsTableFilterComposer
    extends Composer<_$AppDatabase, $AnalysisRunsTable> {
  $$AnalysisRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceIdsJson => $composableBuilder(
    column: $table.sourceIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AuditSessionsTableFilterComposer get auditId {
    final $$AuditSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableFilterComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnalysisRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnalysisRunsTable> {
  $$AnalysisRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceIdsJson => $composableBuilder(
    column: $table.sourceIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AuditSessionsTableOrderingComposer get auditId {
    final $$AuditSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnalysisRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnalysisRunsTable> {
  $$AnalysisRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get engine =>
      $composableBuilder(column: $table.engine, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get sourceIdsJson => $composableBuilder(
    column: $table.sourceIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  $$AuditSessionsTableAnnotationComposer get auditId {
    final $$AuditSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnalysisRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnalysisRunsTable,
          AnalysisRunRow,
          $$AnalysisRunsTableFilterComposer,
          $$AnalysisRunsTableOrderingComposer,
          $$AnalysisRunsTableAnnotationComposer,
          $$AnalysisRunsTableCreateCompanionBuilder,
          $$AnalysisRunsTableUpdateCompanionBuilder,
          (AnalysisRunRow, $$AnalysisRunsTableReferences),
          AnalysisRunRow,
          PrefetchHooks Function({bool auditId})
        > {
  $$AnalysisRunsTableTableManager(_$AppDatabase db, $AnalysisRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnalysisRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnalysisRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnalysisRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> auditId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> engine = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> sourceIdsJson = const Value.absent(),
                Value<String?> modelVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnalysisRunsCompanion(
                id: id,
                auditId: auditId,
                status: status,
                engine: engine,
                reason: reason,
                sourceIdsJson: sourceIdsJson,
                modelVersion: modelVersion,
                createdAt: createdAt,
                finishedAt: finishedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String auditId,
                required String status,
                required String engine,
                required String reason,
                required String sourceIdsJson,
                Value<String?> modelVersion = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnalysisRunsCompanion.insert(
                id: id,
                auditId: auditId,
                status: status,
                engine: engine,
                reason: reason,
                sourceIdsJson: sourceIdsJson,
                modelVersion: modelVersion,
                createdAt: createdAt,
                finishedAt: finishedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnalysisRunsTable, AnalysisRunRow>(table),
                  $$AnalysisRunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({auditId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (auditId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.auditId,
                        referencedTable: $$AnalysisRunsTableReferences
                            ._auditIdTable(db),
                        referencedColumn: $$AnalysisRunsTableReferences
                            ._auditIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AnalysisRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnalysisRunsTable,
      AnalysisRunRow,
      $$AnalysisRunsTableFilterComposer,
      $$AnalysisRunsTableOrderingComposer,
      $$AnalysisRunsTableAnnotationComposer,
      $$AnalysisRunsTableCreateCompanionBuilder,
      $$AnalysisRunsTableUpdateCompanionBuilder,
      (AnalysisRunRow, $$AnalysisRunsTableReferences),
      AnalysisRunRow,
      PrefetchHooks Function({bool auditId})
    >;
typedef $$ReportRecordsTableCreateCompanionBuilder =
    ReportRecordsCompanion Function({
      required String id,
      required String auditId,
      required String status,
      Value<String?> localPath,
      Value<String?> contentSha256,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ReportRecordsTableUpdateCompanionBuilder =
    ReportRecordsCompanion Function({
      Value<String> id,
      Value<String> auditId,
      Value<String> status,
      Value<String?> localPath,
      Value<String?> contentSha256,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ReportRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReportRecordsTable, ReportRecordRow> {
  $$ReportRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AuditSessionsTable _auditIdTable(_$AppDatabase db) => db.auditSessions
      .createAlias('report_records__audit_id__audit_sessions__id');

  $$AuditSessionsTableProcessedTableManager get auditId {
    final $_column = $_itemColumn<String>('audit_id')!;

    final manager = $$AuditSessionsTableTableManager(
      $_db,
      $_db.auditSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_auditIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReportRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportRecordsTable> {
  $$ReportRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentSha256 => $composableBuilder(
    column: $table.contentSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AuditSessionsTableFilterComposer get auditId {
    final $$AuditSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableFilterComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReportRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportRecordsTable> {
  $$ReportRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentSha256 => $composableBuilder(
    column: $table.contentSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AuditSessionsTableOrderingComposer get auditId {
    final $$AuditSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReportRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportRecordsTable> {
  $$ReportRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get contentSha256 => $composableBuilder(
    column: $table.contentSha256,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AuditSessionsTableAnnotationComposer get auditId {
    final $$AuditSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.auditSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.auditSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReportRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReportRecordsTable,
          ReportRecordRow,
          $$ReportRecordsTableFilterComposer,
          $$ReportRecordsTableOrderingComposer,
          $$ReportRecordsTableAnnotationComposer,
          $$ReportRecordsTableCreateCompanionBuilder,
          $$ReportRecordsTableUpdateCompanionBuilder,
          (ReportRecordRow, $$ReportRecordsTableReferences),
          ReportRecordRow,
          PrefetchHooks Function({bool auditId})
        > {
  $$ReportRecordsTableTableManager(_$AppDatabase db, $ReportRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> auditId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> contentSha256 = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReportRecordsCompanion(
                id: id,
                auditId: auditId,
                status: status,
                localPath: localPath,
                contentSha256: contentSha256,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String auditId,
                required String status,
                Value<String?> localPath = const Value.absent(),
                Value<String?> contentSha256 = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ReportRecordsCompanion.insert(
                id: id,
                auditId: auditId,
                status: status,
                localPath: localPath,
                contentSha256: contentSha256,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReportRecordsTable, ReportRecordRow>(table),
                  $$ReportRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({auditId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (auditId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.auditId,
                        referencedTable: $$ReportRecordsTableReferences
                            ._auditIdTable(db),
                        referencedColumn: $$ReportRecordsTableReferences
                            ._auditIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReportRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReportRecordsTable,
      ReportRecordRow,
      $$ReportRecordsTableFilterComposer,
      $$ReportRecordsTableOrderingComposer,
      $$ReportRecordsTableAnnotationComposer,
      $$ReportRecordsTableCreateCompanionBuilder,
      $$ReportRecordsTableUpdateCompanionBuilder,
      (ReportRecordRow, $$ReportRecordsTableReferences),
      ReportRecordRow,
      PrefetchHooks Function({bool auditId})
    >;
typedef $$PrivacyPreferenceRowsTableCreateCompanionBuilder =
    PrivacyPreferenceRowsCompanion Function({
      Value<int> id,
      Value<bool> cloudOptIn,
      Value<bool> analyticsOptIn,
      required DateTime updatedAt,
    });
typedef $$PrivacyPreferenceRowsTableUpdateCompanionBuilder =
    PrivacyPreferenceRowsCompanion Function({
      Value<int> id,
      Value<bool> cloudOptIn,
      Value<bool> analyticsOptIn,
      Value<DateTime> updatedAt,
    });

class $$PrivacyPreferenceRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PrivacyPreferenceRowsTable> {
  $$PrivacyPreferenceRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cloudOptIn => $composableBuilder(
    column: $table.cloudOptIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get analyticsOptIn => $composableBuilder(
    column: $table.analyticsOptIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrivacyPreferenceRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrivacyPreferenceRowsTable> {
  $$PrivacyPreferenceRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cloudOptIn => $composableBuilder(
    column: $table.cloudOptIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get analyticsOptIn => $composableBuilder(
    column: $table.analyticsOptIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrivacyPreferenceRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrivacyPreferenceRowsTable> {
  $$PrivacyPreferenceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get cloudOptIn => $composableBuilder(
    column: $table.cloudOptIn,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get analyticsOptIn => $composableBuilder(
    column: $table.analyticsOptIn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PrivacyPreferenceRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrivacyPreferenceRowsTable,
          PrivacyPreferenceRow,
          $$PrivacyPreferenceRowsTableFilterComposer,
          $$PrivacyPreferenceRowsTableOrderingComposer,
          $$PrivacyPreferenceRowsTableAnnotationComposer,
          $$PrivacyPreferenceRowsTableCreateCompanionBuilder,
          $$PrivacyPreferenceRowsTableUpdateCompanionBuilder,
          (
            PrivacyPreferenceRow,
            BaseReferences<
              _$AppDatabase,
              $PrivacyPreferenceRowsTable,
              PrivacyPreferenceRow
            >,
          ),
          PrivacyPreferenceRow,
          PrefetchHooks Function()
        > {
  $$PrivacyPreferenceRowsTableTableManager(
    _$AppDatabase db,
    $PrivacyPreferenceRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrivacyPreferenceRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PrivacyPreferenceRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PrivacyPreferenceRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> cloudOptIn = const Value.absent(),
                Value<bool> analyticsOptIn = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PrivacyPreferenceRowsCompanion(
                id: id,
                cloudOptIn: cloudOptIn,
                analyticsOptIn: analyticsOptIn,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> cloudOptIn = const Value.absent(),
                Value<bool> analyticsOptIn = const Value.absent(),
                required DateTime updatedAt,
              }) => PrivacyPreferenceRowsCompanion.insert(
                id: id,
                cloudOptIn: cloudOptIn,
                analyticsOptIn: analyticsOptIn,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $PrivacyPreferenceRowsTable,
                    PrivacyPreferenceRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PrivacyPreferenceRowsTable,
                    PrivacyPreferenceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrivacyPreferenceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrivacyPreferenceRowsTable,
      PrivacyPreferenceRow,
      $$PrivacyPreferenceRowsTableFilterComposer,
      $$PrivacyPreferenceRowsTableOrderingComposer,
      $$PrivacyPreferenceRowsTableAnnotationComposer,
      $$PrivacyPreferenceRowsTableCreateCompanionBuilder,
      $$PrivacyPreferenceRowsTableUpdateCompanionBuilder,
      (
        PrivacyPreferenceRow,
        BaseReferences<
          _$AppDatabase,
          $PrivacyPreferenceRowsTable,
          PrivacyPreferenceRow
        >,
      ),
      PrivacyPreferenceRow,
      PrefetchHooks Function()
    >;
typedef $$PendingFileDeletesTableCreateCompanionBuilder =
    PendingFileDeletesCompanion Function({
      required String id,
      required String relativePath,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PendingFileDeletesTableUpdateCompanionBuilder =
    PendingFileDeletesCompanion Function({
      Value<String> id,
      Value<String> relativePath,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PendingFileDeletesTableFilterComposer
    extends Composer<_$AppDatabase, $PendingFileDeletesTable> {
  $$PendingFileDeletesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingFileDeletesTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingFileDeletesTable> {
  $$PendingFileDeletesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingFileDeletesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingFileDeletesTable> {
  $$PendingFileDeletesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingFileDeletesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingFileDeletesTable,
          PendingFileDelete,
          $$PendingFileDeletesTableFilterComposer,
          $$PendingFileDeletesTableOrderingComposer,
          $$PendingFileDeletesTableAnnotationComposer,
          $$PendingFileDeletesTableCreateCompanionBuilder,
          $$PendingFileDeletesTableUpdateCompanionBuilder,
          (
            PendingFileDelete,
            BaseReferences<
              _$AppDatabase,
              $PendingFileDeletesTable,
              PendingFileDelete
            >,
          ),
          PendingFileDelete,
          PrefetchHooks Function()
        > {
  $$PendingFileDeletesTableTableManager(
    _$AppDatabase db,
    $PendingFileDeletesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingFileDeletesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingFileDeletesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingFileDeletesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingFileDeletesCompanion(
                id: id,
                relativePath: relativePath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String relativePath,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingFileDeletesCompanion.insert(
                id: id,
                relativePath: relativePath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PendingFileDeletesTable, PendingFileDelete>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $PendingFileDeletesTable,
                    PendingFileDelete
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingFileDeletesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingFileDeletesTable,
      PendingFileDelete,
      $$PendingFileDeletesTableFilterComposer,
      $$PendingFileDeletesTableOrderingComposer,
      $$PendingFileDeletesTableAnnotationComposer,
      $$PendingFileDeletesTableCreateCompanionBuilder,
      $$PendingFileDeletesTableUpdateCompanionBuilder,
      (
        PendingFileDelete,
        BaseReferences<
          _$AppDatabase,
          $PendingFileDeletesTable,
          PendingFileDelete
        >,
      ),
      PendingFileDelete,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AuditSessionsTableTableManager get auditSessions =>
      $$AuditSessionsTableTableManager(_db, _db.auditSessions);
  $$ApplicationSnapshotsTableTableManager get applicationSnapshots =>
      $$ApplicationSnapshotsTableTableManager(_db, _db.applicationSnapshots);
  $$AppPermissionSnapshotsTableTableManager get appPermissionSnapshots =>
      $$AppPermissionSnapshotsTableTableManager(
        _db,
        _db.appPermissionSnapshots,
      );
  $$DocumentSourcesTableTableManager get documentSources =>
      $$DocumentSourcesTableTableManager(_db, _db.documentSources);
  $$DocumentSegmentsTableTableManager get documentSegments =>
      $$DocumentSegmentsTableTableManager(_db, _db.documentSegments);
  $$ConsentUiSourcesTableTableManager get consentUiSources =>
      $$ConsentUiSourcesTableTableManager(_db, _db.consentUiSources);
  $$EvidenceReferencesTableTableManager get evidenceReferences =>
      $$EvidenceReferencesTableTableManager(_db, _db.evidenceReferences);
  $$UserActionsTableTableManager get userActions =>
      $$UserActionsTableTableManager(_db, _db.userActions);
  $$AnalysisRunsTableTableManager get analysisRuns =>
      $$AnalysisRunsTableTableManager(_db, _db.analysisRuns);
  $$ReportRecordsTableTableManager get reportRecords =>
      $$ReportRecordsTableTableManager(_db, _db.reportRecords);
  $$PrivacyPreferenceRowsTableTableManager get privacyPreferenceRows =>
      $$PrivacyPreferenceRowsTableTableManager(_db, _db.privacyPreferenceRows);
  $$PendingFileDeletesTableTableManager get pendingFileDeletes =>
      $$PendingFileDeletesTableTableManager(_db, _db.pendingFileDeletes);
}
