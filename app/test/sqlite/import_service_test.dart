import 'dart:io';

import 'package:biluca_financas/sqlite/accountability/accountability_repo.dart';
import 'package:biluca_financas/sqlite/accountability/import_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/memory_db_provider.dart';

void main() {
  setUpAll(() {
    MemoryDBProvider.i.init();
  });

  tearDown(() async {
    var db = await MemoryDBProvider.i.database;
    await db.close();
    await MemoryDBProvider.i.clear(db);
  });

  test("deve permitir importar entradas de um arquivo CSV", () async {
    var dir = Directory.systemTemp.createTempSync();
    var temp = await File("${dir.path}/test.csv").create();
    await temp.writeAsString(
      """Criação,Descrição,Valor,Tipo,Identificação
2024-07-31,RSCSS-MASENDEMATE-31/07,-21.7,saída,supermercado
2024-07-31,RSCSS-SUPERMERCAD-31/07,-43.45,saída,supermercado""",
    );

    var db = await MemoryDBProvider.i.database;
    var repo = SQLiteAccountabilityRepo(db);
    var service = SQLiteAccountabilityImportService(repo);

    await service.import(temp);

    var result = await db.rawQuery("select count(*) as total from accountability");

    expect(result.first['total'], 2);
  });
}
