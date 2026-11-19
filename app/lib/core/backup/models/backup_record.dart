import 'package:biluca_financas/core/backup/models/backup_settings.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:biluca_financas/core/backup/models/sync_metadata.dart';
import 'package:equatable/equatable.dart';

class BackupRecord extends Equatable {
  final BackupSettings settings;
  final SyncMetadata? metadata;
  final DateTime? lastSyncAt;
  final int databaseVersion;

  const BackupRecord({
    required this.settings,
    required this.databaseVersion,
    this.metadata,
    this.lastSyncAt,
  });

  factory BackupRecord.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    return BackupRecord(
      settings: BackupSettings.fromJson(
        json['settings'] as Map<String, dynamic>? ?? const {},
      ),
      metadata: metadata is Map<String, dynamic>
          ? SyncMetadata.fromJson(metadata)
          : null,
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String).toUtc(),
      databaseVersion: json['databaseVersion'] as int? ?? 0,
    );
  }

  BackupStatus get status {
    if (!settings.configured) {
      return BackupStatus.notConfigured(databaseVersion: databaseVersion);
    }
    return BackupStatus(
      state: lastSyncAt == null
          ? BackupSyncState.configured
          : BackupSyncState.synchronized,
      isConfigured: true,
      databaseVersion: databaseVersion,
      accountEmail: settings.accountEmail,
      lastSyncAt: lastSyncAt,
    );
  }

  BackupRecord copyWith({
    BackupSettings? settings,
    SyncMetadata? metadata,
    DateTime? lastSyncAt,
    int? databaseVersion,
  }) {
    return BackupRecord(
      settings: settings ?? this.settings,
      metadata: metadata ?? this.metadata,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      databaseVersion: databaseVersion ?? this.databaseVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settings': settings.toJson(),
      if (metadata != null) 'metadata': metadata!.toJson(),
      if (lastSyncAt != null) 'lastSyncAt': lastSyncAt!.toUtc().toIso8601String(),
      'databaseVersion': databaseVersion,
    };
  }

  @override
  List<Object?> get props => [settings, metadata, lastSyncAt, databaseVersion];
}
