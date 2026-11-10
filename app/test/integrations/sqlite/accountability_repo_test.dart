import 'dart:convert';
import 'dart:io';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:biluca_financas/integrations/sqlite/sqlite_accountability_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'helpers/memory_db_provider.dart';

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<LoggerManager>(LoggerManager());
    MemoryDBProvider.i.init();
  });

  tearDown(() async {
    var db = await MemoryDBProvider.i.database;
    await db.close();
    await MemoryDBProvider.i.clear(db);
  });

  test("should return an empty list when nothing is stored", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);
    final entries = await repo.getEntries();
    expect(entries, isEmpty);
  });

  test("should return an accountability entry when stored", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);
    var req = AccountabilityEntryRequest(
        description: "Descricão fictício",
        value: 10.00,
        createdAt: DateTime.now());
    await repo.add(req);

    final entries = await repo.getEntries();

    expect(entries, isNotEmpty);
    expect(entries.length, 1);
  });

  test("should return accountability entries limited by 10 when stored",
      () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    for (var i = 0; i < 20; i++) {
      await repo.add(
        AccountabilityEntryRequest(
          description: "${i + 1}",
          value: 10.00,
          createdAt: DateTime.now().add(Duration(seconds: i)),
        ),
      );
    }

    final entries = await repo.getEntries(limit: 10);
    final entries2 = await repo.getEntries(limit: 10, offset: 10);

    expect(entries.length, 10);
    for (var i = 0; i < 10; i++) {
      expect(entries[i].description, "${20 - i}");
    }

    expect(entries2.length, 10);
    for (var i = 0; i < 10; i++) {
      expect(entries2[i].description, "${10 - i}");
    }
  });

  test("should search entries by description and filter by identification",
      () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);
    final lunch = AccountabilityIdentification("Lunch", Colors.green);
    final groceries = AccountabilityIdentification("Groceries", Colors.blue);

    await repo.add(
      AccountabilityEntryRequest(
        description: "Restaurant payment",
        value: 22,
        createdAt: DateTime.now(),
        identification: lunch,
      ),
    );
    await repo.add(
      AccountabilityEntryRequest(
        description: "Restaurant payment",
        value: 45,
        createdAt: DateTime.now().add(const Duration(seconds: 1)),
        identification: groceries,
      ),
    );

    final entries = await repo.searchEntries(
      searchQuery: "Restaurant",
      identificationId: lunch.id,
    );

    expect(entries, hasLength(1));
    expect(entries.single.identification?.id, lunch.id);

    final categoryMatches = await repo.searchEntries(
      searchQuery: "Lunch",
      identificationId: lunch.id,
    );
    expect(categoryMatches, hasLength(1));
  });

  test("should search alternative descriptions before applying the page limit",
      () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);
    final targetDate = DateTime(2020);
    final target = await repo.add(
      AccountabilityEntryRequest(
        description: "Original description",
        value: 10,
        createdAt: targetDate,
      ),
    );
    target.descriptionAlt = "Unique searchable transaction";
    await repo.update(target);

    for (var i = 0; i < 105; i++) {
      await repo.add(
        AccountabilityEntryRequest(
          description: "Unrelated transaction $i",
          value: 10,
          createdAt: DateTime(2021).add(Duration(seconds: i)),
        ),
      );
    }

    final entries =
        await repo.searchEntries(searchQuery: "Unique searchable", limit: 10);

    expect(entries, hasLength(1));
    expect(entries.single.id, target.id);
  });

  test("should paginate matching entries without duplicates", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    for (var i = 0; i < 25; i++) {
      await repo.add(
        AccountabilityEntryRequest(
          description: "Matching transaction $i",
          value: 10,
          createdAt: DateTime(2022).add(Duration(seconds: i)),
        ),
      );
    }

    final firstPage = await repo.searchEntries(
        searchQuery: "Matching transaction", limit: 10);
    final secondPage = await repo.searchEntries(
        searchQuery: "Matching transaction", limit: 10, offset: 10);
    final thirdPage = await repo.searchEntries(
        searchQuery: "Matching transaction", limit: 10, offset: 20);
    final ids = [...firstPage, ...secondPage, ...thirdPage]
        .map((entry) => entry.id)
        .toSet();

    expect(firstPage, hasLength(10));
    expect(secondPage, hasLength(10));
    expect(thirdPage, hasLength(5));
    expect(ids, hasLength(25));
  });

  test("should search entries by Brazilian and simple monetary values",
      () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);
    final entry = await repo.add(
      AccountabilityEntryRequest(
        description: "Transaction without an amount in its description",
        value: 1234.56,
        createdAt: DateTime.now(),
      ),
    );

    final brazilianFormat =
        await repo.searchEntries(searchQuery: "R\$ 1.234,56");
    final simpleFormat = await repo.searchEntries(searchQuery: "1234.56");

    expect(brazilianFormat.map((result) => result.id), contains(entry.id));
    expect(simpleFormat.map((result) => result.id), contains(entry.id));
  });

  test("should add an accountability entry", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var req = AccountabilityEntryRequest(
        description: "Descricão fictício",
        value: 10.00,
        createdAt: DateTime.now());
    var newEntry = await repo.add(req);

    expect(newEntry.description, req.description);
    expect(newEntry.value, req.value);
    expect(newEntry.identification, isNull);
    expect(newEntry.createdAt, req.createdAt);
    expect(newEntry.insertedAt, isNotNull);
    expect(newEntry.updatedAt, isNotNull);
  });

  test("should delete an accountability entry", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var req = AccountabilityEntryRequest(
        description: "Descricão fictício",
        value: 10.00,
        createdAt: DateTime.now());
    var newEntry = await repo.add(req);
    await repo.delete(newEntry);
    final entries = await repo.getEntries();
    expect(entries, isEmpty);
  });

  test("should not update an accountability entry original description",
      () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var req = AccountabilityEntryRequest(
        description: "Descricão fictício",
        value: 10.00,
        createdAt: DateTime.now());
    var newEntry = await repo.add(req);
    newEntry.description = "Descricão atualizada";

    sleep(const Duration(milliseconds: 10));
    await repo.update(newEntry);
    final updatedEntry = (await repo.getEntries()).first;

    expect(updatedEntry.description, "Descricão fictício");
    expect(updatedEntry.updatedAt.microsecondsSinceEpoch,
        greaterThan(newEntry.updatedAt.microsecondsSinceEpoch));
  });

  test("should update an accountability entry alternative description",
      () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var req = AccountabilityEntryRequest(
        description: "Descricão fictício",
        value: 10.00,
        createdAt: DateTime.now());
    var newEntry = await repo.add(req);
    newEntry.descriptionAlt = "Descricão atualizada";

    sleep(const Duration(milliseconds: 10));
    await repo.update(newEntry);
    final updatedEntry = (await repo.getEntries()).first;

    expect(updatedEntry.description, "Descricão fictício");
    expect(updatedEntry.descriptionAlt, "Descricão atualizada");
    expect(updatedEntry.updatedAt.microsecondsSinceEpoch,
        greaterThan(newEntry.updatedAt.microsecondsSinceEpoch));
  });

  test("should update an accountability entry with identification", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var expectedIdentification =
        AccountabilityIdentification("Identificação fictício", Colors.blue);

    var req = AccountabilityEntryRequest(
      description: "Descricão fictício",
      value: 10.00,
      createdAt: DateTime.now(),
    );

    var newEntry = await repo.add(req);
    sleep(const Duration(milliseconds: 10));

    newEntry.identification = expectedIdentification;
    final updatedEntry = await repo.update(newEntry);

    expect(updatedEntry, isNotNull);
    expect(updatedEntry.identification, isNotNull);
    expect(updatedEntry.identification!.description,
        expectedIdentification.description);
    expect(updatedEntry.identification!.color.toARGB32(),
        expectedIdentification.color.toARGB32());

    final entries = await repo.getEntries();

    expect(entries, isNotEmpty);
    expect(entries.length, 1);
    expect(entries[0].identification, isNotNull);
    expect(entries[0].identification!.id, expectedIdentification.id);
    expect(entries[0].identification!.description,
        expectedIdentification.description);
    expect(entries[0].identification!.color.toARGB32(),
        expectedIdentification.color.toARGB32());
  });

  test("should add entry with identification", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var expectedIdentification =
        AccountabilityIdentification("Identificação fictício", Colors.blue);
    var req = AccountabilityEntryRequest(
      description: "Descricão fictício",
      value: 10.00,
      createdAt: DateTime.now(),
      identification: expectedIdentification,
    );
    var newEntry = await repo.add(req);

    expect(newEntry.identification, isNotNull);
    expect(newEntry.identification!.description,
        expectedIdentification.description);
    expect(newEntry.identification!.color.toARGB32(),
        expectedIdentification.color.toARGB32());
  });

  test("should update a identification", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var expectedIdentification =
        AccountabilityIdentification("Identificação fictício", Colors.blue);
    repo.addIdentification(expectedIdentification);

    sleep(const Duration(milliseconds: 10));

    expectedIdentification.description = "Identificação atualizada";
    expectedIdentification.color = Colors.red;
    await repo.updateIdentification(expectedIdentification);
    var updatedIdentification =
        await repo.getIdentification(expectedIdentification.id);

    expect(updatedIdentification, isNotNull);
    expect(
        updatedIdentification!.description, expectedIdentification.description);
    expect(updatedIdentification.color.toARGB32(),
        expectedIdentification.color.toARGB32());
  });

  test("should delete an identification", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var expectedIdentification =
        AccountabilityIdentification("Identificação fictício", Colors.blue);
    repo.addIdentification(expectedIdentification);

    sleep(const Duration(milliseconds: 10));

    await repo.deleteIdentification(expectedIdentification.id);

    var identifications = await repo.getIdentifications();
    expect(identifications, isEmpty);
  });

  test("deve retornar nada se a entrada de contabilidade não existe na base",
      () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);
    var result = await repo.exists(
      AccountabilityEntryRequest(
        description: "Descrição 1",
        value: 10.00,
        createdAt: DateTime.now(),
      ),
    );
    expect(result, isNull);
  });

  test("deve retornar a entrada se existe na base", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var req = AccountabilityEntryRequest(
      description: "Descrição 1",
      value: 10.00,
      createdAt: DateTime.now(),
    );

    await repo.add(req);

    var result = await repo.exists(req);
    expect(result, isNotNull);
    expect(result!.description, req.description);
    expect(result.value, req.value);
    expect(result.createdAt, req.createdAt);
  });

  test("should persist the identification hierarchy and status", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);
    final parent = AccountabilityIdentification("Parent", Colors.blue);
    final child = AccountabilityIdentification(
      "Child",
      Colors.green,
      parentId: parent.id,
      discontinued: true,
      type: AccountabilityIdentificationType.income,
    )..icon = Icons.restaurant;

    await repo.addIdentification(parent);
    await repo.addIdentification(child);

    final loaded = await repo.getIdentification(child.id);

    expect(loaded, isNotNull);
    expect(loaded!.parentId, parent.id);
    expect(loaded.discontinued, isTrue);
    expect(loaded.type, AccountabilityIdentificationType.income);
    expect(loaded.icon, Icons.restaurant);
    expect(loaded.color.toARGB32(), Colors.green.toARGB32());
  });

  test("should read legacy identifications as active roots", () async {
    final db = await MemoryDBProvider.i.database;
    final repo = SQLiteAccountabilityRepo(db);
    final icon = {
      'code': Icons.help_outline.codePoint,
      'fontFamily': Icons.help_outline.fontFamily,
      'fontPackage': Icons.help_outline.fontPackage,
    };

    await db.rawInsert(
      "INSERT INTO accountability_identifications (id, description, color, icon, type, insertedAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?)",
      [
        "legacy-identification",
        "Legacy",
        Colors.blue.toARGB32(),
        jsonEncode(icon),
        "expense",
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String(),
      ],
    );

    final loaded = await repo.getIdentification("legacy-identification");

    expect(loaded, isNotNull);
    expect(loaded!.parentId, isNull);
    expect(loaded.discontinued, isFalse);
  });

  test(
      "should unidentify entries and promote children when deleting an identification",
      () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);
    final parent = AccountabilityIdentification("Parent", Colors.blue);
    final child = AccountabilityIdentification(
      "Child",
      Colors.green,
      parentId: parent.id,
    );
    await repo.addIdentification(parent);
    await repo.addIdentification(child);

    final entry = await repo.add(
      AccountabilityEntryRequest(
        description: "Entry identified by the parent",
        value: 42,
        createdAt: DateTime(2026),
        identification: parent,
      ),
    );

    await repo.deleteIdentification(parent.id);

    final entries = await repo.getEntries();
    final updatedEntry = entries.single;
    expect(updatedEntry.id, entry.id);
    expect(updatedEntry.description, entry.description);
    expect(updatedEntry.value, entry.value);
    expect(updatedEntry.createdAt, entry.createdAt);
    expect(updatedEntry.identificationId, isNull);
    expect(updatedEntry.identification, isNull);

    final updatedChild = await repo.getIdentification(child.id);
    expect(updatedChild, isNotNull);
    expect(updatedChild!.parentId, isNull);
    expect(await repo.getIdentification(parent.id), isNull);
  });
}
