import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:biluca_financas/common/logging/logging_listener.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';

class TestListener extends Mock implements LoggingListener {}

void main() {
  test("deve retornar um instância de Logger", () {
    registerFallbackValue(LogRecord(Level.INFO, "test", "Teste"));
    var listener = TestListener();
    when(() => listener.onData(any())).thenAnswer((_) => Future.value());
    var loggerManager = LoggerManager()..init([listener]);
    var log = loggerManager.instance("test");
    expect(log, isNotNull);

    log.info("Teste");

    verify(() => listener.onData(any())).called(1);
  });
}
