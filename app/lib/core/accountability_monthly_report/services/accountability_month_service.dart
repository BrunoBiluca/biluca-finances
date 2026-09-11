import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:biluca_financas/core/accountability_stats/models/grouped_by.dart';

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
