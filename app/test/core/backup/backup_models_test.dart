import 'package:biluca_financas/core/backup/models/backup_conflict.dart';
import 'package:biluca_financas/core/backup/models/backup_credentials.dart';
import 'package:biluca_financas/core/backup/models/backup_record.dart';
import 'package:biluca_financas/core/backup/models/backup_settings.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:biluca_financas/core/backup/models/remote_backup_file.dart';
import 'package:biluca_financas/core/backup/models/sync_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackupCredentials', () {
    test('serializes and restores every field', () {
      final credentials = BackupCredentials(
        accessToken: 'token',
        tokenType: 'Bearer',
        expiry: DateTime.utc(2026, 1, 2, 3, 4, 5),
        refreshToken: 'refresh',
        scopes: const ['scope-a', 'scope-b'],
      );

      final restored = BackupCredentials.fromJson(credentials.toJson());

      expect(restored, credentials);
    });

    test('keeps a missing refresh token as null', () {
      final credentials = BackupCredentials(
        accessToken: 'token',
        tokenType: 'Bearer',
        expiry: DateTime.utc(2026, 1, 2),
        scopes: const [],
      );

      expect(BackupCredentials.fromJson(credentials.toJson()).refreshToken, isNull);
    });
  });

  group('BackupSettings', () {
    test('serializes and restores the connection settings', () {
      final settings = BackupSettings(
        configured: true,
        accountEmail: 'pessoa@gmail.com',
        connectedAt: DateTime.utc(2026, 2, 3, 4, 5),
        credentials: BackupCredentials(
          accessToken: 'token',
          tokenType: 'Bearer',
          expiry: DateTime.utc(2026, 2, 3, 5, 5),
          refreshToken: 'refresh',
          scopes: const ['scope'],
        ),
      );

      expect(BackupSettings.fromJson(settings.toJson()), settings);
    });

    test('restores an empty payload as not configured', () {
      final settings = BackupSettings.fromJson(const {});

      expect(settings.configured, isFalse);
      expect(settings.credentials, isNull);
    });
  });

  group('SyncMetadata', () {
    test('serializes and restores the synchronization metadata', () {
      final metadata = SyncMetadata(
        localHash: 'hash',
        remoteFileId: 'remote-id',
        remoteModifiedAt: DateTime.utc(2026, 3, 4, 5, 6),
        lastSyncedAt: DateTime.utc(2026, 3, 4, 5, 10),
      );

      expect(SyncMetadata.fromJson(metadata.toJson()), metadata);
    });
  });

  group('RemoteBackupFile', () {
    test('compares by value', () {
      final modifiedAt = DateTime.utc(2026, 3, 4);

      expect(
        RemoteBackupFile(id: 'a', modifiedAt: modifiedAt, size: 10),
        RemoteBackupFile(id: 'a', modifiedAt: modifiedAt, size: 10),
      );
      expect(
        RemoteBackupFile(id: 'a', modifiedAt: modifiedAt, size: 10),
        isNot(RemoteBackupFile(id: 'a', modifiedAt: modifiedAt, size: 11)),
      );
    });
  });

  group('BackupStatus', () {
    test('serializes and restores the sync state', () {
      final status = BackupStatus(
        state: BackupSyncState.synchronized,
        isConfigured: true,
        databaseVersion: 10,
        accountEmail: 'pessoa@gmail.com',
        profile: 'desenvolvimento',
        lastSyncAt: DateTime.utc(2026, 5, 6, 7, 8),
      );

      final restored = BackupStatus.fromJson(status.toJson());

      expect(restored.state, BackupSyncState.synchronized);
      expect(restored.isConfigured, isTrue);
      expect(restored.databaseVersion, 10);
      expect(restored.accountEmail, 'pessoa@gmail.com');
      expect(restored.profile, 'desenvolvimento');
      expect(restored.lastSyncAt, DateTime.utc(2026, 5, 6, 7, 8));
    });

    test('compares by value', () {
      expect(
        BackupStatus.notConfigured(databaseVersion: 3),
        BackupStatus.notConfigured(databaseVersion: 3),
      );
      expect(
        BackupStatus.notConfigured(databaseVersion: 3),
        isNot(BackupStatus.notConfigured(databaseVersion: 4)),
      );
    });

    test('reports busy and conflict states', () {
      final synchronizing = BackupStatus.notConfigured(databaseVersion: 1)
          .copyWith(state: BackupSyncState.synchronizing);
      final conflict = synchronizing.copyWith(
        state: BackupSyncState.conflict,
        conflict: BackupConflict(
          localModifiedAt: DateTime.utc(2026),
          remoteModifiedAt: DateTime.utc(2026, 1, 2),
        ),
      );

      expect(synchronizing.isBusy, isTrue);
      expect(conflict.hasConflict, isTrue);
      expect(conflict.isBusy, isFalse);
    });
  });

  group('BackupRecord', () {
    test('serializes and restores the record', () {
      final record = BackupRecord(
        settings: BackupSettings(
          configured: true,
          accountEmail: 'pessoa@gmail.com',
          credentials: BackupCredentials(
            accessToken: 'token',
            tokenType: 'Bearer',
            expiry: DateTime.utc(2026, 5, 6),
            refreshToken: 'refresh',
            scopes: const ['scope'],
          ),
        ),
        metadata: SyncMetadata(
          localHash: 'hash',
          remoteFileId: 'remote',
          remoteModifiedAt: DateTime.utc(2026, 5, 6, 1),
          lastSyncedAt: DateTime.utc(2026, 5, 6, 2),
        ),
        lastSyncAt: DateTime.utc(2026, 5, 6, 2),
        databaseVersion: 10,
      );

      expect(BackupRecord.fromJson(record.toJson()), record);
    });

    test('derives the status from the last synchronization', () {
      final neverSynced = BackupRecord(
        settings: const BackupSettings(configured: true),
        databaseVersion: 10,
      );
      final synced = neverSynced.copyWith(lastSyncAt: DateTime.utc(2026, 5, 6));

      expect(neverSynced.status.state, BackupSyncState.configured);
      expect(neverSynced.status.isConfigured, isTrue);
      expect(synced.status.state, BackupSyncState.synchronized);
      expect(synced.status.lastSyncAt, DateTime.utc(2026, 5, 6));
      expect(
        const BackupRecord(settings: BackupSettings.notConfigured, databaseVersion: 2)
            .status
            .state,
        BackupSyncState.notConfigured,
      );
    });
  });
}
