import 'dart:async';

import 'package:biluca_financas/app/home/home.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_bloc.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_events.dart';
import 'package:biluca_financas/core/app_update/models/app_update_restart_result.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../_mocks/fake_app_update_service.dart';
import '../../_mocks/fake_backup_service.dart';

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<(FakeAppUpdateService, AppUpdateBloc)> pumpHome(
    WidgetTester tester, {
    FakeAppUpdateService? service,
    void Function(AppUpdateBloc bloc)? prepare,
  }) async {
    final updateService = service ?? FakeAppUpdateService();
    final bloc = AppUpdateBloc(service: updateService);
    getIt.registerSingleton<AppUpdateBloc>(bloc);
    getIt.registerSingleton<BackupBloc>(
      BackupBloc(
        service: FakeBackupService(
          BackupStatus.notConfigured(databaseVersion: 10),
        ),
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Home())));
    prepare?.call(bloc);
    await tester.pumpAndSettle();
    return (updateService, bloc);
  }

  void prepareAvailable(AppUpdateBloc bloc) {
    final service = bloc.service as FakeAppUpdateService;
    service.checkResult = service.updateAvailable();
    bloc.add(const CheckAppUpdate());
  }

  void prepareReadyToInstall(AppUpdateBloc bloc) {
    final service = bloc.service as FakeAppUpdateService;
    prepareAvailable(bloc);
    service.downloadResult = service.readyToInstall();
    bloc.add(const DownloadAppUpdate());
  }

  testWidgets('does not notify when the application is up to date',
      (tester) async {
    await pumpHome(tester);

    expect(find.byKey(const Key('home-update-notification')), findsNothing);
  });

  testWidgets('notifies the available version and starts the download',
      (tester) async {
    final (service, _) = await pumpHome(tester, prepare: prepareAvailable);

    expect(find.byKey(const Key('home-update-notification')), findsOneWidget);
    expect(find.text('Instalada: 2.0.3 • Disponível: 2.1.0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-update-download')));
    await tester.pumpAndSettle();

    expect(service.downloadCalls, 1);
  });

  testWidgets('shows the download progress', (tester) async {
    final gate = Completer<void>();

    await pumpHome(
      tester,
      service: FakeAppUpdateService()..downloadGate = gate,
      prepare: (bloc) {
        prepareAvailable(bloc);
        bloc.add(const DownloadAppUpdate());
      },
    );

    expect(find.byKey(const Key('home-update-progress')), findsOneWidget);
    expect(find.textContaining('Baixando a atualização'), findsOneWidget);
    expect(find.byKey(const Key('home-update-download')), findsNothing);

    gate.complete();
  });

  testWidgets('shows the failure and offers a new attempt', (tester) async {
    await pumpHome(
      tester,
      prepare: (bloc) {
        prepareAvailable(bloc);
        (bloc.service as FakeAppUpdateService).downloadError =
            Exception('sem conexão');
        bloc.add(const DownloadAppUpdate());
      },
    );

    expect(find.byKey(const Key('home-update-error')), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('confirms before closing the application to install',
      (tester) async {
    final (service, _) =
        await pumpHome(tester, prepare: prepareReadyToInstall);

    expect(find.byKey(const Key('home-update-ready')), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-update-install')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-update-dialog-message')), findsOneWidget);
    expect(find.textContaining('será fechada'), findsOneWidget);
    expect(service.restartCalls, 0);
  });

  testWidgets('does not install when the confirmation is cancelled',
      (tester) async {
    final (service, _) =
        await pumpHome(tester, prepare: prepareReadyToInstall);

    await tester.tap(find.byKey(const Key('home-update-install')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('app-update-dialog-cancel')));
    await tester.pumpAndSettle();

    expect(service.restartCalls, 0);
    expect(find.byKey(const Key('app-update-dialog-message')), findsNothing);
  });

  testWidgets('keeps the update ready and explains a failure to open it',
      (tester) async {
    await pumpHome(tester, prepare: (bloc) {
      final service = bloc.service as FakeAppUpdateService;
      prepareReadyToInstall(bloc);
      service.restartResult = const AppUpdateRestartResult(
        AppUpdateRestartOutcome.failed,
        errorMessage: 'instalador não abriu',
      );
    });

    await tester.tap(find.byKey(const Key('home-update-install')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('app-update-dialog-confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-update-error')), findsOneWidget);
    expect(find.text('instalador não abriu'), findsOneWidget);
    expect(find.byKey(const Key('home-update-install')), findsOneWidget);
  });

  testWidgets('installs after the confirmation is accepted', (tester) async {
    final (service, _) =
        await pumpHome(tester, prepare: prepareReadyToInstall);

    await tester.tap(find.byKey(const Key('home-update-install')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('app-update-dialog-confirm')));
    await tester.pumpAndSettle();

    expect(service.restartCalls, 1);
  });
}
