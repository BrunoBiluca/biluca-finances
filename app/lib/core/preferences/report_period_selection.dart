import 'package:biluca_financas/core/accountability_stats/models/accountability_month_stats.dart';
import 'package:biluca_financas/core/accountability_stats/models/accountability_year_stats.dart';

/// Resolves the report period restored from the stored preference.
class ReportPeriodSelection {
  static AccountabilityMonthStats? resolveMonth({
    required List<AccountabilityMonthStats> availableMonths,
    required String? savedMonth,
  }) {
    if (availableMonths.isEmpty) return null;
    return availableMonths.firstWhere(
      (month) => month.month == savedMonth,
      orElse: () => availableMonths.last,
    );
  }

  static AccountabilityYearStats? resolveYear({
    required List<AccountabilityYearStats> availableYears,
    required String? savedYear,
  }) {
    if (availableYears.isEmpty) return null;
    return availableYears.firstWhere(
      (year) => year.year == savedYear,
      orElse: () => availableYears.first,
    );
  }
}
