import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:equatable/equatable.dart';

abstract class BackupState extends Equatable {
  const BackupState();

  @override
  List<Object?> get props => [];
}

class BackupInitial extends BackupState {
  const BackupInitial();
}

class BackupStatusChanged extends BackupState {
  final BackupStatus status;

  const BackupStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}
