import 'package:biluca_financas/components/mouse_back_button_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var firstPageKey = const Key("page-1");

  var secondPageKey = const Key("page-2");

  var testApp = MaterialApp(
    title: 'Flutter Demo',
    home: Builder(
      builder: (context) {
        return Scaffold(
          body: Row(
            children: [
              Container(
                key: firstPageKey,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MouseBackButtonListener(
                        child: Scaffold(
                          body: Container(
                            key: secondPageKey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text("Ir para a segunda página"),
              ),
            ],
          ),
        );
      },
    ),
  );

  testWidgets("não deve retornar o contexto quando o botão não for pressionado", (tester) async {
    await tester.pumpWidget(testApp);

    expect(find.byKey(firstPageKey), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.byKey(secondPageKey), findsOneWidget);

    await tester.press(find.byType(Container), buttons: 1);
    await tester.pumpAndSettle();

    expect(find.byKey(secondPageKey), findsOneWidget);
  });

  testWidgets("deve retornar o contexto quando o botão de voltar do mouse for pressionado", (tester) async {
    await tester.pumpWidget(testApp);

    expect(find.byKey(firstPageKey), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.byKey(secondPageKey), findsOneWidget);

    await tester.press(find.byType(Container), buttons: 8);
    await tester.pumpAndSettle();

    expect(find.byKey(firstPageKey), findsOneWidget);
  });
}
