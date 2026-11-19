import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/app/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../_mocks/fake_backup_service.dart';

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpHome(WidgetTester tester, BackupStatus status) async {
    getIt.registerSingleton<BackupBloc>(
      BackupBloc(service: FakeBackupService(status)),
    );

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Home())));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the last synchronization and the database version',
      (tester) async {
    final lastSyncAt = DateTime.utc(2026, 5, 6, 14, 30);
    final expectedTime =
        DateFormat('dd/MM/yyyy HH:mm').format(lastSyncAt.toLocal());
    await pumpHome(
      tester,
      BackupStatus(
        state: BackupSyncState.synchronized,
        isConfigured: true,
        databaseVersion: 10,
        lastSyncAt: lastSyncAt,
      ),
    );

    expect(find.byKey(const Key('home-backup-status')), findsOneWidget);
    expect(
      find.text('Última sincronização: $expectedTime'),
      findsOneWidget,
    );
    expect(find.text('Versão do banco de dados: 10'), findsOneWidget);
  });

  testWidgets('indicates that no backup is configured', (tester) async {
    await pumpHome(tester, BackupStatus.notConfigured(databaseVersion: 10));

    expect(find.byKey(const Key('home-backup-not-configured')), findsOneWidget);
    expect(find.byKey(const Key('home-last-sync')), findsNothing);
  });
}
