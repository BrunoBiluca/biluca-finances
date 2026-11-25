import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_filter.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:biluca_financas/core/accountability/services/accountability_search_query.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';

class SQLiteAccountabilityRepo implements AccountabilityRepo {
  final Database db;
  SQLiteAccountabilityRepo(this.db);

  String tableName = "accountability";

  @override
  Future<List<AccountabilityEntry>> getEntries(
      {int limit = 10, int offset = 0}) {
    return searchEntries(searchQuery: "", limit: limit, offset: offset);
  }

  @override
  Future<List<AccountabilityEntry>> searchEntries({
    required String searchQuery,
    int limit = 10,
    int offset = 0,
    String? identificationId,
    AccountabilityEntryFilter filter = AccountabilityEntryFilter.empty,
  }) async {
    final whereArgs = <Object?>[];
    final whereClause = _whereClause(
      searchQuery: searchQuery,
      identificationId: identificationId,
      filter: filter,
      args: whereArgs,
    );

    whereArgs.addAll([limit > 0 ? limit : -1, offset]);
    return await db.rawQuery(
      """
    select 
      a.*, 
      ai.id as ai_id,
      ai.description as ai_description,
      ai.color as ai_color,
      ai.icon as ai_icon,
      ai.type as ai_type
    from $tableName a
    left join accountability_identifications ai on a.identification_id = ai.id
    $whereClause
    order by createdAt desc
    limit ? offset ?
    """,
      whereArgs,
    ).then((value) => value.map(
          (e) {
            var ai = <String, dynamic>{};
            for (var key in e.keys) {
              if (key.startsWith('ai_') && e[key] != null) {
                ai[key.replaceFirst('ai_', '')] = e[key];
              }
            }
            return AccountabilityEntry.fromMap({
              'identification': ai.isEmpty ? null : ai,
              ...e,
            });
          },
        ).toList());
  }

  @override
  Future<int> countEntries({
    required String searchQuery,
    String? identificationId,
    AccountabilityEntryFilter filter = AccountabilityEntryFilter.empty,
  }) async {
    final whereArgs = <Object?>[];
    final whereClause = _whereClause(
      searchQuery: searchQuery,
      identificationId: identificationId,
      filter: filter,
      args: whereArgs,
    );

    final result = await db.rawQuery(
      """
    select count(1) as total
    from $tableName a
    left join accountability_identifications ai on a.identification_id = ai.id
    $whereClause
    """,
      whereArgs,
    );

    return (result.first['total'] as int?) ?? 0;
  }

  String _whereClause({
    required String searchQuery,
    required String? identificationId,
    required AccountabilityEntryFilter filter,
    required List<Object?> args,
  }) {
    final conditions = <String>[];
    final normalizedQuery = searchQuery.trim();

    if (normalizedQuery.isNotEmpty) {
      final pattern = "%$normalizedQuery%";
      final searchTerms = <String>[
        "a.description LIKE ?",
        "a.description_alt LIKE ?",
        "ai.description LIKE ?",
      ];
      args.addAll([pattern, pattern, pattern]);
      final amountInCents =
          AccountabilitySearchQuery.amountInCents(normalizedQuery);
      if (amountInCents != null) {
        searchTerms.add("CAST(ROUND(ABS(a.value) * 100) AS INTEGER) = ?");
        args.add(amountInCents);
      }
      conditions.add("(${searchTerms.join(" OR ")})");
    }

    if (identificationId != null) {
      conditions.add("a.identification_id = ?");
      args.add(identificationId);
    }

    final periodStart = filter.periodStart;
    if (periodStart != null) {
      conditions.add("a.createdAt >= ?");
      args.add(periodStart.toIso8601String());
    }

    final periodEnd = filter.periodEnd;
    if (periodEnd != null) {
      conditions.add("a.createdAt <= ?");
      args.add(periodEnd.toIso8601String());
    }

    if (filter.minValue != null) {
      conditions.add("a.value >= ?");
      args.add(filter.minValue);
    }

    if (filter.maxValue != null) {
      conditions.add("a.value <= ?");
      args.add(filter.maxValue);
    }

    return conditions.isEmpty ? "" : "WHERE ${conditions.join(" AND ")}";
  }

  @override
  Future<AccountabilityEntry> getById(int id) async {
    var entry =
        (await db.query(tableName, where: "id = ?", whereArgs: [id])).first;
    var result = AccountabilityEntry.fromMap(entry);
    if (result.identificationId != null) {
      result.identification = await getIdentification(result.identificationId!);
    }
    return result;
  }

  @override
  Future<AccountabilityEntry> add(AccountabilityEntryRequest req) async {
    final newId = await db.transaction((txn) => _insert(txn, req));

    return getById(newId);
  }

  @override
  Future<void> addAll(List<AccountabilityEntryRequest> requests) async {
    if (requests.isEmpty) return;

    await db.transaction((txn) async {
      for (final request in requests) {
        await _insert(txn, request);
      }
    });
  }

  Future<int> _insert(
    DatabaseExecutor executor,
    AccountabilityEntryRequest req,
  ) async {
    String? identificationId =
        await _addOrGetIdentification(executor, req.identification);

    return executor.rawInsert("""
    INSERT INTO $tableName (description, value, createdAt, insertedAt, updatedAt, identification_id, description_alt)
    VALUES (?, ?, ?, ?, ?, ?, ?);
    """, [
      req.description,
      req.value,
      req.createdAt.toIso8601String(),
      DateTime.now().toIso8601String(),
      DateTime.now().toIso8601String(),
      identificationId,
      req.descriptionAlt,
    ]);
  }

