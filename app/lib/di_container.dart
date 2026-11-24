import 'dart:io';

import 'package:biluca_financas/app/app_exit/application_exit_handler.dart';
import 'package:biluca_financas/app/navigator_key.dart';
import 'package:biluca_financas/app/themes/theme_setup.dart';
import 'package:get_it/get_it.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:biluca_financas/app/themes/theme_manager.dart';

import 'package:biluca_financas/common/logging/console_listener.dart';
import 'package:biluca_financas/common/logging/file_listener.dart';
import 'package:biluca_financas/common/logging/logger_manager.dart';

import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/identification_categories_bloc.dart';
import 'package:biluca_financas/core/accountability_identification_prediction/service/accountability_identification_predition_service.dart';
import 'package:biluca_financas/core/accountability_monthly_report/services/accountability_month_service.dart';
import 'package:biluca_financas/core/accountability_import/services/accountability_import_service.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:biluca_financas/core/accountability_stats/services/accountability_stats_service.dart';
import 'package:biluca_financas/core/accountability_monthly_report/services/current_month_report.service.dart';
import 'package:biluca_financas/core/accountability_yearly_report/services/accountability_yearly_report_service.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_bloc.dart';
import 'package:biluca_financas/core/app_update/models/app_version.dart';
import 'package:biluca_financas/core/app_update/services/app_update_service.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/services/backup_connector.dart';
import 'package:biluca_financas/core/backup/services/backup_record_store.dart';
import 'package:biluca_financas/core/backup/services/backup_service.dart';
import 'package:biluca_financas/core/backup/services/database_file_controller.dart';

import 'package:biluca_financas/integrations/embedded_server/embedded_predict_server.dart';
import 'package:biluca_financas/integrations/embedded_server/embedded_predict_service.dart';
import 'package:biluca_financas/integrations/app_update/inno_setup_installer_launcher.dart';
import 'package:biluca_financas/integrations/app_update/installer_downloader.dart';
import 'package:biluca_financas/integrations/app_update/windows_app_update_service.dart';
import 'package:biluca_financas/integrations/github_releases/github_releases_client.dart';
import 'package:biluca_financas/integrations/google_drive/backup_profile.dart';import 'package:biluca_financas/integrations/google_drive/file_backup_record_store.dart';
import 'package:biluca_financas/integrations/google_drive/google_drive_backup_service.dart';
import 'package:biluca_financas/integrations/google_drive/google_drive_connector.dart';
import 'package:biluca_financas/integrations/google_drive/google_oauth_credentials.dart';
import 'package:biluca_financas/integrations/sqlite/sqlite_accountability_repo.dart';
import 'package:biluca_financas/integrations/sqlite/sqlite_accountability_month_service.dart';
import 'package:biluca_financas/integrations/sqlite/sqlite_accountability_import_service.dart';
import 'package:biluca_financas/integrations/sqlite/db_provider.dart';
import 'package:biluca_financas/integrations/sqlite/sqlite_accountability_stats_service.dart';
import 'package:biluca_financas/integrations/sqlite/sqlite_database_file_controller.dart';
import 'package:biluca_financas/integrations/sqlite/sqlite_yearly_report_service.dart';

