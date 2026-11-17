import 'package:biluca_financas/app/app_layout/app_layout.dart';
import 'package:biluca_financas/app/app_layout/sidebar/closed_sidebar.dart';
import 'package:biluca_financas/app/app_layout/sidebar/open_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Sidebar Tests', () {
    buildApp() {
      return MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            ShellRoute(
              builder: (context, state, child) => AppLayout(child: child),
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const Text('Página: Home'),
                ),
                GoRoute(
                  path: '/accountability',
                  builder: (context, state) => TextButton(
                    onPressed: () => context.push('/identifications'),
                    child: const Text('Abrir identificações pelo modal'),
                  ),
                ),
                GoRoute(
                  path: '/monthly-report',
                  builder: (context, state) =>
                      const Text('Página: Relatório do Mês'),
                ),
                GoRoute(
                  path: '/identifications',
                  builder: (context, state) => TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Página: Identificações'),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }

    tapToggleSidebarBtn(tester) async {
      await tester.tap(find.byKey(const Key('toggle-sidebar')));
      await tester.pumpAndSettle();
    }

    testWidgets('Should start expanded', (tester) async {
      await tester.pumpWidget(buildApp());

      final drawer = find.byType(Drawer);
      expect(drawer, findsOneWidget);

      expect(find.byType(OpenSidebar), findsOneWidget);
      expect(find.byType(ClosedSidebar), findsNothing);
    });

    testWidgets('Should collapse sidebar when arrow button is tapped',
        (tester) async {
      await tester.pumpWidget(buildApp());

      await tapToggleSidebarBtn(tester);

      expect(find.byType(OpenSidebar), findsNothing);
      expect(find.byType(ClosedSidebar), findsOneWidget);
    });

    testWidgets('Should expand sidebar when arrow right button is tapped',
        (tester) async {
      await tester.pumpWidget(buildApp());

      await tapToggleSidebarBtn(tester);

      expect(find.byType(OpenSidebar), findsNothing);
      expect(find.byType(ClosedSidebar), findsOneWidget);

      await tapToggleSidebarBtn(tester);

      expect(find.byType(OpenSidebar), findsOneWidget);
      expect(find.byType(ClosedSidebar), findsNothing);
    });

    testWidgets(
        'Should maintain selected page state when collapsing and expanding',
        (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('Relatório do mês'));
      await tester.pumpAndSettle();

      final selectedTile = tester.widget<ListTile>(find.byType(ListTile).at(1));
      expect(selectedTile.selected, true);

      final selectedTileCollapsed =
          tester.widget<ListTile>(find.byType(ListTile).at(1));
      expect(selectedTileCollapsed.selected, true);

      final selectedTileExpanded =
          tester.widget<ListTile>(find.byType(ListTile).at(1));
      expect(selectedTileExpanded.selected, true);
    });

    testWidgets('Should navigate to correct route when tapping menu items',
        (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text('Página: Home'), findsOneWidget);

      await tester.tap(find.text('Relatório do mês'));
      await tester.pumpAndSettle();

      expect(find.text('Página: Relatório do Mês'), findsOneWidget);
    });

    testWidgets('Should navigate to the identifications page', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('Identificações'));
      await tester.pumpAndSettle();

      expect(find.text('Página: Identificações'), findsOneWidget);
    });

    testWidgets('Should update selected menu item after external navigation',
        (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('Prestação de contas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abrir identificações pelo modal'));
      await tester.pumpAndSettle();

      final identificationTile =
          tester.widget<ListTile>(find.byType(ListTile).at(4));
      expect(identificationTile.selected, true);

      await tester.tap(find.text('Página: Identificações'));
      await tester.pumpAndSettle();

      final accountabilityTile =
          tester.widget<ListTile>(find.byType(ListTile).at(3));
      expect(accountabilityTile.selected, true);
    });

    testWidgets('Should not navigate when tapping the same selected page',
        (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text('Página: Home'), findsOneWidget);

      await tester.tap(find.text('Relatório do mês'));
      await tester.pumpAndSettle();

      expect(find.text('Página: Relatório do Mês'), findsOneWidget);

      await tester.tap(find.text('Relatório do mês'));
      await tester.pumpAndSettle();

      expect(find.text('Página: Relatório do Mês'), findsOneWidget);
    });
  });
}
