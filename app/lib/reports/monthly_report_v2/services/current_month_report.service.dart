import 'dart:collection';

import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';
import 'package:biluca_financas/common/extensions/datetime_extensions.dart';
import 'package:biluca_financas/reports/accountability_month_service.dart';
import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';

class IdentificationRelation {
  final AccountabilityIdentification identification;
  double current;
  double related;
  IdentificationRelation({required this.identification, this.current = 0, this.related = 0});
}

class CurrentMonthReportService {
  final AccountabilityMonthService current;
  final AccountabilityMonthService related;
  CurrentMonthReportService._(this.current, this.related);

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

  Future<List<IdentificationRelation>> expensesByIdentification() async {
    var identifications = (await current.getTotalByIdentification()).where((i) => i.total! < 0).toList();
    var relatedMonth = (await related.getTotalByIdentification()).where((i) => i.total! < 0).toList();

    List<IdentificationRelation> result = [];
    for (var i in identifications) {
      result.add(IdentificationRelation(identification: i.field, current: i.total!));
    }

    for (var i in relatedMonth) {
      var id = result.firstWhereOrNull((r) => r.identification.id == i.field.id);
      if (id == null) {
        result.add(IdentificationRelation(identification: i.field, related: i.total!));
      } else {
        id.related = i.total!;
      }
    }
    return result;
  }

  Future<List<GroupedBy<AccountabilityIdentification>>> incomesByIdentification() async {
    var identifications = await current.getTotalByIdentification();
    identifications.addAll(await related.getTotalByIdentification());
    return identifications.where((i) => i.total! > 0).toList();
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
