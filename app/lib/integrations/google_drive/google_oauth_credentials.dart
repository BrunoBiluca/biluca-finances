import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const String googleOAuthCredentialsFileEnvironmentVariable =
    'BILUCA_GOOGLE_OAUTH_FILE';

class GoogleOAuthClientCredentials {
  final String clientId;
  final String clientSecret;

  const GoogleOAuthClientCredentials({
    required this.clientId,
    required this.clientSecret,
  });
}

class GoogleOAuthCredentialsException implements Exception {
  final String message;

  const GoogleOAuthCredentialsException(this.message);

  @override
  String toString() => message;
}

abstract class GoogleOAuthCredentialsProvider {
  Future<GoogleOAuthClientCredentials> load();
}

class FileGoogleOAuthCredentialsProvider implements GoogleOAuthCredentialsProvider {
  final File file;

  const FileGoogleOAuthCredentialsProvider(this.file);

  @override
  Future<GoogleOAuthClientCredentials> load() async {
    if (!await file.exists()) {
      throw GoogleOAuthCredentialsException(
        'Arquivo de credenciais do Google não encontrado em ${file.path}.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(await file.readAsString());
    } on FormatException {
      throw const GoogleOAuthCredentialsException(
        'O arquivo de credenciais do Google não é um JSON válido.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const GoogleOAuthCredentialsException(
        'O arquivo de credenciais do Google não é um JSON válido.',
      );
    }

    final clientId = decoded['clientId'];
    final clientSecret = decoded['clientSecret'];
    if (clientId is! String ||
        clientSecret is! String ||
        clientId.isEmpty ||
        clientSecret.isEmpty) {
      throw const GoogleOAuthCredentialsException(
        'O arquivo de credenciais do Google precisa conter clientId e clientSecret.',
      );
    }

    return GoogleOAuthClientCredentials(
      clientId: clientId,
      clientSecret: clientSecret,
    );
  }
}

File resolveGoogleOAuthCredentialsFile({
  Map<String, String>? environment,
  String? executableDirectory,
  String? workingDirectory,
}) {
  final env = environment ?? Platform.environment;
  final override = env[googleOAuthCredentialsFileEnvironmentVariable];
  if (override != null && override.isNotEmpty) return File(override);

  final exeDirectory =
      executableDirectory ?? p.dirname(Platform.resolvedExecutable);
  final currentDirectory = workingDirectory ?? Directory.current.path;

  final candidates = [
    File(p.join(exeDirectory, 'secrets', 'google_oauth.json')),
    File(p.join(currentDirectory, 'secrets', 'google_oauth.json')),
  ];
  for (final candidate in candidates) {
    if (candidate.existsSync()) return candidate;
  }
  return candidates.first;
}
