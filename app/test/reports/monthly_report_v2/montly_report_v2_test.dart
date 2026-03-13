import 'package:biluca_financas/reports/monthly_report_v2/monthly_report_v2.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/current_month_report.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../_helpers/ignore_overflow_erros.dart';

class MockMonthlyReportService extends Mock implements CurrentMonthReportService {}

void main() {
  testWidgets("should show summary values", (tester) async {
    FlutterError.onError = ignoreOverflowErrors;

    final mock = MockMonthlyReportService();
    when(
      () => mock.summaryBalance(),
    ).thenAnswer((_) => Future.delayed(
        const Duration(seconds: 1),
        () => {
              "balance": 100.0,
              "related": 50.0,
            }));
    when(
      () => mock.summaryExpenses(),
    ).thenAnswer((_) => Future.delayed(
        const Duration(seconds: 1),
        () => {
              "expenses": 100.00,
              "related": 100.0,
            }));
    when(
      () => mock.summaryIncomes(),
    ).thenAnswer((_) => Future.delayed(
        const Duration(seconds: 1),
        () => {
              "incomes": 200.00,
              "related": 150.0,
            }));

    GetIt.I.registerFactoryParam<CurrentMonthReportService, DateTime, void>((date, _) => mock);

    initializeDateFormatting('pt_BR');
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
  });
}
