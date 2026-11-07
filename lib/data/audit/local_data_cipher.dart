import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class LocalEncryptionKeyProvider {
  Future<List<int>> getOrCreateKey();
}

/// Stores an installation-scoped data key in platform secure storage.
/// On Android, flutter_secure_storage protects the key with Android Keystore.
class SecureStorageEncryptionKeyProvider implements LocalEncryptionKeyProvider {
  SecureStorageEncryptionKeyProvider({
    FlutterSecureStorage? storage,
    this.allowCreate = true,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const _keyName = 'konsena.local_data_key.v1';
  final FlutterSecureStorage _storage;
  final bool allowCreate;

  @override
  Future<List<int>> getOrCreateKey() async {
    final encoded = await _storage.read(key: _keyName);
    if (encoded != null) {
      final key = base64Decode(encoded);
      if (key.length != 32) throw const LocalEncryptionKeyException();
      return key;
    }
    if (!allowCreate) throw const LocalEncryptionKeyException();
    final generated = await AesGcm.with256bits().newSecretKey();
    final key = await generated.extractBytes();
    await _storage.write(key: _keyName, value: base64Encode(key));
    return key;
  }
}

/// AES-256-GCM for app-private source files and sensitive SQLite fields.
/// Encodings are versioned to permit future key/format migrations.
class LocalDataCipher {
  LocalDataCipher({required this.keyProvider});

  final LocalEncryptionKeyProvider keyProvider;
  final AesGcm _algorithm = AesGcm.with256bits();
  static const _fileMagic = [0x4b, 0x53, 0x41, 0x01]; // KSA + format v1

  Future<List<int>> encryptBytes(List<int> plaintext) async {
    final box = await _algorithm.encrypt(
      plaintext,
      secretKey: SecretKey(await keyProvider.getOrCreateKey()),
    );
    return <int>[
      ..._fileMagic,
      ...box.nonce,
      ...box.mac.bytes,
      ...box.cipherText,
    ];
  }

  Future<List<int>> decryptBytes(List<int> encrypted) async {
    if (encrypted.length < _fileMagic.length + 12 + 16 ||
        !_startsWith(encrypted, _fileMagic)) {
      throw const LocalEncryptionFormatException();
    }
    const nonceStart = 4;
    const tagStart = nonceStart + 12;
    const cipherStart = tagStart + 16;
    final box = SecretBox(
      encrypted.sublist(cipherStart),
      nonce: encrypted.sublist(nonceStart, tagStart),
      mac: Mac(encrypted.sublist(tagStart, cipherStart)),
    );
    try {
      return await _algorithm.decrypt(
        box,
        secretKey: SecretKey(await keyProvider.getOrCreateKey()),
      );
    } on SecretBoxAuthenticationError {
      throw const LocalEncryptionAuthenticationException();
    }
  }

  Future<String> encryptText(String plaintext) async {
    final sealed = await encryptBytes(utf8.encode(plaintext));
    return 'enc:v1:${base64Encode(sealed)}';
  }

  Future<String> decryptText(String ciphertext) async {
    const prefix = 'enc:v1:';
    if (!ciphertext.startsWith(prefix)) {
      throw const LocalEncryptionFormatException();
    }
    final bytes = await decryptBytes(
      base64Decode(ciphertext.substring(prefix.length)),
    );
    return utf8.decode(bytes);
  }

  bool _startsWith(List<int> bytes, List<int> prefix) {
    for (var i = 0; i < prefix.length; i++) {
      if (bytes[i] != prefix[i]) return false;
    }
    return true;
  }
}

/// In-memory key provider for deterministic lifecycle tests only.
class MemoryEncryptionKeyProvider implements LocalEncryptionKeyProvider {
  MemoryEncryptionKeyProvider([List<int>? key])
    : _key = key == null ? null : List.of(key);
  List<int>? _key;

  @override
  Future<List<int>> getOrCreateKey() async => List.unmodifiable(
    _key ??= List<int>.generate(32, (_) => Random.secure().nextInt(256)),
  );
}

class LocalEncryptionKeyException implements Exception {
  const LocalEncryptionKeyException();
}

class LocalEncryptionFormatException implements Exception {
  const LocalEncryptionFormatException();
}

class LocalEncryptionAuthenticationException implements Exception {
  const LocalEncryptionAuthenticationException();
}
