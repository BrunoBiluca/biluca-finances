import 'package:biluca_financas/app/accountability_yearly_report/widgets/yearly_summary_cards.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/app/themes/theme_setup.dart';
import 'package:biluca_financas/core/accountability_yearly_report/models/yearly_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../_helpers/ignore_overflow_erros.dart';

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

  testWidgets("exibe N/A quando a média de receitas é zero", (tester) async {
    FlutterError.onError = ignoreOverflowErrors;

    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final summary = YearlySummary(
      balance: 0,
      avgBalance: 0,
      totalExpenses: 100,
      totalIncomes: 0,
      avgExpenses: 100,
      avgIncomes: 0,
      peakIncome: 0,
      peakIncomeMonth: "Janeiro",
      range: DateTimeRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 12, 31),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: YearlySummaryCards(res: summary),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("N/A consolidado"), findsOneWidget);
    expect(find.text("N/A da receita"), findsOneWidget);
  });
}
