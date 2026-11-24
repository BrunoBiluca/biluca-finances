import 'package:biluca_financas/core/app_update/bloc/app_update_bloc.dart';
import 'package:biluca_financas/core/app_update/bloc/app_update_events.dart';

void scheduleStartupAppUpdateCheck(AppUpdateBloc bloc) {
  if (!bloc.service.supported) return;
  bloc.add(const CheckAppUpdate());
}
