import 'package:biluca_financas/app/accountability_monthly_report/widgets/identifications_barchart.dart';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/identifications_percentage_chart.dart';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/identifications_view_section.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:biluca_financas/core/accountability_monthly_report/models/identification_report_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final data = [
    IdentificationReportInfo(
      identification: AccountabilityIdentification(
        "Moradia",
        Colors.blue,
        type: AccountabilityIdentificationType.expense,
      ),
      current: 1200,
      related: 1000,
      avgRecentMonts: 1100,
      participationInTotal: 0.6,
    ),
    IdentificationReportInfo(
      identification: AccountabilityIdentification(
        "Alimentação",
        Colors.orange,
        type: AccountabilityIdentificationType.expense,
      ),
      current: 800,
      related: 900,
      avgRecentMonts: 850,
      participationInTotal: 0.4,
    ),
  ];

  Future<void> pumpSection(WidgetTester tester, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: IdentificationsViewSection(data: data, onDataChanged: () {}),
          ),
        ),
      ),
    );
  }

  testWidgets("empilha os gráficos e mantém a legenda em janela estreita",
      (tester) async {
    await pumpSection(tester, const Size(420, 900));

    expect(tester.takeException(), isNull);
    expect(find.text("Comportamento das identificações"), findsOneWidget);
    expect(find.text("Composição relativa"), findsOneWidget);
    expect(find.text("Mês atual"), findsOneWidget);
    expect(find.text("Mês anterior"), findsOneWidget);

    final barChart = tester.getRect(find.byType(IdentificationsBarChart));
    final percentageChart =
        tester.getRect(find.byType(IdentificationsPercentageChart));
    expect(percentageChart.top, greaterThan(barChart.bottom));
  });

  testWidgets("mantém os gráficos lado a lado em janela larga",
      (tester) async {
    await pumpSection(tester, const Size(1200, 900));

    expect(tester.takeException(), isNull);

    final barChart = tester.getRect(find.byType(IdentificationsBarChart));
    final percentageChart =
        tester.getRect(find.byType(IdentificationsPercentageChart));
    expect(percentageChart.left, greaterThan(barChart.right));
  });
}
