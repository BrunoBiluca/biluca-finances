import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/extensions/datetime_extensions.dart';
import 'package:biluca_financas/common/logging/console_listener.dart';
import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:biluca_financas/sqlite/accountability/accountability_repo.dart';
import 'package:biluca_financas/sqlite/accountability/accountability_month_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'helpers/memory_db_provider.dart';

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<LoggerManager>(LoggerManager()..init([ConsoleLoggingListener()]));
  });

  var currentMonth = DateTime(2024, 7);
  SQLiteAccountabilityRepo? arepo;

  setUp(() async {
    MemoryDBProvider.i.init();

    arepo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);
    var repo = arepo!;

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

  tearDown(() async {
    arepo = null;
    var db = await MemoryDBProvider.i.database;
    await db.close();
    await MemoryDBProvider.i.clear(db);
  });

  test("deve retornar zero quando nenhum registro encontrado", () async {
    var service = SQLiteAccontabilityMonthService(
      db: await MemoryDBProvider.i.database,
      month: currentMonth.subtractMonth(1),
    );

    var count = await service.count();

    expect(count, 0);
  });

  test("deve retornar a quantidade de registros do mês atual", () async {
    var service = SQLiteAccontabilityMonthService(db: await MemoryDBProvider.i.database, month: currentMonth);

    var count = await service.count();

    expect(count, 4);
  });

  test("should return zero balance for the current month", () async {
    var service = SQLiteAccontabilityMonthService(db: await MemoryDBProvider.i.database, month: currentMonth);

    var total = await service.getBalance();

    expect(total, 0.00);
  });

  test("should return positive balance", () async {
    await arepo!.add(
      AccountabilityEntryRequest(
        description: "Descricão fictício",
        value: 10.00,
        createdAt: currentMonth,
      ),
    );

    var service = SQLiteAccontabilityMonthService(
      db: await MemoryDBProvider.i.database,
      month: currentMonth,
    );

    var total = await service.getBalance();

    expect(total, 10.00);
  });

  test("should return negative balance", () async {
    await arepo!.add(
      AccountabilityEntryRequest(
        description: "Descricão fictício",
        value: -10.00,
        createdAt: currentMonth,
      ),
    );

    var service = SQLiteAccontabilityMonthService(
      db: await MemoryDBProvider.i.database,
      month: currentMonth,
    );

    var total = await service.getBalance();

    expect(total, -10.00);
  });
  test("should return sum of accountability expenses for the current month", () async {
    var service = SQLiteAccontabilityMonthService(db: await MemoryDBProvider.i.database, month: currentMonth);

    var total = await service.getExpenses();

    expect(total, -20.00);
  });

  test("should return sum of accountability incomes for the current month", () async {
    var service = SQLiteAccontabilityMonthService(db: await MemoryDBProvider.i.database, month: currentMonth);

    var total = await service.getIncomes();

    expect(total, 20.00);
  });

  test("should return the sum by identification for the current month", () async {
    var service = SQLiteAccontabilityMonthService(db: await MemoryDBProvider.i.database, month: currentMonth);

    var totalByIdentification = await service.getTotalByIdentification();

    expect(totalByIdentification[0].field.description, "Descricão fictício 1");
    expect(totalByIdentification[0].total, 20.00);
    expect(totalByIdentification[1].field.description, "Descricão fictício 2");
    expect(totalByIdentification[1].total, -20.00);
  });
}
