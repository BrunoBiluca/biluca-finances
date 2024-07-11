import 'package:biluca_financas/app.dart';
import 'package:biluca_financas/sqlite/db_provider.dart';
import 'package:flutter/material.dart';

void main() async {
  DBProvider.i.init();
  // DBProvider.i.clear(await DBProvider.i.database);
  runApp(const App());
}
