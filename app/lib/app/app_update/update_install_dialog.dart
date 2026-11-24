import 'package:biluca_financas/common/ui/base_dialog.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_bloc.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_events.dart';
import 'package:biluca_financas/core/app_update/models/app_update_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<bool> showAppUpdateInstallDialog({
  required BuildContext context,
  required AppUpdateStatus status,
}) async {
  final availableVersion =
      status.availableVersion?.toString() ?? 'mais recente';
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => BaseDialog(
      title: 'Atualizar aplicação',
      content: Text(
        'A aplicação será fechada para concluir a atualização para a versão '
        '$availableVersion. Os dados serão sincronizados antes do fechamento, '
        'se o backup estiver configurado. Deseja continuar?',
        key: const Key('app-update-dialog-message'),
      ),
      actions: [
        TextButton(
          key: const Key('app-update-dialog-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('app-update-dialog-confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Fechar e atualizar'),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> confirmAndInstallAppUpdate(BuildContext context) async {
  final bloc = context.read<AppUpdateBloc>();
  final status = bloc.state;
  final confirmed = await showAppUpdateInstallDialog(
    context: context,
    status: status,
  );
  if (!confirmed || !context.mounted) return;
  bloc.add(const InstallAppUpdate());
}
