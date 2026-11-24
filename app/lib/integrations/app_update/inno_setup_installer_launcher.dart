import 'dart:io';

typedef ProcessStarter = Future<void> Function(
  String executable,
  List<String> arguments,
);

class InnoSetupInstallerLauncher {
  static const String powershellExecutable = 'powershell.exe';
  static const Duration defaultExitWaitTimeout = Duration(seconds: 60);

  final ProcessStarter startProcess;
  final int applicationPid;
  final Duration exitWaitTimeout;

  const InnoSetupInstallerLauncher({
    required this.startProcess,
    required this.applicationPid,
    this.exitWaitTimeout = defaultExitWaitTimeout,
  });

  /// Waits for the application process to end before opening the installer,
  /// so the files being updated are no longer in use. Failures are written to
  /// `logPath`, since the helper outlives the application.
  static List<String> argumentsFor({
    required int applicationPid,
    required String installerPath,
    required String logPath,
    required Duration exitWaitTimeout,
  }) {
    final installer = _quote(installerPath);
    final log = _quote(logPath);
    final command = "\$ErrorActionPreference = 'Continue'; "
        '\$log = $log; '
        'try { \$process = Get-Process -Id $applicationPid -ErrorAction Stop; '
        '\$null = \$process.WaitForExit(${exitWaitTimeout.inMilliseconds}) } '
        'catch { } '
        'try { Start-Process -FilePath $installer; '
        "\$null = Add-Content -Path \$log -Value "
        "('instalador aberto: ' + (Get-Date -Format o)) } "
        'catch { \$null = Add-Content -Path \$log -Value '
        "('falha ao abrir o instalador: ' + \$_) }";

    return ['-NoProfile', '-WindowStyle', 'Hidden', '-Command', command];
  }

  static String _quote(String value) => "'${value.replaceAll("'", "''")}'";

  static String logPathFor(File installer) => '${installer.path}.launch.log';

  Future<void> launch(File installer) async {
    await startProcess(
      powershellExecutable,
      argumentsFor(
        applicationPid: applicationPid,
        installerPath: installer.path,
        logPath: logPathFor(installer),
        exitWaitTimeout: exitWaitTimeout,
      ),
    );
  }
}
