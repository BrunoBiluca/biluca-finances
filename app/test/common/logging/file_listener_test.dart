import 'dart:io';

import 'package:biluca_financas/common/logging/file_listener.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late String logPath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('biluca_logs');
    logPath = p.join(tempDir.path, 'logs.txt');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test("grava os registros concorrentes sem perder nem truncar linhas",
      () async {
    final listener = FileLoggingListener(path: logPath);
    final messages = List.generate(
      50,
      (index) => "mensagem $index com um texto longo o suficiente para "
          "ocupar várias posições no arquivo",
    );

    await Future.wait(messages.map(
      (message) => listener.onData(LogRecord(Level.INFO, message, "teste")),
    ));

    final lines = await File(logPath).readAsLines();
    expect(lines, hasLength(messages.length));
    for (final message in messages) {
      expect(
        lines.where((line) => line.contains(message)),
        hasLength(1),
        reason: "registro '$message' deveria aparecer uma única vez",
      );
    }
  });

  test("anexa ao conteúdo existente e inclui erro e stack trace", () async {
    await File(logPath).writeAsString("linha anterior\n");
    final listener = FileLoggingListener(path: logPath);

    await listener.onData(
      LogRecord(
        Level.SEVERE,
        "falha ao abrir",
        "teste",
        "DatabaseException",
        StackTrace.fromString("#0 origem"),
      ),
    );

    final lines = await File(logPath).readAsLines();
    expect(lines, hasLength(2));
    expect(lines.first, "linha anterior");
    expect(lines.last, contains("falha ao abrir"));
    expect(lines.last, contains("DatabaseException"));
    expect(lines.last, contains("#0 origem"));
  });
}
