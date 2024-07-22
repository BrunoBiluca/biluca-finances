import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/sqlite/accountability_repo.dart';
import 'package:biluca_financas/sqlite/current_month_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/memory_db_provider.dart';

void main() {
  setUpAll(() async {
    MemoryDBProvider.i.init();

    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var createdAt = DateTime(2024, 7, 7);
    await repo.add(AccountabilityEntryRequest(description: "Descricão fictício", value: 10.00, createdAt: createdAt));
    await repo.add(AccountabilityEntryRequest(description: "Descricão fictício", value: 10.00, createdAt: createdAt));
    await repo.add(AccountabilityEntryRequest(description: "Descricão fictício", value: -10.00, createdAt: createdAt));
    await repo.add(AccountabilityEntryRequest(description: "Descricão fictício", value: -10.00, createdAt: createdAt));
  });

  tearDownAll(() async {
    var db = await MemoryDBProvider.i.database;
    await db.close();
    await MemoryDBProvider.i.clear(db);
  });

  test("should return balance for the current month", () async {
    var service = SQLiteAccontabilityCurrentMonthService(db: await MemoryDBProvider.i.database, month: "07/2024");

    var total = await service.getBalance();

    expect(total, 0.00);
  });

  test("should return sum of accountability expenses for the current month", () async {
    var service = SQLiteAccontabilityCurrentMonthService(db: await MemoryDBProvider.i.database, month: "07/2024");

    var total = await service.getExpenses();

    expect(total, -20.00);
  });

  test("should return sum of accountability incomes for the current month", () async {
    var service = SQLiteAccontabilityCurrentMonthService(db: await MemoryDBProvider.i.database, month: "07/2024");

    var total = await service.getIncomes();

    expect(total, 20.00);
  });
}
