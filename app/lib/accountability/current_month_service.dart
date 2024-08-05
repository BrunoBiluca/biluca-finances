import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';

abstract class AccountabilityCurrentMonthService {
  String get currentMonth;
  Future<double> getSum();
  Future<double> getBalance();
  Future<double> getExpenses();
  Future<double> getIncomes();
  Future<List<GroupedBy<AccountabilityIdentification>>> getTotalByIdentification();
}
