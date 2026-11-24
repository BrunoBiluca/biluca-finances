import 'dart:io';

import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:biluca_financas/integrations/sqlite/db_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FileDBProvider extends DBProvider {
  _FileDBProvider(this.path);

  final String path;

  @override
  Future<String> getDBPath() async => path;
}

void main() {
  late Directory tempDir;

  setUpAll(() {
    GetIt.I.registerSingleton<LoggerManager>(LoggerManager());
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('biluca_db_provider');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test("cria um banco novo já na versão atual", () async {
    final provider = _FileDBProvider(p.join(tempDir.path, 'myDb.db'));

    final db = await provider.database;

    expect(await db.getVersion(), provider.schemaVersion);

    final columns = await db.rawQuery(
      "PRAGMA table_info('accountability_identifications')",
    );
    expect(columns.map((column) => column['name']),
        contains('description_detail'));

    await db.close();
  });

  test("atualiza a versão de um banco cujo esquema já está aplicado", () async {
    final dbPath = p.join(tempDir.path, 'myDb.db');
    final drifted = _FileDBProvider(dbPath);

    // Reproduz o estado de um banco restaurado de backup: todas as migrações
    // aplicadas, mas a versão registrada ficou em 5.
    final legacy = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 5,
        onCreate: (db, version) async {
          await drifted.execute(db, drifted.migrationsSQL);
        },
      ),
    );
    await legacy.insert('accountability_identifications', {
      'id': 'identificacao-existente',
      'description': 'Supermercado',
    });
    await legacy.close();

    final provider = _FileDBProvider(dbPath);
    final db = await provider.database;

    expect(await db.getVersion(), provider.schemaVersion);

    final rows = await db.query('accountability_identifications');
    expect(rows, hasLength(1));
    expect(rows.single['description'], 'Supermercado');
    expect(rows.single['type'], 'expense');

    await db.close();
  });

  test("propaga erros que não são de migração já aplicada", () async {
    final provider = _FileDBProvider(p.join(tempDir.path, 'myDb.db'));
    final db = await provider.database;

    await expectLater(
      provider.execute(db, [
        'ALTER TABLE accountability_identifications ADD COLUMN',
      ]),
      throwsA(isA<DatabaseException>()),
    );

    await db.close();
  });
}
