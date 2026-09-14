import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

import 'package:biluca_financas/app/routes.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';

class App extends StatelessWidget with WidgetsBindingObserver {
  final Future<void> Function() onAppExit;
  const App(this.onAppExit, {super.key});

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await onAppExit();
    return super.didRequestAppExit();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addObserver(this);
    return MaterialApp.router(
      restorationScopeId: "biluca-financas",
      title: 'Biluca Finanças',
      theme: GetIt.I<ThemeManager>().light,
      darkTheme: GetIt.I<ThemeManager>().dark,
      builder: FToastBuilder(),
      routerConfig: routes(),
    );
  }
}
