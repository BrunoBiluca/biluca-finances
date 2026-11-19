import 'dart:io';

import 'package:biluca_financas/integrations/google_drive/google_oauth_credentials.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('google_oauth_test');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  File credentialsFile(Object content) {
    final file = File('${tempDir.path}${Platform.pathSeparator}google_oauth.json');
    file.writeAsStringSync(content is String ? content : content.toString());
    return file;
  }

  test('loads the client id and secret from the configuration file', () async {
    final provider = FileGoogleOAuthCredentialsProvider(
      credentialsFile(
        '{"clientId": "id.apps.googleusercontent.com", "clientSecret": "secret"}',
      ),
    );

    final credentials = await provider.load();

    expect(credentials.clientId, 'id.apps.googleusercontent.com');
    expect(credentials.clientSecret, 'secret');
  });

  test('fails when the configuration file does not exist', () async {
    final provider = FileGoogleOAuthCredentialsProvider(
      File('${tempDir.path}${Platform.pathSeparator}missing.json'),
    );

    await expectLater(
      provider.load(),
      throwsA(isA<GoogleOAuthCredentialsException>()),
    );
  });

  test('fails when the configuration file is invalid', () async {
    final provider = FileGoogleOAuthCredentialsProvider(
      credentialsFile('not a json'),
    );

    await expectLater(
      provider.load(),
      throwsA(isA<GoogleOAuthCredentialsException>()),
    );
  });

  test('fails when the client secret is missing', () async {
    final provider = FileGoogleOAuthCredentialsProvider(
      credentialsFile('{"clientId": "id.apps.googleusercontent.com"}'),
    );

    await expectLater(
      provider.load(),
      throwsA(isA<GoogleOAuthCredentialsException>()),
    );
  });

  group('resolveGoogleOAuthCredentialsFile', () {
    late Directory executableDir;
    late Directory workingDir;

    setUp(() async {
      executableDir = await tempDir.createTemp('executable');
      workingDir = await tempDir.createTemp('working');
    });

    File credentialsAt(Directory directory) {
      final file = File(
        '${directory.path}${Platform.pathSeparator}secrets'
        '${Platform.pathSeparator}google_oauth.json',
      );
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('{"clientId": "id", "clientSecret": "secret"}');
      return file;
    }

    test('uses the configured file path', () {
      final file = resolveGoogleOAuthCredentialsFile(
        environment: const {
          googleOAuthCredentialsFileEnvironmentVariable: '/custom/oauth.json',
        },
        executableDirectory: executableDir.path,
        workingDirectory: workingDir.path,
      );

      expect(file.path, '/custom/oauth.json');
    });

    test('prefers the file next to the executable', () {
      final executableFile = credentialsAt(executableDir);
      credentialsAt(workingDir);

      final file = resolveGoogleOAuthCredentialsFile(
        environment: const {},
        executableDirectory: executableDir.path,
        workingDirectory: workingDir.path,
      );

      expect(file.path, executableFile.path);
    });

    test('falls back to the working directory used by the project', () {
      final workingFile = credentialsAt(workingDir);

      final file = resolveGoogleOAuthCredentialsFile(
        environment: const {},
        executableDirectory: executableDir.path,
        workingDirectory: workingDir.path,
      );

      expect(file.path, workingFile.path);
    });

    test('points to the executable directory when nothing exists', () {
      final file = resolveGoogleOAuthCredentialsFile(
        environment: const {},
        executableDirectory: executableDir.path,
        workingDirectory: workingDir.path,
      );

      expect(
        file.path,
        '${executableDir.path}${Platform.pathSeparator}secrets'
        '${Platform.pathSeparator}google_oauth.json',
      );
    });
  });
}
