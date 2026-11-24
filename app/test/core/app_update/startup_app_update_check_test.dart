import 'package:biluca_financas/core/app_update/bloc/app_update_bloc.dart';
import 'package:biluca_financas/core/app_update/models/app_update_status.dart';
import 'package:biluca_financas/core/app_update/services/startup_app_update_check.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_mocks/fake_app_update_service.dart';

void main() {
  test('checks for an update when the platform is supported', () async {
    final service = FakeAppUpdateService();
    final bloc = AppUpdateBloc(service: service);
    final checked = bloc.stream.firstWhere(
      (status) => status.state == AppUpdateState.upToDate,
    );

    scheduleStartupAppUpdateCheck(bloc);
    await checked;

    expect(service.checkCalls, 1);
    await bloc.close();
  });

  test('does not check when the platform has no installer', () async {
    final service = FakeAppUpdateService(supported: false);
    final bloc = AppUpdateBloc(service: service);

    scheduleStartupAppUpdateCheck(bloc);
    await Future<void>.delayed(Duration.zero);

    expect(service.checkCalls, 0);
    expect(bloc.state.state, AppUpdateState.unsupported);
    await bloc.close();
  });

  test('keeps the application usable when the check fails', () async {
    final service = FakeAppUpdateService()..checkError = Exception('sem rede');
    final bloc = AppUpdateBloc(service: service);
    final failed = bloc.stream.firstWhere(
      (status) => status.state == AppUpdateState.failed,
    );

    scheduleStartupAppUpdateCheck(bloc);
    final status = await failed;

    expect(status.failureStep, AppUpdateFailureStep.check);
    expect(status.errorMessage, contains('sem rede'));
    expect(status.currentVersion, FakeAppUpdateService.defaultCurrentVersion);
    await bloc.close();
  });
}
