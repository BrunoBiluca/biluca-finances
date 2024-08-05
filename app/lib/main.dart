import 'package:biluca_financas/accountability/current_month_service.dart';
import 'package:biluca_financas/app.dart';
import 'package:biluca_financas/sqlite/current_month_service.dart';
import 'package:biluca_financas/sqlite/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

GetIt getIt = GetIt.instance;

void main() async {
  DBProvider.i.init();
  // DBProvider.i.clear(await DBProvider.i.database);

  getIt.registerSingleton<Database>(await DBProvider.i.database);
  getIt.registerFactoryParam<AccountabilityCurrentMonthService, String, void>(
    (month, _) => SQLiteAccontabilityCurrentMonthService(db: getIt<Database>(), month: month),
  );

  runApp(const App());
}
