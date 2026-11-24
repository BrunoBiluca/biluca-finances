import 'package:biluca_financas/app/home/widgets/backup_status_card.dart';
import 'package:biluca_financas/app/home/widgets/update_notification_card.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_bloc.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/bloc/backup_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class Home extends StatelessWidget {
  const Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final backupBloc = GetIt.I<BackupBloc>()..add(const LoadBackupStatus());
    final appUpdateBloc = GetIt.I<AppUpdateBloc>();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: backupBloc),
        BlocProvider.value(value: appUpdateBloc),
      ],
      child: const _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: "Biluca Finanças",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: " — ",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextSpan(
                      text: "Controle de orçamentos pessoais",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 24),
                    ),
                  ]),
                ),
                const Text(
                  "Bem-vindo de volta! Aqui está um resumo executivo e a consolidação da sua saúde financeira.",
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const UpdateNotificationCard(),
        const SizedBox(height: 20),
        const BackupStatusCard(),
      ],
    );
  }
}
