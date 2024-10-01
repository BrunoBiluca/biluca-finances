import 'dart:io';

import 'package:biluca_financas/common/logging/logging_listener.dart';
import 'package:logging/logging.dart';

class FileLoggingListener extends LoggingListener {
  @override
  Future<void> onData(LogRecord record) async {
    var f = File("logs.txt");
    await f.writeAsString("${record.time}: ${record.message}\n", mode: FileMode.append);
  }
}