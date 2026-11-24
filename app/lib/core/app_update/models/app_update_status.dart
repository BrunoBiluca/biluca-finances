import 'package:biluca_financas/core/app_update/models/app_version.dart';
import 'package:equatable/equatable.dart';

enum AppUpdateState {
  unsupported,
  checking,
  upToDate,
  updateAvailable,
  downloading,
  readyToInstall,
  failed,
}

enum AppUpdateFailureStep { check, download, restart }

class AppUpdateStatus extends Equatable {
  final AppUpdateState state;
  final AppVersion currentVersion;
  final AppVersion? availableVersion;
  final double? downloadProgress;
  final String? errorMessage;
  final AppUpdateFailureStep? failureStep;

  const AppUpdateStatus({
    required this.state,
    required this.currentVersion,
    this.availableVersion,
    this.downloadProgress,
    this.errorMessage,
    this.failureStep,
  });

  factory AppUpdateStatus.initial({
    required AppVersion currentVersion,
    required bool supported,
  }) {
    return AppUpdateStatus(
      state: supported ? AppUpdateState.checking : AppUpdateState.unsupported,
      currentVersion: currentVersion,
    );
  }

  bool get hasUpdate => availableVersion != null &&
      availableVersion!.isNewerThan(currentVersion);

  bool get canDownload => state == AppUpdateState.updateAvailable ||
      (state == AppUpdateState.failed &&
          failureStep == AppUpdateFailureStep.download);

  bool get isReadyToInstall =>
      state == AppUpdateState.readyToInstall ||
      (state == AppUpdateState.failed &&
          failureStep == AppUpdateFailureStep.restart);

  bool get isSupported => state != AppUpdateState.unsupported;

  bool get showsHomeNotification =>
      state == AppUpdateState.updateAvailable ||
      state == AppUpdateState.downloading ||
      state == AppUpdateState.readyToInstall ||
      (state == AppUpdateState.failed &&
          failureStep != null &&
          failureStep != AppUpdateFailureStep.check);

  AppUpdateStatus copyWith({
    AppUpdateState? state,
    AppVersion? currentVersion,
    AppVersion? availableVersion,
    double? downloadProgress,
    String? errorMessage,
    AppUpdateFailureStep? failureStep,
    bool clearAvailableVersion = false,
    bool clearDownloadProgress = false,
    bool clearError = false,
  }) {
    return AppUpdateStatus(
      state: state ?? this.state,
      currentVersion: currentVersion ?? this.currentVersion,
      availableVersion: clearAvailableVersion
          ? null
          : availableVersion ?? this.availableVersion,
      downloadProgress: clearDownloadProgress
          ? null
          : downloadProgress ?? this.downloadProgress,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      failureStep: clearError ? null : failureStep ?? this.failureStep,
    );
  }

  @override
  List<Object?> get props => [
        state,
        currentVersion,
        availableVersion,
        downloadProgress,
        errorMessage,
        failureStep,
      ];
}
