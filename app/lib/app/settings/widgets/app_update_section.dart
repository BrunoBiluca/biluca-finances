import 'package:biluca_financas/app/app_update/update_install_dialog.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_bloc.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_events.dart';
import 'package:biluca_financas/core/app_update/models/app_update_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppUpdateSection extends StatelessWidget {
  const AppUpdateSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: const Key('settings-app-update'),
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
            BlocBuilder<AppUpdateBloc, AppUpdateStatus>(
              builder: (context, status) => _buildContent(context, theme, status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    AppUpdateStatus status,
  ) {
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    if (!status.isSupported) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Versão instalada', value: status.currentVersion.toString()),
          const SizedBox(height: 8),
          Text(
            'A atualização pela aplicação está disponível apenas no Windows.',
            key: const Key('settings-app-update-unsupported'),
            style: secondary,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          label: 'Versão instalada',
          value: status.currentVersion.toString(),
        ),
        if (status.availableVersion != null)
          _InfoRow(
            label: 'Versão publicada',
            value: status.availableVersion.toString(),
          ),
        const SizedBox(height: 8),
        Text(
          _summary(status),
          key: const Key('settings-app-update-summary'),
          style: secondary,
        ),
        if (status.state == AppUpdateState.downloading) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(
            key: const Key('settings-app-update-progress'),
            value: status.downloadProgress,
            minHeight: 2,
          ),
        ],
        if (status.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            status.errorMessage!,
            key: const Key('settings-app-update-error'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              key: const Key('settings-app-update-check'),
              onPressed: status.state == AppUpdateState.checking ||
                      status.state == AppUpdateState.downloading
                  ? null
                  : () => context.read<AppUpdateBloc>().add(const CheckAppUpdate()),
              icon: const Icon(Icons.refresh),
              label: const Text('Verificar novamente'),
            ),
            if (status.isReadyToInstall)
              FilledButton.icon(
                key: const Key('settings-app-update-install'),
                onPressed: () => confirmAndInstallAppUpdate(context),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reiniciar e atualizar'),
              )
            else if (status.canDownload)
              FilledButton.icon(
                key: const Key('settings-app-update-download'),
                onPressed: () =>
                    context.read<AppUpdateBloc>().add(const DownloadAppUpdate()),
                icon: const Icon(Icons.download),
                label: Text(status.errorMessage == null
                    ? 'Baixar atualização'
                    : 'Tentar novamente'),
              ),
          ],
        ),
      ],
    );
  }

  String _summary(AppUpdateStatus status) {
    return switch (status.state) {
      AppUpdateState.checking => 'Verificando a versão publicada...',
      AppUpdateState.upToDate => 'A aplicação está atualizada.',
      AppUpdateState.unsupported =>
        'A atualização pela aplicação está disponível apenas no Windows.',
      AppUpdateState.updateAvailable =>
        'A versão ${status.availableVersion} está disponível para instalação.',
      AppUpdateState.downloading => 'Baixando a atualização...',
      AppUpdateState.readyToInstall =>
        'A atualização está pronta. A aplicação será fechada para concluir a instalação.',
      AppUpdateState.failed =>
        'Não foi possível concluir a etapa anterior da atualização.',
    };
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
