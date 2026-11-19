import 'package:equatable/equatable.dart';

enum BackupConflictResolution { keepLocal, useRemote }

class BackupConflict extends Equatable {
  final DateTime localModifiedAt;
  final DateTime remoteModifiedAt;

  const BackupConflict({
    required this.localModifiedAt,
    required this.remoteModifiedAt,
  });

  @override
  List<Object?> get props => [localModifiedAt, remoteModifiedAt];
}
