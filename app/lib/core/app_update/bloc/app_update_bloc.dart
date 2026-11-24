import 'package:biluca_financas/core/app_update/bloc/app_update_events.dart';
import 'package:biluca_financas/core/app_update/models/app_update_status.dart';
import 'package:biluca_financas/core/app_update/services/app_update_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppUpdateBloc extends Bloc<AppUpdateEvent, AppUpdateStatus> {
  final AppUpdateService service;

  AppUpdateBloc({required this.service})
      : super(AppUpdateStatus.initial(
          currentVersion: service.currentVersion,
          supported: service.supported,
        )) {
    on<CheckAppUpdate>((event, emit) async {
      if (!service.supported) return;
      final current = state;
      final checking = current.copyWith(
        state: AppUpdateState.checking,
        clearError: true,
        clearDownloadProgress: true,
      );
      if (checking != current) emit(checking);
      try {
        emit(await service.checkForUpdate());
      } catch (error) {
        emit(_failed(current, AppUpdateFailureStep.check, error));
      }
    });

    on<DownloadAppUpdate>((event, emit) async {
      final current = state;
      if (!current.canDownload) return;
      emit(current.copyWith(
        state: AppUpdateState.downloading,
        downloadProgress: 0,
        clearError: true,
      ));
      try {
        emit(await service.downloadInstaller(
          onProgress: (progress) => emit(state.copyWith(
            downloadProgress: progress,
            clearDownloadProgress: progress == null,
          )),
        ));
      } catch (error) {
        emit(_failed(state, AppUpdateFailureStep.download, error));
      }
    });

    on<InstallAppUpdate>((event, emit) async {
      final current = state;
      if (!current.isReadyToInstall) return;
      try {
        final result = await service.restartWithInstaller();
        if (result.failed) {
          emit(_failed(
            current,
            AppUpdateFailureStep.restart,
            result.errorMessage ?? 'Não foi possível abrir o instalador.',
          ));
        }
      } catch (error) {
        emit(_failed(current, AppUpdateFailureStep.restart, error));
      }
    });
  }

  AppUpdateStatus _failed(
    AppUpdateStatus current,
    AppUpdateFailureStep step,
    Object error,
  ) {
    return current.copyWith(
      state: AppUpdateState.failed,
      failureStep: step,
      errorMessage: error.toString(),
      clearDownloadProgress: true,
    );
  }
}
