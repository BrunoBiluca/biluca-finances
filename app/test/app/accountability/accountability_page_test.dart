import 'package:biluca_financas/app/accountability_page/accountability_page.dart';
import 'package:biluca_financas/app/accountability_table/accountability_table.dart';
import 'package:biluca_financas/app/themes/obsidian_wealth/obsidian_wealth_dark_theme.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:get_it/get_it.dart';
import 'package:biluca_financas/integrations/embedded_server/embedded_predict_service.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../_mocks/fake_predict_server.dart';
import '../../_mocks/mock_accountability_repo.dart';

class FakeAccountabilityEntryRequest extends Fake
    implements AccountabilityEntryRequest {}

void main() {
  final getIt = GetIt.instance;
  late MockAccountabilityRepo repo;
  late List<AccountabilityEntry> searchResults;
  late List<AccountabilityIdentification> identifications;

  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    await getIt.reset();
    repo = MockAccountabilityRepo();
    searchResults = [];
    identifications = [
      AccountabilityIdentification('Almoço', Colors.green),
      AccountabilityIdentification('Supermercado', Colors.blue),
    ];
    when(
      () => repo.searchEntries(
        searchQuery: any(named: 'searchQuery'),
        identificationId: any(named: 'identificationId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => searchResults);
    when(() => repo.getIdentifications())
        .thenAnswer((_) async => identifications);
    getIt.registerSingleton<AccountabilityBloc>(AccountabilityBloc(repo: repo));
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('renders the page title, actions, search and category filters',
      (tester) async {
    final bloc = getIt<AccountabilityBloc>();
    await _pumpPage(tester);

    expect(bloc.state.identifications, hasLength(2));
    expect(find.text('Contabilidade'), findsOneWidget);
    expect(find.text('Prestação de Contas'), findsOneWidget);
    expect(find.byKey(const Key('import-accountability')), findsOneWidget);
    expect(find.byKey(const Key('new-accountability-entry')), findsOneWidget);
    expect(find.byKey(const Key('accountability-search')), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);
    final filters = find.byKey(const Key('accountability-category-filters'));
    expect(find.descendant(of: filters, matching: find.byType(Scrollable)),
        findsNothing);
    expect(find.text('Almoço'), findsOneWidget);
    expect(find.text('Supermercado'), findsOneWidget);
    expect(find.byKey(const Key('accountability-empty-state')), findsOneWidget);
  });

  testWidgets('adapts the page controls to a narrow viewport', (tester) async {
    searchResults = [_entry(1)];
    await _pumpPage(tester, width: 380, height: 700);

    expect(tester.takeException(), isNull);
    expect(find.byType(AccountabilityTable), findsOneWidget);
    final tableScrollables = tester.widgetList<Scrollable>(
      find.descendant(
        of: find.byType(AccountabilityTable),
        matching: find.byType(Scrollable),
      ),
    );
    expect(
      tableScrollables
          .any((scrollable) => scrollable.axisDirection == AxisDirection.right),
      isTrue,
    );
    expect(find.byKey(const Key('accountability-search')), findsOneWidget);
    expect(find.byKey(const Key('import-accountability')), findsOneWidget);
    expect(find.byKey(const Key('new-accountability-entry')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('accountability-category-filters')),
        matching: find.byType(Scrollable),
      ),
      findsNothing,
    );
    final createButton = tester.widget<FilledButton>(
      find.byKey(const Key('new-accountability-entry')),
    );
    final buttonShape = createButton.style!.shape!.resolve({});
    expect(buttonShape, isA<RoundedRectangleBorder>());
    expect(
      (buttonShape as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(8),
    );
  });

  testWidgets('shows all identification filters without horizontal scrolling',
      (tester) async {
    identifications = List<AccountabilityIdentification>.generate(
      12,
      (index) => AccountabilityIdentification('Categoria $index', Colors.blue),
    );
    await _pumpPage(tester);

    final filters = find.byKey(const Key('accountability-category-filters'));
    expect(find.descendant(of: filters, matching: find.byType(Scrollable)),
        findsNothing);
    for (var index = 0; index < identifications.length; index++) {
      expect(find.text('Categoria $index'), findsOneWidget);
    }
  });

  testWidgets('renders inside the app layout vertical scroll view',
      (tester) async {
    final entry = _entry(77)
      ..identification = identifications.first
      ..identificationId = identifications.first.id;
    searchResults = [entry];
    when(() => repo.update(entry)).thenAnswer((_) async => entry);
    tester.view
      ..physicalSize = const Size(1200, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ObsidianWealthDarkTheme().build(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1600),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: const AccountabilityPage(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await _flushAsync(tester);

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const Key('edit-accountability-0')));
    await tester.tap(find.byKey(const Key('edit-accountability-0')));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('edit-description-0')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('edit-description-0')),
      'Updated from app layout',
    );
    await tester.enterText(find.byKey(const Key('edit-value-0')), '75,25');
    await _selectIdentification(tester, 0);
    expect(tester.takeException(), isNull);

    await tester
        .ensureVisible(find.byKey(const Key('save-accountability-edit-0')));
    await tester.tap(find.byKey(const Key('save-accountability-edit-0')));
    await _flushAsync(tester);

    expect(tester.takeException(), isNull);
    expect(entry.descriptionAlt, 'Updated from app layout');
    expect(entry.value, 75.25);
    expect(entry.identificationId, identifications[1].id);
  });

  testWidgets('combines text search with a category and can clear the category',
      (tester) async {
    final bloc = getIt<AccountabilityBloc>();
    await _pumpPage(tester);
    final lunch = bloc.state.identifications.first;

    await tester.enterText(
        find.byKey(const Key('accountability-search')), 'mercado');
    await _flushAsync(tester);
    expect(bloc.state.searchQuery, 'mercado');

    await tester.tap(find.widgetWithText(FilterChip, 'Almoço'));
    await _flushAsync(tester);
    expect(bloc.state.identificationId, lunch.id);
    expect(bloc.state.searchQuery, 'mercado');

    await tester.tap(find.widgetWithText(FilterChip, 'Todos'));
    await _flushAsync(tester);
    expect(bloc.state.identificationId, isNull);
    expect(bloc.state.searchQuery, 'mercado');
    verify(
      () => repo.searchEntries(
        searchQuery: 'mercado',
        identificationId: lunch.id,
        limit: AccountabilityBloc.pageSize + 1,
        offset: 0,
      ),
    ).called(1);
  });

  testWidgets('shows an empty state when filters have no matching entries',
      (tester) async {
    final bloc = getIt<AccountabilityBloc>();
    await _pumpPage(tester);

    await tester.enterText(
        find.byKey(const Key('accountability-search')), 'inexistente');
    await _flushAsync(tester);

    expect(bloc.state.entries, isEmpty);
    expect(
        find.text('Nenhum lançamento corresponde aos filtros'), findsOneWidget);
  });

  testWidgets('loads the next filtered page without replacing current entries',
      (tester) async {
    searchResults = List<AccountabilityEntry>.generate(
      AccountabilityBloc.pageSize + 1,
      (index) => _entry(index),
    );
    final bloc = getIt<AccountabilityBloc>();
    await _pumpPage(tester);

    expect(bloc.state.entries, hasLength(AccountabilityBloc.pageSize));
    expect(find.byKey(const Key('load-more-accountability')), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byKey(const Key('load-more-accountability')),
        matching: find.byType(AccountabilityTable),
      ),
      findsOneWidget,
    );
    final tableRect = tester.getRect(find.byType(AccountabilityTable));
    final paginationRect =
        tester.getRect(find.byKey(const Key('load-more-accountability')));
    expect(paginationRect.center.dy, greaterThan(tableRect.center.dy));
    expect(paginationRect.bottom, lessThanOrEqualTo(tableRect.bottom));

    searchResults = [];
    await tester.tap(find.byKey(const Key('load-more-accountability')));
    await _flushAsync(tester);

    expect(bloc.state.entries, hasLength(AccountabilityBloc.pageSize));
    expect(bloc.state.hasMore, isFalse);
    expect(find.byKey(const Key('load-more-accountability')), findsNothing);
    verify(
      () => repo.searchEntries(
        searchQuery: '',
        identificationId: null,
        limit: AccountabilityBloc.pageSize + 1,
        offset: AccountabilityBloc.pageSize,
      ),
    ).called(1);
  });

  testWidgets('discards inline edits when cancelled', (tester) async {
    final entry = _entry(42)
      ..identification = identifications.first
      ..identificationId = identifications.first.id;
    searchResults = [entry];
    await _pumpPage(tester);

    await tester.tap(find.byKey(const Key('edit-accountability-0')));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.enterText(
      find.byKey(const Key('edit-description-0')),
      'Draft description',
    );
    await tester.enterText(find.byKey(const Key('edit-value-0')), '99,99');
    await _selectIdentification(tester, 0);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('cancel-accountability-edit-0')));
    await tester.pump();

    expect(entry.descriptionAlt, isNull);
    expect(entry.value, 42);
    expect(entry.identificationId, identifications.first.id);
    verifyNever(() => repo.update(entry));
  });

  testWidgets('opens inline edit after hovering the edit action',
      (tester) async {
    final entry = _entry(46);
    searchResults = [entry];
    await _pumpPage(tester);

    final editButton = find.byKey(const Key('edit-accountability-0'));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(editButton));
    await mouse.moveTo(tester.getCenter(editButton));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);

    await tester.tap(editButton);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('edit-description-0')), findsOneWidget);
  });

  testWidgets('keeps the editor open with an error for an invalid amount',
      (tester) async {
    final entry = _entry(45);
    searchResults = [entry];
    await _pumpPage(tester);

    await tester.tap(find.byKey(const Key('edit-accountability-0')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('edit-value-0')), 'invalid');
    await tester.tap(find.byKey(const Key('save-accountability-edit-0')));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Informe um valor válido'), findsOneWidget);
    expect(find.byKey(const Key('edit-description-0')), findsOneWidget);
    verifyNever(() => repo.update(entry));
  });

  testWidgets('saves inline edits to description, value and identification',
      (tester) async {
    final entry = _entry(43)
      ..identification = identifications.first
      ..identificationId = identifications.first.id;
    searchResults = [entry];
    when(() => repo.update(entry)).thenAnswer((_) async => entry);
    await _pumpPage(tester);

    await tester.tap(find.byKey(const Key('edit-accountability-0')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('edit-description-0')),
      'Updated description',
    );
    await tester.enterText(find.byKey(const Key('edit-value-0')), '22,50');
    await _selectIdentification(tester, 0);
    await tester.tap(find.byKey(const Key('save-accountability-edit-0')));
    await _flushAsync(tester);

    expect(entry.descriptionAlt, 'Updated description');
    expect(entry.value, 22.5);
    expect(entry.identificationId, identifications[1].id);
    expect(find.text('Updated description'), findsOneWidget);
    verify(() => repo.update(entry)).called(1);
  });

  testWidgets('edits a pending import entry without a database id',
      (tester) async {
    final entry = AccountabilityEntryRequest(
      description: 'Pending import',
      value: 18.5,
      createdAt: DateTime(2026, 1, 1),
      identification: identifications.first,
    );
    dynamic updatedEntry;
    tester.view
      ..physicalSize = const Size(1200, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 800,
            child: AccountabilityTable(
              entries: [entry],
              onUpdate: (value) => updatedEntry = value,
              onRemove: (_) {},
              enableInlineEditing: true,
              identifications: identifications,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('edit-accountability-0')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('edit-description-0')),
      'Reviewed import',
    );
    await tester.enterText(find.byKey(const Key('edit-value-0')), '25,75');
    await _selectIdentification(tester, 0);
    await tester.tap(find.byKey(const Key('save-accountability-edit-0')));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(entry.descriptionAlt, 'Reviewed import');
    expect(entry.value, 25.75);
    expect(entry.identification, same(identifications[1]));
    expect(updatedEntry, same(entry));
  });

  testWidgets('creates a new entry through the existing form', (tester) async {
    registerFallbackValue(FakeAccountabilityEntryRequest());
    registerFallbackValue(<AccountabilityEntryRequest>[]);
    final predictor = MockPredictService();
    getIt.registerSingleton<EmbeddedPredictService>(predictor);
    when(() => predictor.predict(entries: any(named: 'entries'))).thenAnswer(
      (invocation) async => invocation.namedArguments[#entries]
          as List<AccountabilityEntryRequest>,
    );
    late AccountabilityEntryRequest addedRequest;
    when(
      () => repo.add(any(that: isA<AccountabilityEntryRequest>())),
    ).thenAnswer((invocation) async {
      addedRequest =
          invocation.positionalArguments.single as AccountabilityEntryRequest;
      return _entry(1000);
    });
    await _pumpPage(tester);

    await tester.tap(find.byKey(const Key('new-accountability-entry')));
    await tester.pumpAndSettle();
    final formFields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(formFields.at(0), 'New entry');
    await tester.enterText(formFields.at(1), '12,34');
    await tester.tap(find.text('Salvar').last);
    await _flushAsync(tester);

    verify(() => predictor.predict(entries: any(named: 'entries'))).called(1);
    expect(addedRequest.description, 'New entry');
    expect(addedRequest.value, 12.34);
    verify(() => repo.add(any(that: isA<AccountabilityEntryRequest>())))
        .called(1);
  });

  testWidgets('deletes an entry through the existing row action',
      (tester) async {
    final entry = _entry(44);
    searchResults = [entry];
    when(() => repo.delete(entry)).thenAnswer((_) async {});
    await _pumpPage(tester);

    await tester.tap(find.byKey(const Key('remove-accountability-0')));
    await _flushAsync(tester);

    verify(() => repo.delete(entry)).called(1);
  });

  testWidgets('uses the requested table header and alternating row colors',
      (tester) async {
    searchResults = [_entry(47), _entry(48)];
    await _pumpPage(tester);

    final table = tester.widget<DataTable2>(find.byType(DataTable2));
    expect(
      table.headingRowDecoration!.color,
      const Color(0xFF0A0E17),
    );
    expect(
      table.rows[1].color!.resolve({}),
      const Color(0xFF0A0E17),
    );
  });

  testWidgets('table expands to the available viewport height', (tester) async {
    searchResults = [_entry(49)];
    await _pumpPage(tester, height: 900);

    expect(tester.getSize(find.byType(AccountabilityTable)).height,
        greaterThan(650));
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  double width = 1200,
  double height = 800,
}) async {
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: const AccountabilityPage(),
        ),
      ),
    ),
  );
  await _flushAsync(tester);
}

Future<void> _flushAsync(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 10)),
  );
  await tester.pump();
}

Future<void> _selectIdentification(WidgetTester tester, int rowIndex) async {
  await tester.tap(find.byKey(Key('edit-identification-$rowIndex')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Supermercado').last);
  await tester.pumpAndSettle();
}

AccountabilityEntry _entry(int id) {
  final date = DateTime(2026, 1, 1).add(Duration(days: id));
  return AccountabilityEntry(
    id: id,
    description: 'Entry $id',
    value: id.toDouble(),
    createdAt: date,
    insertedAt: date,
    updatedAt: date,
  );
}
