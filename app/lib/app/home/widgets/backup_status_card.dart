import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/bloc/backup_states.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BackupStatusCard extends StatelessWidget {
  const BackupStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: const Key('home-backup-status'),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BlocBuilder<BackupBloc, BackupState>(
          builder: (context, state) {
            final status = state is BackupStatusChanged ? state.status : null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backup e sincronização',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildContent(theme, status),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, BackupStatus? status) {
    if (status == null) {
      return const LinearProgressIndicator(minHeight: 2);
    }

    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    if (!status.isConfigured) {
      return Text(
        'Nenhum backup configurado. Conecte uma conta do Google Drive em Configurações.',
        key: const Key('home-backup-not-configured'),
        style: secondary,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status.lastSyncAt == null
              ? 'Última sincronização: ainda não realizada'
              : 'Última sincronização: ${Formatter.dateTime(status.lastSyncAt!)}',
          key: const Key('home-last-sync'),
          style: secondary,
        ),
        const SizedBox(height: 4),
        Text(
          'Versão do banco de dados: ${status.databaseVersion}',
          key: const Key('home-database-version'),
          style: secondary,
        ),
        if (status.isBusy) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(
            key: Key('home-backup-synchronizing'),
            minHeight: 2,
          ),
        ],
        if (status.state == BackupSyncState.failed) ...[
          const SizedBox(height: 8),
          Text(
            'Falha na sincronização: ${status.errorMessage ?? 'erro desconhecido'}',
            key: const Key('home-backup-error'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
