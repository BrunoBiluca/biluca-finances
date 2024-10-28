import 'package:biluca_financas/accountability/components/table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AccountabilityTable vazia apenas com o cabeçalho quando criada', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: AccountabilityTable(entries: const [], onUpdate: (entry) {}, onRemove: (entry) {}),
        ),
      ),
    );

    expect(find.text("Descrição"), findsOneWidget);
    expect(find.text("Valor"), findsOneWidget);
    expect(find.text("Identificação"), findsOneWidget);
    expect(find.text("Criação"), findsOneWidget);
  });
}
