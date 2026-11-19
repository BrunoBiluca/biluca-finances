import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/bloc/backup_events.dart';
import 'package:biluca_financas/core/backup/bloc/backup_states.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoogleDriveBackupSection extends StatelessWidget {
  const GoogleDriveBackupSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: const Key('settings-google-drive-backup'),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_sync, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Backup no Google Drive',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BlocBuilder<BackupBloc, BackupState>(
              builder: (context, state) {
                final status =
                    state is BackupStatusChanged ? state.status : null;
                return _buildContent(context, theme, status);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    BackupStatus? status,
  ) {
    if (status == null) {
      return const LinearProgressIndicator(minHeight: 2);
    }

    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!status.isConfigured) ...[
          Text(
            'Sincronize o banco de dados da aplicação com o seu Google Drive para '
            'proteger os dados e recuperá-los em outra instalação.',
            style: secondary,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('connect-google-drive'),
            onPressed: status.isBusy
                ? null
                : () => context.read<BackupBloc>().add(const ConnectBackupAccount()),
            icon: const Icon(Icons.link),
            label: const Text('Conectar ao Google Drive'),
          ),
        ] else ...[
          Text(
            'Sincronização ativa com a conta '
            '${status.accountEmail ?? 'do Google Drive'}.',
            key: const Key('settings-google-drive-connected'),
            style: secondary,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Conta',
            value: status.accountEmail ?? 'Conta do Google Drive',
          ),
          if (status.profile != null)
            _InfoRow(
              label: 'Perfil de sincronização',
              value: status.profile!,
            ),
          _InfoRow(
            label: 'Última sincronização',
            value: status.lastSyncAt == null
                ? 'Ainda não realizada'
                : Formatter.dateTime(status.lastSyncAt!),
          ),
          _InfoRow(
            label: 'Versão do banco de dados',
            value: '${status.databaseVersion}',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const Key('revoke-google-drive'),
            onPressed: status.isBusy
                ? null
                : () => context.read<BackupBloc>().add(const RevokeBackupAccount()),
            icon: const Icon(Icons.link_off),
            label: const Text('Revogar sincronia'),
          ),
        ],
        if (status.isBusy) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(
            key: Key('settings-google-drive-progress'),
            minHeight: 2,
          ),
        ],
        if (status.state == BackupSyncState.failed) ...[
          const SizedBox(height: 12),
          Text(
            status.errorMessage ?? 'Não foi possível concluir a operação.',
            key: const Key('settings-google-drive-error'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
