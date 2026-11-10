import 'package:biluca_financas/app/accountability_table/widgets/accountability_identification_selector.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/common/ui/text_ballon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSelector(
    WidgetTester tester, {
    required List<AccountabilityIdentification> identifications,
    String? currentIdentificationId,
    ValueChanged<AccountabilityIdentification>? onSelected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountabilityIdentificationSelector(
            identifications: identifications,
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

  testWidgets("shows identifications with their visual attributes",
      (tester) async {
    final identifications = [
      AccountabilityIdentification("identificação 1", Colors.green)
        ..icon = Icons.restaurant,
      AccountabilityIdentification("identificação 2", Colors.blue),
    ];

    await pumpSelector(tester, identifications: identifications);

    expect(find.text("identificação 1"), findsOneWidget);
    expect(find.text("identificação 2"), findsOneWidget);

    final firstItem =
        find.byKey(Key('identification-item-${identifications[0].id}'));
    final ballon = tester.widget<TextBallon>(firstItem);
    expect(ballon.tintedStyle, isTrue);
    final decoration = tester.widget<DecoratedBox>(
      find.descendant(of: firstItem, matching: find.byType(DecoratedBox)),
    );
    expect(
      (decoration.decoration as BoxDecoration).color,
      identifications[0].color.withValues(alpha: 0.16),
    );
    final icon = tester.widget<Icon>(
      find.descendant(of: firstItem, matching: find.byIcon(Icons.restaurant)),
    );
    expect(icon.color, identifications[0].color);
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

  testWidgets("filters identifications by the search text", (tester) async {
    final identifications = [
      AccountabilityIdentification("Alimentação", Colors.green),
      AccountabilityIdentification("Transporte", Colors.blue),
    ];

    await pumpSelector(tester, identifications: identifications);
    await tester.enterText(find.byType(TextField), "trans");
    await tester.pumpAndSettle();

    expect(find.text("Transporte"), findsOneWidget);
    expect(find.text("Alimentação"), findsNothing);
  });

  testWidgets("selects an identification and closes the dialog",
      (tester) async {
    AccountabilityIdentification? selected;
    final identification =
        AccountabilityIdentification("Alimentação", Colors.green);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AccountabilityIdentificationSelector(
                  identifications: [identification],
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
    await tester.tap(find.text("Alimentação"));
    await tester.pumpAndSettle();

    expect(selected?.id, identification.id);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
