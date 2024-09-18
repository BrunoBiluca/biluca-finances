import 'package:biluca_financas/reports/components/month_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_accountability_current_month_service.dart';

void main() {
  testWidgets("should start showing shimmer when loading and show values when loaded", (tester) async {
    final mock = MockAccountabilityCurrentMonthService();
    const callDuration = Duration(seconds: 1);
    when(() => mock.currentMonth).thenReturn("07/2024");
    when(() => mock.getExpenses()).thenAnswer((_) => Future.delayed(callDuration, () => -50.0));
    when(() => mock.getIncomes()).thenAnswer((_) => Future.delayed(callDuration, () => 150.0));

    final lastMonthMock = MockAccountabilityCurrentMonthService();
    when(() => lastMonthMock.currentMonth).thenReturn("06/2024");
    when(() => lastMonthMock.getExpenses()).thenAnswer((_) => Future.delayed(callDuration, () => -100.0));
    when(() => lastMonthMock.getIncomes()).thenAnswer((_) => Future.delayed(callDuration, () => 300.0));

    initializeDateFormatting('pt_BR');
    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: MonthInfoCard(service: mock, relatedMonthService: lastMonthMock),
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
