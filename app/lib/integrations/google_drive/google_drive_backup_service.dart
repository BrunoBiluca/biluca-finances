import 'dart:async';
import 'dart:io';

import 'package:biluca_financas/core/backup/models/backup_conflict.dart';
import 'package:biluca_financas/core/backup/models/backup_credentials.dart';
import 'package:biluca_financas/core/backup/models/backup_exception.dart';
import 'package:biluca_financas/core/backup/models/backup_record.dart';
import 'package:biluca_financas/core/backup/models/backup_settings.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:biluca_financas/core/backup/models/sync_metadata.dart';
import 'package:biluca_financas/core/backup/services/backup_connector.dart';
import 'package:biluca_financas/core/backup/services/backup_conflict_detector.dart';
import 'package:biluca_financas/core/backup/services/backup_record_store.dart';
import 'package:biluca_financas/core/backup/services/backup_remote_storage.dart';
import 'package:biluca_financas/core/backup/services/backup_service.dart';
import 'package:biluca_financas/core/backup/services/database_file_controller.dart';
import 'package:biluca_financas/integrations/google_drive/backup_profile.dart';
import 'package:crypto/crypto.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:logging/logging.dart';

const Duration defaultSyncTimeout = Duration(seconds: 60);

class GoogleDriveBackupService implements BackupService {
  final DatabaseFileController database;
  final BackupRecordStore store;
  final BackupConnector connector;
  final String profile;
  final Duration syncTimeout;
  final Logger _log;

  BackupStatus? _lastStatus;

  GoogleDriveBackupService({
    required this.database,
    required this.store,
    required this.connector,
    this.profile = defaultBackupProfile,
    this.syncTimeout = defaultSyncTimeout,
    Logger? logger,
  }) : _log = logger ?? Logger('GoogleDriveBackupService');

  BackupStatus _remember(BackupStatus status) {
    final withProfile = status.copyWith(profile: profile);
    _lastStatus = withProfile;
    return withProfile;
  }

  @override
  Future<bool> isConfigured() async {
    final record = await store.read();
    return record?.settings.configured ?? false;
  }

  @override
  Future<BackupStatus> getStatus() async {
    final version = database.databaseVersion;
    final cached = _lastStatus;
    if (cached != null) {
      return cached.copyWith(databaseVersion: version);
    }
    final record = await store.read();
    if (record == null) {
      return BackupStatus.notConfigured(databaseVersion: version)
          .copyWith(profile: profile);
    }
    return record
        .copyWith(databaseVersion: version)
        .status
        .copyWith(profile: profile);
  }

  @override
  Future<BackupStatus> connect() async {
    final settings = await connector.connect();
    final record = BackupRecord(
      settings: settings,
      databaseVersion: database.databaseVersion,
    );
    await store.write(record);
    return _remember(record.status);
  }

  @override
  Future<BackupStatus> revoke() async {
    final record = await store.read();
    await store.clear();

    final credentials = record?.settings.credentials;
    if (credentials != null) {
      try {
        await connector.revoke(credentials);
      } catch (error, stackTrace) {
        _log.warning(
          'Não foi possível revogar o acesso ao Google Drive.',
          error,
          stackTrace,
        );
      }
    }

    return _remember(
      BackupStatus.notConfigured(databaseVersion: database.databaseVersion),
    );
  }

  @override
  Future<BackupStatus> syncOnOpen() => _synchronize();

  @override
  Future<BackupStatus> syncOnClose() => _synchronize();

  @override
  Future<BackupStatus> resolveConflict(BackupConflictResolution resolution) {
    return _synchronize(resolution: resolution);
  }

  Future<BackupStatus> _synchronize({BackupConflictResolution? resolution}) async {
    final record = await store.read();
    final credentials = record?.settings.credentials;
    if (record == null || !record.settings.configured || credentials == null) {
      return _remember(
        BackupStatus.notConfigured(databaseVersion: database.databaseVersion),
      );
    }

    BackupRemoteStorage? storage;
    var databaseClosed = false;
    try {
      storage = await connector.openStorage(
        credentials,
        onCredentialsRefreshed: (refreshed) =>
            _persistCredentials(record, refreshed),
      );

      await database.close();
      databaseClosed = true;

      final status = await _transfer(storage, record, resolution)
          .timeout(syncTimeout, onTimeout: () {
        throw const BackupException(
          'A sincronização com o Google Drive excedeu o tempo limite.',
        );
      });

      return _remember(status);
    } catch (error, stackTrace) {
      _log.warning('Falha ao sincronizar com o Google Drive.', error, stackTrace);
      return _remember(record.status.copyWith(
        state: BackupSyncState.failed,
        errorMessage: _describeError(error),
        clearConflict: true,
      ));
    } finally {
      storage?.close();
      if (databaseClosed) {
        await database.reopen();
      }
    }
  }

