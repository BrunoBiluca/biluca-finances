import 'package:biluca_financas/accountability/current_month_service.dart';
import 'package:biluca_financas/reports/current_month_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shimmer/shimmer.dart';

import 'current_month_report_test.mocks.dart';

@GenerateMocks([AccountabilityCurrentMonthService])
void main() {
  testWidgets("should start showing shimmer when loading and show values when loaded", (tester) async {
    final mock = MockAccountabilityCurrentMonthService();
    const callDuration = Duration(seconds: 1);
    when(mock.currentMonth).thenReturn("07/2024");
    when(mock.getBalance()).thenAnswer((_) => Future.delayed(callDuration, () => 3.0));
    when(mock.getSum()).thenAnswer((_) => Future.delayed(callDuration, () => 100.0));
    when(mock.getExpenses()).thenAnswer((_) => Future.delayed(callDuration, () => -50.0));
    when(mock.getIncomes()).thenAnswer((_) => Future.delayed(callDuration, () => 150.0));

    final lastMonthMock = MockAccountabilityCurrentMonthService();
    when(lastMonthMock.currentMonth).thenReturn("06/2024");
    when(lastMonthMock.getBalance()).thenAnswer((_) => Future.delayed(callDuration, () => 2.0));
    when(lastMonthMock.getSum()).thenAnswer((_) => Future.delayed(callDuration, () => 200.0));
    when(lastMonthMock.getExpenses()).thenAnswer((_) => Future.delayed(callDuration, () => -100.0));
    when(lastMonthMock.getIncomes()).thenAnswer((_) => Future.delayed(callDuration, () => 300.0));

    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: FittedBox(
            child: CurrentMonthCard(service: mock, lastMonthService: lastMonthMock),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(Shimmer), findsExactly(4));

    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(Shimmer), findsNothing);
    expect(find.byKey(const Key("total")), findsOneWidget);
    expect(find.byKey(const Key("total")), findsOneWidget);
    expect(find.byKey(const Key("expenses_total")), findsOneWidget);
    expect(find.byKey(const Key("expenses_relative")), findsOneWidget);
    expect(find.byKey(const Key("incomes_total")), findsOneWidget);
    expect(find.byKey(const Key("incomes_relative")), findsOneWidget);
  });
}
