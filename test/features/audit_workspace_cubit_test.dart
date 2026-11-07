import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/data/audit/audit_repository.dart';
import 'package:konsena_ai/data/audit/local_source_file_store.dart';
import 'package:konsena_ai/data/audit/local_data_cipher.dart';
import 'package:konsena_ai/data/local/app_database.dart';
import 'package:konsena_ai/domain/audit/audit_entities.dart';
import 'package:konsena_ai/features/audit/presentation/audit_workspace_cubit.dart';
import 'package:konsena_ai/features/home/data/local_home_summary_repository.dart';

void main() {
  late Directory temp;
  late AppDatabase database;
  late AuditRepository repository;
  late LocalDataCipher cipher;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('workspace_cubit_');
    database = AppDatabase(NativeDatabase(File('${temp.path}/audit.sqlite')));
    cipher = LocalDataCipher(
      keyProvider: MemoryEncryptionKeyProvider(List.filled(32, 7)),
    );
    repository = AuditRepository(
      database: database,
      files: LocalSourceFileStore(
        root: Directory('${temp.path}/sources'),
        cipher: cipher,
      ),
      cipher: cipher,
    );
  });

  tearDown(() async {
    await database.close();
    await temp.delete(recursive: true);
  });

  test('workspace cubit resumes, edits, attaches, reviews and deletes; summary follows', () async {
    final audit = await repository.create(name: 'Draft');
    final cubit = AuditWorkspaceCubit(repository, audit.id);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.session?.id, audit.id);
    await cubit.rename('Draft revisi');
    expect(cubit.state.session?.name, 'Draft revisi');

    await cubit.attach(
      bytes: [1, 2, 3],
      type: AuditSourceType.privacyPolicy,
      mediaType: 'application/octet-stream',
    );
    expect(cubit.state.sources, hasLength(1));
    await cubit.setReviewed(cubit.state.sources.single.id);
    expect(
      cubit.state.sources.single.reviewStatus,
      SourceReviewStatus.reviewed,
    );

    final summaryRepo = LocalHomeSummaryRepository(repository);
    expect((await summaryRepo.load()).auditCount, 1);
    expect((await summaryRepo.load()).findingCount, 0);
    expect(await cubit.deleteAudit(), isTrue);
    expect(cubit.state.sources, isEmpty);
    expect((await summaryRepo.load()).auditCount, 0);
  });

  test(
    'workspace cubit reports deleted/missing ID without synthesizing a session',
    () async {
      final cubit = AuditWorkspaceCubit(repository, 'missing');
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.session, isNull);
      expect(cubit.state.error, isNotNull);
    },
  );
}
