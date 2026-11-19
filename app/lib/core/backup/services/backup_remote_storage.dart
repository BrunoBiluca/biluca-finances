import 'package:biluca_financas/core/backup/models/remote_backup_file.dart';

abstract class BackupRemoteStorage {
  Future<RemoteBackupFile?> findBackup();

  Future<RemoteBackupFile> uploadBackup(List<int> bytes);

  Future<List<int>> downloadBackup(String fileId);

  void close();
}
