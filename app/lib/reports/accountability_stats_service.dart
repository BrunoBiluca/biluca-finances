import 'package:biluca_financas/reports/accountability_month_stats.dart';
import 'package:biluca_financas/reports/accountability_year_stats.dart';

abstract interface class AccountabilityStatsService {
  Future<List<AccountabilityMonthStats>> getAllMonthsWithAccountability({bool fillBlanks = false});
  Future<List<AccountabilityYearStats>> getAllYearsWithAccountability({bool fillBlanks = false});
}
