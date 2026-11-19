import 'package:biluca_financas/app/app.dart';
import 'package:biluca_financas/app/app_exit/app_exit_dialog.dart';
import 'package:biluca_financas/app/app_exit/app_exit_flow.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/services/backup_service.dart';
import 'package:biluca_financas/core/backup/services/startup_backup_sync.dart';
import 'package:biluca_financas/init_database.dart';
import 'package:biluca_financas/di_container.dart';
import 'package:biluca_financas/tear_down.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  initializeDateFormatting('pt_BR');
  WidgetsFlutterBinding.ensureInitialized();

  await setup();

  await initDatabase();

  await runStartupBackupSync(GetIt.I<BackupService>());

  runApp(App(_handleAppExit));
}

Future<bool> _handleAppExit() async {
  final canExit = await runApplicationExitFlow(
    service: GetIt.I<BackupService>(),
    showSynchronizationModal: () async {
      final context = navigatorKey.currentContext;
      if (context == null) return true;
      return showAppExitDialog(
        context: context,
        bloc: GetIt.I<BackupBloc>(),
      );
    },
  );

  if (!canExit) return false;

  await tearDown();
  return true;
}