Future<void> setup() async {
  var getIt = GetIt.instance;
  getIt.registerSingleton<LoggerManager>(LoggerManager()
    ..init([
      ConsoleLoggingListener(),
      FileLoggingListener(),
    ]));

  DBProvider.i.init();

  getIt.registerSingleton<Database>(await DBProvider.i.database);
  getIt.registerFactoryParam<AccountabilityMonthService, DateTime, void>(
    (month, _) => SQLiteAccontabilityMonthService(
      db: getIt<Database>(),
      month: month,
    ),
  );
  getIt.registerFactory<AccountabilityRepo>(
    () => SQLiteAccountabilityRepo(getIt<Database>()),
  );
  getIt.registerFactory<AccountabilityBloc>(
    () => AccountabilityBloc(repo: getIt<AccountabilityRepo>()),
  );
  getIt.registerFactory<IdentificationCategoriesBloc>(
    () => IdentificationCategoriesBloc(repo: getIt<AccountabilityRepo>()),
  );
  getIt.registerFactory<AccountabilityIdentificationPredictionService>(
    () => EmbeddedPredictService(Client(), getIt<AccountabilityRepo>()),
  );
  getIt.registerFactory<AccountabilityImportService>(
    () => SQLiteAccountabilityImportService(
      repo: getIt<AccountabilityRepo>(),
      predictService: getIt<AccountabilityIdentificationPredictionService>(),
    ),
  );
  getIt.registerFactory<FToast>(
    () => FToast()..init(navigatorKey.currentContext!),
  );
  getIt.registerFactoryParam<CurrentMonthReportService, DateTime, void>(
    (date, _) => CurrentMonthReportService(date),
  );

  getIt.registerCachedFactory<ThemeManager>(setupThemes);

  getIt.registerSingleton<EmbeddedPredictServer>(
      EmbeddedPredictServer()..init());

  getIt.registerFactory<AccountabilityStatsService>(
    () => SqliteAccountabilityStatsService(
      db: getIt<Database>(),
    ),
  );

  getIt.registerFactoryParam<AccountabilityYearlyReportService, DateTime,
      DateTime>(
    (start, end) => SqliteYearlyReportService(
      db: getIt<Database>(),
      start: start,
      end: end,
    ),
  );

  await _registerBackup(getIt);

  await _registerAppUpdate(getIt);
}

Future<void> _registerAppUpdate(GetIt getIt) async {
  final loggerManager = getIt<LoggerManager>();
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion =
      AppVersion.tryParse(packageInfo.version) ?? const AppVersion(0, 0, 0);

  final AppUpdateService service;
  if (Platform.isWindows) {
    final http = Client();
    service = WindowsAppUpdateService(
      releasesClient: GithubReleasesClient(http: http),
      downloader: InstallerDownloader(
        http: http,
        temporaryDirectory: getTemporaryDirectory,
      ),
      installerLauncher: InnoSetupInstallerLauncher(
        applicationPid: pid,
        startProcess: (executable, arguments) async {
          await Process.start(executable, arguments);
        },
      ),
      requestExit: runApplicationExitHandler,
      exitApplication: (code) async => exit(code),
      currentVersion: currentVersion,
      log: loggerManager.instance('WindowsAppUpdateService'),
    );
  } else {
    service = UnsupportedAppUpdateService(currentVersion: currentVersion);
  }

  getIt.registerSingleton<AppUpdateService>(service);
  getIt.registerSingleton<AppUpdateBloc>(AppUpdateBloc(service: service));
}

Future<void> _registerBackup(GetIt getIt) async {
  final databasePath = await DBProvider.i.getDBPath();
  final profile = resolveBackupProfile();
  final loggerManager = getIt<LoggerManager>();

  getIt.registerSingleton<DatabaseFileController>(
    SqliteDatabaseFileController(),
  );
  getIt.registerSingleton<BackupRecordStore>(
    FileBackupRecordStore(
      File(p.join(p.dirname(databasePath), 'backup_record.json')),
    ),
  );
  getIt.registerSingleton<BackupConnector>(
    GoogleDriveConnector(
      credentialsProvider: FileGoogleOAuthCredentialsProvider(
        resolveGoogleOAuthCredentialsFile(),
      ),
      backupFileName: p.basename(databasePath),
      profile: profile,
      prompt: (url) {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      logger: loggerManager.instance('GoogleDriveConnector'),
    ),
  );
  getIt.registerSingleton<BackupService>(
    GoogleDriveBackupService(
      database: getIt<DatabaseFileController>(),
      store: getIt<BackupRecordStore>(),
      connector: getIt<BackupConnector>(),
      profile: profile,
      logger: loggerManager.instance('GoogleDriveBackupService'),
    ),
  );
  getIt.registerSingleton<BackupBloc>(
    BackupBloc(service: getIt<BackupService>()),
  );
}

extension AccountabilityYearlyReportServiceFactory on GetIt {
  AccountabilityYearlyReportService getAccountabilityYearlyReportService({
    required DateTime start,
    required DateTime end,
  }) {
    return this
        .get<AccountabilityYearlyReportService>(param1: start, param2: end);
  }
}