  Future<BackupStatus> _transfer(
    BackupRemoteStorage storage,
    BackupRecord record,
    BackupConflictResolution? resolution,
  ) async {
    final localFile = File(await database.databasePath);
    final exists = await localFile.exists();
    final localBytes = exists ? await localFile.readAsBytes() : <int>[];
    final localModifiedAt = exists
        ? (await localFile.stat()).modified.toUtc()
        : DateTime.now().toUtc();
    final localHash = _hash(localBytes);
    final remoteFile = await storage.findBackup();

    final BackupSyncAction action;
    if (resolution == null) {
      final plan = planBackupSync(
        metadata: record.metadata,
        localHash: localHash,
        remoteFile: remoteFile,
        localModifiedAt: localModifiedAt,
      );
      if (plan.action == BackupSyncAction.conflict) {
        return record.status.copyWith(
          state: BackupSyncState.conflict,
          conflict: plan.conflict,
          clearError: true,
        );
      }
      action = plan.action;
    } else {
      action = resolution == BackupConflictResolution.keepLocal
          ? BackupSyncAction.uploadLocal
          : BackupSyncAction.downloadRemote;
    }

    switch (action) {
      case BackupSyncAction.uploadLocal:
        final uploaded = await storage.uploadBackup(localBytes);
        final now = DateTime.now().toUtc();
        return _persistSync(
          record,
          SyncMetadata(
            localHash: localHash,
            remoteFileId: uploaded.id,
            remoteModifiedAt: uploaded.modifiedAt ?? now,
            lastSyncedAt: now,
          ),
        );
      case BackupSyncAction.downloadRemote:
        if (remoteFile == null) {
          throw const BackupException(
            'Nenhum backup foi encontrado no Google Drive.',
          );
        }
        final downloaded = await storage.downloadBackup(remoteFile.id);
        final tempFile = File('${localFile.path}.tmp');
        await tempFile.writeAsBytes(downloaded, flush: true);
        await tempFile.copy(localFile.path);
        await tempFile.delete();
        final now = DateTime.now().toUtc();
        return _persistSync(
          record,
          SyncMetadata(
            localHash: _hash(downloaded),
            remoteFileId: remoteFile.id,
            remoteModifiedAt: remoteFile.modifiedAt ?? now,
            lastSyncedAt: now,
          ),
        );
      case BackupSyncAction.none:
        final metadata = record.metadata;
        if (metadata == null || remoteFile == null) return record.status;
        return _persistSync(
          record,
          SyncMetadata(
            localHash: localHash,
            remoteFileId: remoteFile.id,
            remoteModifiedAt: remoteFile.modifiedAt ?? metadata.remoteModifiedAt,
            lastSyncedAt: DateTime.now().toUtc(),
          ),
        );
      case BackupSyncAction.conflict:
        return record.status.copyWith(
          state: BackupSyncState.conflict,
          clearError: true,
        );
    }
  }

  Future<BackupStatus> _persistSync(
    BackupRecord record,
    SyncMetadata metadata,
  ) async {
    final current = await store.read() ?? record;
    final updated = BackupRecord(
      settings: current.settings,
      metadata: metadata,
      lastSyncAt: metadata.lastSyncedAt,
      databaseVersion: database.databaseVersion,
    );
    await store.write(updated);
    return updated.status;
  }

  Future<void> _persistCredentials(
    BackupRecord record,
    BackupCredentials credentials,
  ) async {
    final current = await store.read();
    final settings = current?.settings ?? record.settings;
    await store.write(
      (current ?? record).copyWith(
        settings: BackupSettings(
          configured: true,
          accountEmail: settings.accountEmail,
          connectedAt: settings.connectedAt,
          credentials: credentials,
        ),
      ),
    );
  }

  String _describeError(Object error) {
    if (error is BackupException) return error.message;
    if (error is drive.DetailedApiRequestError) {
      if (_isInsufficientScope(error.message)) {
        return 'A conta conectada não tem permissão para acessar o Google Drive. '
            'Revogue a sincronia e conecte novamente concedendo o acesso.';
      }
      final message = error.message?.trim();
      if (message != null && message.isNotEmpty) return message;
    }
    if (error is TimeoutException) {
      return 'A sincronização com o Google Drive excedeu o tempo limite.';
    }
    return 'Não foi possível sincronizar os dados com o Google Drive.';
  }

  bool _isInsufficientScope(String? message) {
    return message != null &&
        message.toLowerCase().contains('insufficient authentication scopes');
  }

  String _hash(List<int> bytes) => sha256.convert(bytes).toString();
}
