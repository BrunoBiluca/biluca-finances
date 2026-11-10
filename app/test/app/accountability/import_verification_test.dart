import 'package:biluca_financas/app/accountability_import_verification/accountability_import_verification.dart';
import 'package:biluca_financas/app/accountability_table/accountability_table.dart';
import 'package:biluca_financas/app/themes/app_theme.dart';
import 'package:biluca_financas/app/themes/obsidian_wealth/obsidian_wealth_dark_theme.dart';
import 'package:biluca_financas/app/themes/obsidian_wealth/obsidian_wealth_light_theme.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../_mocks/fake_accountability_bloc.dart';
import '../../_mocks/fake_accountability_import_service.dart';
import '../../_mocks/mock_accountability_repo.dart';

late List<AccountabilityIdentification> identifications;

void main() {
  final getIt = GetIt.instance;

  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    await getIt.reset();
    final themeManager = ThemeManager()
      ..add(ObsidianWealthDarkTheme())
      ..add(ObsidianWealthLightTheme())
      ..setDark('Obsidian Wealth Dark')
      ..setLight('Obsidian Wealth Light');
    getIt.registerSingleton<ThemeManager>(themeManager);
    identifications = [
      AccountabilityIdentification('Almoço', Colors.green)
        ..icon = Icons.restaurant,
      AccountabilityIdentification('Supermercado', Colors.blue)
        ..icon = Icons.shopping_cart,
    ];
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('apresenta título, arquivo e saldo líquido no cabeçalho',
      (tester) async {
    final service = FakeAccountabilityImportService()
      ..entries.addAll([
        _request('Mercado', 100.50),
        _request('Salário', 200),
      ]);

    await _pumpModal(tester, service: service);

    expect(find.byKey(const Key('import-verification-title')), findsOneWidget);
    expect(find.text('Conferência de Importação de Extratos'), findsOneWidget);
    expect(find.text('extrato-agosto.pdf'), findsOneWidget);
    final balance = _balanceText(tester);
    expect(balance.data, contains('300,50'));
    expect(balance.style?.color, _appTheme(tester).colors.positiveYield);
  });

  testWidgets('usa um nome padrão quando o arquivo não é informado',
      (tester) async {
    await _pumpModal(
      tester,
      service: FakeAccountabilityImportService(),
      fileName: null,
    );

    expect(
      find.text(AccountabilityImportVerification.defaultFileName),
      findsOneWidget,
    );
  });

  testWidgets('recalcula o saldo líquido após editar e remover novas entradas',
      (tester) async {
    final service = FakeAccountabilityImportService()
      ..entries.add(_request('Mercado', -10));
    await _pumpModal(tester, service: service);

    expect(_balanceText(tester).style?.color,
        _appTheme(tester).colors.negativeYield);

    final table = find.byKey(const Key('import-new-entries-table'));
    await tester.tap(_inTable(table, const Key('edit-accountability-0')));
    await tester.pump();
    await tester.enterText(
      _inTable(table, const Key('edit-value-0')),
      '25,50',
    );
    await tester.tap(_inTable(table, const Key('save-accountability-edit-0')));
    await tester.pump();

    expect(service.entries.single.value, 25.5);
    expect(_balanceText(tester).data, contains('25,50'));
    expect(_balanceText(tester).style?.color,
        _appTheme(tester).colors.positiveYield);

    await tester.tap(_inTable(table, const Key('remove-accountability-0')));
    await tester.pump();

    expect(service.entries, isEmpty);
    expect(_balanceText(tester).data, contains('0,00'));
    expect(_balanceText(tester).style?.color,
        _appTheme(tester).colors.neutralYield);
  });

  testWidgets('apresenta as três abas com contadores e a aba de regras',
      (tester) async {
    final service = FakeAccountabilityImportService()
      ..entries.add(_request('Nova', 10))
      ..duplicatedEntries.add(_duplicate(1));
    await _pumpModal(tester, service: service);

    expect(find.text('Novas Entradas'), findsOneWidget);
    expect(find.text('Registros Duplicados'), findsOneWidget);
    expect(find.text('Regras Aplicadas'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('import-tab-count-new'))).data,
      '1',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('import-tab-count-duplicates')))
          .data,
      '1',
    );
    expect(find.text('Nova'), findsOneWidget);

    await tester.tap(find.text('Registros Duplicados'));
    await tester.pumpAndSettle();
    expect(find.text('Duplicado 1'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('import-duplicates-table')),
        matching: find.text(Formatter.date(_duplicate(1).insertedAt)),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Regras Aplicadas'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('applied-rules-under-construction')),
      findsOneWidget,
    );
    expect(find.textContaining('não está disponível'), findsOneWidget);
    expect(find.byType(AccountabilityTable), findsNothing);
  });

  testWidgets(
      'ocupa a altura disponível e não oferece paginação, filtros ou seleção',
      (tester) async {
    final service = FakeAccountabilityImportService()
      ..entries.addAll(
        List.generate(40, (index) => _request('Entrada $index', index + 1)),
      );
    await _pumpModal(
      tester,
      service: service,
      size: const Size(1200, 900),
    );

    final tabViewHeight = tester.getSize(find.byType(TabBarView)).height;
    final tableHeight = tester
        .getSize(find.byKey(const Key('import-new-entries-table')))
        .height;
    expect(tableHeight, closeTo(tabViewHeight - 32, 1));
    expect(tableHeight, greaterThan(400));
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('load-more-accountability')), findsNothing);
    expect(find.byKey(const Key('accountability-search')), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byType(FilterChip), findsNothing);
  });

  testWidgets('mantém a tabela na altura total com poucos registros',
      (tester) async {
    final service = FakeAccountabilityImportService()
      ..entries.add(_request('Única', 10));
    await _pumpModal(
      tester,
      service: service,
      size: const Size(1200, 900),
    );

    final tabViewHeight = tester.getSize(find.byType(TabBarView)).height;
    final tableHeight = tester
        .getSize(find.byKey(const Key('import-new-entries-table')))
        .height;
    expect(tableHeight, closeTo(tabViewHeight - 32, 1));
  });

  testWidgets('edita descrição, valor e identificação antes de importar',
      (tester) async {
    final service = FakeAccountabilityImportService()
      ..entries.add(_request(
        'Mercado',
        10,
        identification: identifications.first,
      ));
    await _pumpModal(tester, service: service);

    final table = find.byKey(const Key('import-new-entries-table'));
    await tester.tap(_inTable(table, const Key('edit-accountability-0')));
    await tester.pump();
    await tester.enterText(
      _inTable(table, const Key('edit-description-0')),
      'Mercado editado',
    );
    await tester.enterText(_inTable(table, const Key('edit-value-0')), '25,50');
    await tester.tap(_inTable(table, const Key('edit-identification-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supermercado').last);
    await tester.pumpAndSettle();
    await tester.tap(_inTable(table, const Key('save-accountability-edit-0')));
    await tester.pump();

    expect(service.entries.single.descriptionAlt, 'Mercado editado');
    expect(service.entries.single.value, 25.5);
    expect(service.entries.single.identification, same(identifications[1]));
    expect(find.text('Mercado editado'), findsOneWidget);
  });

  testWidgets('mantém o erro para valor inválido e não grava a edição',
      (tester) async {
    final service = FakeAccountabilityImportService()
      ..entries.add(_request('Mercado', 10));
    await _pumpModal(tester, service: service);

    final table = find.byKey(const Key('import-new-entries-table'));
    await tester.tap(_inTable(table, const Key('edit-accountability-0')));
    await tester.pump();
    await tester.enterText(
        _inTable(table, const Key('edit-value-0')), 'inválido');
    await tester.tap(_inTable(table, const Key('save-accountability-edit-0')));
    await tester.pump();

    expect(find.text('Informe um valor válido'), findsOneWidget);
    expect(service.entries.single.value, 10);
  });

  testWidgets('desconsidera uma duplicata e move para as novas entradas',
      (tester) async {
    final duplicate = _duplicate(1);
    final service = FakeAccountabilityImportService()
      ..duplicatedEntries.add(duplicate);
    await _pumpModal(tester, service: service);

    await tester.tap(find.text('Registros Duplicados'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byKey(const Key('import-duplicates-table')),
      matching: find.byKey(const Key('remove-accountability-0')),
    ));
    await tester.pump();

    expect(service.duplicatedEntries, isEmpty);
    expect(service.entries, hasLength(1));
    expect(_balanceText(tester).data, contains('50,00'));

    await tester.tap(find.text('Novas Entradas'));
    await tester.pumpAndSettle();
    expect(find.text('Duplicado 1'), findsOneWidget);
  });

  testWidgets('salva todas as novas entradas e não salva ao cancelar',
      (tester) async {
    final service = FakeAccountabilityImportService()
      ..entries.add(_request('Mercado', 10));
    await _pumpModal(tester, service: service);

    await tester.tap(find.byKey(const Key('cancel-import-verification')));
    await tester.pumpAndSettle();
    expect(service.saveCalls, 0);

    await _pumpModal(tester, service: service);
    await tester.tap(find.byKey(const Key('save-import-verification')));
    await tester.pumpAndSettle();
    expect(service.saveCalls, 1);
  });

  testWidgets('usa o mesmo raio do botão contornado e um ícone no botão salvar',
      (tester) async {
    await _pumpModal(tester, service: FakeAccountabilityImportService());

    final saveButton = tester.widget<FilledButton>(
      find.byKey(const Key('save-import-verification')),
    );
    final context =
        tester.element(find.byType(AccountabilityImportVerification));
    final saveShape =
        saveButton.style!.shape!.resolve({}) as RoundedRectangleBorder;
    final outlinedShape = Theme.of(context)
        .outlinedButtonTheme
        .style!
        .shape!
        .resolve({}) as RoundedRectangleBorder;

    expect(saveShape.borderRadius, outlinedShape.borderRadius);
    expect(
      find.descendant(
        of: find.byKey(const Key('save-import-verification')),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
  });

  testWidgets('usa as cores do tema escuro e do tema claro no saldo',
      (tester) async {
    for (final theme in <AppTheme>[
      ObsidianWealthDarkTheme(),
      ObsidianWealthLightTheme(),
    ]) {
      final service = FakeAccountabilityImportService()
        ..entries.add(_request('Mercado', 10));
      await _pumpModal(
        tester,
        service: service,
        theme: theme.build(),
      );

      expect(tester.takeException(), isNull);
      expect(_balanceText(tester).style?.color,
          _appTheme(tester).colors.positiveYield);

      await tester.tap(find.byKey(const Key('close-import-verification')));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('edita um registro duplicado antes de importar', (tester) async {
    final duplicate = _duplicate(1);
    final service = FakeAccountabilityImportService()
      ..duplicatedEntries.add(duplicate);
    await _pumpModal(tester, service: service);

    await tester.tap(find.text('Registros Duplicados'));
    await tester.pumpAndSettle();
    final table = find.byKey(const Key('import-duplicates-table'));
    await tester.tap(_inTable(table, const Key('edit-accountability-0')));
    await tester.pump();
    await tester.enterText(
      _inTable(table, const Key('edit-description-0')),
      'Duplicado editado',
    );
    await tester.enterText(_inTable(table, const Key('edit-value-0')), '60,00');
    await tester.tap(_inTable(table, const Key('save-accountability-edit-0')));
    await tester.pump();

    expect(duplicate.descriptionAlt, 'Duplicado editado');
    expect(duplicate.value, 60);
    expect(find.text('Duplicado editado'), findsOneWidget);
  });

  testWidgets(
      'não oferece gerenciamento e ignora categorias descontinuadas no seletor',
      (tester) async {
    final active = AccountabilityIdentification('Ativa', Colors.green);
    final current =
        AccountabilityIdentification('Atual', Colors.blue, discontinued: true);
    final other = AccountabilityIdentification('Outra', Colors.orange,
        discontinued: true);
    identifications = [active, current, other];
    final service = FakeAccountabilityImportService()
      ..entries.add(_request('Mercado', 10, identification: current));
    await _pumpModal(tester, service: service);

    await tester
        .tap(find.byKey(const Key('accountability-identification-label')));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog).last;
    expect(
      find.descendant(
        of: dialog,
        matching: find.text('Selecionar identificação'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Ativa')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Atual')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Outra')),
      findsNothing,
    );
    expect(
      find.descendant(of: dialog, matching: find.byType(IconButton)),
      findsNothing,
    );
  });

  testWidgets('não gera overflow em viewport estreita', (tester) async {
    final service = FakeAccountabilityImportService()
      ..entries.add(_request('Entrada', 10))
      ..duplicatedEntries.add(_duplicate(1));
    await _pumpModal(
      tester,
      service: service,
      size: const Size(420, 700),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Conferência de Importação de Extratos'), findsOneWidget);
    expect(find.byKey(const Key('import-net-balance-value')), findsOneWidget);
  });
}

Future<void> _pumpModal(
  WidgetTester tester, {
  required FakeAccountabilityImportService service,
  String? fileName = 'extrato-agosto.pdf',
  ThemeData? theme,
  Size size = const Size(1200, 900),
}) async {
  final bloc = FakeAccountabilityBloc(repo: MockAccountabilityRepo())
    ..emitIdentifications(identifications);
  addTearDown(bloc.close);

  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? ObsidianWealthDarkTheme().build(),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => BlocProvider<AccountabilityBloc>.value(
                  value: bloc,
                  child: AccountabilityImportVerification(
                    service: service,
                    sourceFileName: fileName,
                  ),
                ),
              ),
              child: const Text('Abrir conferência'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('Abrir conferência'));
  await tester.pumpAndSettle();
}

Finder _inTable(Finder table, Key key) {
  return find.descendant(of: table, matching: find.byKey(key));
}

Text _balanceText(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('import-net-balance-value')));
}

AppTheme _appTheme(WidgetTester tester) {
  final context = tester.element(
    find.byType(AccountabilityImportVerification),
  );
  return GetIt.I<ThemeManager>().getCurrentTheme(context);
}

AccountabilityEntryRequest _request(
  String description,
  double value, {
  AccountabilityIdentification? identification,
}) {
  return AccountabilityEntryRequest(
    description: description,
    value: value,
    createdAt: DateTime(2026, 1, 1),
    identification: identification,
  );
}

AccountabilityEntry _duplicate(int id) {
  final date = DateTime(2026, 1, 1);
  final entry = AccountabilityEntry(
    id: id,
    description: 'Duplicado $id',
    value: 50,
    createdAt: date,
    insertedAt: DateTime(2026, 1, 2),
    updatedAt: date,
  );
  entry.identification = identifications.first;
  return entry;
}
