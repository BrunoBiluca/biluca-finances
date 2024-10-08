import 'dart:io';

import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class PredictLocal {
  var log = GetIt.I<LoggerManager>().instance("Execução do servidor de predição");

  void init() async {
    log.info("Iniciando servidor de predição...");

    var path = Directory.current.path;
    if (kReleaseMode) {
      path += "/data/flutter_assets";
    }
    path += "/assets/gen/predict_win/predict_win.exe";

    Process serverProcess;
    try {
      serverProcess = await Process.start(path, []);
    } on ProcessException catch (e, s) {
      log.severe("Servidor de predição não foi inicializado com sucesso.", e, s);
      return;
    }
    serverProcess.stdout.forEach((msg) => log.info(String.fromCharCodes(msg)));
    serverProcess.stderr.forEach((msg) => log.info(String.fromCharCodes(msg)));

    int? exitCode;
    serverProcess.exitCode.then((v) {
      exitCode = v;
    });
    await Future.delayed(const Duration(seconds: 1));
    log.info("Servidor de predição iniciado com sucesso. HOST: http://localhost:5000/predict");

    if (exitCode != null) {
      log.severe("Servidor de predição parou de executar. Exit code: $exitCode");
    }
  }

  void terminate() async {
    log.info("Encerrando servidor de predição...");
    await Process.run('taskkill', ['/F', '/IM', "predict_win.exe"]);
    log.info("Servidor de predição encerrado com sucesso");
  }
}
