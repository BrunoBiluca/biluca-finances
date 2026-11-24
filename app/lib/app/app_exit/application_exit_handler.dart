import 'package:biluca_financas/app/app_exit/app_exit_dialog.dart';
import 'package:biluca_financas/app/app_exit/app_exit_flow.dart';
import 'package:biluca_financas/app/navigator_key.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/services/backup_service.dart';
import 'package:biluca_financas/tear_down.dart';
import 'package:get_it/get_it.dart';

Future<bool> runApplicationExitHandler() async {
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
