import 'package:biluca_financas/app_layout.dart';
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
                  builder: (context, state) => const Text('Página: Prestação de contas'),
                ),
                GoRoute(
                  path: '/monthly-report',
                  builder: (context, state) => const Text('Página: Relatório do Mês'),
                )
              ],
            ),
          ],
        ),
      );
    }

    testWidgets('Should start expanded', (tester) async {
      await tester.pumpWidget(buildApp());

      final drawer = find.byType(Drawer);
      expect(drawer, findsOneWidget);

      expect(find.text('Navegação'), findsOneWidget);
      expect(find.text('N'), findsNothing);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Relatório do mês'), findsOneWidget);
      expect(find.text('Relatório anual'), findsOneWidget);
      expect(find.text('Prestação de contas'), findsOneWidget);

      expect(find.byType(Icon), findsAtLeast(4));
      expect(find.byIcon(Icons.arrow_left), findsOneWidget);
      expect(find.byIcon(Icons.arrow_right), findsNothing);
    });

    testWidgets('Should collapse sidebar when arrow button is tapped', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.byKey(const Key('toggle-sidebar')));
      await tester.pumpAndSettle();

      expect(find.text('N'), findsOneWidget);
      expect(find.text('Navegação'), findsNothing);

      expect(find.text('Home'), findsNothing);
      expect(find.text('Relatório do mês'), findsNothing);
      expect(find.text('Relatório anual'), findsNothing);
      expect(find.text('Prestação de contas'), findsNothing);

      expect(find.byType(Icon), findsAtLeast(4));
      expect(find.byIcon(Icons.arrow_right), findsOneWidget);
      expect(find.byIcon(Icons.arrow_left), findsNothing);
    });

    testWidgets('Should expand sidebar when arrow right button is tapped', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.byKey(const Key('toggle-sidebar')));
      await tester.pumpAndSettle();

      expect(find.text('N'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_right), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_right));
      await tester.pumpAndSettle();

      expect(find.text('Navegação'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_left), findsOneWidget);
    });

    testWidgets('Should maintain selected page state when collapsing and expanding', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('Relatório do mês'));
      await tester.pumpAndSettle();

      final selectedTile = tester.widget<ListTile>(find.byType(ListTile).at(1));
      expect(selectedTile.selected, true);

      await tester.tap(find.byKey(const Key('toggle-sidebar')));
      await tester.pumpAndSettle();

      final selectedTileCollapsed = tester.widget<ListTile>(find.byType(ListTile).at(1));
      expect(selectedTileCollapsed.selected, true);

      await tester.tap(find.byKey(const Key('toggle-sidebar')));
      await tester.pumpAndSettle();

      final selectedTileExpanded = tester.widget<ListTile>(find.byType(ListTile).at(1));
      expect(selectedTileExpanded.selected, true);
    });

    testWidgets('Should navigate to correct route when tapping menu items', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text('Página: Home'), findsOneWidget);

      await tester.tap(find.text('Relatório do mês'));
      await tester.pumpAndSettle();

      expect(find.text('Página: Relatório do Mês'), findsOneWidget);
    });

    testWidgets('Should not navigate when tapping the same selected page', (tester) async {
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
