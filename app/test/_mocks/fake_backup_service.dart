import 'package:biluca_financas/core/backup/models/backup_conflict.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:biluca_financas/core/backup/services/backup_service.dart';

class FakeBackupService implements BackupService {
  BackupStatus status;
  List<BackupStatus> syncResults = [];
  Object? connectError;
  Object? syncError;

  int connectCalls = 0;
  int revokeCalls = 0;
  int syncOnOpenCalls = 0;
  int syncOnCloseCalls = 0;
  final List<BackupConflictResolution> resolutions = [];

  FakeBackupService(this.status);

  @override
  Future<bool> isConfigured() async => status.isConfigured;

  @override
  Future<BackupStatus> getStatus() async => status;

  @override
  Future<BackupStatus> connect() async {
    connectCalls++;
    if (connectError != null) throw connectError!;
    status = BackupStatus(
      state: BackupSyncState.configured,
      isConfigured: true,
      databaseVersion: status.databaseVersion,
      accountEmail: 'conta@gmail.com',
    );
    return status;
  }

  @override
  Future<BackupStatus> revoke() async {
    revokeCalls++;
    status = BackupStatus.notConfigured(databaseVersion: status.databaseVersion);
    return status;
  }

  @override
  Future<BackupStatus> syncOnOpen() async {
    syncOnOpenCalls++;
    return _sync();
  }

  @override
  Future<BackupStatus> syncOnClose() async {
    syncOnCloseCalls++;
    return _sync();
  }

  @override
  Future<BackupStatus> resolveConflict(BackupConflictResolution resolution) async {
    resolutions.add(resolution);
    return _sync();
  }

  Future<BackupStatus> _sync() async {
    if (syncError != null) throw syncError!;
    if (syncResults.isNotEmpty) {
      status = syncResults.length > 1 ? syncResults.removeAt(0) : syncResults.first;
    }
    return status;
  }
}
