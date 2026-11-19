import 'package:biluca_financas/core/backup/models/backup_credentials.dart';
import 'package:biluca_financas/core/backup/models/backup_settings.dart';
import 'package:biluca_financas/core/backup/services/backup_remote_storage.dart';

abstract class BackupConnector {
  Future<BackupSettings> connect();

  Future<void> revoke(BackupCredentials credentials);

  Future<BackupRemoteStorage> openStorage(
    BackupCredentials credentials, {
    void Function(BackupCredentials refreshed)? onCredentialsRefreshed,
  });
}
