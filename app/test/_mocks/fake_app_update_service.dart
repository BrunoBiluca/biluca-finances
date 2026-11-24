import 'dart:async';

import 'package:biluca_financas/core/app_update/models/app_update_restart_result.dart';import 'package:biluca_financas/core/app_update/models/app_update_status.dart';
import 'package:biluca_financas/core/app_update/models/app_version.dart';
import 'package:biluca_financas/core/app_update/services/app_update_service.dart';

class FakeAppUpdateService implements AppUpdateService {
  static const defaultCurrentVersion = AppVersion(2, 0, 3);
  static const defaultNewerVersion = AppVersion(2, 1, 0);

  @override
  final AppVersion currentVersion;

  @override
  bool supported;

  AppUpdateStatus? checkResult;
  Object? checkError;

  List<double?> downloadProgressValues = [];
  AppUpdateStatus? downloadResult;
  Object? downloadError;
  Completer<void>? downloadGate;

  AppUpdateRestartResult restartResult =
      const AppUpdateRestartResult(AppUpdateRestartOutcome.launched);
  Object? restartError;

  int checkCalls = 0;
  int downloadCalls = 0;
  int restartCalls = 0;

  FakeAppUpdateService({
    this.supported = true,
    this.currentVersion = defaultCurrentVersion,
  });

  AppUpdateStatus updateAvailable({
    AppVersion version = defaultNewerVersion,
  }) {
    return AppUpdateStatus(
      state: AppUpdateState.updateAvailable,
      currentVersion: currentVersion,
      availableVersion: version,
    );
  }

  AppUpdateStatus readyToInstall({AppVersion version = defaultNewerVersion}) {
    return AppUpdateStatus(
      state: AppUpdateState.readyToInstall,
      currentVersion: currentVersion,
      availableVersion: version,
    );
  }

  @override
  Future<AppUpdateStatus> checkForUpdate() async {
    checkCalls++;
    if (checkError != null) throw checkError!;
    return checkResult ??
        AppUpdateStatus(
          state: AppUpdateState.upToDate,
          currentVersion: currentVersion,
        );
  }

  @override
  Future<AppUpdateStatus> downloadInstaller({
    DownloadProgressCallback? onProgress,
  }) async {
    downloadCalls++;
    if (downloadGate != null) await downloadGate!.future;
    for (final progress in downloadProgressValues) {
      onProgress?.call(progress);
    }
    if (downloadError != null) throw downloadError!;
    return downloadResult ?? readyToInstall();
  }

  @override
  Future<AppUpdateRestartResult> restartWithInstaller() async {
    restartCalls++;
    if (restartError != null) throw restartError!;
    return restartResult;
  }
}