  @override
  Future<String?> addOrGetIdentification(
      AccountabilityIdentification? identification) {
    return _addOrGetIdentification(db, identification);
  }

  Future<String?> _addOrGetIdentification(
    DatabaseExecutor executor,
    AccountabilityIdentification? identification,
  ) async {
    String? identificationId;
    if (identification != null) {
      var dbIdentification =
          await _getIdentification(executor, identification.id);

      if (dbIdentification != null) {
        identificationId = dbIdentification.id;
      } else {
        var newIdentification =
            await _addIdentification(executor, identification);
        identificationId = newIdentification.id;
      }
    }
    return identificationId;
  }

  @override
  Future<void> delete(AccountabilityEntry entry) async {
    await db.delete(tableName, where: "id = ?", whereArgs: [entry.id]);
  }

  @override
  Future<AccountabilityEntry> update(AccountabilityEntry entry) async {
    String? identificationId =
        await addOrGetIdentification(entry.identification);

    await db.update(
      tableName,
      {
        "value": entry.value,
        "updatedAt": DateTime.now().toIso8601String(),
        "description_alt": entry.descriptionAlt,
        "identification_id": identificationId,
      },
      where: "id = ?",
      whereArgs: [entry.id],
    );
    return getById(entry.id);
  }

  @override
  Future<List<AccountabilityIdentification>> getIdentifications() async {
    return await db.query("accountability_identifications").then((value) =>
        value.map((e) => AccountabilityIdentification.fromMap(e)).toList());
  }

  @override
  Future<AccountabilityIdentification?> getIdentification(
      String identificationId) {
    return _getIdentification(db, identificationId);
  }

  Future<AccountabilityIdentification?> _getIdentification(
    DatabaseExecutor executor,
    String identificationId,
  ) async {
    var result = await executor.query(
      "accountability_identifications",
      where: "id = ?",
      whereArgs: [identificationId],
    );

    if (result.isEmpty) {
      return null;
    }

    var idResult = {
      ...result.first,
      "icon": json.decode(result.first["icon"] as String),
    };

    return AccountabilityIdentification.fromMap(idResult);
  }

  @override
  Future<AccountabilityIdentification> addIdentification(
      AccountabilityIdentification identification) {
    return _addIdentification(db, identification);
  }

  Future<AccountabilityIdentification> _addIdentification(
    DatabaseExecutor executor,
    AccountabilityIdentification identification,
  ) async {
    var identificationMap = identification.toMap();

    await executor.rawInsert("""
    INSERT INTO accountability_identifications (id, description, description_detail, color, icon, type, parent_id, discontinued, insertedAt, updatedAt)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """, [
      identificationMap["id"],
      identificationMap["description"],
      identificationMap["description_detail"],
      identificationMap["color"],
      json.encode(identificationMap["icon"]),
      identificationMap["type"],
      identificationMap["parent_id"],
      identificationMap["discontinued"],
      DateTime.now().toIso8601String(),
      DateTime.now().toIso8601String()
    ]);
    return identification;
  }

  @override
  Future<void> updateIdentification(
      AccountabilityIdentification updatedIdentification) async {
    var map = updatedIdentification.toMap();
    map["icon"] = json.encode(map["icon"]);
    map["updatedAt"] = DateTime.now().toIso8601String();
    await db.update(
      "accountability_identifications",
      map,
      where: "id = ?",
      whereArgs: [updatedIdentification.id],
    );
  }

  @override
  Future<void> deleteIdentification(String id) async {
    await db.transaction((txn) async {
      final updatedAt = DateTime.now().toIso8601String();

      await txn.update(
        tableName,
        {
          "identification_id": null,
          "updatedAt": updatedAt,
        },
        where: "identification_id = ?",
        whereArgs: [id],
      );

      await txn.update(
        "accountability_identifications",
        {
          "parent_id": null,
          "updatedAt": updatedAt,
        },
        where: "parent_id = ?",
        whereArgs: [id],
      );

      await txn.delete(
        "accountability_identifications",
        where: "id = ?",
        whereArgs: [id],
      );
    });
  }

  @override
  Future<AccountabilityEntry?> exists(AccountabilityEntryRequest req) async {
    var result = await db.query(
      tableName,
      where: "description = ? AND value = ? AND createdAt = ?",
      whereArgs: [req.description, req.value, req.createdAt.toIso8601String()],
    );
    if (result.isEmpty) {
      return null;
    }
    var entry = AccountabilityEntry.fromMap(result.first);

    if (entry.identificationId != null) {
      entry.identification = await getIdentification(entry.identificationId!);
    }

    return entry;
  }

  @override
  Future<List<AccountabilityEntry>> getEntriesByIdentification(
      AccountabilityIdentification identification) async {
    return await db.rawQuery(
      """
    select 
      a.*, 
      ai.id as ai_id,
      ai.description as ai_description,
      ai.color as ai_color,
      ai.icon as ai_icon,
      ai.type as ai_type,
      strftime('%m/%Y', a.createdAt) AS month
    from accountability a
    left join accountability_identifications ai on a.identification_id = ai.id
    AND a.identification_id = '${identification.id}'
    order by a.createdAt desc
    """,
    ).then((value) => value.map(
          (e) {
            var ai = <String, dynamic>{};
            for (var key in e.keys) {
              if (key.startsWith('ai_') && e[key] != null) {
                ai[key.replaceFirst('ai_', '')] = e[key];
              }
            }
            return AccountabilityEntry.fromMap({
              'identification': ai.isEmpty ? null : ai,
              ...e,
            });
          },
        ).toList());
  }
}
