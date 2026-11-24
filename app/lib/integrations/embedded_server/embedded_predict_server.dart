import 'dart:io';
import 'dart:io' as io;

import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class EmbeddedPredictServer {
  final log = GetIt.I<LoggerManager>().instance("PredictServer");
  final String host = "http://localhost:5666/";

  Process? _process;

  bool get isRunning => _process != null;

  Future<void> init() async {
    log.info("Starting the prediction server...");

    var path = Directory.current.path;
    if (kReleaseMode) {
      path += "/data/flutter_assets";
    }
    path += "/assets/gen/predict_win/";
    if (io.Platform.isLinux) {
      path += "predict_win";
    } else if (io.Platform.isWindows) {
      path += "predict_win.exe";
    }
    log.info("Predict server path: $path");

    Process serverProcess;
    try {
      serverProcess = await Process.start(path, []);
    } on ProcessException catch (e, s) {
      log.severe("Prediction server failed to start.", e, s);
      return;
    }

    _process = serverProcess;
    serverProcess.stdout.forEach((msg) => log.info(String.fromCharCodes(msg)));
    serverProcess.stderr.forEach((msg) => log.info(String.fromCharCodes(msg)));

    serverProcess.exitCode.then((code) {
      log.info("Prediction server exited with code $code");
      if (identical(_process, serverProcess)) {
        _process = null;
      }
    });

    await Future.delayed(const Duration(seconds: 1));
    log.info("Prediction server started. HOST: $host/predict");
  }

  Future<void> terminate() async {
    log.info("Stopping the prediction server...");

    final process = _process;
    if (process == null) {
      log.warning("No prediction server process to terminate.");
      return;
    }

    process.kill();
    await process.exitCode;
    _process = null;

    log.info("Prediction server stopped.");
  }
}
