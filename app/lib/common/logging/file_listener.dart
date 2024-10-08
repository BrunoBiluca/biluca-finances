import 'dart:io';

import 'package:biluca_financas/common/logging/logging_listener.dart';
import 'package:logging/logging.dart';

class FileLoggingListener extends LoggingListener {
  @override
  Future<void> onData(LogRecord record) async {
    var f = File("logs.txt");

    var logstr = "${record.time} [${record.level.name}] : ${record.message}";

    if (record.error != null) {
      logstr += " - ${record.error}";
    }

    if (record.stackTrace != null) {
      logstr += " - ${record.stackTrace}";
    }

    await f.writeAsString('$logstr\n', mode: FileMode.append);
  }
}
