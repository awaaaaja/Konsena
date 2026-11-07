import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'local_data_cipher.dart';

class StoredSourceFile {
  const StoredSourceFile({
    required this.id,
    required this.relativePath,
    required this.sha256,
    required this.byteLength,
  });

  final String id;
  final String relativePath;
  final String sha256;
  final int byteLength;
}

/// Stores encrypted user-selected source bytes under app-private storage.
/// Callers must never log bytes or paths.
class LocalSourceFileStore {
  LocalSourceFileStore({required this._root, required this.cipher, Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final Directory _root;
  final LocalDataCipher cipher;
  final Uuid _uuid;

  static Future<LocalSourceFileStore> openDefault({
    required LocalDataCipher cipher,
  }) async {
    final support = await getApplicationSupportDirectory();
    final root = Directory(p.join(support.path, 'audit_sources'));
    await root.create(recursive: true);
    return LocalSourceFileStore(root: root, cipher: cipher);
  }

  Future<StoredSourceFile> write(List<int> bytes, {String? id}) async {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes.length, 'bytes', 'must not be empty');
    }
    final fileId = id ?? _uuid.v4();
    _validateId(fileId);
    final relative = p.join(fileId.substring(0, 2), '$fileId.source');
    final target = _resolve(relative);
    await target.parent.create(recursive: true);
    final temp = File('${target.path}.tmp-${_uuid.v4()}');
    try {
      await temp.writeAsBytes(await cipher.encryptBytes(bytes), flush: true);
      await temp.rename(target.path);
    } on Object {
      if (await temp.exists()) await temp.delete();
      rethrow;
    }
    return StoredSourceFile(
      id: fileId,
      relativePath: relative,
      sha256: sha256.convert(bytes).toString(),
      byteLength: bytes.length,
    );
  }

  Future<List<int>> read(
    String relativePath, {
    required String expectedSha256,
  }) async {
    final file = _resolve(relativePath);
    if (!await file.exists()) throw const SourceFileMissingException();
    final bytes = await cipher.decryptBytes(await file.readAsBytes());
    if (sha256.convert(bytes).toString() != expectedSha256) {
      throw const SourceFileIntegrityException();
    }
    return bytes;
  }

  Future<void> delete(String relativePath) async {
    final file = _resolve(relativePath);
    if (await file.exists()) await file.delete();
    final parent = file.parent;
    if (await parent.exists() && await parent.list().isEmpty) {
      await parent.delete();
    }
  }

  Future<Set<String>> listStoredRelativePaths() async {
    if (!await _root.exists()) return const {};
    final result = <String>{};
    await for (final entity in _root.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File && entity.path.endsWith('.source')) {
        result.add(p.relative(entity.path, from: _root.path));
      }
    }
    return result;
  }

  Future<void> removeTemporaryFiles() async {
    if (!await _root.exists()) return;
    await for (final entity in _root.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File && p.basename(entity.path).contains('.tmp-')) {
        await entity.delete();
      }
    }
  }

  File _resolve(String relativePath) {
    final normalized = p.normalize(relativePath);
    if (p.isAbsolute(normalized) ||
        normalized.startsWith('..') ||
        normalized.contains('/../')) {
      throw const InvalidSourcePathException();
    }
    final rootPath = p.normalize(_root.absolute.path);
    final target = p.normalize(p.join(rootPath, normalized));
    if (!p.isWithin(rootPath, target)) throw const InvalidSourcePathException();
    return File(target);
  }

  void _validateId(String id) {
    if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(id)) {
      throw const InvalidSourcePathException();
    }
  }
}

class InvalidSourcePathException implements Exception {
  const InvalidSourcePathException();
}

class SourceFileMissingException implements Exception {
  const SourceFileMissingException();
}

class SourceFileIntegrityException implements Exception {
  const SourceFileIntegrityException();
}
