import 'package:biluca_financas/app/app_exit/app_exit_dialog.dart';
import 'package:biluca_financas/app/app_exit/app_exit_flow.dart';
import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/models/backup_conflict.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_mocks/fake_backup_service.dart';

void main() {
  final configured = BackupStatus(
    state: BackupSyncState.configured,
    isConfigured: true,
    databaseVersion: 10,
    accountEmail: 'pessoa@gmail.com',
  );
  final synchronized = configured.copyWith(
    state: BackupSyncState.synchronized,
    lastSyncAt: DateTime.utc(2026, 5, 6, 10),
  );
  final conflict = configured.copyWith(
    state: BackupSyncState.conflict,
    conflict: BackupConflict(
      localModifiedAt: DateTime.utc(2026, 5, 6, 11),
      remoteModifiedAt: DateTime.utc(2026, 5, 6, 12),
    ),
  );

  Future<FakeBackupService> pumpExitDialog(
    WidgetTester tester, {
    List<BackupStatus> syncResults = const [],
    Object? syncError,
  }) async {
    final service = FakeBackupService(configured)
      ..syncResults = List.of(syncResults)
      ..syncError = syncError;
    final bloc = BackupBloc(service: service);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAppExitDialog(context: context, bloc: bloc),
              child: const Text('fechar aplicação'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('fechar aplicação'));
    await tester.pump();
    return service;
  }

  testWidgets('shows the synchronization modal and finishes the application',
      (tester) async {
    final service = await pumpExitDialog(tester, syncResults: [synchronized]);

    expect(find.byKey(const Key('app-exit-progress')), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-exit-finished')), findsOneWidget);
    expect(find.text('Finalizar aplicação'), findsOneWidget);
    expect(service.syncOnCloseCalls, 1);

    await tester.tap(find.byKey(const Key('app-exit-finish')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-exit-finish')), findsNothing);
  });

  testWidgets('offers the conflict options while closing', (tester) async {
    final service = await pumpExitDialog(
      tester,
      syncResults: [conflict, synchronized],
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-exit-conflict')), findsOneWidget);
    expect(find.text('Manter o local'), findsOneWidget);
    expect(find.text('Atualizar com o do Google Drive'), findsOneWidget);
    expect(find.byKey(const Key('app-exit-finish')), findsNothing);

    await tester.tap(find.byKey(const Key('app-exit-use-remote')));
    await tester.pumpAndSettle();

    expect(service.resolutions, [BackupConflictResolution.useRemote]);
    expect(find.byKey(const Key('app-exit-finish')), findsOneWidget);
  });

  testWidgets('allows finishing the application when the synchronization fails',
      (tester) async {
    await pumpExitDialog(tester, syncError: Exception('sem rede'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-exit-finished')), findsOneWidget);
    expect(find.byKey(const Key('app-exit-finish')), findsOneWidget);
  });

  group('runApplicationExitFlow', () {
    test('does not open the modal when the backup is not configured', () async {
      final service = FakeBackupService(
        BackupStatus.notConfigured(databaseVersion: 10),
      );
      var modalShown = false;

      final canExit = await runApplicationExitFlow(
        service: service,
        showSynchronizationModal: () async {
          modalShown = true;
          return true;
        },
      );

      expect(canExit, isTrue);
      expect(modalShown, isFalse);
    });

    test('opens the modal when the backup is configured', () async {
      final service = FakeBackupService(configured);
      var modalShown = false;

      final canExit = await runApplicationExitFlow(
        service: service,
        showSynchronizationModal: () async {
          modalShown = true;
          return false;
        },
      );

      expect(canExit, isFalse);
      expect(modalShown, isTrue);
    });
  });
}
