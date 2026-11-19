import 'package:biluca_financas/core/backup/bloc/backup_events.dart';
import 'package:biluca_financas/core/backup/bloc/backup_states.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:biluca_financas/core/backup/services/backup_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final BackupService service;

  BackupBloc({required this.service}) : super(const BackupInitial()) {
    on<LoadBackupStatus>((event, emit) async {
      emit(BackupStatusChanged(await _currentStatus()));
    });

    on<ConnectBackupAccount>((event, emit) async {
      final current = await _currentStatus();
      emit(BackupStatusChanged(
        current.copyWith(state: BackupSyncState.connecting, clearError: true),
      ));
      try {
        emit(BackupStatusChanged(await service.connect()));
      } catch (error) {
        emit(BackupStatusChanged(_failed(current, error)));
      }
    });

    on<RevokeBackupAccount>((event, emit) async {
      final current = await _currentStatus();
      emit(BackupStatusChanged(
        current.copyWith(state: BackupSyncState.connecting, clearError: true),
      ));
      try {
        emit(BackupStatusChanged(await service.revoke()));
      } catch (error) {
        emit(BackupStatusChanged(_failed(current, error)));
      }
    });

    on<SynchronizeBackupOnOpen>((event, emit) => _synchronize(
          emit,
          service.syncOnOpen,
        ));

    on<SynchronizeBackupOnClose>((event, emit) => _synchronize(
          emit,
          service.syncOnClose,
        ));

    on<ResolveBackupConflictEvent>((event, emit) => _synchronize(
          emit,
          () => service.resolveConflict(event.resolution),
        ));
  }

  Future<void> _synchronize(
    Emitter<BackupState> emit,
    Future<BackupStatus> Function() action,
  ) async {
    final current = await _currentStatus();
    emit(BackupStatusChanged(current.copyWith(
      state: BackupSyncState.synchronizing,
      clearError: true,
      clearConflict: true,
    )));
    try {
      emit(BackupStatusChanged(await action()));
    } catch (error) {
      emit(BackupStatusChanged(_failed(current, error)));
    }
  }

  BackupStatus _failed(BackupStatus current, Object error) {
    return current.copyWith(
      state: BackupSyncState.failed,
      errorMessage: error.toString(),
      clearConflict: true,
    );
  }

  Future<BackupStatus> _currentStatus() async {
    final current = state;
    if (current is BackupStatusChanged) return current.status;
    return service.getStatus();
  }
}
