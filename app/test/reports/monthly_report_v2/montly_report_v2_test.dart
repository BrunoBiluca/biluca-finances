import 'package:biluca_financas/app/accountability_monthly_report/monthly_report_v2.dart';
import 'package:biluca_financas/core/accountability_monthly_report/services/current_month_report.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../_helpers/ignore_overflow_erros.dart';

class MockMonthlyReportService extends Mock implements CurrentMonthReportService {}

void main() {
  var mockReportService = MockMonthlyReportService();

  setUp(() async {
    mockReportService = MockMonthlyReportService();
    when(
      () => mockReportService.summaryBalance(),
    ).thenAnswer((_) => Future.delayed(
        const Duration(seconds: 1),
        () => {
              "balance": 100.0,
              "related": 50.0,
            }));
    when(
      () => mockReportService.summaryExpenses(),
    ).thenAnswer((_) => Future.delayed(
        const Duration(seconds: 1),
        () => {
              "expenses": 100.00,
              "related": 100.0,
            }));
    when(
      () => mockReportService.summaryIncomes(),
    ).thenAnswer((_) => Future.delayed(
        const Duration(seconds: 1),
        () => {
              "incomes": 200.00,
              "related": 150.0,
            }));

    when(
      () => mockReportService.expensesByIdentification(),
    ).thenAnswer((_) => Future.value([]));

    when(
      () => mockReportService.incomesByIdentification(),
    ).thenAnswer((_) => Future.value([]));

    GetIt.I.registerFactoryParam<CurrentMonthReportService, DateTime, void>(
      (date, _) => mockReportService,
    );
    initializeDateFormatting('pt_BR');
  });

  testWidgets(
    "should show summary values",
    (tester) async {
      FlutterError.onError = ignoreOverflowErrors;

      await tester.pumpWidget(
        MaterialApp(
          title: 'Flutter Demo',
          home: MonthlyReportV2(),
        ),
      );

      await tester.pump(const Duration(seconds: 4));

      expect(find.byKey(const Key("summary_balance")), findsOneWidget);
      expect(find.byKey(const Key("summary_expenses")), findsOneWidget);
      expect(find.byKey(const Key("summary_incomes")), findsOneWidget);
    },
    skip: true,
  );
}
