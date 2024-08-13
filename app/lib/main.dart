import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/services/current_month_service.dart';
import 'package:biluca_financas/accountability/services/import_service.dart';
import 'package:biluca_financas/accountability/services/repo.dart';
import 'package:biluca_financas/app.dart';
import 'package:biluca_financas/sqlite/accountability/accountability_repo.dart';
import 'package:biluca_financas/sqlite/accountability/current_month_service.dart';
import 'package:biluca_financas/sqlite/accountability/import_service.dart';
import 'package:biluca_financas/sqlite/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

GetIt getIt = GetIt.instance;
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  DBProvider.i.init();
  // DBProvider.i.clear(await DBProvider.i.database);

  getIt.registerSingleton<Database>(await DBProvider.i.database);
  getIt.registerFactoryParam<AccountabilityCurrentMonthService, String, void>(
    (month, _) => SQLiteAccontabilityCurrentMonthService(db: getIt<Database>(), month: month),
  );
  getIt.registerFactory<AccountabilityRepo>(() => SQLiteAccountabilityRepo(getIt<Database>()));
  getIt.registerFactory<AccountabilityBloc>(() => AccountabilityBloc(repo: getIt<AccountabilityRepo>()));
  getIt.registerFactory<AccountabilityImportService>(
      () => SQLiteAccountabilityImportService(repo: getIt<AccountabilityRepo>()));
  getIt.registerFactory<FToast>(() => FToast()..init(navigatorKey.currentContext!));

  runApp(const App());
}
