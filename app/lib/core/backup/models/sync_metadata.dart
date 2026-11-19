import 'package:equatable/equatable.dart';

class SyncMetadata extends Equatable {
  final String localHash;
  final String remoteFileId;
  final DateTime remoteModifiedAt;
  final DateTime lastSyncedAt;

  const SyncMetadata({
    required this.localHash,
    required this.remoteFileId,
    required this.remoteModifiedAt,
    required this.lastSyncedAt,
  });

  factory SyncMetadata.fromJson(Map<String, dynamic> json) {
    return SyncMetadata(
      localHash: json['localHash'] as String,
      remoteFileId: json['remoteFileId'] as String,
      remoteModifiedAt: DateTime.parse(json['remoteModifiedAt'] as String).toUtc(),
      lastSyncedAt: DateTime.parse(json['lastSyncedAt'] as String).toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localHash': localHash,
      'remoteFileId': remoteFileId,
      'remoteModifiedAt': remoteModifiedAt.toUtc().toIso8601String(),
      'lastSyncedAt': lastSyncedAt.toUtc().toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [localHash, remoteFileId, remoteModifiedAt, lastSyncedAt];
}
