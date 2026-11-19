import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:biluca_financas/core/backup/models/backup_exception.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

typedef BrowserLauncher = Future<void> Function(Uri url);

class GoogleOAuthLoopbackFlow {
  static const Duration defaultTimeout = Duration(minutes: 2);
  static final Uri _authorizationEndpoint =
      Uri.parse('https://accounts.google.com/o/oauth2/v2/auth');

  final ClientId clientId;
  final List<String> scopes;
  final BrowserLauncher launchBrowser;
  final Client Function() httpClientFactory;
  final Duration timeout;

  HttpServer? _server;
  final Completer<void> _listening = Completer<void>();

  GoogleOAuthLoopbackFlow({
    required this.clientId,
    required this.scopes,
    required this.launchBrowser,
    Client Function()? httpClientFactory,
    this.timeout = defaultTimeout,
  }) : httpClientFactory = httpClientFactory ?? Client.new;

  Future<void> get listening => _listening.future;

  Future<AccessCredentials> run() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server = server;
    if (!_listening.isCompleted) _listening.complete();

    final redirectUrl = 'http://localhost:${server.port}';
    final state = _randomState();

    try {
      await launchBrowser(_authorizationUri(redirectUrl, state));

      final request = await server.first.timeout(timeout);
      final code = await _readCode(request, state);

      final client = httpClientFactory();
      try {
        return await obtainAccessCredentialsViaCodeExchange(
          client,
          clientId,
          code,
          redirectUrl: redirectUrl,
        );
      } finally {
        client.close();
      }
    } on TimeoutException {
      throw const BackupException(
        'A autorização do Google Drive não foi concluída dentro do tempo limite.',
      );
    } on StateError {
      throw const BackupException('A autorização do Google Drive foi cancelada.');
    } finally {
      await _closeServer(server);
    }
  }

  Future<void> cancel() => _closeServer(_server);

  Uri _authorizationUri(String redirectUrl, String state) {
    return _authorizationEndpoint.replace(queryParameters: {
      'client_id': clientId.identifier,
      'redirect_uri': redirectUrl,
      'response_type': 'code',
      'scope': scopes.join(' '),
      'access_type': 'offline',
      'prompt': 'consent',
      'state': state,
    });
  }

  Future<String> _readCode(HttpRequest request, String state) async {
    if (request.method != 'GET') {
      await _respond(request, 'Resposta de autorização inválida.');
      throw const BackupException(
        'A resposta de autorização do Google Drive é inválida.',
      );
    }

    final query = request.uri.queryParameters;
    if (query['error'] != null) {
      await _respond(request, 'A autorização não foi concluída.');
      throw const BackupException(
        'A autorização do Google Drive não foi concluída.',
      );
    }
    if (query['state'] != state) {
      await _respond(request, 'Resposta de autorização inválida.');
      throw const BackupException(
        'A resposta de autorização do Google Drive é inválida.',
      );
    }

    final code = query['code'];
    if (code == null || code.isEmpty) {
      await _respond(request, 'Resposta de autorização inválida.');
      throw const BackupException(
        'A resposta de autorização do Google Drive é inválida.',
      );
    }

    await _respond(request, 'Autorização concluída. Você pode fechar esta janela.');
    return code;
  }

  Future<void> _respond(HttpRequest request, String message) async {
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType('text', 'html', charset: 'utf-8')
      ..write('<html><body><h3>$message</h3></body></html>');
    await request.response.close();
  }

  Future<void> _closeServer(HttpServer? server) async {
    _server = null;
    if (server == null) return;
    await server.close(force: true);
  }

  String _randomState() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
