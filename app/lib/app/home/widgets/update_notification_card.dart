import 'package:biluca_financas/app/app_update/update_install_dialog.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_bloc.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_events.dart';
import 'package:biluca_financas/core/app_update/models/app_update_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateNotificationCard extends StatelessWidget {
  const UpdateNotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUpdateBloc, AppUpdateStatus>(
      builder: (context, status) {
        if (!status.showsHomeNotification) return const SizedBox.shrink();

        final theme = Theme.of(context);
        return Card(
          key: const Key('home-update-notification'),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.system_update, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Atualização da aplicação',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Instalada: ${status.currentVersion} • '
                  'Disponível: ${status.availableVersion}',
                  key: const Key('home-update-versions'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                _buildContent(context, theme, status),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    AppUpdateStatus status,
  ) {
    if (status.state == AppUpdateState.downloading) {
      return Column(
        key: const Key('home-update-progress'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: status.downloadProgress, minHeight: 4),
          const SizedBox(height: 8),
          Text(_progressLabel(status), style: theme.textTheme.bodyMedium),
        ],
      );
    }

    final error = status.errorMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error != null) ...[
          Text(
            error,
            key: const Key('home-update-error'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (status.isReadyToInstall) ...[
          Text(
            'A atualização está pronta para ser instalada.',
            key: const Key('home-update-ready'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('home-update-install'),
            onPressed: () => confirmAndInstallAppUpdate(context),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reiniciar e atualizar'),
          ),
        ] else
          FilledButton.icon(
            key: const Key('home-update-download'),
            onPressed: () =>
                context.read<AppUpdateBloc>().add(const DownloadAppUpdate()),
            icon: const Icon(Icons.download),
            label: Text(
              error == null ? 'Baixar atualização' : 'Tentar novamente',
            ),
          ),
      ],
    );
  }

  String _progressLabel(AppUpdateStatus status) {
    final progress = status.downloadProgress;
    if (progress == null) return 'Baixando a atualização...';
    return 'Baixando a atualização... ${(progress * 100).round()}%';
  }
}
