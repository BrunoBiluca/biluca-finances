import 'dart:io';
import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/sqlite/sqlite_accountability_repo.dart';
import 'package:flutter/material.dart';
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

  test("should return an empty list when nothing is stored", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);
    final entries = await repo.getEntries();
    expect(entries, isEmpty);
  });

  test("should return an accountability entry when stored", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);
    var req = AccountabilityEntryRequest(description: "Descricão fictício", value: 10.00, createdAt: DateTime.now());
    await repo.add(req);

    final entries = await repo.getEntries();

    expect(entries, isNotEmpty);
    expect(entries.length, 1);
  });

  test("should return accountability entries limited by 10 when stored", () async {
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

  test("should add an accountability entry", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var req = AccountabilityEntryRequest(description: "Descricão fictício", value: 10.00, createdAt: DateTime.now());
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

    var req = AccountabilityEntryRequest(description: "Descricão fictício", value: 10.00, createdAt: DateTime.now());
    var newEntry = await repo.add(req);
    await repo.delete(newEntry);
    final entries = await repo.getEntries();
    expect(entries, isEmpty);
  });

  test("should update an accountability entry", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var req = AccountabilityEntryRequest(description: "Descricão fictício", value: 10.00, createdAt: DateTime.now());
    var newEntry = await repo.add(req);
    newEntry.description = "Descricão atualizada";

    sleep(const Duration(milliseconds: 10));
    await repo.update(newEntry);
    final updatedEntry = (await repo.getEntries()).first;

    expect(updatedEntry.description, "Descricão atualizada");
    expect(updatedEntry.updatedAt.microsecondsSinceEpoch, greaterThan(newEntry.updatedAt.microsecondsSinceEpoch));
  });

  test("should update an accountability entry with identification", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var req = AccountabilityEntryRequest(
      description: "Descricão fictício",
      value: 10.00,
      createdAt: DateTime.now(),
    );
    var newEntry = await repo.add(req);

    sleep(const Duration(milliseconds: 10));
    var expectedIdentification = AccountabilityIdentification("Identificação fictício", Colors.blue);
    newEntry.identification = expectedIdentification;
    await repo.update(newEntry);
    final updatedEntry = await repo.getById(newEntry.id);

    expect(updatedEntry, isNotNull);
    expect(updatedEntry.identification, isNotNull);
    expect(updatedEntry.identification!.description, expectedIdentification.description);
    expect(updatedEntry.identification!.color.value, expectedIdentification.color.value);

    final entries = await repo.getEntries();

    expect(entries, isNotEmpty);
    expect(entries.length, 1);
    expect(entries[0].identification, isNotNull);
    expect(entries[0].identification!.id, expectedIdentification.id);
    expect(entries[0].identification!.description, expectedIdentification.description);
    expect(entries[0].identification!.color.value, expectedIdentification.color.value);
  });

  test("should add entry with identification", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var expectedIdentification = AccountabilityIdentification("Identificação fictício", Colors.blue);
    var req = AccountabilityEntryRequest(
      description: "Descricão fictício",
      value: 10.00,
      createdAt: DateTime.now(),
      identification: expectedIdentification,
    );
    var newEntry = await repo.add(req);

    expect(newEntry.identification, isNotNull);
    expect(newEntry.identification!.description, expectedIdentification.description);
    expect(newEntry.identification!.color.value, expectedIdentification.color.value);
  });

  test("should update a identification", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var expectedIdentification = AccountabilityIdentification("Identificação fictício", Colors.blue);
    repo.addIdentification(expectedIdentification);

    sleep(const Duration(milliseconds: 10));

    expectedIdentification.description = "Identificação atualizada";
    expectedIdentification.color = Colors.red;
    await repo.updateIdentification(expectedIdentification);
    var updatedIdentification = await repo.getIdentification(expectedIdentification.id);

    expect(updatedIdentification, isNotNull);
    expect(updatedIdentification!.description, expectedIdentification.description);
    expect(updatedIdentification.color.value, expectedIdentification.color.value);
  });

  test("should delete an identification", () async {
    final repo = SQLiteAccountabilityRepo(await MemoryDBProvider.i.database);

    var expectedIdentification = AccountabilityIdentification("Identificação fictício", Colors.blue);
    repo.addIdentification(expectedIdentification);

    sleep(const Duration(milliseconds: 10));

    await repo.deleteIdentification(expectedIdentification.id);

    var identifications = await repo.getIdentifications();
    expect(identifications, isEmpty);
  });
}
