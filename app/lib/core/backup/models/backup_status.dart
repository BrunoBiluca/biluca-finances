import 'package:biluca_financas/core/backup/models/backup_conflict.dart';
import 'package:equatable/equatable.dart';

enum BackupSyncState {
  notConfigured,
  connecting,
  configured,
  synchronizing,
  synchronized,
  failed,
  conflict,
}

class BackupStatus extends Equatable {
  final BackupSyncState state;
  final bool isConfigured;
  final int databaseVersion;
  final String? accountEmail;
  final String? profile;
  final DateTime? lastSyncAt;
  final String? errorMessage;
  final BackupConflict? conflict;

  const BackupStatus({
    required this.state,
    required this.isConfigured,
    required this.databaseVersion,
    this.accountEmail,
    this.profile,
    this.lastSyncAt,
    this.errorMessage,
    this.conflict,
  });

  factory BackupStatus.notConfigured({required int databaseVersion}) {
    return BackupStatus(
      state: BackupSyncState.notConfigured,
      isConfigured: false,
      databaseVersion: databaseVersion,
    );
  }

  factory BackupStatus.fromJson(Map<String, dynamic> json) {
    return BackupStatus(
      state: BackupSyncState.values.firstWhere(
        (value) => value.name == json['state'],
        orElse: () => BackupSyncState.notConfigured,
      ),
      isConfigured: json['isConfigured'] as bool? ?? false,
      databaseVersion: json['databaseVersion'] as int? ?? 0,
      accountEmail: json['accountEmail'] as String?,
      profile: json['profile'] as String?,
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String).toUtc(),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  bool get isBusy =>
      state == BackupSyncState.connecting || state == BackupSyncState.synchronizing;

  bool get hasConflict => state == BackupSyncState.conflict;

  BackupStatus copyWith({
    BackupSyncState? state,
    bool? isConfigured,
    int? databaseVersion,
    String? accountEmail,
    String? profile,
    DateTime? lastSyncAt,
    String? errorMessage,
    BackupConflict? conflict,
    bool clearError = false,
    bool clearConflict = false,
  }) {
    return BackupStatus(
      state: state ?? this.state,
      isConfigured: isConfigured ?? this.isConfigured,
      databaseVersion: databaseVersion ?? this.databaseVersion,
      accountEmail: accountEmail ?? this.accountEmail,
      profile: profile ?? this.profile,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      conflict: clearConflict ? null : conflict ?? this.conflict,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state.name,
      'isConfigured': isConfigured,
      'databaseVersion': databaseVersion,
      if (accountEmail != null) 'accountEmail': accountEmail,
      if (profile != null) 'profile': profile,
      if (lastSyncAt != null) 'lastSyncAt': lastSyncAt!.toUtc().toIso8601String(),
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  @override
  List<Object?> get props => [
        state,
        isConfigured,
        databaseVersion,
        accountEmail,
        profile,
        lastSyncAt,
        errorMessage,
        conflict,
      ];
}
