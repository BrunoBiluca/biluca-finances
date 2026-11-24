import 'package:equatable/equatable.dart';

enum AppUpdateRestartOutcome { launched, cancelled, failed }

class AppUpdateRestartResult extends Equatable {
  final AppUpdateRestartOutcome outcome;
  final String? errorMessage;

  const AppUpdateRestartResult(this.outcome, {this.errorMessage});

  bool get launched => outcome == AppUpdateRestartOutcome.launched;

  bool get cancelled => outcome == AppUpdateRestartOutcome.cancelled;

  bool get failed => outcome == AppUpdateRestartOutcome.failed;

  @override
  List<Object?> get props => [outcome, errorMessage];
}
