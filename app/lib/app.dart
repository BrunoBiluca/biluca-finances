import 'dart:io';
import 'dart:ui';

import 'package:biluca_financas/main.dart';
import 'package:biluca_financas/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

import 'home.dart';

class App extends StatelessWidget with WidgetsBindingObserver {
  const App({super.key});

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    print("Encerrando servidor de predição...");
    await Process.run('taskkill', ['/F', '/IM', "predict_win.exe"]);
    print("Servidor de predição encerrado com sucesso");
    return super.didRequestAppExit();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addObserver(this);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: GetIt.I<ThemeManager>().light,
      darkTheme: GetIt.I<ThemeManager>().dark,
      builder: FToastBuilder(),
      home: const Home(),
      navigatorKey: navigatorKey,
    );
  }
}