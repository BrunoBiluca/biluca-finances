import 'package:biluca_financas/reports/monthly_report_v2/monthly_report_v2.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/current_month_report.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class MockMonthlyReportService extends Mock implements CurrentMonthReportService {}

void main() {
  testWidgets("should start showing shimmer when loading and show values when loaded", (tester) async {
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
        home: Scaffold(
          body: MonthlyReportV2(),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 4));

    expect(find.byKey(const Key("despesas")), findsOneWidget);
    expect(find.byKey(const Key("despesas relativas")), findsOneWidget);
    expect(find.byKey(const Key("receitas")), findsOneWidget);
    expect(find.byKey(const Key("receitas relativas")), findsOneWidget);
  });
}
