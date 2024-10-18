import 'package:biluca_financas/reports/accountability_month_service.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:biluca_financas/common/data/grouped_by.dart';

class SQLiteAccontabilityMonthService implements AccountabilityMonthService {
  final Database db;
  final DateTime month;
  SQLiteAccontabilityMonthService({required this.db, required this.month});

  String get monthf => DateFormat("MM/yyyy").format(month);

  @override
  Future<double> getSum() async {
    var result = await db.rawQuery(
      """
      SELECT Sum(value) AS total, strftime('%m/%Y', createdAt) AS month
      FROM accountability
      WHERE month == '$monthf'
      GROUP BY month
      """,
    );

    if (result.isEmpty) {
      return 0.00;
    }

    return result.first['total'] as double;
  }

  @override
  Future<double> getExpenses() async {
    var result = await db.rawQuery(
      """
      SELECT Sum(value) AS total, strftime('%m/%Y', createdAt) AS month
      FROM accountability
      WHERE month == '$monthf' AND value < 0
      GROUP BY month
      """,
    );

    if (result.isEmpty) {
      return 0.00;
    }

    return result.first['total'] as double;
  }

  @override
  Future<double> getIncomes() async {
    var result = await db.rawQuery(
      """
      SELECT Sum(value) AS total, strftime('%m/%Y', createdAt) AS month
      FROM accountability
      WHERE month == '$monthf' AND value > 0
      GROUP BY month
      """,
    );

    if (result.isEmpty) {
      return 0.00;
    }

    return result.first['total'] as double;
  }

  @override
  String get currentMonth => monthf;

  @override
  Future<double> getBalance() async {
    var incomes = await getIncomes();
    var expenses = (await getExpenses()).abs();
    return incomes - expenses;
  }

  @override
  Future<List<GroupedBy<AccountabilityIdentification>>> getTotalByIdentification() async {
    var result = await db.rawQuery(
      """
      SELECT ai.id, ai.description, ai.color, ai.icon, Sum(value) AS total, strftime('%m/%Y', createdAt) AS month
      FROM accountability a
      INNER JOIN accountability_identifications ai ON a.identification_id = ai.id
      WHERE month == '$monthf'
      GROUP BY ai.id
      """,
    );

    return result
        .map(
          (e) => GroupedBy(
            AccountabilityIdentification.fromMap({...e}),
            total: e['total'] as double,
          ),
        )
        .toList()
        .sorted((a, b) => b.total!.compareTo(a.total!));
  }

  @override
  Future<int> count() async {
    var result = await db.rawQuery(
      """
      SELECT Count(*) AS total, strftime('%m/%Y', createdAt) AS month
      FROM accountability
      WHERE month == '$monthf'
      """,
    );
    return result.first['total'] as int;
  }

  @override
  Future<List<GroupedBy<AccountabilityIdentification>>> getAccumulatedMeansByIdentification() async {
    var datef = DateFormat("yyyy-MM-dd").format(month);

    var result = await db.rawQuery(
      """
      select ai.id, ai.description, ai.color, ai.icon, a.mean
      from (
        select identification_id,  AVG(total) as mean 
        from(
          SELECT identification_id, strftime('%m/%Y', createdAt) AS month, SUM(value) AS total
          FROM accountability
          WHERE createdAt >= DATE('$datef', '-12 months') and createdAt < DATE('$datef')
          GROUP BY identification_id, month
        )
        group by identification_id
      ) a
      INNER JOIN accountability_identifications ai ON a.identification_id = ai.id
      """,
    );

    return result
        .map(
          (e) => GroupedBy(
            AccountabilityIdentification.fromMap(e),
            mean: e['mean'] == null ? 0.00 : e['mean'] as double,
          ),
        )
        .toList();
  }

  @override
  Future<double> getAccumulatedExpenses() async {
    var datef = DateFormat("yyyy-MM-dd").format(month);

    var result = await db.rawQuery(
      """
      Select AVG(a.total) as mean
      from (
        SELECT SUM(value) AS total, strftime('%m/%Y', createdAt) AS month
        FROM accountability
        WHERE createdAt >= DATE('$datef', '-12 months') and createdAt < DATE('$datef') AND value < 0
        group by month
      ) a
      """,
    );

    if (result.first['mean'] == null) {
      return 0.00;
    }

    return result.first['mean'] as double;
  }

  @override
  Future<double> getAccumulatedIncomes() async {
    var datef = DateFormat("yyyy-MM-dd").format(month);

    var result = await db.rawQuery(
      """
      Select AVG(a.total) as mean
      from (
        SELECT SUM(value) AS total, strftime('%m/%Y', createdAt) AS month
        FROM accountability
        WHERE createdAt >= DATE('$datef', '-12 months') and createdAt < DATE('$datef') AND value > 0
        group by month
      ) a
      """,
    );

    if (result.first['mean'] == null) {
      return 0.00;
    }

    return result.first['mean'] as double;
  }
}
