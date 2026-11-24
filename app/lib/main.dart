import 'dart:io';

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
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');

  try {
    await setup();
    await initDatabase();
    await runStartupBackupSync(GetIt.I<BackupService>());
    scheduleStartupAppUpdateCheck(GetIt.I<AppUpdateBloc>());
  } catch (error, stackTrace) {
    stderr.writeln("Failed to initialize the application: $error");
    stderr.writeln(stackTrace);
    exit(1);
  }

  runApp(App(runApplicationExitHandler));
}
