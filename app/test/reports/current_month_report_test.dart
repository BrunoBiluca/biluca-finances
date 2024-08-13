import 'package:biluca_financas/accountability/services/current_month_service.dart';
import 'package:biluca_financas/reports/current_month_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'current_month_report_test.mocks.dart';

@GenerateMocks([AccountabilityCurrentMonthService])
void main() {
  testWidgets('Deve exibir que não existem registros para o mês atual', (tester) async {
    var service = MockAccountabilityCurrentMonthService();
    when(service.count()).thenAnswer((_) => Future.delayed(const Duration(milliseconds: 10), () => 0));
    GetIt.I.registerFactory<AccountabilityCurrentMonthService>(() => service);

    await tester.pumpWidget(
      const MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: SizedBox(
            height: 200,
            width: 200,
            child: CurrentMonthReport(),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 15));

    expect(find.byKey(const Key("no_entries")), findsOneWidget);
  });
}
