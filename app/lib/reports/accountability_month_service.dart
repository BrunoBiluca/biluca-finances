import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/accountability/services/repo.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';

abstract class AccountabilityMonthService extends AccountabilityRepo {
  String get currentMonth;
  Future<int> count();
  Future<double> getSum();
  Future<double> getBalance();
  Future<double> getExpenses();
  Future<double> getAvgExpensesByMonth();
  Future<double> getIncomes();
  Future<double> getAvgIncomesByMonth();
  Future<List<GroupedBy<AccountabilityIdentification>>> getTotalByIdentification();
  Future<List<GroupedBy<AccountabilityIdentification>>> getAccumulatedMeansByIdentification();
}
