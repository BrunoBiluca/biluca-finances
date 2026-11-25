import 'package:biluca_financas/app/app_layout/app_layout.dart';
import 'package:biluca_financas/app/settings/settings_page.dart';
import 'package:biluca_financas/app/themes/theme_mode_controller.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_bloc.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_events.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:biluca_financas/core/preferences/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../_mocks/fake_app_update_service.dart';
import '../../_mocks/fake_backup_service.dart';

void main() {
  final getIt = GetIt.instance;
  late FakeBackupService service;
  late FakeAppUpdateService updateService;
  late PreferencesService preferences;
  late ThemeModeController themeMode;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    preferences = await PreferencesService.load();
    themeMode = ThemeModeController.fromPreferences(preferences);
    getIt.registerSingleton<PreferencesService>(preferences);
    getIt.registerSingleton<ThemeModeController>(themeMode);
    service = FakeBackupService(BackupStatus.notConfigured(databaseVersion: 10));
    updateService = FakeAppUpdateService();
  });

  tearDown(() async {
    await getIt.reset();
  });

  void registerBloc() {
    getIt.registerSingleton<BackupBloc>(BackupBloc(service: service));
    getIt.registerSingleton<AppUpdateBloc>(
      AppUpdateBloc(service: updateService),
    );
  }

  Future<void> pumpSettings(WidgetTester tester) async {
    registerBloc();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: SettingsPage())),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> runCheck(WidgetTester tester) async {
    getIt<AppUpdateBloc>().add(const CheckAppUpdate());
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

    await tester.ensureVisible(find.byKey(const Key('connect-google-drive')));
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

    await tester.ensureVisible(find.byKey(const Key('revoke-google-drive')));
    await tester.tap(find.byKey(const Key('revoke-google-drive')));
    await tester.pumpAndSettle();

    expect(service.revokeCalls, 1);
    expect(find.text('Conectar ao Google Drive'), findsOneWidget);
  });

  testWidgets('shows the installed version and that the app is up to date',
      (tester) async {
    await pumpSettings(tester);
    await runCheck(tester);

    expect(find.byKey(const Key('settings-app-update')), findsOneWidget);
    expect(find.text('2.0.3'), findsOneWidget);
    expect(find.text('A aplicação está atualizada.'), findsOneWidget);
    expect(
      find.byKey(const Key('settings-app-update-download')),
      findsNothing,
    );
  });

  testWidgets('checks the published version again', (tester) async {
    await pumpSettings(tester);
    await runCheck(tester);

    await tester.ensureVisible(
      find.byKey(const Key('settings-app-update-check')),
    );
    await tester.tap(find.byKey(const Key('settings-app-update-check')));
    await tester.pumpAndSettle();

    expect(updateService.checkCalls, 2);
  });

  testWidgets('shows the published version and downloads the installer',
      (tester) async {
    updateService.checkResult = updateService.updateAvailable();

    await pumpSettings(tester);
    await runCheck(tester);

    expect(find.text('2.1.0'), findsOneWidget);
    expect(
      find.text('A versão 2.1.0 está disponível para instalação.'),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const Key('settings-app-update-download')),
    );
    await tester.tap(find.byKey(const Key('settings-app-update-download')));
    await tester.pumpAndSettle();

    expect(updateService.downloadCalls, 1);
  });

  testWidgets('shows the failure and keeps a new attempt available',
      (tester) async {
    updateService.checkError = Exception('sem conexão');

    await pumpSettings(tester);
    await runCheck(tester);

    expect(find.byKey(const Key('settings-app-update-error')), findsOneWidget);
    expect(find.textContaining('sem conexão'), findsOneWidget);
    final checkButton = tester.widget<OutlinedButton>(
      find.byKey(const Key('settings-app-update-check')),
    );
    expect(checkButton.onPressed, isNotNull);
  });

  testWidgets('hides the update actions on an unsupported platform',
      (tester) async {
    updateService.supported = false;

    await pumpSettings(tester);

    expect(
      find.byKey(const Key('settings-app-update-unsupported')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('settings-app-update-check')), findsNothing);
    expect(
      find.byKey(const Key('settings-app-update-download')),
      findsNothing,
    );
  });

  testWidgets('selects and persists the appearance mode', (tester) async {
    await pumpSettings(tester);

    expect(find.byKey(const Key('settings-appearance')), findsOneWidget);
    expect(themeMode.value, ThemeMode.system);

    await tester.ensureVisible(find.text('Escuro'));
    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();

    expect(themeMode.value, ThemeMode.dark);
    expect((await PreferencesService.load()).themeMode, ThemeMode.dark);

    await tester.tap(find.text('Claro'));
    await tester.pumpAndSettle();

    expect(themeMode.value, ThemeMode.light);
    expect((await PreferencesService.load()).themeMode, ThemeMode.light);
  });
}
