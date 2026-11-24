import 'dart:io';

import 'package:biluca_financas/integrations/app_update/inno_setup_installer_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  InnoSetupInstallerLauncher launcherRecording(
    List<(String, List<String>)> calls,
  ) {
    return InnoSetupInstallerLauncher(
      startProcess: (executable, arguments) async {
        calls.add((executable, arguments));
      },
      applicationPid: 4321,
    );
  }

  test('waits for the application before opening the installer', () {
    final arguments = InnoSetupInstallerLauncher.argumentsFor(
      applicationPid: 4321,
      installerPath: r'C:\caminho com espacos\setup.exe',
      logPath: r'C:\caminho com espacos\setup.exe.launch.log',
      exitWaitTimeout: const Duration(seconds: 60),
    );

    final command = arguments.last;
    expect(arguments, containsAllInOrder(['-NoProfile', '-Command']));
    expect(command, contains('Get-Process -Id 4321'));
    expect(command, contains('WaitForExit(60000)'));
    expect(
      command,
      contains("Start-Process -FilePath 'C:\\caminho com espacos\\setup.exe'"),
    );
    expect(
      command.indexOf('Get-Process'),
      lessThan(command.indexOf('Start-Process')),
    );
  });

  test('writes launch details and failures to a log file', () {
    final arguments = InnoSetupInstallerLauncher.argumentsFor(
      applicationPid: 1,
      installerPath: r'C:\update\setup.exe',
      logPath: r'C:\update\setup.exe.launch.log',
      exitWaitTimeout: const Duration(seconds: 1),
    );

    final command = arguments.last;
    expect(command, contains(r"'C:\update\setup.exe.launch.log'"));
    expect(command, contains('instalador aberto'));
    expect(command, contains('falha ao abrir o instalador'));
  });

  test('escapes quotes in the installer path', () {
    final arguments = InnoSetupInstallerLauncher.argumentsFor(
      applicationPid: 1,
      installerPath: "C:\\it's here\\setup.exe",
      logPath: "C:\\it's here\\setup.exe.launch.log",
      exitWaitTimeout: const Duration(seconds: 1),
    );

    expect(
      arguments.last,
      contains(r"Start-Process -FilePath 'C:\it''s here\setup.exe'"),
    );
  });

  test('starts a hidden PowerShell process for the installer', () async {
    final calls = <(String, List<String>)>[];
    final launcher = launcherRecording(calls);
    final installer = File(r'C:\update\biluca-financas-setup-2.1.0.exe');

    await launcher.launch(installer);

    expect(calls, hasLength(1));
    expect(calls.single.$1, InnoSetupInstallerLauncher.powershellExecutable);
    expect(calls.single.$2, contains('-WindowStyle'));
    expect(
      calls.single.$2.last,
      contains(r"'C:\update\biluca-financas-setup-2.1.0.exe'"),
    );
    expect(
      calls.single.$2.last,
      contains(InnoSetupInstallerLauncher.logPathFor(installer)),
    );
  });
}
