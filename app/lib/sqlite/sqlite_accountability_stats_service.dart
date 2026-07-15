import 'package:biluca_financas/common/extensions/datetime_extensions.dart';
import 'package:biluca_financas/reports/accountability_month_stats.dart';
import 'package:biluca_financas/reports/accountability_stats_service.dart';
import 'package:biluca_financas/reports/accountability_year_stats.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteAccountabilityStatsService implements AccountabilityStatsService {
  final Database db;
  SqliteAccountabilityStatsService({required this.db});

  @override
  Future<List<AccountabilityMonthStats>> getAllMonthsWithAccountability({bool fillBlanks = false}) async {
    var months = await db.rawQuery(
      """
        SELECT 
          strftime('%Y/%m', createdAt) AS month, 
          count(1) as entriesCount
        FROM accountability a 
        GROUP BY "month"
        ORDER by "month"
      """,
    ).then(
      (value) => value
          .map(
            (e) => AccountabilityMonthStats.fromMap(e),
          )
          .toList(),
    );

    if (fillBlanks) {
      var first = DateFormat("yyyy/MM").parse(months.first.month);
      var last = DateTime.now();

      var current = first;
      while (current.isBefore(last)) {
        var monthStr = DateFormat("yyyy/MM").format(current);
        if (!months.any((e) => e.month == monthStr)) {
          months.add(AccountabilityMonthStats(monthStr, 0));
        }
        current = current.addMonth(1);
      }
    }

    months.sort((a, b) => a.month.compareTo(b.month));

    return months;
  }

  @override
  Future<List<AccountabilityYearStats>> getAllYearsWithAccountability({bool fillBlanks = false}) async {
    var lastYear = await db.rawQuery("""
        SELECT COUNT(*) AS total
        FROM accountability
        WHERE createdAt  >= DATE('now', '-365 days');
      """).then((value) => AccountabilityYearStats("Últimos 12 meses", value.first['total'] as int));

    var years = await db.rawQuery(
      """
        SELECT 
          strftime('%Y', createdAt) AS year, 
          count(1) as entriesCount
        FROM accountability a 
        GROUP BY "year"
        ORDER by "year" DESC
      """,
    ).then(
      (value) => value
          .map(
            (e) => AccountabilityYearStats.fromMap(e),
          )
          .toList(),
    );

    if (fillBlanks) {
      var first = DateFormat("yyyy").parse(years.first.year);
      var last = DateTime.now();

      var current = first;
      while (current.isBefore(last)) {
        var yearStr = DateFormat("yyyy").format(current);
        if (!years.any((e) => e.year == yearStr)) {
          years.add(AccountabilityYearStats(yearStr, 0));
        }
        current = current.add(const Duration(days: 365));
      }
    }

    return [lastYear, ...years];
  }
}
