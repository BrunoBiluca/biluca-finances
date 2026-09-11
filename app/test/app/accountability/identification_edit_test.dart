import 'package:biluca_financas/app/accountability_table/widgets/accountability_identification_label.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("deve retornar a mensagem de nenhum identificação quando não passado", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: AccountabilityIdentificationLabel(identification: null, onEdit: (identification) {}),
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
          body: AccountabilityIdentificationLabel(identification: id, onEdit: (identification) {}),
        ),
      ),
    );

    expect(find.text(id.description), findsOneWidget);
  });
}
