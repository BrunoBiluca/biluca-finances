import 'package:biluca_financas/app/settings/widgets/appearance_section.dart';
import 'package:biluca_financas/app/settings/widgets/app_update_section.dart';
import 'package:biluca_financas/app/settings/widgets/google_drive_backup_section.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_bloc.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/bloc/backup_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final backupBloc = GetIt.I<BackupBloc>()..add(const LoadBackupStatus());
    final appUpdateBloc = GetIt.I<AppUpdateBloc>();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: backupBloc),
        BlocProvider.value(value: appUpdateBloc),
      ],
      child: const _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aplicativo',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Configurações',
              key: const Key('settings-page-title'),
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                'Gerencie as integrações e preferências da aplicação, incluindo o backup dos dados.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const AppearanceSection(),
        const SizedBox(height: 24),
        const AppUpdateSection(),
        const SizedBox(height: 24),
        const GoogleDriveBackupSection(),
      ],
    );
  }
}
