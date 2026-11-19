import 'dart:typed_data';

import 'package:biluca_financas/core/backup/models/backup_credentials.dart';
import 'package:biluca_financas/core/backup/models/remote_backup_file.dart';
import 'package:biluca_financas/core/backup/services/backup_remote_storage.dart';
import 'package:biluca_financas/integrations/google_drive/backup_profile.dart';
import 'package:biluca_financas/integrations/google_drive/google_drive_backup_queries.dart';
import 'package:biluca_financas/integrations/google_drive/google_drive_credentials_mapper.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

class GoogleDriveRemoteStorage implements BackupRemoteStorage {
  static const String _fields = 'files(id,name,size,modifiedTime)';

  final drive.DriveApi api;
  final AutoRefreshingAuthClient authClient;
  final String backupFileName;
  final String profile;
  final void Function(BackupCredentials refreshed)? onCredentialsRefreshed;

  String? _syncFolderId;

  GoogleDriveRemoteStorage({
    required this.api,
    required this.authClient,
    required this.backupFileName,
    this.profile = defaultBackupProfile,
    this.onCredentialsRefreshed,
  });

  @override
  Future<RemoteBackupFile?> findBackup() async {
    final folderId = await _ensureSyncFolder();
    final file = await _findBackupFile(folderId);
    if (file == null) return null;
    return _toRemoteBackupFile(file);
  }

  @override
  Future<RemoteBackupFile> uploadBackup(List<int> bytes) async {
    final folderId = await _ensureSyncFolder();
    final existing = await _findBackupFile(folderId);
    final media = drive.Media(Stream.value(bytes), bytes.length);

    final drive.File result;
    if (existing == null) {
      result = await api.files.create(
        drive.File(name: backupFileName, parents: [folderId]),
        uploadMedia: media,
        $fields: 'id,name,size,modifiedTime',
      );
    } else {
      result = await api.files.update(
        drive.File(),
        existing.id!,
        uploadMedia: media,
        $fields: 'id,name,size,modifiedTime',
      );
    }

    _notifyCredentialsRefreshed();
    return _toRemoteBackupFile(result);
  }

  @override
  Future<List<int>> downloadBackup(String fileId) async {
    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final builder = BytesBuilder(copy: false);
    await for (final chunk in media.stream) {
      builder.add(chunk);
    }
    _notifyCredentialsRefreshed();
    return builder.takeBytes();
  }

  @override
  void close() {
    authClient.close();
  }

  Future<String> _ensureSyncFolder() async {
    final cached = _syncFolderId;
    if (cached != null) return cached;

    String? parentId;
    for (final name in backupFolderPath(profile)) {
      final existing = parentId == null
          ? await _findTopLevelFolder(name)
          : await _findChildFolder(name, parentId);
      parentId = existing ?? await _createFolder(name, parentId);
    }

    _syncFolderId = parentId!;
    return parentId;
  }

  Future<drive.File?> _findBackupFile(String folderId) async {
    return _search(backupFileQuery(backupFileName, folderId));
  }

  Future<String?> _findTopLevelFolder(String name) async {
    final file = await _search(topLevelFolderQuery(name));
    return file?.id;
  }

  Future<String?> _findChildFolder(String name, String parentId) async {
    final file = await _search(childFolderQuery(name, parentId));
    return file?.id;
  }

  Future<drive.File?> _search(String query) async {
    final result = await api.files.list(
      q: query,
      spaces: 'drive',
      $fields: _fields,
    );
    _notifyCredentialsRefreshed();

    final files = result.files;
    if (files == null || files.isEmpty) return null;
    return files.first;
  }

  Future<String> _createFolder(String name, String? parentId) async {
    final folder = await api.files.create(
      drive.File(
        name: name,
        mimeType: driveFolderMimeType,
        parents: parentId == null ? null : [parentId],
      ),
      $fields: 'id,name,size,modifiedTime',
    );
    _notifyCredentialsRefreshed();
    return folder.id!;
  }

  RemoteBackupFile _toRemoteBackupFile(drive.File file) {
    final size = file.size;
    return RemoteBackupFile(
      id: file.id!,
      modifiedAt: file.modifiedTime?.toUtc(),
      size: size == null ? null : int.tryParse(size),
    );
  }

  void _notifyCredentialsRefreshed() {
    onCredentialsRefreshed?.call(toBackupCredentials(authClient.credentials));
  }
}
