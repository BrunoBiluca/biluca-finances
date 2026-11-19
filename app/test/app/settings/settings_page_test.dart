import 'package:biluca_financas/app/app_layout/app_layout.dart';
import 'package:biluca_financas/app/settings/settings_page.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../_mocks/fake_backup_service.dart';

void main() {
  final getIt = GetIt.instance;
  late FakeBackupService service;

  setUp(() async {
    await getIt.reset();
    service = FakeBackupService(BackupStatus.notConfigured(databaseVersion: 10));
  });

  tearDown(() async {
    await getIt.reset();
  });

  void registerBloc() {
    getIt.registerSingleton<BackupBloc>(BackupBloc(service: service));
  }

  Future<void> pumpSettings(WidgetTester tester) async {
    registerBloc();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SettingsPage())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens the settings page from the sidebar', (tester) async {
    registerBloc();
    await tester.pumpWidget(
      MaterialApp.router(
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
                  path: '/settings',
                  builder: (context, state) => const SettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-page-title')), findsOneWidget);
    final settingsTile = tester.widget<ListTile>(find.byType(ListTile).at(5));
    expect(settingsTile.selected, isTrue);
  });

  testWidgets('offers the connection when the backup is not configured',
      (tester) async {
    await pumpSettings(tester);

    expect(find.text('Conectar ao Google Drive'), findsOneWidget);
    expect(find.byKey(const Key('revoke-google-drive')), findsNothing);

    await tester.tap(find.byKey(const Key('connect-google-drive')));
    await tester.pumpAndSettle();

    expect(service.connectCalls, 1);
    expect(
      find.byKey(const Key('settings-google-drive-connected')),
      findsOneWidget,
    );
    expect(find.text('conta@gmail.com'), findsWidgets);
  });

  testWidgets('shows the connection details and the revoke option',
      (tester) async {
    final lastSyncAt = DateTime.utc(2026, 5, 6, 14, 30);
    service.status = BackupStatus(
      state: BackupSyncState.synchronized,
      isConfigured: true,
      databaseVersion: 10,
      accountEmail: 'pessoa@gmail.com',
      profile: 'principal',
      lastSyncAt: lastSyncAt,
    );

    await pumpSettings(tester);

    expect(find.text('pessoa@gmail.com'), findsWidgets);
    expect(
      find.text(DateFormat('dd/MM/yyyy HH:mm').format(lastSyncAt.toLocal())),
      findsOneWidget,
    );
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Perfil de sincronização'), findsOneWidget);
    expect(find.text('principal'), findsOneWidget);
    expect(find.byKey(const Key('revoke-google-drive')), findsOneWidget);

    await tester.tap(find.byKey(const Key('revoke-google-drive')));
    await tester.pumpAndSettle();

    expect(service.revokeCalls, 1);
    expect(find.text('Conectar ao Google Drive'), findsOneWidget);
  });
}
