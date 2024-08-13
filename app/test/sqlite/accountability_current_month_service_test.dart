import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/sqlite/accountability/accountability_repo.dart';
import 'package:biluca_financas/sqlite/accountability/current_month_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/memory_db_provider.dart';

void main() {
  var currentMonth = "07/2024";

  setUpAll(() async {
    MemoryDBProvider.i.init();

    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var id1 = AccountabilityIdentification("Descricão fictício 1", Colors.red);
    var id2 = AccountabilityIdentification("Descricão fictício 2", Colors.blue);

    var aid1 = await repo.addIdentification(id1);
    var aid2 = await repo.addIdentification(id2);

    var createdAt = DateTime(2024, 7, 7); // 07/07/2024
    await repo.add(AccountabilityEntryRequest(
        description: "Descricão fictício", value: 10.00, createdAt: createdAt, identification: aid1));
    await repo.add(AccountabilityEntryRequest(
        description: "Descricão fictício", value: 10.00, createdAt: createdAt, identification: aid1));
    await repo.add(AccountabilityEntryRequest(
        description: "Descricão fictício", value: -10.00, createdAt: createdAt, identification: aid2));
    await repo.add(AccountabilityEntryRequest(
        description: "Descricão fictício", value: -10.00, createdAt: createdAt, identification: aid2));
  });

  tearDownAll(() async {
    var db = await MemoryDBProvider.i.database;
    await db.close();
    await MemoryDBProvider.i.clear(db);
  });

  test("deve retornar zero quando nenhum registro encontrado", () async {
    var service = SQLiteAccontabilityCurrentMonthService(db: await MemoryDBProvider.i.database, month: "06/2024");

    var count = await service.count();

    expect(count, 0);
  });

  test("deve retornar a quantidade de registros do mês atual", () async {
    var service = SQLiteAccontabilityCurrentMonthService(db: await MemoryDBProvider.i.database, month: currentMonth);

    var count = await service.count();

    expect(count, 4);
  });

  test("should return balance for the current month", () async {
    var service = SQLiteAccontabilityCurrentMonthService(db: await MemoryDBProvider.i.database, month: currentMonth);

    var total = await service.getBalance();

    expect(total, 0.00);
  });

  test("should return sum of accountability expenses for the current month", () async {
    var service = SQLiteAccontabilityCurrentMonthService(db: await MemoryDBProvider.i.database, month: currentMonth);

    var total = await service.getExpenses();

    expect(total, -20.00);
  });

  test("should return sum of accountability incomes for the current month", () async {
    var service = SQLiteAccontabilityCurrentMonthService(db: await MemoryDBProvider.i.database, month: currentMonth);

    var total = await service.getIncomes();

    expect(total, 20.00);
  });

  test("should return the sum by identification for the current month", () async {
    var service = SQLiteAccontabilityCurrentMonthService(db: await MemoryDBProvider.i.database, month: currentMonth);

    var totalByIdentification = await service.getTotalByIdentification();

    expect(totalByIdentification[0].field.description, "Descricão fictício 1");
    expect(totalByIdentification[0].total, 20.00);
    expect(totalByIdentification[1].field.description, "Descricão fictício 2");
    expect(totalByIdentification[1].total, -20.00);
  });
}
