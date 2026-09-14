import 'package:biluca_financas/init_database.dart';
import 'package:biluca_financas/app/app.dart';
import 'package:biluca_financas/setup.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  initializeDateFormatting('pt_BR');
  WidgetsFlutterBinding.ensureInitialized();

  await setup();

  await initDatabase();

  runApp(const App());
}
