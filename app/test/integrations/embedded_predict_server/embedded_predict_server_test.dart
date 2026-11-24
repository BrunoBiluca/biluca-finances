import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:biluca_financas/integrations/embedded_server/embedded_predict_server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<LoggerManager>(LoggerManager());
  });

  test("isRunning is false before the server is started", () {
    final server = EmbeddedPredictServer();

    expect(server.isRunning, isFalse);
  });

  test("terminate does not throw when no process was started", () async {
    final server = EmbeddedPredictServer();

    await expectLater(server.terminate(), completes);

    expect(server.isRunning, isFalse);
  });
}
