import 'package:biluca_financas/app/themes/theme_setup.dart';
import 'package:biluca_financas/main.dart';
import 'package:get_it/get_it.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:biluca_financas/app/themes/theme_manager.dart';

import 'package:biluca_financas/common/logging/console_listener.dart';
import 'package:biluca_financas/common/logging/file_listener.dart';
import 'package:biluca_financas/common/logging/logger_manager.dart';

import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability_identification_prediction/service/accountability_identification_predition_service.dart';
import 'package:biluca_financas/core/accountability_monthly_report/services/accountability_month_service.dart';
import 'package:biluca_financas/core/accountability_import/services/accountability_import_service.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:biluca_financas/core/accountability_stats/services/accountability_stats_service.dart';
import 'package:biluca_financas/core/accountability_monthly_report/services/current_month_report.service.dart';
import 'package:biluca_financas/core/accountability_yearly_report/services/accountability_yearly_report_service.dart';

import 'package:biluca_financas/integrations/embedded_server/embedded_predict_server.dart';
import 'package:biluca_financas/integrations/embedded_server/embedded_predict_service.dart';
import 'package:biluca_financas/integrations/sqlite/sqlite_accountability_repo.dart';
import 'package:biluca_financas/integrations/sqlite/sqlite_accountability_month_service.dart';
import 'package:biluca_financas/integrations/sqlite/sqlite_accountability_import_service.dart';
import 'package:biluca_financas/integrations/sqlite/db_provider.dart';
import 'package:biluca_financas/integrations/sqlite/sqlite_accountability_stats_service.dart';
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

  getIt.registerSingleton<EmbeddedPredictServer>(EmbeddedPredictServer()..init());

  getIt.registerFactory<AccountabilityStatsService>(
    () => SqliteAccountabilityStatsService(
      db: getIt<Database>(),
    ),
  );

  getIt.registerFactoryParam<AccountabilityYearlyReportService, DateTime, DateTime>(
    (start, end) => SqliteYearlyReportService(
      db: getIt<Database>(),
      start: start,
      end: end,
    ),
  );
}

extension AccountabilityYearlyReportServiceFactory on GetIt {
  AccountabilityYearlyReportService getAccountabilityYearlyReportService({
    required DateTime start,
    required DateTime end,
  }) {
    return this.get<AccountabilityYearlyReportService>(param1: start, param2: end);
  }
}
