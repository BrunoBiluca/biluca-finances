import 'package:biluca_financas/core/backup/bloc/backup_bloc.dart';
import 'package:biluca_financas/core/backup/bloc/backup_events.dart';
import 'package:biluca_financas/core/backup/bloc/backup_states.dart';
import 'package:biluca_financas/core/backup/models/backup_conflict.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_mocks/fake_backup_service.dart';

void main() {
  final notConfigured = BackupStatus.notConfigured(databaseVersion: 10);
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

  blocTest<BackupBloc, BackupState>(
    'loads the current status',
    build: () => BackupBloc(service: FakeBackupService(notConfigured)),
    act: (bloc) => bloc.add(const LoadBackupStatus()),
    expect: () => [
      isA<BackupStatusChanged>()
          .having((state) => state.status, 'status', notConfigured),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'goes from not configured to connecting and configured',
    build: () => BackupBloc(service: FakeBackupService(notConfigured)),
    act: (bloc) => bloc
      ..add(const LoadBackupStatus())
      ..add(const ConnectBackupAccount()),
    expect: () => [
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.notConfigured,
      ),
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.connecting,
      ),
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.configured,
      ),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'reports a connect failure',
    build: () {
      final service = FakeBackupService(notConfigured)
        ..connectError = Exception('sem rede');
      return BackupBloc(service: service);
    },
    act: (bloc) => bloc.add(const ConnectBackupAccount()),
    expect: () => [
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.connecting,
      ),
      isA<BackupStatusChanged>()
          .having((state) => state.status.state, 'state', BackupSyncState.failed)
          .having(
            (state) => state.status.errorMessage,
            'errorMessage',
            contains('sem rede'),
          ),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'revokes the connection',
    build: () => BackupBloc(service: FakeBackupService(configured)),
    act: (bloc) => bloc.add(const RevokeBackupAccount()),
    expect: () => [
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.connecting,
      ),
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.notConfigured,
      ),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'synchronizes on open and on close',
    build: () {
      final service = FakeBackupService(configured)
        ..syncResults = [synchronized];
      return BackupBloc(service: service);
    },
    act: (bloc) => bloc
      ..add(const SynchronizeBackupOnOpen())
      ..add(const SynchronizeBackupOnClose()),
    verify: (bloc) {
      final service = bloc.service as FakeBackupService;
      expect(service.syncOnOpenCalls, 1);
      expect(service.syncOnCloseCalls, 1);
    },
    expect: () => [
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.synchronizing,
      ),
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.synchronized,
      ),
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.synchronizing,
      ),
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.synchronized,
      ),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'reports a synchronization failure keeping the previous data',
    build: () => BackupBloc(
      service: FakeBackupService(synchronized)..syncError = Exception('sem conexão'),
    ),
    act: (bloc) => bloc.add(const SynchronizeBackupOnOpen()),
    expect: () => [
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.synchronizing,
      ),
      isA<BackupStatusChanged>()
          .having((state) => state.status.state, 'state', BackupSyncState.failed)
          .having((state) => state.status.lastSyncAt, 'lastSyncAt',
              synchronized.lastSyncAt),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'exposes a conflict and resolves it with the chosen option',
    build: () {
      final service = FakeBackupService(configured)
        ..syncResults = [conflict, synchronized];
      return BackupBloc(service: service);
    },
    act: (bloc) => bloc
      ..add(const SynchronizeBackupOnOpen())
      ..add(const ResolveBackupConflictEvent(BackupConflictResolution.useRemote)),
    verify: (bloc) {
      final service = bloc.service as FakeBackupService;
      expect(service.resolutions, [BackupConflictResolution.useRemote]);
    },
    expect: () => [
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.synchronizing,
      ),
      isA<BackupStatusChanged>()
          .having((state) => state.status.state, 'state', BackupSyncState.conflict)
          .having((state) => state.status.hasConflict, 'hasConflict', isTrue),
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.synchronizing,
      ),
      isA<BackupStatusChanged>().having(
        (state) => state.status.state,
        'state',
        BackupSyncState.synchronized,
      ),
    ],
  );
}
