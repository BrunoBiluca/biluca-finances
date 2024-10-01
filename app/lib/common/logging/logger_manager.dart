import 'package:biluca_financas/common/logging/logging_listener.dart';
import 'package:logging/logging.dart';

class LoggerManager {

  void init(List<LoggingListener> listeners) {
    Logger.root.level = Level.ALL;

    for (var l in listeners) {
      Logger.root.onRecord.listen(l.onData);
    }
  }

  Logger instance(String name) {
    return Logger(name);
  }
}
