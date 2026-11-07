import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/data/audit/audit_repository.dart';
import 'package:konsena_ai/data/audit/local_data_cipher.dart';
import 'package:konsena_ai/data/audit/local_source_file_store.dart';
import 'package:konsena_ai/data/local/app_database.dart';
import 'package:konsena_ai/domain/audit/audit_entities.dart';

void main() {
  test(
    'guest audit create, attach, restart, resume and delete stays local',
    () async {
      final temp = await Directory.systemTemp.createTemp('local_audit_flow_');
      final key = List<int>.filled(32, 5);
      final cipher = LocalDataCipher(
        keyProvider: MemoryEncryptionKeyProvider(key),
      );
      AppDatabase openDatabase() =>
          AppDatabase(NativeDatabase(File('${temp.path}/db.sqlite')));
      AuditRepository openRepository(AppDatabase db) => AuditRepository(
        database: db,
        files: LocalSourceFileStore(
          root: Directory('${temp.path}/sources'),
          cipher: cipher,
        ),
        cipher: cipher,
      );

      var database = openDatabase();
      var repository = openRepository(database);
      final audit = await repository.create(name: 'Audit offline');
      final source = await repository.attachSource(
        auditId: audit.id,
        bytes: [1, 2, 3, 4],
        type: AuditSourceType.privacyPolicy,
        mediaType: 'text/plain',
        originalName: 'policy.txt',
      );
      expect(await repository.sessionCount(), 1);
      await database.close();

      database = openDatabase();
      repository = openRepository(database);
      final resumed = await repository.get(audit.id);
      expect(resumed?.name, 'Audit offline');
      expect((await repository.sources(audit.id)).single.id, source.id);
      expect(await repository.readSource(source.id), [1, 2, 3, 4]);

      await repository.deleteAudit(audit.id);
      expect(await repository.sessionCount(), 0);
      expect(await repository.get(audit.id), isNull);
      await database.close();
      await temp.delete(recursive: true);
    },
  );
}
