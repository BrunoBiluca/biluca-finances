import 'package:biluca_financas/core/app_update/models/app_update_status.dart';
import 'package:biluca_financas/core/app_update/models/app_version.dart';
import 'package:biluca_financas/core/app_update/models/published_release.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const current = AppVersion(2, 0, 3);
  const newer = AppVersion(2, 1, 0);

  group('PublishedRelease', () {
    test('carries the version and installer information', () {
      const release = PublishedRelease(
        version: newer,
        tagName: '2.1.0',
        installerName: 'biluca-financas-setup-2.1.0.exe',
        installerUrl:
            'https://github.com/BrunoBiluca/biluca-finances/releases/download/2.1.0/biluca-financas-setup-2.1.0.exe',
      );

      expect(release.version, newer);
      expect(release.installerName, 'biluca-financas-setup-2.1.0.exe');
      expect(release.installerUrl, endsWith(release.installerName));
    });

    test('compares by value', () {
      const release = PublishedRelease(
        version: newer,
        tagName: '2.1.0',
        installerName: 'setup.exe',
        installerUrl: 'https://example.com/setup.exe',
      );

      expect(
        release,
        const PublishedRelease(
          version: newer,
          tagName: '2.1.0',
          installerName: 'setup.exe',
          installerUrl: 'https://example.com/setup.exe',
        ),
      );
    });
  });

  group('AppUpdateStatus', () {
    test('starts as checking when the platform is supported', () {
      final status = AppUpdateStatus.initial(
        currentVersion: current,
        supported: true,
      );

      expect(status.state, AppUpdateState.checking);
      expect(status.currentVersion, current);
      expect(status.isSupported, isTrue);
      expect(status.hasUpdate, isFalse);
    });

    test('starts as unsupported when the platform has no installer', () {
      final status = AppUpdateStatus.initial(
        currentVersion: current,
        supported: false,
      );

      expect(status.state, AppUpdateState.unsupported);
      expect(status.isSupported, isFalse);
    });

    test('identifies an available update', () {
      const status = AppUpdateStatus(
        state: AppUpdateState.updateAvailable,
        currentVersion: current,
        availableVersion: newer,
      );

      expect(status.hasUpdate, isTrue);
      expect(status.canDownload, isTrue);
      expect(status.showsHomeNotification, isTrue);
    });

    test('does not identify an update when the published version is older', () {
      const status = AppUpdateStatus(
        state: AppUpdateState.upToDate,
        currentVersion: current,
        availableVersion: AppVersion(1, 9, 9),
      );

      expect(status.hasUpdate, isFalse);
      expect(status.canDownload, isFalse);
      expect(status.showsHomeNotification, isFalse);
    });

    test('only notifies on the home page for download failures', () {
      const checkFailure = AppUpdateStatus(
        state: AppUpdateState.failed,
        currentVersion: current,
        errorMessage: 'sem conexão',
        failureStep: AppUpdateFailureStep.check,
      );
      const downloadFailure = AppUpdateStatus(
        state: AppUpdateState.failed,
        currentVersion: current,
        availableVersion: newer,
        errorMessage: 'sem conexão',
        failureStep: AppUpdateFailureStep.download,
      );

      expect(checkFailure.showsHomeNotification, isFalse);
      expect(downloadFailure.showsHomeNotification, isTrue);
      expect(downloadFailure.canDownload, isTrue);
    });

    test('keeps the update available after a restart failure', () {
      const status = AppUpdateStatus(
        state: AppUpdateState.failed,
        currentVersion: current,
        availableVersion: newer,
        errorMessage: 'não foi possível abrir o instalador',
        failureStep: AppUpdateFailureStep.restart,
      );

      expect(status.isReadyToInstall, isTrue);
      expect(status.canDownload, isFalse);
      expect(status.showsHomeNotification, isTrue);
    });

    test('tracks the download progress', () {
      const status = AppUpdateStatus(
        state: AppUpdateState.downloading,
        currentVersion: current,
        availableVersion: newer,
      );

      final progress = status.copyWith(downloadProgress: 0.5);
      expect(progress.downloadProgress, 0.5);
      expect(progress.state, AppUpdateState.downloading);
      expect(progress.copyWith(clearDownloadProgress: true).downloadProgress,
          isNull);
    });

    test('clears the error and the failure step together', () {
      const status = AppUpdateStatus(
        state: AppUpdateState.failed,
        currentVersion: current,
        errorMessage: 'falhou',
        failureStep: AppUpdateFailureStep.download,
      );

      final cleared = status.copyWith(
        state: AppUpdateState.updateAvailable,
        clearError: true,
      );

      expect(cleared.errorMessage, isNull);
      expect(cleared.failureStep, isNull);
    });

    test('compares by value', () {
      const status = AppUpdateStatus(
        state: AppUpdateState.updateAvailable,
        currentVersion: current,
        availableVersion: newer,
      );

      expect(
        status,
        const AppUpdateStatus(
          state: AppUpdateState.updateAvailable,
          currentVersion: current,
          availableVersion: newer,
        ),
      );
      expect(status, isNot(status.copyWith(downloadProgress: 0.1)));
    });
  });
}
