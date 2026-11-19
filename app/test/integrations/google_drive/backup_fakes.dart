import 'package:biluca_financas/core/backup/models/backup_credentials.dart';
import 'package:biluca_financas/core/backup/models/backup_record.dart';
import 'package:biluca_financas/core/backup/models/backup_settings.dart';
import 'package:biluca_financas/core/backup/models/remote_backup_file.dart';
import 'package:biluca_financas/core/backup/services/backup_connector.dart';
import 'package:biluca_financas/core/backup/services/backup_record_store.dart';
import 'package:biluca_financas/core/backup/services/backup_remote_storage.dart';
import 'package:biluca_financas/core/backup/services/database_file_controller.dart';

class FakeDatabaseFileController implements DatabaseFileController {
  final String path;
  final int version;
  int closeCalls = 0;
  int reopenCalls = 0;

  FakeDatabaseFileController({required this.path, this.version = 10});

  @override
  Future<String> get databasePath async => path;

  @override
  int get databaseVersion => version;

  @override
  Future<void> close() async {
    closeCalls++;
  }

  @override
  Future<void> reopen() async {
    reopenCalls++;
  }
}

class InMemoryBackupRecordStore implements BackupRecordStore {
  BackupRecord? record;

  InMemoryBackupRecordStore([this.record]);

  @override
  Future<BackupRecord?> read() async => record;

  @override
  Future<void> write(BackupRecord record) async {
    this.record = record;
  }

  @override
  Future<void> clear() async {
    record = null;
  }
}

class FakeRemoteStorage implements BackupRemoteStorage {
  List<int>? storedBytes;
  DateTime? modifiedAt;
  String fileId = 'remote-file-id';
  int uploads = 0;
  int downloads = 0;
  bool closed = false;

  RemoteBackupFile? get file {
    final bytes = storedBytes;
    if (bytes == null) return null;
    return RemoteBackupFile(id: fileId, modifiedAt: modifiedAt, size: bytes.length);
  }

  @override
  Future<RemoteBackupFile?> findBackup() async => file;

  @override
  Future<RemoteBackupFile> uploadBackup(List<int> bytes) async {
    uploads++;
    storedBytes = List.of(bytes);
    modifiedAt = DateTime.utc(2026, 1, 1).add(Duration(minutes: uploads));
    return file!;
  }

  @override
  Future<List<int>> downloadBackup(String fileId) async {
    downloads++;
    return List.of(storedBytes!);
  }

  @override
  void close() {
    closed = true;
  }
}

class FakeBackupConnector implements BackupConnector {
  final FakeRemoteStorage storage;
  BackupSettings connectResult;
  int openCalls = 0;
  int revokeCalls = 0;

  FakeBackupConnector({
    required this.storage,
    this.connectResult = const BackupSettings(
      configured: true,
      accountEmail: 'pessoa@gmail.com',
    ),
  });

  @override
  Future<BackupSettings> connect() async => connectResult;

  @override
  Future<void> revoke(BackupCredentials credentials) async {
    revokeCalls++;
  }

  @override
  Future<BackupRemoteStorage> openStorage(
    BackupCredentials credentials, {
    void Function(BackupCredentials refreshed)? onCredentialsRefreshed,
  }) async {
    openCalls++;
    return storage;
  }
}

BackupSettings configuredSettings() {
  return BackupSettings(
    configured: true,
    accountEmail: 'pessoa@gmail.com',
    connectedAt: DateTime.utc(2026, 1, 1),
    credentials: BackupCredentials(
      accessToken: 'token',
      tokenType: 'Bearer',
      expiry: DateTime.utc(2026, 1, 1, 1),
      refreshToken: 'refresh',
      scopes: const ['scope'],
    ),
  );
}
