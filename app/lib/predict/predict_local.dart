import 'dart:io';
import 'dart:io' as io;

import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class PredictLocal {
  var log = GetIt.I<LoggerManager>().instance("Execução do servidor de predição");
  final String host = "http://localhost:5666/";

  void init() async {
    log.info("Iniciando servidor de predição...");

    var path = Directory.current.path;
    if (kReleaseMode && io.Platform.isWindows) {
      path += "/data/flutter_assets";
    }
    path += "/assets/gen/predict_win/";
    if(io.Platform.isLinux){
      path += "predict_win";
    }
    else if(io.Platform.isWindows){
      path += "predict_win.exe";
    }
    log.info("Predict server path: $path");
    Process serverProcess;
    try {
      serverProcess = await Process.start(path, []);
    } on ProcessException catch (e, s) {
      log.severe("Servidor de predição não foi inicializado com sucesso.", e, s);
      log.severe(e.toString());
      return;
    }
    serverProcess.stdout.forEach((msg) => log.info(String.fromCharCodes(msg)));
    serverProcess.stderr.forEach((msg) => log.info(String.fromCharCodes(msg)));

    int? exitCode;
    serverProcess.exitCode.then((v) {
      exitCode = v;
    });
    await Future.delayed(const Duration(seconds: 1));
    log.info("Servidor de predição iniciado com sucesso. HOST: $host/predict");

    if (exitCode != null) {
      log.severe("Servidor de predição parou de executar. Exit code: $exitCode");
    }
  }

  void terminate() async {
    log.info("Encerrando servidor de predição...");
    if(io.Platform.isWindows){
    await Process.run('taskkill', ['/F', '/IM', "predict_win.exe"]);
    }
    else if(io.Platform.isLinux){
      await Process.run('killall', ["predict_win"]);
    }
    log.info("Servidor de predição encerrado com sucesso");
  }
}
