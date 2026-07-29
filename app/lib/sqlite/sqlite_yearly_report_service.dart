import 'package:biluca_financas/reports/yearly_report/yearly_report_service.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteYearlyReportService extends YearlyReportService {
  final Database db;
  final DateTime start;
  final DateTime end;

  SqliteYearlyReportService({required this.start, required this.end, required this.db});

  String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  Future<YearlySummary> summary() async {
    var startDate = formatDate(start);
    var endDate = formatDate(end);

    var totals = await db.rawQuery(
      """
      SELECT 
        totalExpenses,
        totalIncomes,
        totalIncomes - ABS(totalExpenses) as balance
      FROM (
        SELECT 
          COALESCE(SUM(CASE WHEN i.type = 'expense' THEN value ELSE 0 END), 0) AS totalExpenses,
          COALESCE(SUM(CASE WHEN i.type = 'income' THEN value ELSE 0 END), 0) AS totalIncomes 
        FROM accountability a
        join accountability_identifications i on i.id = a.identification_id
        where a.createdAt BETWEEN '$startDate' AND '$endDate'
      );
      """,
    );

    var avgs = await db.rawQuery(
      """
      SELECT 
        AVG(expenses) as avgExpenses,
        AVG(incomes) as avgIncomes,
        AVG(balances) as avgBalances
      from (
        SELECT 
          expenses,
          incomes,
          incomes - ABS(expenses) as balances
        FROM (
        SELECT 
          strftime('%Y-%m', a.createdAt) AS month,
          COALESCE(SUM(CASE WHEN i.type = 'expense' THEN value ELSE 0 END), 0) AS expenses,
          COALESCE(SUM(CASE WHEN i.type = 'income' THEN value ELSE 0 END), 0) AS incomes 
        FROM accountability a
        join accountability_identifications i on i.id = a.identification_id
        where a.createdAt BETWEEN '$startDate' AND '$endDate'
        group by month
        )
      );
      """,
    );

    return YearlySummary(
        balance: totals.first["balance"] as double,
        avgBalance: avgs.first["avgBalances"] as double,
        totalIncomes: totals.first["totalIncomes"] as double,
        avgIncomes: avgs.first["avgIncomes"] as double,
        totalExpenses: totals.first["totalExpenses"] as double,
        avgExpenses: avgs.first["avgExpenses"] as double);
  }

  @override
  Future<List<MonthlySummary>> getMonthlySummary() {
    var startDate = formatDate(start);
    var endDate = formatDate(end);

    return db.rawQuery(
      """
      SELECT 
        expenses,
        incomes,
        incomes - ABS(expenses) as balance,
        month
      FROM (
        SELECT 
          strftime('%Y-%m', a.createdAt) AS month,
          COALESCE(SUM(CASE WHEN i.type = 'expense' THEN value ELSE 0 END), 0) AS expenses,
          COALESCE(SUM(CASE WHEN i.type = 'income' THEN value ELSE 0 END), 0) AS incomes 
        FROM accountability a
        join accountability_identifications i on i.id = a.identification_id
        where a.createdAt BETWEEN '$startDate' AND '$endDate'
          group by month
      )
      """,
    ).then((value) => value
        .map(
          (e) => MonthlySummary(
            balance: e["balance"] as double,
            sumIncomes: e["incomes"] as double,
            sumExpenses: e["expenses"] as double,
            month: e["month"] as String,
          ),
        )
        .toList());
  }
}
