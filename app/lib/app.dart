import 'dart:io';
import 'dart:ui';

import 'package:biluca_financas/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      theme: darkTheme,
      darkTheme: darkTheme,
      builder: FToastBuilder(),
      home: const Home(),
      navigatorKey: navigatorKey,
    );
  }
}

var darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF14161D),
    outline: Color(0xFF232428)
  ),
  typography: Typography.material2021(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFE8E6E3),
      secondary: Color(0xFF737373)
    ),
  ),
  scaffoldBackgroundColor: const Color(0xFF000000),
);
