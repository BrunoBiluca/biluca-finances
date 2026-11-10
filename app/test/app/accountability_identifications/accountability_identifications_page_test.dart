import 'package:biluca_financas/app/accountability_identifications/accountability_identifications_page.dart';
import 'package:biluca_financas/app/themes/obsidian_wealth/obsidian_wealth_dark_theme.dart';
import 'package:biluca_financas/app/themes/obsidian_wealth/obsidian_wealth_light_theme.dart';
import 'package:biluca_financas/core/accountability/bloc/identification_categories_bloc.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../_mocks/mock_accountability_repo.dart';

void main() {
  final getIt = GetIt.instance;
  late MockAccountabilityRepo repo;
  late List<AccountabilityIdentification> categories;

  setUpAll(() {
    registerFallbackValue(
      AccountabilityIdentification('fallback', Colors.black),
    );
  });

  setUp(() async {
    await getIt.reset();
    repo = MockAccountabilityRepo();
    categories = [];

    when(() => repo.getIdentifications()).thenAnswer((_) async => List.of(categories));
    when(() => repo.addIdentification(any())).thenAnswer((invocation) async {
      final identification = invocation.positionalArguments.first as AccountabilityIdentification;
      categories.add(identification);
      return identification;
    });
    when(() => repo.updateIdentification(any())).thenAnswer((invocation) async {
      final identification = invocation.positionalArguments.first as AccountabilityIdentification;
      final index = categories.indexWhere((item) => item.id == identification.id);
      if (index >= 0) categories[index] = identification;
    });
    when(() => repo.deleteIdentification(any())).thenAnswer((invocation) async {
      final identificationId = invocation.positionalArguments.first as String;
      categories.removeWhere((item) => item.id == identificationId);
      for (final item in categories) {
        if (item.parentId == identificationId) item.parentId = null;
      }
    });

    getIt.registerFactory<IdentificationCategoriesBloc>(
      () => IdentificationCategoriesBloc(repo: repo),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> flush(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    double width = 1200,
    double height = 900,
    ThemeData? theme,
  }) async {
    tester.view
      ..physicalSize = Size(width, height)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? ObsidianWealthDarkTheme().build(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: AccountabilityIdentificationsPage(),
          ),
        ),
      ),
    );
    await flush(tester);
    await flush(tester);
  }

  String? textOf(WidgetTester tester, Key key) {
    return tester.widget<Text>(find.byKey(key)).data;
  }

  testWidgets('shows title, creation action and consolidation values', (tester) async {
    final root = AccountabilityIdentification('Alimentação', Colors.green);
    final child = AccountabilityIdentification(
      'Restaurante',
      Colors.orange,
      parentId: root.id,
    );
    final discontinued = AccountabilityIdentification(
      'Antiga',
      Colors.grey,
      discontinued: true,
    );
    categories = [root, child, discontinued];

    await pumpPage(tester);

    expect(find.byKey(const Key('identification-page-title')), findsOneWidget);
    expect(find.byKey(const Key('new-identification-category')), findsOneWidget);
    expect(textOf(tester, const Key('identification-total-count')), '3');
    expect(textOf(tester, const Key('identification-parent-count')), '2');
    expect(textOf(tester, const Key('identification-subcategory-count')), '1');
    expect(textOf(tester, const Key('identification-discontinued-count')), '1');
    expect(find.text('Todas as categorias (3)'), findsOneWidget);
    expect(find.text('Categorias ativas (2)'), findsOneWidget);
    expect(find.text('Categorias descontinuadas (1)'), findsOneWidget);
    expect(find.textContaining('R\$'), findsNothing);
  });

  testWidgets('filters the list by status tabs', (tester) async {
    final active = AccountabilityIdentification('Ativa', Colors.green);
    final discontinued = AccountabilityIdentification(
      'Descontinuada',
      Colors.grey,
      discontinued: true,
    );
    categories = [active, discontinued];

    await pumpPage(tester);
    expect(find.byKey(Key('identification-name-${active.id}')), findsOneWidget);
    expect(
      find.byKey(Key('identification-name-${discontinued.id}')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('identification-tab-active')));
    await tester.pump();
    expect(find.byKey(Key('identification-name-${active.id}')), findsOneWidget);
    expect(
      find.byKey(Key('identification-name-${discontinued.id}')),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('identification-tab-discontinued')));
    await tester.pump();
    expect(find.byKey(Key('identification-name-${active.id}')), findsNothing);
    expect(
      find.byKey(Key('identification-name-${discontinued.id}')),
      findsOneWidget,
    );
  });

  testWidgets('shows an empty state when the tab has no categories', (tester) async {
    categories = [AccountabilityIdentification('Ativa', Colors.green)];

    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('identification-tab-discontinued')));
    await tester.pump();

    expect(find.byKey(const Key('identification-empty-state')), findsOneWidget);
  });

  testWidgets('groups subcategories and presents them as roots when the parent is filtered out', (tester) async {
    final parent = AccountabilityIdentification('Ativa', Colors.green);
    final child = AccountabilityIdentification(
      'Filha da ativa',
      Colors.orange,
      parentId: parent.id,
    );
    final discontinuedChild = AccountabilityIdentification(
      'Filha descontinuada',
      Colors.grey,
      parentId: parent.id,
      discontinued: true,
    );
    categories = [parent, child, discontinuedChild];

    await pumpPage(tester);

    expect(
      find.descendant(
        of: find.byKey(Key('identification-group-${parent.id}')),
        matching: find.byKey(Key('identification-item-${child.id}')),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('identification-tab-active')));
    await tester.pump();
    expect(
      find.byKey(Key('identification-name-${discontinuedChild.id}')),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('identification-tab-discontinued')));
    await tester.pump();

    expect(
      find.byKey(Key('identification-group-${discontinuedChild.id}')),
      findsOneWidget,
    );
    expect(find.text('Subcategoria de Ativa'), findsOneWidget);
    expect(
      find.byKey(Key('add-subcategory-${discontinuedChild.id}')),
      findsNothing,
    );
  });

  testWidgets('creates a root category with the defaults and updates the counts', (tester) async {
    categories = [];
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('new-identification-category')));
    await tester.pumpAndSettle();

    expect(find.text('Nova identificação'), findsWidgets);
    expect(find.byKey(const Key('identification-name-field')), findsOneWidget);
    expect(find.byKey(const Key('identification-parent-field')), findsOneWidget);
    expect(find.byKey(const Key('identification-type-field')), findsOneWidget);
    expect(find.byKey(const Key('identification-icon-button')), findsOneWidget);
    expect(find.byKey(const Key('identification-color-button')), findsOneWidget);
    expect(find.byKey(const Key('identification-status-active')), findsOneWidget);
    expect(find.byKey(const Key('identification-status-discontinued')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('identification-name-field')),
      'Nova categoria',
    );
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pumpAndSettle();
    await flush(tester);

    expect(categories, hasLength(1));
    final created = categories.single;
    expect(created.description, 'Nova categoria');
    expect(created.parentId, isNull);
    expect(created.discontinued, isFalse);
    expect(created.type, AccountabilityIdentificationType.expense);
    expect(find.text('Nova categoria'), findsOneWidget);
    expect(textOf(tester, const Key('identification-total-count')), '1');
  });

  testWidgets('requires a name and cancels creation without persisting', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('new-identification-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pump();

    expect(find.text('Informe o nome da categoria'), findsOneWidget);
    expect(categories, isEmpty);

    await tester.tap(find.byKey(const Key('identification-cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('identification-name-field')), findsNothing);
    expect(categories, isEmpty);
  });

  testWidgets('creates a subcategory with the parent preselected', (tester) async {
    final parent = AccountabilityIdentification('Ativa', Colors.green);
    categories = [parent];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('add-subcategory-${parent.id}')));
    await tester.pumpAndSettle();

    final dropdown = tester.widget<DropdownButton<String?>>(
      find.byKey(const Key('identification-parent-field')),
    );
    expect(dropdown.value, parent.id);

    await tester.enterText(
      find.byKey(const Key('identification-name-field')),
      'Subcategoria',
    );
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pumpAndSettle();
    await flush(tester);

    final created = categories.firstWhere((item) => item.description == 'Subcategoria');
    expect(created.parentId, parent.id);
    expect(
      find.descendant(
        of: find.byKey(Key('identification-group-${parent.id}')),
        matching: find.byKey(Key('identification-item-${created.id}')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('edits all fields of a category', (tester) async {
    final original = AccountabilityIdentification('Original', Colors.green);
    categories = [original];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('edit-identification-${original.id}')));
    await tester.pumpAndSettle();

    expect(find.text('Editar identificação'), findsOneWidget);
    expect(find.byKey(const Key('identification-delete')), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byKey(const Key('identification-name-field'))).controller!.text,
      'Original',
    );

    await tester.enterText(
      find.byKey(const Key('identification-name-field')),
      'Atualizada',
    );
    await tester.tap(find.byKey(const Key('identification-type-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Receita').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-status-discontinued')));
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pumpAndSettle();
    await flush(tester);

    expect(categories.single.description, 'Atualizada');
    expect(categories.single.type, AccountabilityIdentificationType.income);
    expect(categories.single.discontinued, isTrue);
    expect(find.text('Atualizada'), findsOneWidget);
  });

  testWidgets('disables the parent field for a category with children', (tester) async {
    final parent = AccountabilityIdentification('Pai', Colors.green);
    final child = AccountabilityIdentification(
      'Filha',
      Colors.orange,
      parentId: parent.id,
    );
    categories = [parent, child];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('edit-identification-${parent.id}')));
    await tester.pumpAndSettle();

    final dropdown = tester.widget<DropdownButton<String?>>(
      find.byKey(const Key('identification-parent-field')),
    );
    expect(dropdown.onChanged, isNull);
    expect(
      find.text(
        'Esta categoria possui subcategorias e não pode ser filha de outra categoria.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('promotes a subcategory to a root category', (tester) async {
    final parent = AccountabilityIdentification('Pai', Colors.green);
    final child = AccountabilityIdentification(
      'Filha',
      Colors.orange,
      parentId: parent.id,
    );
    categories = [parent, child];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('edit-identification-${child.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-parent-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nenhuma (categoria pai)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pumpAndSettle();
    await flush(tester);

    expect(categories.firstWhere((item) => item.id == child.id).parentId, isNull);

    await tester.tap(find.byKey(Key('edit-identification-${child.id}')));
    await tester.pumpAndSettle();
    final typeField = tester.widget<DropdownButton<AccountabilityIdentificationType>>(
      find.byKey(const Key('identification-type-field')),
    );
    expect(typeField.onChanged, isNotNull);
  });

  testWidgets('blocks discontinuing a parent with active children', (tester) async {
    final parent = AccountabilityIdentification('Ativa', Colors.green);
    final child = AccountabilityIdentification(
      'Filha',
      Colors.orange,
      parentId: parent.id,
    );
    categories = [parent, child];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('edit-identification-${parent.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-status-discontinued')));
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pump();

    expect(
      find.byKey(const Key('identification-status-error')),
      findsOneWidget,
    );
    expect(categories.first.discontinued, isFalse);
  });

  testWidgets('allows discontinuing a parent after its children are discontinued', (tester) async {
    final parent = AccountabilityIdentification('Pai', Colors.green);
    final child = AccountabilityIdentification(
      'Filha',
      Colors.orange,
      parentId: parent.id,
    );
    categories = [parent, child];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('edit-identification-${child.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-status-discontinued')));
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pumpAndSettle();
    await flush(tester);

    await tester.tap(find.byKey(Key('edit-identification-${parent.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-status-discontinued')));
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pumpAndSettle();
    await flush(tester);

    expect(
      categories.firstWhere((item) => item.id == parent.id).discontinued,
      isTrue,
    );
  });

  testWidgets('blocks reactivating a child whose parent is discontinued', (tester) async {
    final parent = AccountabilityIdentification(
      'Pai',
      Colors.green,
      discontinued: true,
    );
    final child = AccountabilityIdentification(
      'Filha',
      Colors.orange,
      parentId: parent.id,
      discontinued: true,
    );
    categories = [parent, child];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('edit-identification-${child.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-status-active')));
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pump();

    expect(
      find.byKey(const Key('identification-status-error')),
      findsOneWidget,
    );
    expect(
      categories.firstWhere((item) => item.id == child.id).discontinued,
      isTrue,
    );
  });

  testWidgets('filters by type and updates the tab counters', (tester) async {
    final expense = AccountabilityIdentification(
      'Despesa ativa',
      Colors.green,
      type: AccountabilityIdentificationType.expense,
    );
    final income = AccountabilityIdentification(
      'Receita ativa',
      Colors.blue,
      type: AccountabilityIdentificationType.income,
    );
    final discontinuedIncome = AccountabilityIdentification(
      'Receita antiga',
      Colors.grey,
      type: AccountabilityIdentificationType.income,
      discontinued: true,
    );
    final investment = AccountabilityIdentification(
      'Investimento',
      Colors.orange,
      type: AccountabilityIdentificationType.investment,
    );
    categories = [expense, income, discontinuedIncome, investment];

    await pumpPage(tester);

    await tester.tap(
      find.byKey(const Key('identification-type-filter-income')),
    );
    await tester.pump();

    expect(find.byKey(Key('identification-name-${expense.id}')), findsNothing);
    expect(find.byKey(Key('identification-name-${income.id}')), findsOneWidget);
    expect(
      find.byKey(Key('identification-name-${discontinuedIncome.id}')),
      findsOneWidget,
    );
    expect(
      find.byKey(Key('identification-name-${investment.id}')),
      findsNothing,
    );
    expect(find.text('Todas as categorias (2)'), findsOneWidget);
    expect(find.text('Categorias ativas (1)'), findsOneWidget);
    expect(find.text('Categorias descontinuadas (1)'), findsOneWidget);
    expect(textOf(tester, const Key('identification-total-count')), '4');

    await tester.tap(
      find.byKey(const Key('identification-tab-discontinued')),
    );
    await tester.pump();
    expect(
      find.byKey(Key('identification-name-${discontinuedIncome.id}')),
      findsOneWidget,
    );
    expect(find.byKey(Key('identification-name-${income.id}')), findsNothing);

    await tester.tap(find.byKey(const Key('identification-type-filter-all')));
    await tester.pump();
    expect(find.text('Todas as categorias (4)'), findsOneWidget);
  });

  testWidgets('shows an empty state for a type without categories', (tester) async {
    categories = [
      AccountabilityIdentification(
        'Despesa',
        Colors.green,
        type: AccountabilityIdentificationType.expense,
      ),
    ];
    await pumpPage(tester);

    await tester.tap(
      find.byKey(const Key('identification-type-filter-investment')),
    );
    await tester.pump();

    expect(find.byKey(const Key('identification-empty-state')), findsOneWidget);
  });

  testWidgets('inherits and locks the parent type when creating a child', (tester) async {
    final parent = AccountabilityIdentification(
      'Receitas',
      Colors.green,
      type: AccountabilityIdentificationType.income,
    );
    categories = [parent];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('add-subcategory-${parent.id}')));
    await tester.pumpAndSettle();

    final typeField = tester.widget<DropdownButton<AccountabilityIdentificationType>>(
      find.byKey(const Key('identification-type-field')),
    );
    expect(typeField.value, AccountabilityIdentificationType.income);
    expect(typeField.onChanged, isNull);
    expect(
      find.byKey(const Key('identification-type-helper')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('identification-name-field')),
      'Salários',
    );
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pumpAndSettle();
    await flush(tester);

    final child = categories.firstWhere((item) => item.description == 'Salários');
    expect(child.type, AccountabilityIdentificationType.income);
  });

  testWidgets('normalizes a child type to the parent type on save', (tester) async {
    final parent = AccountabilityIdentification(
      'Receitas',
      Colors.green,
      type: AccountabilityIdentificationType.income,
    );
    final child = AccountabilityIdentification(
      'Salários',
      Colors.orange,
      parentId: parent.id,
      type: AccountabilityIdentificationType.expense,
    );
    categories = [parent, child];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('edit-identification-${child.id}')));
    await tester.pumpAndSettle();

    final typeField = tester.widget<DropdownButton<AccountabilityIdentificationType>>(
      find.byKey(const Key('identification-type-field')),
    );
    expect(typeField.value, AccountabilityIdentificationType.income);
    expect(typeField.onChanged, isNull);

    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pumpAndSettle();
    await flush(tester);

    expect(
      categories.firstWhere((item) => item.id == child.id).type,
      AccountabilityIdentificationType.income,
    );
  });

  testWidgets('cascades the parent type to its children', (tester) async {
    final parent = AccountabilityIdentification(
      'Despesas',
      Colors.green,
      type: AccountabilityIdentificationType.expense,
    );
    final child = AccountabilityIdentification(
      'Mercado',
      Colors.orange,
      parentId: parent.id,
      type: AccountabilityIdentificationType.expense,
    );
    categories = [parent, child];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('edit-identification-${parent.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-type-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Receita').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pumpAndSettle();
    await flush(tester);

    expect(
      categories.firstWhere((item) => item.id == parent.id).type,
      AccountabilityIdentificationType.income,
    );
    expect(
      categories.firstWhere((item) => item.id == child.id).type,
      AccountabilityIdentificationType.income,
    );
  });

  testWidgets('uses the fixed border color and a lighter child background', (tester) async {
    final parent = AccountabilityIdentification('Pai', Colors.green);
    final child = AccountabilityIdentification(
      'Filha',
      Colors.orange,
      parentId: parent.id,
    );
    categories = [parent, child];

    for (final theme in [
      ObsidianWealthDarkTheme().build(),
      ObsidianWealthLightTheme().build(),
    ]) {
      await pumpPage(tester, theme: theme);

      final parentContainer = tester.widget<Container>(
        find.byKey(Key('identification-group-${parent.id}')),
      );
      final parentDecoration = parentContainer.decoration! as BoxDecoration;
      final parentBorder = parentDecoration.border! as Border;
      expect(parentBorder.top.color, const Color(0xFF272D36));
      expect(parentBorder.top.width, 1);
      expect(parentDecoration.borderRadius, BorderRadius.circular(6));

      final childContainer = tester.widget<Container>(
        find.byKey(Key('identification-item-${child.id}')),
      );
      final childDecoration = childContainer.decoration! as BoxDecoration;
      final childBorder = childDecoration.border! as Border;
      expect(childBorder.top.color, const Color(0xFF272D36));
      expect(childDecoration.borderRadius, BorderRadius.circular(6));
      expect(
        childDecoration.color!.computeLuminance(),
        greaterThan(parentDecoration.color!.computeLuminance()),
      );
    }
  });

  testWidgets('positions the type filter to the right on wide screens and below on narrow screens', (tester) async {
    categories = [
      AccountabilityIdentification('Categoria', Colors.green),
    ];

    await pumpPage(tester, width: 1200);
    expect(
      tester.getCenter(find.byKey(const Key('identification-type-filter-all'))).dx,
      greaterThan(
        tester.getCenter(find.byKey(const Key('identification-tab-all'))).dx,
      ),
    );

    await pumpPage(tester, width: 380);
    expect(tester.takeException(), isNull);
    expect(
      tester.getCenter(find.byKey(const Key('identification-type-filter-all'))).dy,
      greaterThan(
        tester.getCenter(find.byKey(const Key('identification-tab-all'))).dy,
      ),
    );
  });

  testWidgets('orders active categories before discontinued ones', (tester) async {
    final alpha = AccountabilityIdentification('Alpha', Colors.green);
    final beta = AccountabilityIdentification('Beta', Colors.blue);
    final discontinuedRoot = AccountabilityIdentification(
      'Zulu',
      Colors.grey,
      discontinued: true,
    );
    final activeChild = AccountabilityIdentification(
      'Child Active',
      Colors.orange,
      parentId: alpha.id,
    );
    final discontinuedChild = AccountabilityIdentification(
      'Child Old',
      Colors.grey,
      parentId: alpha.id,
      discontinued: true,
    );
    categories = [
      discontinuedRoot,
      beta,
      activeChild,
      alpha,
      discontinuedChild,
    ];

    await pumpPage(tester);

    double top(Key key) => tester.getTopLeft(find.byKey(key)).dy;

    expect(
      top(Key('identification-group-${alpha.id}')),
      lessThan(top(Key('identification-group-${beta.id}'))),
    );
    expect(
      top(Key('identification-group-${beta.id}')),
      lessThan(top(Key('identification-group-${discontinuedRoot.id}'))),
    );
    expect(
      top(Key('identification-item-${activeChild.id}')),
      lessThan(top(Key('identification-item-${discontinuedChild.id}'))),
    );
  });

  testWidgets('applies opacity only to discontinued categories', (tester) async {
    final activeParent = AccountabilityIdentification('Ativa', Colors.green);
    final discontinuedParent = AccountabilityIdentification(
      'Descontinuada',
      Colors.grey,
      discontinued: true,
    );
    final activeChild = AccountabilityIdentification(
      'Filha ativa',
      Colors.orange,
      parentId: activeParent.id,
    );
    final discontinuedChild = AccountabilityIdentification(
      'Filha descontinuada',
      Colors.grey,
      parentId: activeParent.id,
      discontinued: true,
    );
    categories = [
      activeParent,
      discontinuedParent,
      activeChild,
      discontinuedChild,
    ];

    await pumpPage(tester);

    double opacityOf(String id) => tester.widget<Opacity>(find.byKey(Key('identification-opacity-$id'))).opacity;

    expect(opacityOf(activeParent.id), 1.0);
    expect(opacityOf(discontinuedParent.id), 0.9);
    expect(opacityOf(activeChild.id), 1.0);
    expect(opacityOf(discontinuedChild.id), 0.8);
  });

  testWidgets('applies modal field borders with focus and error colors', (tester) async {
    categories = [AccountabilityIdentification('Categoria', Colors.green)];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('edit-identification-${categories.single.id}')));
    await tester.pumpAndSettle();

    final nameField = tester.widget<TextField>(find.byKey(const Key('identification-name-field')));
    final enabledBorder = nameField.decoration!.enabledBorder! as OutlineInputBorder;
    final focusedBorder = nameField.decoration!.focusedBorder! as OutlineInputBorder;
    expect(enabledBorder.borderSide.color, const Color(0xFF272D36));
    expect(focusedBorder.borderSide.color, const Color(0xFF3A424C));

    for (final key in [
      const Key('identification-parent-container'),
      const Key('identification-type-container'),
      const Key('identification-icon-container'),
      const Key('identification-color-container'),
    ]) {
      final container = tester.widget<Container>(find.byKey(key));
      final border = (container.decoration! as BoxDecoration).border! as Border;
      expect(border.top.color, const Color(0xFF272D36));
    }

    final activeStatusContainer = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byKey(const Key('identification-status-active')),
            matching: find.byType(Container),
          ),
        )
        .first;
    final statusBorder = (activeStatusContainer.decoration! as BoxDecoration).border! as Border;
    expect(statusBorder.top.color, const Color(0xFF272D36));

    await tester.enterText(
      find.byKey(const Key('identification-name-field')),
      '',
    );
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pump();

    final errorField = tester.widget<TextField>(find.byKey(const Key('identification-name-field')));
    final errorBorder = errorField.decoration!.errorBorder! as OutlineInputBorder;
    final context = tester.element(find.byKey(const Key('identification-name-field')));
    expect(errorBorder.borderSide.color, Theme.of(context).colorScheme.error);
  });

  testWidgets('shows icon and color in the parent category selector', (tester) async {
    final parent = AccountabilityIdentification(
      'Receitas',
      Colors.green,
      type: AccountabilityIdentificationType.income,
    )..icon = Icons.restaurant;
    categories = [parent];

    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('new-identification-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-parent-field')));
    await tester.pumpAndSettle();

    final option = find.byKey(Key('identification-parent-option-${parent.id}'));
    expect(option, findsOneWidget);
    expect(
      find.descendant(of: option, matching: find.byIcon(Icons.restaurant)),
      findsOneWidget,
    );

    await tester.tap(option);
    await tester.pumpAndSettle();

    final selected = find.byKey(Key('identification-parent-selected-${parent.id}'));
    expect(selected, findsOneWidget);
    expect(
      find.descendant(of: selected, matching: find.byIcon(Icons.restaurant)),
      findsOneWidget,
    );

    final textFinder = find.descendant(
      of: selected,
      matching: find.byType(Text),
    );
    final textWidget = tester.widget<Text>(textFinder);
    expect(
      textWidget.style!.color!,
      Colors.green,
    );
  });

  testWidgets('opens the compact color picker with a hex field', (tester) async {
    categories = [AccountabilityIdentification('Categoria', Colors.green)];

    await pumpPage(tester, height: 700);
    await tester.tap(find.byKey(Key('edit-identification-${categories.single.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-color-button')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const Key('identification-color-hex-field')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('identification-color-hex-field')),
      '#123456',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('identification-color-save')));
    await tester.pumpAndSettle();

    expect(find.text('#123456'), findsOneWidget);
    await tester.tap(find.byKey(const Key('identification-save')));
    await tester.pumpAndSettle();
    await flush(tester);

    expect(categories.single.color, const Color(0xFF123456));
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the icon picker with visible Material icons', (tester) async {
    categories = [AccountabilityIdentification('Categoria', Colors.green)];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('edit-identification-${categories.single.id}')));
    await tester.pumpAndSettle();

    final iconButton = find.byKey(const Key('identification-icon-button'));
    final iconBefore = tester
        .widget<Icon>(
          find.descendant(of: iconButton, matching: find.byType(Icon)),
        )
        .icon;
    await tester.tap(iconButton);
    await tester.pumpAndSettle();

    final grid = find.byType(GridView);
    expect(grid, findsOneWidget);
    final icons = find.descendant(of: grid, matching: find.byType(Icon));
    expect(icons, findsWidgets);

    await tester.tap(icons.first);
    await tester.pumpAndSettle();

    final iconAfter = tester
        .widget<Icon>(
          find.descendant(of: iconButton, matching: find.byType(Icon)),
        )
        .icon;
    expect(iconAfter, isNot(iconBefore));
  });

  testWidgets('deletes a category after confirmation, promoting its children', (tester) async {
    final parent = AccountabilityIdentification('Pai', Colors.green);
    final child = AccountabilityIdentification(
      'Filha',
      Colors.orange,
      parentId: parent.id,
    );
    categories = [parent, child];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('edit-identification-${parent.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-delete')));
    await tester.pumpAndSettle();

    expect(find.text('Excluir categoria'), findsOneWidget);
    await tester.tap(find.byKey(const Key('identification-delete-confirm')));
    await tester.pumpAndSettle();
    await flush(tester);

    expect(categories.map((item) => item.id), [child.id]);
    expect(categories.single.parentId, isNull);
    expect(find.text('Pai'), findsNothing);
    expect(textOf(tester, const Key('identification-total-count')), '1');
  });

  testWidgets('cancels deletion without changing the categories', (tester) async {
    final category = AccountabilityIdentification('Categoria', Colors.green);
    categories = [category];

    await pumpPage(tester);
    await tester.tap(find.byKey(Key('edit-identification-${category.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identification-delete-cancel')));
    await tester.pumpAndSettle();

    expect(categories, [category]);
    expect(find.byKey(Key('identification-name-${category.id}')), findsOneWidget);
    verifyNever(() => repo.deleteIdentification(category.id));
  });

  testWidgets('adapts to a narrow viewport without layout errors', (tester) async {
    final category = AccountabilityIdentification('Categoria', Colors.green);
    categories = [category];

    await pumpPage(tester, width: 380);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('identification-page-title')), findsOneWidget);
    expect(find.byKey(const Key('new-identification-category')), findsOneWidget);
    expect(find.byKey(const Key('identification-tab-all')), findsOneWidget);
  });
}
