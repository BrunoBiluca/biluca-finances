import 'package:biluca_financas/app/accountability_page/accountability_page.dart';
import 'package:biluca_financas/app/accountability_table/accountability_table.dart';
import 'package:biluca_financas/app/accountability_table/widgets/accountability_table_row.dart';
import 'package:biluca_financas/app/themes/obsidian_wealth/obsidian_wealth_dark_theme.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/app/themes/theme_setup.dart';
import 'package:biluca_financas/common/ui/base_toast.dart';
import 'package:biluca_financas/common/ui/real_currency.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability_identification_prediction/service/accountability_identification_predition_service.dart';
import 'package:biluca_financas/core/accountability_import/services/accountability_import_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mocktail/mocktail.dart';

import '../../_mocks/fake_accountability_import_service.dart';
import '../../_mocks/fake_file_picker.dart';
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
    getIt.registerSingleton<ThemeManager>(setupThemes());
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

  testWidgets('uses semantic colors for each toast category', (tester) async {
    for (final type in BaseToastType.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaseToast(
              text: 'Toast message',
              type: type,
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(BaseToast));
      final theme = Theme.of(context);
      final appTheme = getIt<ThemeManager>().getCurrentTheme(context);
      final color = switch (type) {
        BaseToastType.success => appTheme.colors.positiveYield,
        BaseToastType.information => appTheme.colors.positiveYieldAlt,
        BaseToastType.error => theme.colorScheme.error,
      };
      final expectedIcon = switch (type) {
        BaseToastType.success => Icons.check,
        BaseToastType.information => Icons.info_outline,
        BaseToastType.error => Icons.error_outline,
      };
      final toast = tester.widget<BaseToast>(find.byType(BaseToast));
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(BaseToast),
          matching: find.byType(Icon),
        ),
      );
      final text = tester.widget<Text>(find.text('Toast message'));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BaseToast),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      final border = decoration.border! as Border;

      expect(toast.type, type);
      expect(icon.icon, expectedIcon);
      expect(icon.color, color);
      expect(
        text.style,
        theme.textTheme.bodyMedium?.copyWith(color: color),
      );
      expect(decoration.color, theme.scaffoldBackgroundColor);
      expect(border.top.width, 1);
      expect(border.top.color, color);
    }
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

  testWidgets('increases height only for the row being edited', (tester) async {
    final entries = [_entry(111), _entry(112), _entry(113)];
    tester.view
      ..physicalSize = const Size(1200, 700)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ObsidianWealthDarkTheme().build(),
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 600,
            child: AccountabilityTable(
              entries: entries,
              onUpdate: (_) {},
              onRemove: (_) {},
              enableInlineEditing: true,
            ),
          ),
        ),
      ),
    );

    DataTable2 table() => tester.widget<DataTable2>(find.byType(DataTable2));
    List<DataRow2> rows() => table().rows.cast<DataRow2>().toList();

    expect(table().dataRowHeight, 56);
    expect(rows().map((row) => row.specificRowHeight), everyElement(isNull));

    await tester.tap(find.byKey(const Key('edit-accountability-1')));
    await tester.pump();

    expect(table().dataRowHeight, 56);
    expect(
      rows().map((row) => row.specificRowHeight),
      [null, 72, null],
    );

    await tester.enterText(find.byKey(const Key('edit-value-1')), 'invalid');
    await tester.tap(find.byKey(const Key('save-accountability-edit-1')));
    await tester.pump();

    expect(
      rows().map((row) => row.specificRowHeight),
      [null, 88, null],
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('preserves alternating row backgrounds while editing',
      (tester) async {
    final entries = [_entry(121), _entry(122)];
    tester.view
      ..physicalSize = const Size(1200, 700)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ObsidianWealthDarkTheme().build(),
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 600,
            child: AccountabilityTable(
              entries: entries,
              onUpdate: (_) {},
              onRemove: (_) {},
              enableInlineEditing: true,
            ),
          ),
        ),
      ),
    );

    final table = tester.widget<DataTable2>(find.byType(DataTable2));
    final rowsBeforeEdit = table.rows.cast<DataRow2>().toList();
    final evenRowColor = rowsBeforeEdit[0].color!.resolve({});
    final oddRowColor = rowsBeforeEdit[1].color!.resolve({});

    await tester.tap(find.byKey(const Key('edit-accountability-0')));
    await tester.pump();

    final editedRows = tester
        .widget<DataTable2>(find.byType(DataTable2))
        .rows
        .cast<DataRow2>()
        .toList();
    expect(editedRows[0].color!.resolve({}), evenRowColor);
    expect(editedRows[1].color!.resolve({}), oddRowColor);
    expect(editedRows[0].color!.resolve({}), Colors.transparent);
    expect(editedRows[1].color!.resolve({}), const Color(0xFF0A0E17));

    final input = tester.widget<TextField>(
      find.byKey(const Key('edit-description-0')),
    );
    final border = input.decoration!.enabledBorder! as OutlineInputBorder;
    expect(border.borderSide.width, 0.5);
    expect(
      border.borderSide.color,
      Theme.of(tester.element(find.byKey(const Key('edit-description-0'))))
          .colorScheme
          .outlineVariant
          .withValues(alpha: 0.5),
    );
    expect(border.borderRadius, BorderRadius.circular(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('colors displayed and edited values by their sign',
      (tester) async {
    final entries = [
      _entry(101)..value = 12.5,
      _entry(102)..value = -12.5,
      _entry(103)..value = 0,
    ];
    final appTheme = setupThemes().themes['Obsidian Wealth Dark']!;
    tester.view
      ..physicalSize = const Size(1200, 700)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ObsidianWealthDarkTheme().build(),
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 600,
            child: AccountabilityTable(
              entries: entries,
              onUpdate: (_) {},
              onRemove: (_) {},
              enableInlineEditing: true,
            ),
          ),
        ),
      ),
    );

    final currencies = tester
        .widgetList<RealCurrency>(
          find.byType(RealCurrency),
        )
        .toList()
      ..sort((first, second) => first.number.compareTo(second.number));
    expect(currencies, hasLength(3));
    final valueColors = [
      appTheme.colors.negativeYield,
      appTheme.colors.neutralYield,
      appTheme.colors.positiveYield,
    ];
    for (var index = 0; index < currencies.length; index++) {
      final valueText = tester.widget<Text>(
        find.descendant(
          of: find.byWidget(currencies[index]),
          matching: find.byType(Text),
        ),
      );
      expect(valueText.style?.color, valueColors[index]);
    }

    await tester.tap(find.byKey(const Key('edit-accountability-1')));
    await tester.pump();
    var valueField = tester.widget<TextField>(
      find.byKey(const Key('edit-value-1')),
    );
    expect(valueField.style?.color, appTheme.colors.negativeYield);

    await tester.enterText(find.byKey(const Key('edit-value-1')), '12,25');
    await tester.pump();
    valueField = tester.widget<TextField>(
      find.byKey(const Key('edit-value-1')),
    );
    expect(valueField.style?.color, appTheme.colors.positiveYield);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'uses the row input background for the identification field while editing',
      (tester) async {
    final entries = [_entry(131), _entry(132)];
    tester.view
      ..physicalSize = const Size(1200, 700)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ObsidianWealthDarkTheme().build(),
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 600,
            child: AccountabilityTable(
              entries: entries,
              onUpdate: (_) {},
              onRemove: (_) {},
              enableInlineEditing: true,
              identifications: identifications,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('edit-accountability-1')));
    await tester.pump();

    final background = tester.widget<Container>(
      find.byKey(const Key('edit-identification-background-1')),
    );
    expect(
      (background.decoration! as BoxDecoration).color,
      getInputFieldBackgroundColor(1),
    );
    expect(getInputFieldBackgroundColor(1), const Color(0xFF1C1F29));
  });

  testWidgets('shows identification details and keeps the none option',
      (tester) async {
    identifications[0].icon = Icons.restaurant;
    identifications[1].icon = Icons.shopping_cart;
    final entry = _entry(104)
      ..identification = identifications.first
      ..identificationId = identifications.first.id;
    tester.view
      ..physicalSize = const Size(1200, 700)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ObsidianWealthDarkTheme().build(),
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 600,
            child: AccountabilityTable(
              entries: [entry],
              onUpdate: (_) {},
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
    await tester.tap(find.byKey(const Key('edit-identification-0')));
    await tester.pumpAndSettle();

    final option =
        find.byKey(Key('identification-option-${identifications[0].id}')).last;
    expect(
      find.descendant(of: option, matching: find.text('Almoço')),
      findsOneWidget,
    );
    final optionContainer = tester.widget<Container>(option);
    expect(
      (optionContainer.decoration! as BoxDecoration).color,
      identifications[0].color.withValues(alpha: 0.16),
    );
    final optionIcon = tester.widget<Icon>(
      find.descendant(of: option, matching: find.byIcon(Icons.restaurant)),
    );
    expect(optionIcon.color, identifications[0].color);
    expect(find.byKey(const Key('identification-option-none')), findsOneWidget);
    expect(find.text('Não identificado'), findsOneWidget);

    await tester.tap(find.byKey(const Key('identification-option-none')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-accountability-edit-0')));
    await tester.pump();

    expect(entry.identification, isNull);
    expect(entry.identificationId, isNull);
    expect(tester.takeException(), isNull);
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
    expect(find.text('Editando'), findsOneWidget);
    expect(find.text('Descrição do comprovante'), findsNothing);
    expect(find.text('Valor e fluxo'), findsNothing);
    final descriptionField = tester.widget<TextField>(
      find.byKey(const Key('edit-description-0')),
    );
    expect(descriptionField.decoration!.filled, isTrue);
    expect(
      descriptionField.decoration!.fillColor,
      const Color(0xFF0A0E17),
    );
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
    getIt.registerSingleton<AccountabilityIdentificationPredictionService>(
        predictor);
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
    final toastFinder = find.byType(BaseToast);
    expect(find.text('Registro criado com sucesso'), findsOneWidget);
    final position = tester.widget<Positioned>(
      find
          .ancestor(
            of: toastFinder,
            matching: find.byType(Positioned),
          )
          .first,
    );
    expect(position.bottom, 50);
    expect(position.right, 24);
    expect(position.top, isNull);
    expect(position.left, isNull);

    final toastContext = tester.element(toastFinder);
    final theme = Theme.of(toastContext);
    final successColor = getIt<ThemeManager>()
        .getCurrentTheme(toastContext)
        .colors
        .positiveYield;
    final toastContainer = tester.widget<Container>(
      find.descendant(
        of: toastFinder,
        matching: find.byType(Container),
      ),
    );
    final decoration = toastContainer.decoration! as BoxDecoration;
    expect(decoration.color, theme.scaffoldBackgroundColor);
    expect(decoration.border, isA<Border>());
    final border = decoration.border! as Border;
    expect(border.top.width, lessThanOrEqualTo(1));
    expect(border.top.color, successColor);
    final toastText = tester.widget<Text>(
      find.descendant(
        of: toastFinder,
        matching: find.text('Registro criado com sucesso'),
      ),
    );
    expect(
      toastText.style,
      theme.textTheme.bodyMedium?.copyWith(color: successColor),
    );
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('creates an entry when prediction returns no entries',
      (tester) async {
    registerFallbackValue(FakeAccountabilityEntryRequest());
    registerFallbackValue(<AccountabilityEntryRequest>[]);
    final predictor = MockPredictService();
    getIt.registerSingleton<AccountabilityIdentificationPredictionService>(
        predictor);
    when(() => predictor.predict(entries: any(named: 'entries')))
        .thenAnswer((_) async => []);
    late AccountabilityEntryRequest addedRequest;
    when(
      () => repo.add(any(that: isA<AccountabilityEntryRequest>())),
    ).thenAnswer((invocation) async {
      addedRequest =
          invocation.positionalArguments.single as AccountabilityEntryRequest;
      return _entry(1001);
    });
    await _pumpPage(tester);

    await tester.tap(find.byKey(const Key('new-accountability-entry')));
    await tester.pumpAndSettle();
    final formFields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(formFields.at(0), 'Uncategorized entry');
    await tester.enterText(formFields.at(1), '5,00');
    await tester.tap(find.text('Salvar').last);
    await _flushAsync(tester);

    expect(addedRequest.description, 'Uncategorized entry');
    expect(addedRequest.value, 5);
    verify(() => repo.add(any(that: isA<AccountabilityEntryRequest>())))
        .called(1);
    await tester.pump(const Duration(seconds: 3));
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

  testWidgets(
      'opens the redesigned import verification with the selected file name',
      (tester) async {
    final importService = FakeAccountabilityImportService()
      ..entries.add(AccountabilityEntryRequest(
        description: 'Nova importada',
        value: 10,
        createdAt: DateTime(2026, 1, 1),
        identification: identifications.first,
      ));
    getIt.registerSingleton<AccountabilityImportService>(importService);
    when(() => repo.getEntries(limit: any(named: 'limit')))
        .thenAnswer((_) async => <AccountabilityEntry>[]);
    FilePicker.platform = FakeFilePicker(
      result: FilePickerResult([
        PlatformFile(
          name: 'extrato-agosto.pdf',
          size: 1,
          path: 'extrato-agosto.pdf',
        ),
      ]),
    );

    await _pumpPage(tester);
    await tester.tap(find.byKey(const Key('import-accountability')));
    await _flushAsync(tester);
    await tester.pumpAndSettle();

    expect(find.text('Conferência de Importação de Extratos'), findsOneWidget);
    expect(find.text('extrato-agosto.pdf'), findsOneWidget);
    expect(find.text('Nova importada'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('import-new-entries-table')),
        matching: find.text('Almoço'),
      ),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 3));
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
  if (!GetIt.I.isRegistered<FToast>()) {
    GetIt.I.registerFactory<FToast>(
      () => FToast()..init(tester.element(find.byType(AccountabilityPage))),
    );
  }
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
