import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

import 'package:biluca_financas/app/routes.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';

class App extends StatelessWidget with WidgetsBindingObserver {
  final Future<bool> Function() onAppExit;
  final ThemeMode themeMode;
  const App(this.onAppExit, {super.key, this.themeMode = ThemeMode.system});

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    final shouldExit = await onAppExit();
    return shouldExit ? AppExitResponse.exit : AppExitResponse.cancel;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addObserver(this);
    return MaterialApp.router(
      restorationScopeId: "biluca-financas",
      title: 'Biluca Finanças',
      theme: GetIt.I<ThemeManager>().light,
      darkTheme: GetIt.I<ThemeManager>().dark,
      themeMode: themeMode,
      builder: FToastBuilder(),
      routerConfig: routes(),
    );
  }
}
