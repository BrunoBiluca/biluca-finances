import 'dart:convert';
import 'dart:io';

import 'package:biluca_financas/core/app_update/models/app_update_restart_result.dart';
import 'package:biluca_financas/core/app_update/models/app_update_status.dart';
import 'package:biluca_financas/core/app_update/models/app_version.dart';
import 'package:biluca_financas/integrations/app_update/inno_setup_installer_launcher.dart';
import 'package:biluca_financas/integrations/app_update/installer_downloader.dart';
import 'package:biluca_financas/integrations/app_update/windows_app_update_service.dart';
import 'package:biluca_financas/integrations/github_releases/github_releases_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

void main() {
  const installedVersion = AppVersion(2, 0, 3);
  const publishedVersion = AppVersion(2, 1, 0);
  const installerName = 'biluca-financas-setup-2.1.0.exe';
  const installerBytes = 'instalador';

  late Directory temporaryDirectory;
  late List<String> operations;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('update-service');
    operations = [];
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  Client fakeHttp({String tagName = '2.1.0', bool failDownload = false}) {
    return MockClient((request) async {
      if (request.url.host == 'api.github.com') {
        return Response(
          jsonEncode({
            'tag_name': tagName,
            'assets': [
              {
                'name': installerName,
                'browser_download_url': 'https://example.com/$installerName',
              },
            ],
          }),
          200,
        );
      }
      if (failDownload) {
        return Response('falha', 500);
      }
      return Response(installerBytes, 200);
    });
  }

  WindowsAppUpdateService buildService({
    String tagName = '2.1.0',
    bool failDownload = false,
    bool exitPermitted = true,
    bool failLaunch = false,
    void Function(int code)? onExit,
  }) {
    final http = fakeHttp(tagName: tagName, failDownload: failDownload);
    final launcher = InnoSetupInstallerLauncher(
      applicationPid: 1,
      startProcess: (executable, arguments) async {
        operations.add('launch');
        if (failLaunch) throw ProcessException('powershell.exe', arguments);
      },
    );
    return WindowsAppUpdateService(
      releasesClient: GithubReleasesClient(http: http),
      downloader: InstallerDownloader(
        http: http,
        temporaryDirectory: () async => temporaryDirectory,
      ),
      installerLauncher: launcher,
      requestExit: () async {
        operations.add('exit-request');
        return exitPermitted;
      },
      exitApplication: (code) async {
        operations.add('exit');
        onExit?.call(code);
      },
      currentVersion: installedVersion,
      log: Logger('test'),
    );
  }

  test('reports an available update when the release is newer', () async {
    final service = buildService();

    final status = await service.checkForUpdate();

    expect(status.state, AppUpdateState.updateAvailable);
    expect(status.availableVersion, publishedVersion);
    expect(status.currentVersion, installedVersion);
    expect(status.hasUpdate, isTrue);
  });

  test('reports up to date when the release matches the installed version',
      () async {
    final service = buildService(tagName: '2.0.3');

    final status = await service.checkForUpdate();

    expect(status.state, AppUpdateState.upToDate);
    expect(status.hasUpdate, isFalse);
  });

  test('requires a check before downloading', () async {
    final service = buildService();

    await expectLater(
      service.downloadInstaller(),
      throwsA(isA<AppUpdateException>()),
    );
  });

  test('downloads the installer and reports it ready', () async {
    final service = buildService();
    await service.checkForUpdate();
    final progress = <double?>[];

    final status = await service.downloadInstaller(onProgress: progress.add);

    expect(status.state, AppUpdateState.readyToInstall);
    expect(progress, isNotEmpty);
    expect(
      await File(p.join(
        temporaryDirectory.path,
        InstallerDownloader.updateDirectoryName,
        installerName,
      )).exists(),
      isTrue,
    );
  });

  test('reports a download failure', () async {
    final service = buildService(failDownload: true);
    await service.checkForUpdate();

    await expectLater(
      service.downloadInstaller(),
      throwsA(isA<InstallerDownloadException>()),
    );
  });

  test('requests the exit, opens the installer and only then exits', () async {
    int? exitCode;
    final service = buildService(onExit: (code) => exitCode = code);
    await service.checkForUpdate();
    await service.downloadInstaller();

    final result = await service.restartWithInstaller();

    expect(result.outcome, AppUpdateRestartOutcome.launched);
    expect(operations, ['exit-request', 'launch', 'exit']);
    expect(exitCode, 0);
  });

  test('does not open the installer when the closing flow is refused', () async {
    final service = buildService(exitPermitted: false);
    await service.checkForUpdate();
    await service.downloadInstaller();

    final result = await service.restartWithInstaller();

    expect(result.outcome, AppUpdateRestartOutcome.cancelled);
    expect(operations, ['exit-request']);
  });

  test('keeps the application open when the installer cannot be opened',
      () async {
    final service = buildService(failLaunch: true);
    await service.checkForUpdate();
    await service.downloadInstaller();

    final result = await service.restartWithInstaller();

    expect(result.outcome, AppUpdateRestartOutcome.failed);
    expect(result.errorMessage, contains('Não foi possível abrir o instalador'));
    expect(operations, ['exit-request', 'launch']);
  });

  test('fails when the installer was not downloaded', () async {
    final service = buildService();
    await service.checkForUpdate();

    final result = await service.restartWithInstaller();

    expect(result.outcome, AppUpdateRestartOutcome.failed);
    expect(operations, isEmpty);
  });
}
