import 'dart:io';

import 'package:biluca_financas/sqlite/accountability/accountability_repo.dart';
import 'package:biluca_financas/sqlite/accountability/import_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

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
    var db = await MemoryDBProvider.i.database;
    var repo = SQLiteAccountabilityRepo(db);
    var service = SQLiteAccountabilityImportService(repo: repo);

    var importedFile = await testFile(DateFormat("yyyy-mm-dd"));
    await service.import(importedFile);

    var result = await db.rawQuery("select count(*) as total from accountability");

    expect(result.first['total'], 2);
  });

  test("deve permitir importar entradas em outros formatos de datas", () async {
    var db = await MemoryDBProvider.i.database;
    var repo = SQLiteAccountabilityRepo(db);
    var service = SQLiteAccountabilityImportService(repo: repo);

    var importedFile = await testFile(DateFormat("dd/mm/yyyy"));
    await service.import(importedFile);

    var result = await db.rawQuery("select count(*) as total from accountability");
    
    expect(result.first['total'], 2);
  });
}

Future<File> testFile(dataFormatter) async {
  var dir = Directory.systemTemp.createTempSync();
  var temp = await File("${dir.path}/test.csv").create();
  await temp.writeAsString(
    """Criação,Descrição,Valor,Tipo,Identificação
${dataFormatter.format(DateTime.now())},RSCSS-MASENDEMATE-31/07,-21.7,saída,supermercado
${dataFormatter.format(DateTime.now())},RSCSS-SUPERMERCAD-31/07,-43.45,saída,supermercado""",
  );
  return temp;
}
