import 'package:biluca_financas/reports/current_month_service.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:collection/collection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../common/data/grouped_by.dart';

class SQLiteAccontabilityCurrentMonthService implements AccountabilityCurrentMonthService {
  final Database db;
  final String month;
  SQLiteAccontabilityCurrentMonthService({required this.db, required this.month});

  @override
  Future<double> getSum() async {
    var result = await db.rawQuery(
      """
      SELECT Sum(value) AS total, strftime('%m/%Y', createdAt) AS month
      FROM accountability
      WHERE month == '$month'
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
      WHERE month == '$month' AND value < 0
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
      WHERE month == '$month' AND value > 0
      GROUP BY month
      """,
    );

    if (result.isEmpty) {
      return 0.00;
    }

    return result.first['total'] as double;
  }

  @override
  String get currentMonth => month;

  @override
  Future<double> getBalance() async {
    var incomes = await getIncomes();
    var expenses = (await getExpenses()).abs();
    return incomes / expenses - 1.0;
  }

  @override
  Future<List<GroupedBy<AccountabilityIdentification>>> getTotalByIdentification() async {
    var result = await db.rawQuery(
      """
      SELECT ai.id, ai.description, ai.color, Sum(value) AS total, strftime('%m/%Y', createdAt) AS month
      FROM accountability a
      INNER JOIN accountability_identifications ai ON a.identification_id = ai.id
      WHERE month == '$month'
      GROUP BY ai.id
      """,
    );

    return result
        .map(
          (e) => GroupedBy(
            AccountabilityIdentification.fromMap(e),
            e['total'] as double,
          ),
        )
        .toList()
        .sorted((a, b) => b.total.compareTo(a.total));
  }

  @override
  Future<int> count() async {
    var result = await db.rawQuery(
      """
      SELECT Count(*) AS total, strftime('%m/%Y', createdAt) AS month
      FROM accountability
      WHERE month == '$month'
      """,
    );
    return result.first['total'] as int;
  }
}
