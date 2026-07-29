import 'dart:async';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/extensions/datetime_extensions.dart';
import 'package:biluca_financas/reports/accountability_month_service.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/identification_report_info.dart';
import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';

class CurrentMonthReportService {
  final AccountabilityMonthService current;
  final AccountabilityMonthService related;
  CurrentMonthReportService._(this.current, this.related);

  final _controller = StreamController<void>();

  Stream<void> get onChange => _controller.stream;

  void emitRefresh() {
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }

  factory CurrentMonthReportService(DateTime month) {
    return CurrentMonthReportService._(
      GetIt.I<AccountabilityMonthService>(param1: month),
      GetIt.I<AccountabilityMonthService>(param1: month.subtractMonth(1)),
    );
  }

  Future<dynamic> summaryBalance() async {
    return {"balance": await current.getBalance(), "related": await related.getBalance()};
  }

  Future<dynamic> summaryIncomes() async {
    return {"incomes": await current.getIncomes(), "related": await related.getIncomes()};
  }

  Future<dynamic> summaryExpenses() async {
    return {"expenses": await current.getExpenses(), "related": await related.getExpenses()};
  }

  Future<List<IdentificationReportInfo>> expensesByIdentification() async {
    var identifications = (await current.getTotalByIdentification())
        .where((i) => i.field.type == AccountabilityIdentificationType.expense)
        .toList();
    var relatedMonth = (await related.getTotalByIdentification())
        .where((i) => i.field.type == AccountabilityIdentificationType.expense)
        .toList();

    List<IdentificationReportInfo> result = [];
    var totalExpenses = 0.0;
    for (var i in identifications) {
      totalExpenses += i.total!;
    }

    for (var i in identifications) {
      result.add(
        IdentificationReportInfo(
          identification: i.field,
          current: i.total!,
          currentPercentage: i.total! / totalExpenses,
        ),
      );
    }

    for (var i in relatedMonth) {
      var id = result.firstWhereOrNull((r) => r.identification.id == i.field.id);
      if (id == null) {
        result.add(IdentificationReportInfo(identification: i.field, related: i.total!));
      } else {
        id.related = i.total!;
      }
    }

    var accIncomes = await current.getAccumulatedMeansByIdentification();
    for (var i in accIncomes) {
      var id = result.firstWhereOrNull((r) => r.identification.id == i.field.id);
      if (id != null) {
        id.avgRecentMonts = i.mean!;
      }
    }

    return result;
  }

  Future<List<IdentificationReportInfo>> incomesByIdentification() async {
    var identifications = (await current.getTotalByIdentification())
        .where((i) => i.field.type == AccountabilityIdentificationType.income)
        .toList();
    var relatedMonth = (await related.getTotalByIdentification())
        .where((i) => i.field.type == AccountabilityIdentificationType.income)
        .toList();

    List<IdentificationReportInfo> result = [];
    var totalIncomes = 0.0;
    for (var i in identifications) {
      totalIncomes += i.total!;
    }

    for (var i in identifications) {
      result.add(
        IdentificationReportInfo(
          identification: i.field,
          current: i.total!,
          currentPercentage: i.total! / totalIncomes,
        ),
      );
    }

    for (var i in relatedMonth) {
      var id = result.firstWhereOrNull((r) => r.identification.id == i.field.id);
      if (id == null) {
        result.add(IdentificationReportInfo(identification: i.field, related: i.total!));
      } else {
        id.related = i.total!;
      }
    }

    var accIncomes = await current.getAccumulatedMeansByIdentification();
    for (var i in accIncomes) {
      var id = result.firstWhereOrNull((r) => r.identification.id == i.field.id);
      if (id != null) {
        id.avgRecentMonts = i.mean!;
      }
    }
    return result;
  }
}
