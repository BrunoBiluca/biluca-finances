import 'package:biluca_financas/accountability/current_month_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SQLiteAccontabilityCurrentMonthService implements AccountabilityCurrentMonthService {
  final Database db;
  final String month;
  SQLiteAccontabilityCurrentMonthService({required this.db, required this.month});

  @override
  Future<double> getBalance() async {
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
}
