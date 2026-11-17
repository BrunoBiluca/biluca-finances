import 'package:biluca_financas/app/accountability_table/widgets/accountability_identification_label.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      "deve retornar a mensagem de nenhum identificação quando não passado",
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: AccountabilityIdentificationLabel(
            identification: null,
            recordDescription: "Lançamento",
            recordValue: 10,
            onEdit: (identification) {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key("no-identification")), findsOneWidget);
  });

  testWidgets("deve retornar o identificação quando passado", (tester) async {
    var id = AccountabilityIdentification(
      "identificação teste",
      Colors.green,
      descriptionDetail: "Descrição que não deve aparecer na tag",
    )..icon = Icons.restaurant;
    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: AccountabilityIdentificationLabel(
            identification: id,
            recordDescription: "Lançamento",
            recordValue: 10,
            onEdit: (identification) {},
          ),
        ),
      ),
    );

    expect(find.text(id.description), findsOneWidget);
    expect(find.text(id.descriptionDetail), findsNothing);
    final label = tester.widget<Container>(
      find.byKey(const Key('accountability-identification-label')),
    );
    expect(
      (label.decoration! as BoxDecoration).color,
      id.color.withValues(alpha: 0.16),
    );
    final icon = tester.widget<Icon>(find.byIcon(id.icon));
    expect(icon.color, id.color);
  });
}
