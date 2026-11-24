import 'dart:io';

import 'package:biluca_financas/core/app_update/models/app_update_restart_result.dart';
import 'package:biluca_financas/core/app_update/models/app_update_status.dart';
import 'package:biluca_financas/core/app_update/models/app_version.dart';
import 'package:biluca_financas/core/app_update/models/published_release.dart';
import 'package:biluca_financas/core/app_update/services/app_update_service.dart';
import 'package:biluca_financas/integrations/app_update/inno_setup_installer_launcher.dart';
import 'package:biluca_financas/integrations/app_update/installer_downloader.dart';
import 'package:biluca_financas/integrations/github_releases/github_releases_client.dart';
import 'package:logging/logging.dart';

typedef ApplicationExitRequest = Future<bool> Function();
typedef ApplicationExit = Future<void> Function(int exitCode);

class AppUpdateException implements Exception {
  final String message;

  const AppUpdateException(this.message);

  @override
  String toString() => message;
}

class WindowsAppUpdateService implements AppUpdateService {
  final GithubReleasesClient releasesClient;
  final InstallerDownloader downloader;
  final InnoSetupInstallerLauncher installerLauncher;
  final ApplicationExitRequest requestExit;
  final ApplicationExit exitApplication;
  final Logger log;

  @override
  final AppVersion currentVersion;

  PublishedRelease? _publishedRelease;
  File? _installer;

  WindowsAppUpdateService({
    required this.releasesClient,
    required this.downloader,
    required this.installerLauncher,
    required this.requestExit,
    required this.exitApplication,
    required this.currentVersion,
    required this.log,
  });

  @override
  bool get supported => true;

  @override
  Future<AppUpdateStatus> checkForUpdate() async {
    final release = await releasesClient.fetchLatestRelease();
    _publishedRelease = release;
    return AppUpdateStatus(
      state: release.version.isNewerThan(currentVersion)
          ? AppUpdateState.updateAvailable
          : AppUpdateState.upToDate,
      currentVersion: currentVersion,
      availableVersion: release.version,
    );
  }

  @override
  Future<AppUpdateStatus> downloadInstaller({
    DownloadProgressCallback? onProgress,
  }) async {
    final release = _publishedRelease;
    if (release == null || !release.version.isNewerThan(currentVersion)) {
      throw const AppUpdateException(
        'Nenhuma atualização disponível para baixar. Verifique novamente.',
      );
    }

    final file = await downloader.download(release, onProgress: onProgress);
    _installer = file;
    return AppUpdateStatus(
      state: AppUpdateState.readyToInstall,
      currentVersion: currentVersion,
      availableVersion: release.version,
    );
  }

  @override
  Future<AppUpdateRestartResult> restartWithInstaller() async {
    final installer = _installer;
    if (installer == null) {
      return const AppUpdateRestartResult(
        AppUpdateRestartOutcome.failed,
        errorMessage: 'O instalador da atualização ainda não foi baixado.',
      );
    }
    if (!await installer.exists()) {
      return const AppUpdateRestartResult(
        AppUpdateRestartOutcome.failed,
        errorMessage: 'O instalador baixado não foi encontrado no disco.',
      );
    }

    final canExit = await requestExit();
    if (!canExit) {
      return const AppUpdateRestartResult(AppUpdateRestartOutcome.cancelled);
    }

    try {
      await installerLauncher.launch(installer);
    } catch (error, stackTrace) {
      log.severe('Failed to open the update installer.', error, stackTrace);
      return AppUpdateRestartResult(
        AppUpdateRestartOutcome.failed,
        errorMessage: 'Não foi possível abrir o instalador: $error',
      );
    }

    await exitApplication(0);
    return const AppUpdateRestartResult(AppUpdateRestartOutcome.launched);
  }
}
