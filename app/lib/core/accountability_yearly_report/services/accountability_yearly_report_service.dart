import 'package:biluca_financas/core/accountability_yearly_report/models/monthly_identifications_summary.dart';
import 'package:biluca_financas/core/accountability_yearly_report/models/monthly_summary.dart';
import 'package:biluca_financas/core/accountability_yearly_report/models/yearly_summary.dart';

abstract class AccountabilityYearlyReportService {
  Future<YearlySummary> summary();
  Future<List<MonthlySummary>> getMonthlySummary();
  Future<List<MonthlyIdentificationsSummary>> getMonthlyIdentificationsSummary();
}
