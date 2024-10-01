import 'package:logging/logging.dart';

abstract class LoggingListener {
  Future<void> onData(LogRecord record) async {}
}
