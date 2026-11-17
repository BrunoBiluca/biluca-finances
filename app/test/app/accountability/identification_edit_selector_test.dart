import 'package:biluca_financas/app/accountability_table/widgets/accountability_identification_selector.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/app/themes/theme_setup.dart';
import 'package:biluca_financas/common/ui/real_currency.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();
    getIt.registerSingleton<ThemeManager>(setupThemes());
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpSelector(
    WidgetTester tester, {
    required List<AccountabilityIdentification> identifications,
    String recordDescription = "Descrição do lançamento",
    double recordValue = -22,
    String? currentIdentificationId,
    ValueChanged<AccountabilityIdentification>? onSelected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountabilityIdentificationSelector(
            identifications: identifications,
            recordDescription: recordDescription,
            recordValue: recordValue,
            currentIdentificationId: currentIdentificationId,
            onSelected: onSelected ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("shows an empty message when there are no identifications",
      (tester) async {
    await pumpSelector(tester, identifications: []);

    expect(find.byKey(const Key("no-identification-found")), findsOneWidget);
  });

  testWidgets("shows the title and edited entry context", (tester) async {
    await pumpSelector(
      tester,
      identifications: [],
      recordDescription: "PIX TRANSF 30.234.05/09",
      recordValue: -22,
    );

    expect(find.text("Selecionar identificação"), findsOneWidget);
    expect(find.text("PIX TRANSF 30.234.05/09"), findsOneWidget);
    expect(tester.widget<RealCurrency>(find.byType(RealCurrency)).number, -22);
  });

  testWidgets("shows identification names, details and icons", (tester) async {
    final identifications = [
      AccountabilityIdentification(
        "identificação 1",
        Colors.green,
        descriptionDetail: "Descrição auxiliar da primeira",
      )..icon = Icons.restaurant,
      AccountabilityIdentification("identificação 2", Colors.blue),
    ];

    await pumpSelector(tester, identifications: identifications);

    expect(find.text("identificação 1"), findsOneWidget);
    expect(find.text("Descrição auxiliar da primeira"), findsOneWidget);
    expect(find.text("identificação 2"), findsOneWidget);

    final firstItem =
        find.byKey(Key('identification-item-${identifications[0].id}'));
    final icon = tester.widget<Icon>(
      find.descendant(of: firstItem, matching: find.byIcon(Icons.restaurant)),
    );
    expect(icon.color, identifications[0].color);
  });

  testWidgets("keeps long identification details fully available",
      (tester) async {
    final detail = List.filled(20, "descrição auxiliar").join(" ");
    final identification = AccountabilityIdentification(
      "Identificação longa",
      Colors.green,
      descriptionDetail: detail,
    );

    await pumpSelector(tester, identifications: [identification]);

    final detailText = tester.widget<Text>(find.text(detail));
    expect(detailText.maxLines, isNull);
    expect(detailText.overflow, isNull);
  });

  testWidgets("scrolls through a long identification list", (tester) async {
    final identifications = List.generate(
      30,
      (index) => AccountabilityIdentification(
        "Categoria ${index.toString().padLeft(2, '0')}",
        Colors.blue,
      ),
    );

    await pumpSelector(tester, identifications: identifications);

    final lastItem = find.byKey(
      Key('identification-item-${identifications.last.id}'),
    );
    final viewport = find.byType(SingleChildScrollView);
    expect(
      tester.getTopLeft(lastItem).dy,
      greaterThan(tester.getBottomLeft(viewport).dy),
    );

    await tester.drag(viewport, const Offset(0, -3000));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(lastItem).dy,
      lessThan(tester.getBottomLeft(viewport).dy),
    );
  });

  testWidgets("does not offer creation, edition or deletion actions",
      (tester) async {
    final active = AccountabilityIdentification("Ativa", Colors.green);
    final discontinuedCurrent = AccountabilityIdentification(
      "Descontinuada atual",
      Colors.grey,
      discontinued: true,
    );
    final discontinuedOther = AccountabilityIdentification(
      "Descontinuada outra",
      Colors.grey,
      discontinued: true,
    );

    await pumpSelector(
      tester,
      identifications: [active, discontinuedCurrent, discontinuedOther],
      currentIdentificationId: discontinuedCurrent.id,
    );

    expect(find.text("Ativa"), findsOneWidget);
    expect(find.text("Descontinuada atual"), findsOneWidget);
    expect(find.text("Descontinuada outra"), findsNothing);
    expect(find.text("Criar identificação"), findsNothing);
    expect(find.byType(IconButton), findsNothing);
    expect(find.byIcon(Icons.edit), findsNothing);
    expect(find.byIcon(Icons.delete), findsNothing);
  });

  testWidgets("opens identification settings and returns to the ledger",
      (tester) async {
    final router = GoRouter(
      initialLocation: '/accountability',
      routes: [
        GoRoute(
          path: '/accountability',
          builder: (context, state) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AccountabilityIdentificationSelector(
                    identifications: const [],
                    recordDescription: "Compra",
                    recordValue: -10,
                    onSelected: (_) {},
                  ),
                ),
                child: const Text("Abrir seletor"),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/identifications',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop(),
              child: const Text("Página de identificações"),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Abrir seletor"));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-identification-settings')));
    await tester.pumpAndSettle();

    expect(find.text("Página de identificações"), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);

    await tester.tap(find.text("Página de identificações"));
    await tester.pumpAndSettle();
    expect(find.text("Abrir seletor"), findsOneWidget);
  });

  testWidgets("filters identifications by the search text", (tester) async {
    final identifications = [
      AccountabilityIdentification(
        "Alimentação",
        Colors.green,
        descriptionDetail: "Despesas de mercado",
      ),
      AccountabilityIdentification("Transporte", Colors.blue),
    ];

    await pumpSelector(tester, identifications: identifications);
    await tester.enterText(find.byType(TextField), "trans");
    await tester.pumpAndSettle();

    expect(find.text("Transporte"), findsOneWidget);
    expect(find.text("Alimentação"), findsNothing);

    await tester.enterText(find.byType(TextField), "mercado");
    await tester.pumpAndSettle();
    expect(find.text("Alimentação"), findsNothing);
    expect(find.byKey(const Key("no-identification-found")), findsOneWidget);
  });

  testWidgets("selects an identification and closes the dialog",
      (tester) async {
    AccountabilityIdentification? selected;
    final identification =
        AccountabilityIdentification("Alimentação", Colors.green);
    final otherIdentification =
        AccountabilityIdentification("Transporte", Colors.blue);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AccountabilityIdentificationSelector(
                  identifications: [identification, otherIdentification],
                  recordDescription: "Compra",
                  recordValue: -10,
                  onSelected: (value) => selected = value,
                ),
              ),
              child: const Text("Abrir seletor"),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text("Abrir seletor"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), "alimenta");
    await tester.pumpAndSettle();

    expect(find.text("Alimentação"), findsOneWidget);
    expect(find.text("Transporte"), findsNothing);
    await tester.tap(find.text("Alimentação"));
    await tester.pumpAndSettle();

    expect(selected?.id, identification.id);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("highlights the current identification with a check", (
    tester,
  ) async {
    final current = AccountabilityIdentification("Atual", Colors.green);
    final other = AccountabilityIdentification("Outra", Colors.blue);

    await pumpSelector(
      tester,
      identifications: [current, other],
      currentIdentificationId: current.id,
    );

    expect(
      find.byKey(Key('identification-current-${current.id}')),
      findsOneWidget,
    );
    expect(
      find.byKey(Key('identification-current-${other.id}')),
      findsNothing,
    );
  });

  testWidgets("selects the last identification when pressing up from the start",
      (tester) async {
    AccountabilityIdentification? selected;
    final identifications = [
      AccountabilityIdentification("Alimentação", Colors.green),
      AccountabilityIdentification("Transporte", Colors.blue),
      AccountabilityIdentification("Utilidades", Colors.orange),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AccountabilityIdentificationSelector(
                  identifications: identifications,
                  recordDescription: "Compra",
                  recordValue: -10,
                  onSelected: (value) => selected = value,
                ),
              ),
              child: const Text("Abrir seletor"),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text("Abrir seletor"));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(selected?.id, identifications.last.id);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets("wraps the keyboard highlight from the last item to the first",
      (tester) async {
    AccountabilityIdentification? selected;
    final identifications = [
      AccountabilityIdentification("Alimentação", Colors.green),
      AccountabilityIdentification("Transporte", Colors.blue),
      AccountabilityIdentification("Utilidades", Colors.orange),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AccountabilityIdentificationSelector(
                  identifications: identifications,
                  recordDescription: "Compra",
                  recordValue: -10,
                  onSelected: (value) => selected = value,
                ),
              ),
              child: const Text("Abrir seletor"),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text("Abrir seletor"));
    await tester.pumpAndSettle();

    for (var step = 0; step < identifications.length + 1; step++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(selected?.id, identifications.first.id);
  });

  testWidgets("keeps the keyboard-highlighted item in the visible list",
      (tester) async {
    final identifications = List.generate(
      24,
      (index) => AccountabilityIdentification(
        "Categoria ${index.toString().padLeft(2, '0')}",
        Colors.blue,
      ),
    );
    await pumpSelector(tester, identifications: identifications);

    for (var index = 0; index < identifications.length; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
    }

    final lastItem =
        find.byKey(Key('identification-item-${identifications.last.id}'));
    final viewport = find.byType(SingleChildScrollView);
    expect(
      tester.getTopLeft(lastItem).dy,
      greaterThanOrEqualTo(tester.getTopLeft(viewport).dy),
    );
    expect(
      tester.getBottomLeft(lastItem).dy,
      lessThanOrEqualTo(tester.getBottomLeft(viewport).dy),
    );
  });
}
