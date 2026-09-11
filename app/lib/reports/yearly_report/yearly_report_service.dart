import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';

abstract class YearlyReportService {
  Future<YearlySummary> summary();
  Future<List<MonthlySummary>> getMonthlySummary();
  Future<List<MonthlyIdentificationsSummary>> getMonthlyIdentificationsSummary();
}

class YearlySummary {
  final double balance;
  final double avgBalance;
  final double totalExpenses;
  final double totalIncomes;
  final double avgExpenses;
  final double avgIncomes;
  YearlySummary({
    required this.balance,
    required this.avgBalance,
    required this.totalExpenses,
    required this.totalIncomes,
    required this.avgExpenses,
    required this.avgIncomes,
  });
}

class MonthlySummary {
  final double balance;
  final double sumExpenses;
  final double sumIncomes;
  final String month;
  MonthlySummary({
    required this.balance,
    required this.sumExpenses,
    required this.sumIncomes,
    required this.month,
  });
}

class MonthlyIdentificationsSummary {
  final AccountabilityIdentification identification;
  final Map<String, double> monthTotal;
  MonthlyIdentificationsSummary({
    required this.identification,
    required this.monthTotal,
  });
}
