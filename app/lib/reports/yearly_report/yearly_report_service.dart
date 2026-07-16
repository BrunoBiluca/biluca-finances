abstract class YearlyReportService {
  Future<YearlyReportSummary> summary();
}

class YearlyReportSummary {
  final double balance;
  final double avgBalance;
  final double totalExpenses;
  final double totalIncomes;
  final double avgExpenses;
  final double avgIncomes;
  YearlyReportSummary({
    required this.balance,
    required this.avgBalance,
    required this.totalExpenses,
    required this.totalIncomes,
    required this.avgExpenses,
    required this.avgIncomes,
  });
}
