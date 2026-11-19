import 'package:biluca_financas/core/backup/models/backup_credentials.dart';
import 'package:biluca_financas/core/backup/models/backup_exception.dart';
import 'package:biluca_financas/integrations/google_drive/google_drive_connector.dart';
import 'package:biluca_financas/integrations/google_drive/google_drive_remote_storage.dart';
import 'package:biluca_financas/integrations/google_drive/google_oauth_credentials.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

class _StubCredentialsProvider implements GoogleOAuthCredentialsProvider {
  @override
  Future<GoogleOAuthClientCredentials> load() async {
    return const GoogleOAuthClientCredentials(
      clientId: 'client-id',
      clientSecret: 'client-secret',
    );
  }
}

void main() {
  final credentials = BackupCredentials(
    accessToken: 'access',
    tokenType: 'Bearer',
    expiry: DateTime.utc(2026, 1, 1),
    refreshToken: 'refresh-token',
    scopes: const ['scope'],
  );

  GoogleDriveConnector buildConnector(
    Client client, {
    void Function(String url)? prompt,
  }) {
    return GoogleDriveConnector(
      credentialsProvider: _StubCredentialsProvider(),
      backupFileName: 'myDb.db',
      prompt: prompt ?? (_) {},
      httpClientFactory: () => client,
    );
  }

  test('revokes the access using the refresh token', () async {
    final requests = <Request>[];
    final connector = buildConnector(
      MockClient((request) async {
        requests.add(request);
        return Response('', 200);
      }),
    );

    await connector.revoke(credentials);

    expect(requests, hasLength(1));
    expect(requests.single.url.toString(), 'https://oauth2.googleapis.com/revoke');
    expect(requests.single.body, contains('refresh-token'));
  });

  test('reports a failure when the revoke request is rejected', () async {
    final connector = buildConnector(
      MockClient((request) async => Response('', 400)),
    );

    await expectLater(
      connector.revoke(credentials),
      throwsA(isA<BackupException>()),
    );
  });

  test('opens a Google Drive storage for the configured credentials', () async {
    final connector = buildConnector(
      MockClient((request) async => Response('', 200)),
    );

    final storage = await connector.openStorage(credentials);

    expect(storage, isA<GoogleDriveRemoteStorage>());
    storage.close();
  });

  group('ensureDriveScopeGranted', () {
    test('accepts the credentials that include the Drive scope', () {
      expect(
        () => ensureDriveScopeGranted([
          GoogleDriveConnector.driveScope,
          GoogleDriveConnector.userInfoEmailScope,
        ]),
        returnsNormally,
      );
    });

    test('rejects credentials without the Drive scope', () {
      expect(
        () => ensureDriveScopeGranted([
          GoogleDriveConnector.userInfoEmailScope,
        ]),
        throwsA(isA<BackupException>().having(
          (error) => error.message,
          'message',
          contains('não concedeu permissão de acesso ao Google Drive'),
        )),
      );
    });
  });
}
