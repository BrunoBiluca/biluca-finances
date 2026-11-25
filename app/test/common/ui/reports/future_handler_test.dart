import 'package:biluca_financas/common/ui/reports/future_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("não recarrega ao mudar a largura da janela", (tester) async {
    var loads = 0;

    tester.view
      ..physicalSize = const Size(800, 600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) => FutureHandler<String>(
              dependency: "2026/11",
              load: () {
                loads++;
                return Future.value("consolidado");
              },
              builder: (context, data) => Text(data),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loads, 1);

    tester.view.physicalSize = const Size(400, 600);
    await tester.pumpAndSettle();

    expect(loads, 1);
    expect(find.text("consolidado"), findsOneWidget);
  });

  testWidgets("recarrega quando a dependência muda", (tester) async {
    var loads = 0;
    final period = ValueNotifier("2026/11");
    addTearDown(period.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<String>(
            valueListenable: period,
            builder: (context, value, child) => FutureHandler<String>(
              dependency: value,
              load: () {
                loads++;
                return Future.value(value);
              },
              builder: (context, data) => Text(data),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loads, 1);
    expect(find.text("2026/11"), findsOneWidget);

    period.value = "2026/12";
    await tester.pumpAndSettle();

    expect(loads, 2);
    expect(find.text("2026/12"), findsOneWidget);
  });

  testWidgets("refaz o carregamento ao tentar novamente após uma falha",
      (tester) async {
    var loads = 0;

    Future<String> load() {
      loads++;
      if (loads == 1) return Future.error(Exception("falha ao carregar"));
      return Future.value("consolidado");
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FutureHandler<String>(
            load: load,
            builder: (context, data) => Text(data),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Tentar novamente"), findsOneWidget);

    await tester.tap(find.byKey(const Key("future-handler-retry")));
    await tester.pumpAndSettle();

    expect(loads, 2);
    expect(find.text("consolidado"), findsOneWidget);
  });
}
