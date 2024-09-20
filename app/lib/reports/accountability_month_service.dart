import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';

abstract class AccountabilityMonthService {
  String get currentMonth;
  Future<int> count();
  Future<double> getSum();
  Future<double> getBalance();
  Future<double> getExpenses();
  Future<double> getAccumulatedExpenses();
  Future<double> getIncomes();
  Future<double> getAccumulatedIncomes();
  Future<List<GroupedBy<AccountabilityIdentification>>> getTotalByIdentification();
  Future<List<GroupedBy<AccountabilityIdentification>>> getAccumulatedMeansByIdentification();
}
