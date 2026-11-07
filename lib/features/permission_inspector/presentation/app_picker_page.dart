import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/konsena_spacing.dart';
import '../data/method_channel_permission_inspector.dart';
import '../domain/permission_models.dart';

class AppPickerPage extends StatefulWidget {
  const AppPickerPage({required this.auditId, this.inspector, super.key});

  final String? auditId;
  final PermissionInspectorPlatform? inspector;

  @override
  State<AppPickerPage> createState() => _AppPickerPageState();
}

class _AppPickerPageState extends State<AppPickerPage> {
  late final PermissionInspectorPlatform _inspector =
      widget.inspector ?? MethodChannelPermissionInspector();
  final _searchController = TextEditingController();
  List<VisibleApplication> _apps = const [];
  bool _loading = true;
  String? _error;
  final String _visibilityScope = 'launcher_query';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final apps = await _inspector.listVisibleLaunchableApps();
      if (!mounted) return;
      setState(() {
        _apps = apps;
        _loading = false;
      });
    } on PermissionInspectorException catch (error) {
      if (mounted)
        setState(() {
          _error = error.message;
          _loading = false;
        });
    } on Object {
      if (mounted)
        setState(() {
          _error = 'Daftar aplikasi tidak tersedia.';
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _apps
        .where(
          (app) =>
              app.label.toLowerCase().contains(query) ||
              app.packageName.toLowerCase().contains(query),
        )
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Aplikasi'),
        actions: [
          IconButton(
            tooltip: 'Segarkan daftar aplikasi',
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(KonsenaSpacing.lg),
        children: [
          const Text(
            'Daftar terbatas pada aplikasi yang dapat dibuka dari launcher dan terlihat oleh Android untuk KONSENA. Ini bukan daftar semua aplikasi di perangkat.',
          ),
          const SizedBox(height: KonsenaSpacing.md),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Cari nama atau package ID',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: KonsenaSpacing.sm),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null) ...[
            const SizedBox(height: KonsenaSpacing.md),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: KonsenaSpacing.sm),
            OutlinedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ] else if (!_loading && filtered.isEmpty) ...[
            const SizedBox(height: KonsenaSpacing.md),
            Text(
              _apps.isEmpty
                  ? 'Tidak ada hasil yang terlihat pada cakupan launcher saat ini. Ini tidak membuktikan perangkat tidak memiliki aplikasi lain.'
                  : 'Tidak ada aplikasi yang cocok dengan pencarian.',
            ),
          ],
          for (final app in filtered)
            Card(
              child: ListTile(
                leading: const Icon(Icons.android),
                title: Text(app.label),
                subtitle: Text(
                  '${app.packageName}${app.versionName == null ? '' : ' · ${app.versionName}'}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final auditQuery = widget.auditId == null
                      ? ''
                      : '?auditId=${Uri.encodeQueryComponent(widget.auditId!)}';
                  context.push(
                    '/audit/apps/${Uri.encodeComponent(app.packageName)}$auditQuery',
                  );
                },
              ),
            ),
          const SizedBox(height: KonsenaSpacing.sm),
          Text('Cakupan hasil: $_visibilityScope'),
        ],
      ),
    );
  }
}
