import 'dart:io';

import 'package:biluca_financas/core/backup/models/backup_conflict.dart';
import 'package:biluca_financas/core/backup/models/backup_record.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:biluca_financas/core/backup/models/remote_backup_file.dart';
import 'package:biluca_financas/integrations/google_drive/google_drive_backup_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'backup_fakes.dart';

void main() {
  late Directory tempDir;
  late File databaseFile;
  late FakeDatabaseFileController database;
  late InMemoryBackupRecordStore store;
  late FakeRemoteStorage storage;
  late FakeBackupConnector connector;
  late GoogleDriveBackupService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('backup_service_test');
    databaseFile = File('${tempDir.path}${Platform.pathSeparator}myDb.db');
    await databaseFile.writeAsBytes([1, 2, 3, 4]);

    database = FakeDatabaseFileController(path: databaseFile.path, version: 7);
    store = InMemoryBackupRecordStore(
      BackupRecord(
        settings: configuredSettings(),
        databaseVersion: 7,
      ),
    );
    storage = FakeRemoteStorage();
    connector = FakeBackupConnector(storage: storage);
    service = GoogleDriveBackupService(
      database: database,
      store: store,
      connector: connector,
    );
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('reports the current status with the database version', () async {
    final status = await service.getStatus();

    expect(status.isConfigured, isTrue);
    expect(status.databaseVersion, 7);
    expect(status.state, BackupSyncState.configured);
  });

  test('reports the configured synchronization profile', () async {
    final profiledService = GoogleDriveBackupService(
      database: database,
      store: store,
      connector: connector,
      profile: 'desenvolvimento',
    );

    expect((await profiledService.getStatus()).profile, 'desenvolvimento');

    final status = await profiledService.syncOnOpen();

    expect(status.profile, 'desenvolvimento');
    expect((await profiledService.getStatus()).profile, 'desenvolvimento');
  });

  test('reports an unconfigured status when there is no record', () async {
    store.record = null;

    final status = await service.getStatus();

    expect(status.isConfigured, isFalse);
    expect(status.state, BackupSyncState.notConfigured);
    expect(await service.isConfigured(), isFalse);
  });

  test('persists the connection when connecting', () async {
    store.record = null;

    final status = await service.connect();

    expect(status.isConfigured, isTrue);
    expect(status.accountEmail, 'pessoa@gmail.com');
    expect(store.record?.settings.configured, isTrue);
    expect(await service.isConfigured(), isTrue);
  });

  test('revokes the synchronization and clears the local record', () async {
    final status = await service.revoke();

    expect(status.isConfigured, isFalse);
    expect(store.record, isNull);
    expect(connector.revokeCalls, 1);
  });

  test('uploads the local database on the initial synchronization', () async {
    final status = await service.syncOnOpen();

    expect(status.state, BackupSyncState.synchronized);
    expect(storage.uploads, 1);
    expect(storage.storedBytes, [1, 2, 3, 4]);
    expect(store.record?.metadata?.localHash, sha256.convert([1, 2, 3, 4]).toString());
    expect(store.record?.metadata?.remoteFileId, storage.fileId);
    expect(store.record?.lastSyncAt, isNotNull);
    expect(database.closeCalls, 1);
    expect(database.reopenCalls, 1);
    expect(storage.closed, isTrue);
  });

  test('does not synchronize when the backup is not configured', () async {
    store.record = null;

    final status = await service.syncOnOpen();

    expect(status.state, BackupSyncState.notConfigured);
    expect(connector.openCalls, 0);
  });

  test('downloads the remote file when only the remote file changed', () async {
    await service.syncOnOpen();
    storage.storedBytes = [9, 9, 9];
    storage.modifiedAt = DateTime.utc(2026, 1, 2);

    final status = await service.syncOnClose();

    expect(status.state, BackupSyncState.synchronized);
    expect(storage.downloads, 1);
    expect(await databaseFile.readAsBytes(), [9, 9, 9]);
    expect(
      store.record?.metadata?.localHash,
      sha256.convert([9, 9, 9]).toString(),
    );
  });

  test('reports a conflict when both files changed', () async {
    await service.syncOnOpen();
    await databaseFile.writeAsBytes([5, 5, 5]);
    storage.storedBytes = [9, 9, 9];
    storage.modifiedAt = DateTime.utc(2026, 1, 2);

    final status = await service.syncOnOpen();

    expect(status.state, BackupSyncState.conflict);
    expect(status.conflict, isNotNull);
    expect(storage.uploads, 1);
    expect(storage.downloads, 0);
    expect(await databaseFile.readAsBytes(), [5, 5, 5]);
    expect(database.reopenCalls, 2);
  });

  test('keeps the local file when resolving a conflict with the local version', () async {
    await service.syncOnOpen();
    await databaseFile.writeAsBytes([5, 5, 5]);
    storage.storedBytes = [9, 9, 9];
    storage.modifiedAt = DateTime.utc(2026, 1, 2);
    await service.syncOnOpen();

    final status = await service.resolveConflict(
      BackupConflictResolution.keepLocal,
    );

    expect(status.state, BackupSyncState.synchronized);
    expect(storage.uploads, 2);
    expect(storage.storedBytes, [5, 5, 5]);
    expect(await databaseFile.readAsBytes(), [5, 5, 5]);
    expect(
      store.record?.metadata?.localHash,
      sha256.convert([5, 5, 5]).toString(),
    );
  });

  test('replaces the local file when resolving a conflict with the remote version', () async {
    await service.syncOnOpen();
    await databaseFile.writeAsBytes([5, 5, 5]);
    storage.storedBytes = [9, 9, 9];
    storage.modifiedAt = DateTime.utc(2026, 1, 2);
    await service.syncOnOpen();

    final status = await service.resolveConflict(
      BackupConflictResolution.useRemote,
    );

    expect(status.state, BackupSyncState.synchronized);
    expect(await databaseFile.readAsBytes(), [9, 9, 9]);
    expect(
      store.record?.metadata?.localHash,
      sha256.convert([9, 9, 9]).toString(),
    );
    expect(store.record?.metadata?.remoteModifiedAt, DateTime.utc(2026, 1, 2));
  });

  test('reports a failure and keeps the previous metadata when the synchronization fails', () async {
    await service.syncOnOpen();
    final previous = store.record;

    final failingService = GoogleDriveBackupService(
      database: database,
      store: store,
      connector: FakeBackupConnector(storage: _FailingRemoteStorage()),
    );

    final status = await failingService.syncOnOpen();

    expect(status.state, BackupSyncState.failed);
    expect(status.errorMessage, isNotNull);
    expect(status.lastSyncAt, previous?.lastSyncAt);
    expect(store.record, previous);
    expect(database.reopenCalls, 2);
    expect((await failingService.getStatus()).state, BackupSyncState.failed);
  });

  test('shows the message returned by the Google API', () async {
    final failingService = GoogleDriveBackupService(
      database: database,
      store: store,
      connector: FakeBackupConnector(storage: _ApiErrorRemoteStorage()),
    );

    final status = await failingService.syncOnOpen();

    expect(status.state, BackupSyncState.failed);
    expect(status.errorMessage, 'Arquivo não encontrado.');
  });

  test('explains a missing Drive permission', () async {
    final failingService = GoogleDriveBackupService(
      database: database,
      store: store,
      connector: FakeBackupConnector(storage: _MissingScopeRemoteStorage()),
    );

    final status = await failingService.syncOnOpen();

    expect(status.state, BackupSyncState.failed);
    expect(status.errorMessage, contains('não tem permissão para acessar o Google Drive'));
    expect(status.errorMessage, contains('Revogue a sincronia'));
  });

  test('fails with a timeout message when the synchronization takes too long',
      () async {
    final slowService = GoogleDriveBackupService(
      database: database,
      store: store,
      connector: FakeBackupConnector(storage: _SlowRemoteStorage()),
      syncTimeout: const Duration(milliseconds: 50),
    );

    final status = await slowService.syncOnOpen();

    expect(status.state, BackupSyncState.failed);
    expect(status.errorMessage, contains('tempo limite'));
    expect(store.record?.metadata, isNull);
    expect(database.reopenCalls, 1);
  });
}

class _FailingRemoteStorage extends FakeRemoteStorage {
  @override
  Future<RemoteBackupFile?> findBackup() async {
    throw const SocketException('sem rede');
  }
}

class _ApiErrorRemoteStorage extends FakeRemoteStorage {
  @override
  Future<RemoteBackupFile?> findBackup() async {
    throw drive.DetailedApiRequestError(404, 'Arquivo não encontrado.');
  }
}

class _MissingScopeRemoteStorage extends FakeRemoteStorage {
  @override
  Future<RemoteBackupFile?> findBackup() async {
    throw drive.DetailedApiRequestError(
      403,
      'Request had insufficient authentication scopes.',
    );
  }
}

class _SlowRemoteStorage extends FakeRemoteStorage {
  @override
  Future<RemoteBackupFile?> findBackup() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return null;
  }
}
