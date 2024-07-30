abstract class AccountabilityCurrentMonthService {
  String get currentMonth;
  Future<double> getSum();
  Future<double> getBalance();
  Future<double> getExpenses();
  Future<double> getIncomes();
}

