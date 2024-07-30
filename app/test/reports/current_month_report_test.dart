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

    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: FittedBox(
            child: CurrentMonthCard(service: mock),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(Shimmer), findsExactly(4));

    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(Shimmer), findsNothing);
    expect(find.text("300.00%"), findsOneWidget);
    expect(find.text("100.00"), findsOneWidget);
    expect(find.text("-50.00"), findsOneWidget);
    expect(find.text("150.00"), findsOneWidget);
  });
}
