import 'dart:async';
import 'dart:collection';
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
    for (var i in identifications) {
      result.add(IdentificationReportInfo(identification: i.field, current: i.total!));
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
    for (var i in identifications) {
      result.add(IdentificationReportInfo(identification: i.field, current: i.total!));
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

  Future<Map<dynamic, dynamic>> getMeansByIdentification() async {
    var incomes = await current.getIncomes();
    var expenses = await current.getExpenses();

    var accIncomes = await current.getAccumulatedIncomes();
    var accExpenses = await current.getAccumulatedExpenses();

    var values = {};
    values["Receitas"] = {"desc": "Receitas", "field": null, "mean": accIncomes, "current": incomes};
    values["Despesas"] = {"desc": "Despesas", "field": null, "mean": accExpenses, "current": expenses};

    var valuesByIdentifications = SplayTreeMap();
    var identifications = await current.getAccumulatedMeansByIdentification();
    for (var i in identifications) {
      valuesByIdentifications[i.field.description] = {
        "desc": i.field.description,
        "field": i.field,
        "mean": i.mean,
        "current": null
      };
    }

    var currIdentifications = await current.getTotalByIdentification();
    for (var i in currIdentifications) {
      if (!valuesByIdentifications.containsKey(i.field.description)) {
        valuesByIdentifications[i.field.description] = {
          "desc": i.field.description,
          "field": i.field,
          "mean": null,
          "current": i.total
        };
      } else {
        valuesByIdentifications[i.field.description]["current"] = i.total;
      }
    }

    values.addAll(valuesByIdentifications);

    return values;
  }
}
