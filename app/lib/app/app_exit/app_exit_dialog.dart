import 'package:biluca_financas/common/ui/base_dialog.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/bloc/backup_events.dart';
import 'package:biluca_financas/core/backup/bloc/backup_states.dart';
import 'package:biluca_financas/core/backup/models/backup_conflict.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<bool> showAppExitDialog({
  required BuildContext context,
  required BackupBloc bloc,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: const AppExitDialog(),
    ),
  );
  return result ?? false;
}

class AppExitDialog extends StatefulWidget {
  const AppExitDialog({super.key});

  @override
  State<AppExitDialog> createState() => _AppExitDialogState();
}

class _AppExitDialogState extends State<AppExitDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BackupBloc>().add(const SynchronizeBackupOnClose());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackupBloc, BackupState>(
      builder: (context, state) {
        final status = state is BackupStatusChanged ? state.status : null;
        return BaseDialog(
          title: 'Sincronização com o Google Drive',
          content: _buildContent(context, status),
          actions: _buildActions(context, status),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, BackupStatus? status) {
    final theme = Theme.of(context);

    if (status == null || status.isBusy) {
      return Column(
        key: const Key('app-exit-progress'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LinearProgressIndicator(minHeight: 4),
          const SizedBox(height: 16),
          Text(
            'Sincronizando seus dados com o Google Drive...',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }

    if (status.hasConflict) {
      return Column(
        key: const Key('app-exit-conflict'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O banco de dados local e o arquivo no Google Drive foram alterados. '
            'Escolha qual versão deseja manter.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            key: const Key('app-exit-keep-local'),
            onPressed: () => context.read<BackupBloc>().add(
                  const ResolveBackupConflictEvent(
                    BackupConflictResolution.keepLocal,
                  ),
                ),
            child: const Text('Manter o local'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('app-exit-use-remote'),
            onPressed: () => context.read<BackupBloc>().add(
                  const ResolveBackupConflictEvent(
                    BackupConflictResolution.useRemote,
                  ),
                ),
            child: const Text('Atualizar com o do Google Drive'),
          ),
        ],
      );
    }

    final failed = status.state == BackupSyncState.failed;
    return Column(
      key: const Key('app-exit-finished'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          failed
              ? 'Não foi possível sincronizar com o Google Drive. '
                  'Os dados locais foram mantidos e a aplicação pode ser finalizada.'
              : 'Sincronização concluída. Você já pode finalizar a aplicação.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  List<Widget>? _buildActions(BuildContext context, BackupStatus? status) {
    if (status == null || status.isBusy || status.hasConflict) return null;

    return [
      FilledButton(
        key: const Key('app-exit-finish'),
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text('Finalizar aplicação'),
      ),
    ];
  }
}
