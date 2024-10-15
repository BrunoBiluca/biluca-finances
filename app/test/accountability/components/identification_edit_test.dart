import 'package:biluca_financas/accountability/components/identification_edit.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("deve retornar a mensagem de nenhum identificação quando não passado", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: AccountabilityIdentificationEdit(identification: null, onEdit: (identification) {}),
        ),
      ),
    );

    expect(find.byKey(const Key("no-identification")), findsOneWidget);
  });

  testWidgets("deve retornar o identificação quando passado", (tester) async {
    var id = AccountabilityIdentification("identificação teste", Colors.black);
    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: AccountabilityIdentificationEdit(identification: id, onEdit: (identification) {}),
        ),
      ),
    );

    expect(find.text(id.description), findsOneWidget);
  });
}
