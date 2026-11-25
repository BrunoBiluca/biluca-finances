import 'package:biluca_financas/common/ui/reports/report_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpHeader(
    WidgetTester tester, {
    required Size size,
    List<Widget> actions = const [],
    Widget? periodSelector,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportHeader(
            icon: Icons.dashboard,
            iconColor: Colors.purpleAccent,
            title: "Relatório mensal",
            actions: actions,
            periodSelector: periodSelector,
          ),
        ),
      ),
    );
  }

  Widget buildAction() {
    return ElevatedButton(
      onPressed: () {},
      child: const Text("Dados do relatório"),
    );
  }

  testWidgets("apresenta ícone, título e ação na mesma linha em janela larga",
      (tester) async {
    await pumpHeader(
      tester,
      size: const Size(1200, 800),
      actions: [buildAction()],
    );

    expect(find.byIcon(Icons.dashboard), findsOneWidget);

    final title = tester.getRect(find.text("Relatório mensal"));
    final action = tester.getRect(find.text("Dados do relatório"));
    expect(action.left, greaterThan(title.right));
  });

  testWidgets("empilha as ações e o seletor abaixo do título em janela estreita",
      (tester) async {
    await pumpHeader(
      tester,
      size: const Size(420, 800),
      actions: [buildAction()],
      periodSelector: const SizedBox(
        key: Key("period-selector"),
        height: 40,
      ),
    );

    expect(find.byIcon(Icons.dashboard), findsOneWidget);

    final title = tester.getRect(find.text("Relatório mensal"));
    final action = tester.getRect(find.text("Dados do relatório"));
    final selector = tester.getRect(find.byKey(const Key("period-selector")));
    expect(action.top, greaterThan(title.bottom));
    expect(selector.top, greaterThan(action.bottom));
  });
}
