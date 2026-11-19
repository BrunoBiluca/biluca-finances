import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:biluca_financas/core/backup/models/backup_exception.dart';
import 'package:biluca_financas/integrations/google_drive/google_oauth_flow.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

void main() {
  final clientId = ClientId('client-id', 'client-secret');
  const scopes = ['scope-a'];

  Future<void> callBack(
    Uri authorizationUrl, {
    String? code,
    String? error,
    String? state,
  }) async {
    final redirectUrl =
        Uri.parse(authorizationUrl.queryParameters['redirect_uri']!);
    final callbackUri = redirectUrl.replace(queryParameters: {
      'state': state ?? authorizationUrl.queryParameters['state']!,
      if (code != null) 'code': code,
      if (error != null) 'error': error,
    });

    final client = HttpClient();
    try {
      final request = await client.getUrl(callbackUri);
      final response = await request.close();
      await response.drain<void>();
    } finally {
      client.close();
    }
  }

  test('authorizes and exchanges the returned code', () async {
    final tokenRequests = <Request>[];
    final flow = GoogleOAuthLoopbackFlow(
      clientId: clientId,
      scopes: scopes,
      timeout: const Duration(seconds: 5),
      httpClientFactory: () => MockClient((request) async {
        tokenRequests.add(request);
        return Response(
          jsonEncode({
            'access_token': 'access',
            'expires_in': 3600,
            'refresh_token': 'refresh',
            'scope': 'scope-a',
            'token_type': 'Bearer',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
      launchBrowser: (url) async {
        unawaited(callBack(url, code: 'auth-code'));
      },
    );

    final credentials = await flow.run();

    expect(credentials.accessToken.data, 'access');
    expect(credentials.refreshToken, 'refresh');
    expect(credentials.scopes, ['scope-a']);
    expect(tokenRequests, hasLength(1));
    expect(
      tokenRequests.single.url.toString(),
      contains('oauth2.googleapis.com/token'),
    );
    expect(tokenRequests.single.bodyFields['code'], 'auth-code');
    expect(
      tokenRequests.single.bodyFields['redirect_uri'],
      startsWith('http://localhost:'),
    );
  });

  test('opens the browser with the offline consent request', () async {
    Uri? openedUrl;
    final flow = GoogleOAuthLoopbackFlow(
      clientId: clientId,
      scopes: scopes,
      timeout: const Duration(milliseconds: 150),
      httpClientFactory: () => MockClient((_) async => Response('', 500)),
      launchBrowser: (url) async {
        openedUrl = url;
      },
    );

    await expectLater(flow.run(), throwsA(isA<BackupException>()));

    expect(openedUrl, isNotNull);
    expect(openedUrl!.path, '/o/oauth2/v2/auth');
    expect(openedUrl!.queryParameters['client_id'], 'client-id');
    expect(openedUrl!.queryParameters['response_type'], 'code');
    expect(openedUrl!.queryParameters['access_type'], 'offline');
    expect(openedUrl!.queryParameters['prompt'], 'consent');
    expect(openedUrl!.queryParameters['scope'], 'scope-a');
    expect(openedUrl!.queryParameters['state'], isNotEmpty);
  });

  test('fails when the authorization is not completed in time', () async {
    final flow = GoogleOAuthLoopbackFlow(
      clientId: clientId,
      scopes: scopes,
      timeout: const Duration(milliseconds: 100),
      httpClientFactory: () => MockClient((_) async => Response('', 500)),
      launchBrowser: (_) async {},
    );

    await expectLater(
      flow.run(),
      throwsA(isA<BackupException>().having(
        (error) => error.message,
        'message',
        contains('tempo limite'),
      )),
    );
  });

  test('fails when the local server is closed', () async {
    final flow = GoogleOAuthLoopbackFlow(
      clientId: clientId,
      scopes: scopes,
      timeout: const Duration(seconds: 5),
      httpClientFactory: () => MockClient((_) async => Response('', 500)),
      launchBrowser: (_) async {},
    );

    final running = flow.run();
    await flow.listening;
    await flow.cancel();

    await expectLater(
      running,
      throwsA(isA<BackupException>().having(
        (error) => error.message,
        'message',
        contains('cancelada'),
      )),
    );
  });

  test('fails when the permission is denied', () async {
    final flow = GoogleOAuthLoopbackFlow(
      clientId: clientId,
      scopes: scopes,
      timeout: const Duration(seconds: 5),
      httpClientFactory: () => MockClient((_) async => Response('', 500)),
      launchBrowser: (url) async {
        unawaited(callBack(url, error: 'access_denied'));
      },
    );

    await expectLater(
      flow.run(),
      throwsA(isA<BackupException>().having(
        (error) => error.message,
        'message',
        contains('não foi concluída'),
      )),
    );
  });

  test('fails when the callback state does not match', () async {
    final flow = GoogleOAuthLoopbackFlow(
      clientId: clientId,
      scopes: scopes,
      timeout: const Duration(seconds: 5),
      httpClientFactory: () => MockClient((_) async => Response('', 500)),
      launchBrowser: (url) async {
        unawaited(callBack(url, code: 'auth-code', state: 'other-state'));
      },
    );

    await expectLater(
      flow.run(),
      throwsA(isA<BackupException>().having(
        (error) => error.message,
        'message',
        contains('inválida'),
      )),
    );
  });
}
