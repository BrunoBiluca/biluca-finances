import 'package:biluca_financas/core/accountability_stats/models/accountability_year_stats.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/year_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("deve exibir os anos disponíveis", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: YearSelector(
            currentYear: "Últimos 12 meses",
            years: [
              AccountabilityYearStats(year: "Últimos 12 meses", entriesCount: 10),
              AccountabilityYearStats(year: "2022", entriesCount: 10),
              AccountabilityYearStats(year: "2021", entriesCount: 10),
            ],
            onDateChanged: (v) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(DropdownButton<String>),
        matching: find.text('Últimos 12 meses'),
      ),
      findsOneWidget,
    );
  });
}
