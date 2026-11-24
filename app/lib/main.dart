import 'package:biluca_financas/app/app.dart';
import 'package:biluca_financas/app/app_exit/application_exit_handler.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_bloc.dart';
import 'package:biluca_financas/core/app_update/services/startup_app_update_check.dart';
import 'package:biluca_financas/core/backup/services/backup_service.dart';
import 'package:biluca_financas/core/backup/services/startup_backup_sync.dart';
import 'package:biluca_financas/init_database.dart';
import 'package:biluca_financas/di_container.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  initializeDateFormatting('pt_BR');
  WidgetsFlutterBinding.ensureInitialized();

  await setup();

  await initDatabase();

  await runStartupBackupSync(GetIt.I<BackupService>());

  scheduleStartupAppUpdateCheck(GetIt.I<AppUpdateBloc>());

  runApp(App(runApplicationExitHandler));
}
