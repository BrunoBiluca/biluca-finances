import 'package:equatable/equatable.dart';

abstract class AppUpdateEvent extends Equatable {
  const AppUpdateEvent();

  @override
  List<Object?> get props => [];
}

class CheckAppUpdate extends AppUpdateEvent {
  const CheckAppUpdate();
}

class DownloadAppUpdate extends AppUpdateEvent {
  const DownloadAppUpdate();
}

class InstallAppUpdate extends AppUpdateEvent {
  const InstallAppUpdate();
}
