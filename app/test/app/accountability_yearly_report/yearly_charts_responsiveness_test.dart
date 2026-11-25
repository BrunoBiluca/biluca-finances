import 'package:biluca_financas/app/accountability_yearly_report/widgets/balance_chart.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/incomes_expenses_evolution_chart.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/yearly_identifications_summary_charts.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/yearly_summary_charts.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/app/themes/theme_setup.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:biluca_financas/core/accountability_yearly_report/models/monthly_identifications_summary.dart';
import 'package:biluca_financas/core/accountability_yearly_report/models/monthly_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<ThemeManager>(setupThemes());
    await initializeDateFormatting('pt_BR');
    await initializeDateFormatting('de');
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pumpAt(WidgetTester tester, Size size, Widget child) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  List<MonthlySummary> buildMonthlySummaries() {
    return [
      MonthlySummary(balance: 100, sumExpenses: 200, sumIncomes: 300, month: "2026-01"),
      MonthlySummary(balance: -50, sumExpenses: 350, sumIncomes: 300, month: "2026-02"),
      MonthlySummary(balance: 200, sumExpenses: 100, sumIncomes: 300, month: "2026-03"),
    ];
  }

  testWidgets("gráficos anuais se ajustam a uma janela estreita", (tester) async {
    await pumpAt(
      tester,
      const Size(420, 1400),
      YearlySummaryCharts(res: buildMonthlySummaries()),
    );

    expect(tester.takeException(), isNull);
    expect(find.text("Evolução das receitas e despesas"), findsOneWidget);
    expect(find.text("Balanço mensal"), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(IncomesExpensesEvolutionChart),
        matching: find.text("Despesas"),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(BalanceChart),
        matching: find.text("Despesas"),
      ),
      findsOneWidget,
    );
  });

  testWidgets("resumo por identificação se ajusta a uma janela estreita",
      (tester) async {
    final res = [
      MonthlyIdentificationsSummary(
        identification: AccountabilityIdentification(
          "Salário",
          Colors.green,
          type: AccountabilityIdentificationType.income,
        ),
        monthTotal: const {"2026-01": 1000, "2026-02": 0},
      ),
      MonthlyIdentificationsSummary(
        identification: AccountabilityIdentification(
          "Moradia",
          Colors.blue,
          type: AccountabilityIdentificationType.expense,
        ),
        monthTotal: const {"2026-01": 800, "2026-02": 900},
      ),
    ];

    await pumpAt(
      tester,
      const Size(420, 1400),
      YearlyIdentificationsSummaryCharts(res: res),
    );

    expect(tester.takeException(), isNull);
    expect(find.text("Receitas por identificação"), findsOneWidget);
    expect(find.text("Despesas por identificação"), findsOneWidget);
    expect(find.text("Salário"), findsOneWidget);
    expect(find.text("Moradia"), findsOneWidget);
  });
}
