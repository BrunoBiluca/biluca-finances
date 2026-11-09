import 'package:biluca_financas/app/accountability_new_entry_form/accountability_new_entry_form.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('requires a description and a value', (tester) async {
    await _openForm(tester);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Preencha o campo, por favor'), findsNWidgets(2));
    expect(find.byType(AccountabilityEntryForm), findsOneWidget);
  });

  testWidgets('rejects a whitespace-only description', (tester) async {
    await _openForm(tester);
    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.enterText(find.byType(TextField).at(1), '12,34');

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Preencha o campo, por favor'), findsOneWidget);
    expect(find.byType(AccountabilityEntryForm), findsOneWidget);
  });

  testWidgets('shows an error for an invalid monetary value', (tester) async {
    await _openForm(tester);
    await tester.enterText(find.byType(TextField).first, 'New entry');
    await tester.enterText(find.byType(TextField).at(1), 'abc');

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe um valor válido'), findsOneWidget);
    expect(find.byType(AccountabilityEntryForm), findsOneWidget);
  });

  for (final testCase in [
    (input: '0', expected: 0.0),
    (input: '-123', expected: -1.23),
  ]) {
    testWidgets('saves valid monetary value ${testCase.expected}',
        (tester) async {
      AccountabilityEntryRequest? result;
      await _openForm(tester, onResult: (request) => result = request);

      await tester.enterText(find.byType(TextField).first, ' New entry ');
      await tester.enterText(find.byType(TextField).at(1), testCase.input);
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.description, 'New entry');
      expect(result!.value, testCase.expected);
      expect(result!.createdAt, isA<DateTime>());
    });
  }
}

Future<void> _openForm(
  WidgetTester tester, {
  void Function(AccountabilityEntryRequest?)? onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final result = await showDialog<AccountabilityEntryRequest>(
                context: context,
                builder: (_) => const AccountabilityEntryForm(),
              );
              onResult?.call(result);
            },
            child: const Text('Open form'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open form'));
  await tester.pumpAndSettle();
}
