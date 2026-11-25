import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:biluca_financas/app/routes.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/app/themes/theme_mode_controller.dart';

class App extends StatefulWidget {
  final Future<bool> Function() onAppExit;
  const App(this.onAppExit, {super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  // A single router instance keeps the navigation state when the theme changes.
  late final GoRouter _router = routes();
  late final ThemeModeController _themeMode = GetIt.I<ThemeModeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _themeMode.addListener(_onThemeModeChanged);
  }

  @override
  void dispose() {
    _themeMode.removeListener(_onThemeModeChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onThemeModeChanged() => setState(() {});

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    final shouldExit = await widget.onAppExit();
    return shouldExit ? AppExitResponse.exit : AppExitResponse.cancel;
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = GetIt.I<ThemeManager>();
    return MaterialApp.router(
      restorationScopeId: "biluca-financas",
      title: 'Biluca Finanças',
      theme: themeManager.light,
      darkTheme: themeManager.dark,
      themeMode: _themeMode.value,
      builder: FToastBuilder(),
      routerConfig: _router,
    );
  }
}
