import 'package:biluca_financas/reports/components/single_value_card/single_value_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pw(WidgetTester t, Widget w) async {
    await t.pumpWidget(MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(body: w),
    ));
  }

  testWidgets("deve conter as principais informações de análise", (tester) async {
    await pw(
      tester,
      const SingleValueCard(
        title: "Balanço",
        currentValue: 10,
      ),
    );

    expect(find.byKey(const Key("valor")), findsOneWidget);
    expect(find.text("R\$ 10,00"), findsOneWidget);
    expect(find.byKey(const Key("título")), findsOneWidget);
    expect(find.text("Balanço"), findsOneWidget);
  });

  testWidgets("deve conter informações de relação a outros valores", (tester) async {
    await pw(
      tester,
      const SingleValueCard(
        title: "Balanço",
        currentValue: 11,
        relatedValue: 10,
      ),
    );

    expect(find.byKey(const Key("relação")), findsOneWidget);
    expect(find.text("+10%"), findsOneWidget);
  });

  testWidgets("para relações acima de 100% a notação deve ser em vezes", (tester) async {
    await pw(
      tester,
      const SingleValueCard(
        title: "Balanço",
        currentValue: 20,
        relatedValue: 10,
      ),
    );

    expect(find.byKey(const Key("relação")), findsOneWidget);
    expect(find.text("+2x"), findsOneWidget);
  });
}
