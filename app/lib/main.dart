import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/logging/console_listener.dart';
import 'package:biluca_financas/common/logging/file_listener.dart';
import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:biluca_financas/predict/predict_local.dart';
import 'package:biluca_financas/reports/accountability_month_service.dart';
import 'package:biluca_financas/accountability/services/import_service.dart';
import 'package:biluca_financas/accountability/services/repo.dart';
import 'package:biluca_financas/app.dart';
import 'package:biluca_financas/predict/predict_service.dart';
import 'package:biluca_financas/sqlite/accountability/accountability_repo.dart';
import 'package:biluca_financas/sqlite/accountability/accountability_month_service.dart';
import 'package:biluca_financas/sqlite/accountability/import_service.dart';
import 'package:biluca_financas/sqlite/db_provider.dart';
import 'package:biluca_financas/theme_manager.dart';
import 'package:biluca_financas/themes/dark.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

GetIt getIt = GetIt.instance;
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  initializeDateFormatting('pt_BR');
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  await initilizeAccountabilityIdentifications();

  runApp(const App());
}

Future<void> setupDependencies() async {
  getIt.registerSingleton<LoggerManager>(LoggerManager()
    ..init([
      ConsoleLoggingListener(),
      FileLoggingListener(),
    ]));

  DBProvider.i.init();

  getIt.registerSingleton<Database>(await DBProvider.i.database);
  getIt.registerFactoryParam<AccountabilityMonthService, DateTime, void>(
    (month, _) => SQLiteAccontabilityMonthService(db: getIt<Database>(), month: month),
  );
  getIt.registerFactory<AccountabilityRepo>(
    () => SQLiteAccountabilityRepo(getIt<Database>()),
  );
  getIt.registerFactory<AccountabilityBloc>(
    () => AccountabilityBloc(repo: getIt<AccountabilityRepo>()),
  );
  getIt.registerFactory<PredictService>(
    () => PredictService(Client(), getIt<AccountabilityRepo>()),
  );
  getIt.registerFactory<AccountabilityImportService>(
    () => SQLiteAccountabilityImportService(repo: getIt<AccountabilityRepo>(), predictService: getIt<PredictService>()),
  );
  getIt.registerFactory<FToast>(
    () => FToast()..init(navigatorKey.currentContext!),
  );
  
  getIt.registerSingleton<ThemeManager>(
    ThemeManager()
      ..add(DarkTheme())
      ..setDark("dark")
      ..setLight("dark"),
  );

  getIt.registerSingleton<PredictLocal>(PredictLocal()..init());
}

Future<void> initilizeAccountabilityIdentifications() async {
  var repo = getIt<AccountabilityRepo>();
  var identificationsCount = (await repo.getIdentifications()).length;
  if (identificationsCount > 0) return;

  var startIdentifications = [
    AccountabilityIdentification("Supermercado", Colors.blueAccent),
    AccountabilityIdentification("Apoio causa", Colors.grey),
    AccountabilityIdentification("Lanche", Colors.greenAccent),
    AccountabilityIdentification("Rendimento", Colors.yellowAccent),
    AccountabilityIdentification("Outros", const Color.fromARGB(255, 104, 102, 102)),
    AccountabilityIdentification("Saúde", const Color.fromARGB(255, 15, 105, 179)),
    AccountabilityIdentification("Lazer", Colors.redAccent),
    AccountabilityIdentification("Streaming", const Color.fromARGB(255, 180, 57, 48)),
    AccountabilityIdentification("Compras", Colors.brown),
    AccountabilityIdentification("Games", const Color.fromARGB(255, 131, 58, 31)),
    AccountabilityIdentification("Almoço", const Color.fromARGB(255, 68, 156, 113)),
    AccountabilityIdentification("Contas", Colors.pinkAccent),
    AccountabilityIdentification("Educação", Colors.pink),
    AccountabilityIdentification("Salário", Colors.yellow),
    AccountabilityIdentification("Empréstimo", const Color.fromARGB(255, 17, 168, 168)),
    AccountabilityIdentification("Padaria", const Color.fromARGB(255, 105, 240, 112)),
    AccountabilityIdentification("Transporte", const Color.fromARGB(255, 141, 28, 122)),
    AccountabilityIdentification("Extra salário", const Color.fromARGB(255, 228, 217, 66)),
  ];

  for (var i in startIdentifications) {
    getIt<AccountabilityRepo>().addIdentification(i);
  }
}
