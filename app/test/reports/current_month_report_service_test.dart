import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability_stats/models/grouped_by.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:biluca_financas/core/accountability_monthly_report/services/accountability_month_service.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/current_month_report.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_accountability_month_service.dart';

void main() {
  var currentMonth = DateTime(2024, 7);

  test("should return totals by identifications for current month", () async {
    // despesas
    var idSupermercado = AccountabilityIdentification("supermercado", Colors.red);
    var idCompras = AccountabilityIdentification("compras", Colors.red);
    var idLazer = AccountabilityIdentification("lazer", Colors.red);

    // receitas
    var idSalario = AccountabilityIdentification("salário", Colors.red);
    idSalario.type = AccountabilityIdentificationType.income;

    var current = MockAccountabilityMonthService();
    when(() => current.getTotalByIdentification()).thenAnswer((_) async => Future.value([
          GroupedBy(idSupermercado, total: -1000.00),
          GroupedBy(idCompras, total: -500.00),
          GroupedBy(idSalario, total: 500.00),
        ]));
    when(() => current.getAccumulatedMeansByIdentification()).thenAnswer((_) async => Future.value([
          GroupedBy(idSupermercado, total: 0, mean: 0.00),
          GroupedBy(idCompras, total: 0, mean: 0.00),
          GroupedBy(idSalario, total: 0, mean: 0.00),
        ]));

    var related = MockAccountabilityMonthService();
    when(() => related.getTotalByIdentification()).thenAnswer((_) async => Future.value([
          GroupedBy(idSupermercado, total: -500.00, mean: 0.00),
          GroupedBy(idLazer, total: -100.00),
        ]));
    when(() => related.getAccumulatedMeansByIdentification()).thenAnswer((_) async => Future.value([
          GroupedBy(idSupermercado, total: 0, mean: 0.00),
          GroupedBy(idCompras, total: 0, mean: 0.00),
          GroupedBy(idSalario, total: 0, mean: 0.00),
        ]));

    GetIt.I.registerFactoryParam<AccountabilityMonthService, DateTime, void>(
      (month, _) => month == currentMonth ? current : related,
    );

    var service = CurrentMonthReportService(currentMonth);

    var expenses = await service.expensesByIdentification();

    expect(expenses.length, 3);

    var resultSupermercado = expenses.firstWhere((e) => e.identification.id == idSupermercado.id);
    expect(resultSupermercado.current, -1000.00);
    expect(resultSupermercado.related, -500.00);

    var resultCompras = expenses.firstWhere((e) => e.identification.id == idCompras.id);
    expect(resultCompras.current, -500.00);
    expect(resultCompras.related, 0.00);

    var resultLazer = expenses.firstWhere((e) => e.identification.id == idLazer.id);
    expect(resultLazer.current, 0.00);
    expect(resultLazer.related, -100.00);
  });
}
