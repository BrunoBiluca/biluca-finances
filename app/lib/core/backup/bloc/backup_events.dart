import 'package:biluca_financas/core/backup/models/backup_conflict.dart';
import 'package:equatable/equatable.dart';

abstract class BackupEvent extends Equatable {
  const BackupEvent();

  @override
  List<Object?> get props => [];
}

class LoadBackupStatus extends BackupEvent {
  const LoadBackupStatus();
}

class ConnectBackupAccount extends BackupEvent {
  const ConnectBackupAccount();
}

class RevokeBackupAccount extends BackupEvent {
  const RevokeBackupAccount();
}

class SynchronizeBackupOnOpen extends BackupEvent {
  const SynchronizeBackupOnOpen();
}

class SynchronizeBackupOnClose extends BackupEvent {
  const SynchronizeBackupOnClose();
}

class ResolveBackupConflictEvent extends BackupEvent {
  final BackupConflictResolution resolution;

  const ResolveBackupConflictEvent(this.resolution);

  @override
  List<Object?> get props => [resolution];
}
