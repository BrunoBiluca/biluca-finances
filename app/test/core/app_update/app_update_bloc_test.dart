import 'package:biluca_financas/core/app_update/bloc/app_update_bloc.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_events.dart';
import 'package:biluca_financas/core/app_update/models/app_update_restart_result.dart';
import 'package:biluca_financas/core/app_update/models/app_update_status.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_mocks/fake_app_update_service.dart';

void main() {
  test('starts checking when the platform is supported', () {
    final bloc = AppUpdateBloc(service: FakeAppUpdateService());

    expect(bloc.state.state, AppUpdateState.checking);
    expect(bloc.state.currentVersion, FakeAppUpdateService.defaultCurrentVersion);
  });

  test('starts unsupported when the platform is not supported', () {
    final bloc = AppUpdateBloc(service: FakeAppUpdateService(supported: false));

    expect(bloc.state.state, AppUpdateState.unsupported);
  });

  blocTest<AppUpdateBloc, AppUpdateStatus>(
    'reports the application is up to date',
    build: () => AppUpdateBloc(service: FakeAppUpdateService()),
    act: (bloc) => bloc.add(const CheckAppUpdate()),
    expect: () => [
      isA<AppUpdateStatus>()
          .having((status) => status.state, 'state', AppUpdateState.upToDate),
    ],
  );

  blocTest<AppUpdateBloc, AppUpdateStatus>(
    'reports an available update',
    build: () {
      final service = FakeAppUpdateService();
      service.checkResult = service.updateAvailable();
      return AppUpdateBloc(service: service);
    },
    act: (bloc) => bloc.add(const CheckAppUpdate()),
    expect: () => [
      isA<AppUpdateStatus>()
          .having((status) => status.state, 'state',
              AppUpdateState.updateAvailable)
          .having((status) => status.availableVersion, 'availableVersion',
              FakeAppUpdateService.defaultNewerVersion)
          .having((status) => status.hasUpdate, 'hasUpdate', isTrue),
    ],
  );

  blocTest<AppUpdateBloc, AppUpdateStatus>(
    'reports a check failure without losing the current version',
    build: () => AppUpdateBloc(
      service: FakeAppUpdateService()..checkError = Exception('sem conexão'),
    ),
    act: (bloc) => bloc.add(const CheckAppUpdate()),
    expect: () => [
      isA<AppUpdateStatus>()
          .having((status) => status.state, 'state', AppUpdateState.failed)
          .having((status) => status.failureStep, 'failureStep',
              AppUpdateFailureStep.check)
          .having((status) => status.errorMessage, 'errorMessage',
              contains('sem conexão'))
          .having((status) => status.currentVersion, 'currentVersion',
              FakeAppUpdateService.defaultCurrentVersion)
          .having((status) => status.showsHomeNotification,
              'showsHomeNotification', isFalse),
    ],
  );

  blocTest<AppUpdateBloc, AppUpdateStatus>(
    'downloads the installer reporting the progress until it is ready',
    build: () {
      final service = FakeAppUpdateService()
        ..downloadProgressValues = [0.5];
      service.checkResult = service.updateAvailable();
      return AppUpdateBloc(service: service);
    },
    act: (bloc) => bloc
      ..add(const CheckAppUpdate())
      ..add(const DownloadAppUpdate()),
    expect: () => [
      isA<AppUpdateStatus>()
          .having((status) => status.state, 'state',
              AppUpdateState.updateAvailable),
      isA<AppUpdateStatus>()
          .having((status) => status.state, 'state', AppUpdateState.downloading)
          .having((status) => status.downloadProgress, 'progress', 0.0),
      isA<AppUpdateStatus>()
          .having((status) => status.downloadProgress, 'progress', 0.5),
      isA<AppUpdateStatus>().having(
          (status) => status.state, 'state', AppUpdateState.readyToInstall),
    ],
  );

  blocTest<AppUpdateBloc, AppUpdateStatus>(
    'reports a download failure keeping the available version',
    build: () {
      final service = FakeAppUpdateService();
      service.checkResult = service.updateAvailable();
      service.downloadError = Exception('download interrompido');
      return AppUpdateBloc(service: service);
    },
    act: (bloc) => bloc
      ..add(const CheckAppUpdate())
      ..add(const DownloadAppUpdate()),
    expect: () => [
      isA<AppUpdateStatus>()
          .having((status) => status.state, 'state',
              AppUpdateState.updateAvailable),
      isA<AppUpdateStatus>().having(
          (status) => status.state, 'state', AppUpdateState.downloading),
      isA<AppUpdateStatus>()
          .having((status) => status.state, 'state', AppUpdateState.failed)
          .having((status) => status.failureStep, 'failureStep',
              AppUpdateFailureStep.download)
          .having((status) => status.availableVersion, 'availableVersion',
              FakeAppUpdateService.defaultNewerVersion)
          .having((status) => status.canDownload, 'canDownload', isTrue)
          .having((status) => status.showsHomeNotification,
              'showsHomeNotification', isTrue),
    ],
  );

  blocTest<AppUpdateBloc, AppUpdateStatus>(
    'does not download without an available update',
    build: () => AppUpdateBloc(service: FakeAppUpdateService()),
    act: (bloc) => bloc.add(const DownloadAppUpdate()),
    expect: () => <AppUpdateStatus>[],
    verify: (bloc) {
      expect((bloc.service as FakeAppUpdateService).downloadCalls, 0);
    },
  );

  blocTest<AppUpdateBloc, AppUpdateStatus>(
    'keeps the update ready when the closing flow cancels the restart',
    build: () {
      final service = FakeAppUpdateService();
      service
        ..checkResult = service.updateAvailable()
        ..downloadResult = service.readyToInstall()
        ..restartResult =
            const AppUpdateRestartResult(AppUpdateRestartOutcome.cancelled);
      return AppUpdateBloc(service: service);
    },
    act: (bloc) => bloc
      ..add(const CheckAppUpdate())
      ..add(const DownloadAppUpdate())
      ..add(const InstallAppUpdate()),
    skip: 3,
    expect: () => <AppUpdateStatus>[],
    verify: (bloc) {
      final service = bloc.service as FakeAppUpdateService;
      expect(service.restartCalls, 1);
      expect(bloc.state.state, AppUpdateState.readyToInstall);
      expect(bloc.state.errorMessage, isNull);
    },
  );

  blocTest<AppUpdateBloc, AppUpdateStatus>(
    'reports a restart failure keeping the update available',
    build: () {
      final service = FakeAppUpdateService();
      service
        ..checkResult = service.updateAvailable()
        ..downloadResult = service.readyToInstall()
        ..restartResult = const AppUpdateRestartResult(
          AppUpdateRestartOutcome.failed,
          errorMessage: 'instalador não abriu',
        );
      return AppUpdateBloc(service: service);
    },
    act: (bloc) => bloc
      ..add(const CheckAppUpdate())
      ..add(const DownloadAppUpdate())
      ..add(const InstallAppUpdate()),
    skip: 3,
    expect: () => [
      isA<AppUpdateStatus>()
          .having((status) => status.state, 'state', AppUpdateState.failed)
          .having((status) => status.failureStep, 'failureStep',
              AppUpdateFailureStep.restart)
          .having((status) => status.errorMessage, 'errorMessage',
              'instalador não abriu')
          .having((status) => status.isReadyToInstall, 'ready', isTrue),
    ],
  );
}
