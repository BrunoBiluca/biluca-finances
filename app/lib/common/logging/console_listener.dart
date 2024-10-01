import 'package:biluca_financas/common/logging/logging_listener.dart';
import 'package:logging/logging.dart';

class ConsoleLoggingListener extends LoggingListener {
  @override
  Future<void> onData(LogRecord record) async {
    print('${record.level.name}: ${record.time}: ${record.message}');
    super.onData(record);
  }
}
