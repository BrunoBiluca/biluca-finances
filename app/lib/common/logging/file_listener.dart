import 'dart:io';

import 'package:biluca_financas/common/logging/logging_listener.dart';
import 'package:logging/logging.dart';

class FileLoggingListener extends LoggingListener {
  FileLoggingListener({this.path = "logs.txt"});

  final String path;

  Future<void> _queue = Future.value();

  @override
  Future<void> onData(LogRecord record) {
    final content = "${_format(record)}\n";

    // Chained writes: opening the file in FileMode.append simultaneously
    // makes concurrent records overwrite each other.
    final write = _queue.then((_) => _append(content));
    _queue = write.then<void>((_) {}, onError: (error, stackTrace) {});
    return write;
  }

  Future<void> _append(String content) async {
    await File(path).writeAsString(content, mode: FileMode.append, flush: true);
  }

  String _format(LogRecord record) {
    var logstr = "${record.time} [${record.level.name}] : ${record.message}";

    if (record.error != null) {
      logstr += " - ${record.error}";
    }

    if (record.stackTrace != null) {
      logstr += " - ${record.stackTrace}";
    }

    return logstr;
  }
}
