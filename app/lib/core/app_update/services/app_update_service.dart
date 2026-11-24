import 'package:biluca_financas/core/app_update/models/app_update_restart_result.dart';
import 'package:biluca_financas/core/app_update/models/app_update_status.dart';
import 'package:biluca_financas/core/app_update/models/app_version.dart';

typedef DownloadProgressCallback = void Function(double? progress);

abstract class AppUpdateService {
  bool get supported;

  AppVersion get currentVersion;

  Future<AppUpdateStatus> checkForUpdate();

  Future<AppUpdateStatus> downloadInstaller({
    DownloadProgressCallback? onProgress,
  });

  Future<AppUpdateRestartResult> restartWithInstaller();
}

class UnsupportedAppUpdateService implements AppUpdateService {
  @override
  final AppVersion currentVersion;

  const UnsupportedAppUpdateService({
    this.currentVersion = const AppVersion(0, 0, 0),
  });

  @override
  bool get supported => false;

  Future<AppUpdateStatus> _unsupportedStatus() async {
    return AppUpdateStatus(
      state: AppUpdateState.unsupported,
      currentVersion: currentVersion,
    );
  }

  @override
  Future<AppUpdateStatus> checkForUpdate() => _unsupportedStatus();

  @override
  Future<AppUpdateStatus> downloadInstaller({
    DownloadProgressCallback? onProgress,
  }) =>
      _unsupportedStatus();

  @override
  Future<AppUpdateRestartResult> restartWithInstaller() async {
    return const AppUpdateRestartResult(AppUpdateRestartOutcome.cancelled);
  }
}
