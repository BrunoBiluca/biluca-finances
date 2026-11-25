import 'package:biluca_financas/app/accountability_new_entry_form/accountability_new_entry_form.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:biluca_financas/core/accountability_identification_prediction/service/accountability_identification_prediction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../_mocks/mock_accountability_repo.dart';

class _FakePredictService extends Fake
    implements AccountabilityIdentificationPredictionService {
  List<AccountabilityEntryRequest> Function(List<AccountabilityEntryRequest>)
      onPredict = (entries) => const [];

  @override
  Future<List<AccountabilityEntryRequest>> predict({
    List<AccountabilityEntryRequest>? entries,
    dynamic importedFile,
  }) async {
    return onPredict(entries ?? const []);
  }
}

void main() {
  final getIt = GetIt.instance;
  late _FakePredictService predictor;
  late MockAccountabilityRepo repo;

  setUp(() async {
    await getIt.reset();
    predictor = _FakePredictService();
    repo = MockAccountabilityRepo();
    getIt.registerSingleton<AccountabilityIdentificationPredictionService>(
      predictor,
    );
    getIt.registerSingleton<AccountabilityRepo>(repo);
    when(() => repo.getIdentifications()).thenAnswer((_) async => []);
  });

  tearDown(() async {
    await getIt.reset();
  });

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

  testWidgets('shows the predicted identification for the filled data',
      (tester) async {
    final lunch = AccountabilityIdentification('Almoço', Colors.green);
    predictor.onPredict = (entries) => [
          AccountabilityEntryRequest(
            description: entries.single.description,
            value: entries.single.value,
            createdAt: entries.single.createdAt,
            identification: lunch,
          ),
        ];
    await _openForm(tester);

    await tester.enterText(find.byType(TextField).first, 'Almoço no shopping');
    await tester.enterText(find.byType(TextField).at(1), '12,34');
    await tester.pump(
      AccountabilityEntryForm.predictionDelay + const Duration(milliseconds: 50),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('entry-predicted-identification')),
      findsOneWidget,
    );
    expect(find.text('Almoço'), findsOneWidget);
  });

  testWidgets('keeps the entry saveable without a predicted identification',
      (tester) async {
    AccountabilityEntryRequest? result;
    await _openForm(tester, onResult: (request) => result = request);

    await tester.enterText(find.byType(TextField).first, 'Nova entrada');
    await tester.enterText(find.byType(TextField).at(1), '10,00');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.identification, isNull);
  });

  testWidgets('allows changing the identification before saving',
      (tester) async {
    final lunch = AccountabilityIdentification('Almoço', Colors.green);
    final market = AccountabilityIdentification('Mercado', Colors.blue);
    when(() => repo.getIdentifications())
        .thenAnswer((_) async => [lunch, market]);
    AccountabilityEntryRequest? result;
    await _openForm(tester, onResult: (request) => result = request);

    await tester.enterText(find.byType(TextField).first, 'Compra do mês');
    await tester.enterText(find.byType(TextField).at(1), '50,00');
    await tester.tap(find.byKey(const Key('entry-change-identification')));
    await tester.pumpAndSettle();

    final marketItem = find.byKey(Key('identification-item-${market.id}'));
    await tester.ensureVisible(marketItem);
    await tester.pumpAndSettle();
    await tester.tap(marketItem);
    await tester.pumpAndSettle();

    expect(find.text('Mercado'), findsOneWidget);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.identification?.id, market.id);
  });
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
