import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/accountability/services/repo.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../accountability/models/entry.dart';
import '../../accountability/models/entry_request.dart';

class SQLiteAccountabilityRepo implements AccountabilityRepo {
  final Database db;
  SQLiteAccountabilityRepo(this.db);

  String tableName = "accountability";

  @override
  Future<List<AccountabilityEntry>> getEntries({int limit = 10, int offset = 0}) async {
    return await db.rawQuery(
      """
    select 
      a.*, 
      ai.id as ai_id,
      ai.description as ai_description,
      ai.color as ai_color
    from $tableName a
    left join accountability_identifications ai on a.identification_id = ai.id
    order by createdAt desc
    ${limit > 0 ? "limit $limit" : ""}
    ${offset > 0 ? "offset $offset" : ""}
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

  @override
  Future<AccountabilityEntry> getById(int id) async {
    var entry = (await db.query(tableName, where: "id = ?", whereArgs: [id])).first;
    var result = AccountabilityEntry.fromMap(entry);
    if (result.identificationId != null) {
      result.identification = await getIdentification(result.identificationId!);
    }
    return result;
  }

  @override
  Future<AccountabilityEntry> add(AccountabilityEntryRequest req) async {
    String? identificationId = await addOrGetIdentification(req.identification);

    var newId = await db.rawInsert("""
    INSERT INTO $tableName (description, value, createdAt, insertedAt, updatedAt, identification_id)
    VALUES (?, ?, ?, ?, ?, ?);
    """, [
      req.description,
      req.value,
      req.createdAt.toIso8601String(),
      DateTime.now().toIso8601String(),
      DateTime.now().toIso8601String(),
      identificationId
    ]);

    return getById(newId);
  }

  @override
  Future<String?> addOrGetIdentification(AccountabilityIdentification? identification) async {
    String? identificationId;
    if (identification != null) {
      var dbIdentification = await getIdentification(identification.id);

      if (dbIdentification != null) {
        identificationId = dbIdentification.id;
      } else {
        var newIdentification = await addIdentification(identification);
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
    String? identificationId = await addOrGetIdentification(entry.identification);

    var updatedEntry = entry.toMap();
    updatedEntry["updatedAt"] = DateTime.now().toIso8601String();
    updatedEntry["identification_id"] = identificationId;
    await db.update(
      tableName,
      updatedEntry,
      where: "id = ?",
      whereArgs: [entry.id],
    );
    return getById(entry.id);
  }

  @override
  Future<List<AccountabilityIdentification>> getIdentifications() async {
    return await db
        .query("accountability_identifications")
        .then((value) => value.map((e) => AccountabilityIdentification.fromMap(e)).toList());
  }

  @override
  Future<AccountabilityIdentification?> getIdentification(String identificationId) async {
    var result = await db.query(
      "accountability_identifications",
      where: "id = ?",
      whereArgs: [identificationId],
    );

    if (result.isEmpty) {
      return null;
    }

    return AccountabilityIdentification.fromMap(result.first);
  }

  @override
  Future<AccountabilityIdentification> addIdentification(AccountabilityIdentification identification) async {
    await db.rawInsert("""
    INSERT INTO accountability_identifications (id, description, color, insertedAt, updatedAt)
    VALUES (?, ?, ?, ?, ?);
    """, [
      identification.id,
      identification.description,
      identification.color.value,
      DateTime.now().toIso8601String(),
      DateTime.now().toIso8601String()
    ]);
    return identification;
  }

  @override
  Future<void> updateIdentification(AccountabilityIdentification updatedIdentification) async {
    var map = updatedIdentification.toMap();
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
    await db.delete("accountability_identifications", where: "id = ?", whereArgs: [id]);
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
}
