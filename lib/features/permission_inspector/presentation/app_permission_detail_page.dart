import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/konsena_back_button.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../../theme/konsena_spacing.dart';
import '../data/method_channel_permission_inspector.dart';
import '../domain/permission_models.dart';

class AppPermissionDetailPage extends StatefulWidget {
  const AppPermissionDetailPage({
    required this.packageName,
    this.auditId,
    this.repository,
    this.inspector,
    super.key,
  });

  final String packageName;
  final String? auditId;
  final AuditRepository? repository;
  final PermissionInspectorPlatform? inspector;

  @override
  State<AppPermissionDetailPage> createState() =>
      _AppPermissionDetailPageState();
}

class _AppPermissionDetailPageState extends State<AppPermissionDetailPage>
    with WidgetsBindingObserver {
  late final PermissionInspectorPlatform _inspector =
      widget.inspector ?? MethodChannelPermissionInspector();
  ApplicationPermissionSnapshot? _snapshot;
  ApplicationSnapshotRecord? _previousSnapshot;
  String? _error;
  bool _loading = true;
  bool _saving = false;
  bool _returnedFromSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _returnedFromSettings = true;
    if (state == AppLifecycleState.resumed && _returnedFromSettings) {
      _returnedFromSettings = false;
      _refresh();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snapshot = await _inspector.getPermissionSnapshot(
        widget.packageName,
      );
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _previousSnapshot = null;
        _loading = false;
      });
      await _persist(snapshot);
    } on PermissionInspectorException catch (error) {
      final auditId = widget.auditId;
      final repository = widget.repository;
      ApplicationSnapshotRecord? previous;
      if (auditId != null && repository != null) {
        try {
          previous = (await repository.applicationSnapshots(auditId))
              .cast<ApplicationSnapshotRecord?>()
              .firstWhere(
                (record) => record?.packageName == widget.packageName,
                orElse: () => null,
              );
        } on Object {
          // Keep the native error visible even if historical lookup is unavailable.
        }
      }
      if (mounted) {
        setState(() {
          _error = _errorCopy(error);
          _previousSnapshot = previous;
          _loading = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _error = 'Snapshot izin tidak dapat dimuat.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _persist(ApplicationPermissionSnapshot snapshot) async {
    final auditId = widget.auditId;
    final repository = widget.repository;
    if (auditId == null || repository == null) return;
    setState(() => _saving = true);
    try {
      await repository.saveApplicationSnapshot(
        auditId: auditId,
        packageName: snapshot.packageName,
        appLabel: snapshot.label,
        versionName: snapshot.versionName,
        snapshotStatus: snapshot.snapshotStatus,
        visibilityScope: snapshot.visibilityScope,
        androidSdk: snapshot.androidSdk,
        capturedAt: snapshot.capturedAt,
        permissions: snapshot.permissions
            .map(
              (permission) => AppPermissionSnapshot(
                id: '',
                auditId: auditId,
                packageName: snapshot.packageName,
                permissionName: permission.name,
                grantStatus: permission.status.code,
                permissionLabel: permission.label,
                granted: permission.granted,
                flagsAvailable: permission.flagsAvailable,
                androidSdk: snapshot.androidSdk,
                protectionLevel: permission.protectionLevel?.toString(),
                capturedAt: snapshot.capturedAt,
              ),
            )
            .toList(growable: false),
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Snapshot ditampilkan, tetapi belum tersimpan ke audit lokal.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openSettings() async {
    try {
      final opened = await _inspector.openAppSettings(widget.packageName);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Halaman Settings aplikasi tidak tersedia.'),
          ),
        );
      } else {
        _returnedFromSettings = true;
      }
    } on PermissionInspectorException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_errorCopy(error))));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings Android tidak dapat dibuka.')),
        );
      }
    }
  }

  String _errorCopy(PermissionInspectorException error) => switch (error.code) {
    'PACKAGE_NOT_FOUND' => 'Aplikasi sudah tidak terpasang. Snapshot lama, jika ada, bukan status terkini.',
    'NOT_VISIBLE' => 'Package tidak terlihat dalam cakupan launcher Android; aplikasi mungkin dihapus atau tidak terlihat.',
    'ACTIVITY_UNAVAILABLE' =>
      'Halaman Settings aplikasi tidak tersedia pada perangkat ini.',
    'SDK_UNSUPPORTED' =>
      'Pemeriksaan tidak tersedia pada platform atau versi Android ini.',
    _ => 'Snapshot tidak tersedia: ${error.message}',
  };

  String _statusLabel(PermissionFactStatus status) => switch (status) {
    PermissionFactStatus.declaredGranted => 'Diberikan',
    PermissionFactStatus.declaredNotGranted => 'Belum diberikan',
    PermissionFactStatus.nonRuntimeOrUnknown => 'Tidak tersedia',
    PermissionFactStatus.unavailable => 'Tidak tersedia',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const KonsenaBackButton(fallback: '/audit/apps'),
      title: const Text('Detail Izin Aplikasi'),
      actions: [
        IconButton(
          tooltip: 'Refresh snapshot izin',
          onPressed: _loading ? null : _refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(KonsenaSpacing.lg),
      children: [
        Text(
          widget.packageName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: KonsenaSpacing.sm),
        const Text(
          'Snapshot menunjukkan deklarasi dan grant flag yang diekspos PackageManager. Ini bukan pelacakan penggunaan izin.',
        ),
        const SizedBox(height: KonsenaSpacing.md),
        OutlinedButton.icon(
          onPressed: _openSettings,
          icon: const Icon(Icons.settings_outlined),
          label: const Text('Buka Settings Android'),
        ),
        if (_loading) const Text('Memuat snapshot izin…'),
        if (_saving) const Text('Menyimpan snapshot lokal…'),
        if (widget.auditId != null)
          FilledButton(
            onPressed: () => context.go('/audit/${widget.auditId}/sources'),
            child: const Text('Lanjut ke workspace audit'),
          ),
        if (_error != null) ...[
          const SizedBox(height: KonsenaSpacing.md),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          OutlinedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
          if (_previousSnapshot case final previous?) ...[
            const SizedBox(height: KonsenaSpacing.md),
            Text(
              'Snapshot tersimpan — historis, bukan status terkini',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Diambil: ${previous.capturedAt.toLocal()} · API ${previous.androidSdk}',
            ),
            for (final permission in previous.permissions)
              ListTile(
                title: Text(
                  permission.permissionLabel ?? permission.permissionName,
                ),
                subtitle: Text(permission.permissionName),
                trailing: Text(
                  _statusLabel(
                    PermissionFactStatus.fromCode(permission.grantStatus),
                  ),
                ),
              ),
          ],
        ],
        if (_snapshot case final snapshot?) ...[
          const SizedBox(height: KonsenaSpacing.md),
          Text(
            snapshot.label,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text('Versi: ${snapshot.versionName ?? 'Tidak tersedia'}'),
          Text(
            'Android API ${snapshot.androidSdk} · ${snapshot.visibilityScope}',
          ),
          Text('Snapshot: ${snapshot.capturedAt.toLocal()}'),
          const SizedBox(height: KonsenaSpacing.md),
          if (snapshot.permissions.isEmpty)
            const Text(
              'PackageManager tidak melaporkan permission yang diminta untuk aplikasi ini.',
            ),
          for (final permission in snapshot.permissions)
            Card(
              child: ListTile(
                title: Text(permission.label ?? permission.name),
                subtitle: Text(
                  permission.label == null
                      ? 'Label tidak tersedia · ${permission.name}'
                      : permission.name,
                ),
                trailing: Text(_statusLabel(permission.status)),
              ),
            ),
        ],
      ],
    ),
  );
}
