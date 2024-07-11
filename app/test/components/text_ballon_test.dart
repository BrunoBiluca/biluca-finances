import 'package:biluca_financas/components/text_ballon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TextBallon cria um balão', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: TextBallon(
          text: "Balão",
          color: Colors.black,
        ),
      ),
    ));

    expect(find.text("Balão"), findsOneWidget);
  });

  testWidgets('TextBallon chama o callback onDelete', (tester) async {
    bool onDeleteCalled = false;
    await tester.pumpWidget(MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: TextBallon(
          text: "Balão",
          color: Colors.black,
          onDelete: () {
            onDeleteCalled = true;
          },
        ),
      ),
    ));

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(onDeleteCalled, true);
  });

  testWidgets('TextBallon chama o callback onEdit', (tester) async {
    bool onEditCalled = false;
    String actualNewValue = "";
    Color actualColor = Colors.black;
    await tester.pumpWidget(MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: TextBallon(
          text: "Balão",
          color: Colors.black,
          onEdit: (String newValue, Color color) {
            onEditCalled = true;
            actualNewValue = newValue;
            color = color;
          },
        ),
      ),
    ));

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), "Novo Texto");
    await tester.pumpAndSettle();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(onEditCalled, true);
    expect(actualNewValue, "Novo Texto");
    expect(actualColor, Colors.black);
  });
}
