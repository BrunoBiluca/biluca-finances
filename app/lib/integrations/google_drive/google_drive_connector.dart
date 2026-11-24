import 'package:biluca_financas/core/backup/models/backup_credentials.dart';
import 'package:biluca_financas/core/backup/models/backup_exception.dart';
import 'package:biluca_financas/core/backup/models/backup_settings.dart';
import 'package:biluca_financas/core/backup/services/backup_connector.dart';
import 'package:biluca_financas/core/backup/services/backup_remote_storage.dart';
import 'package:biluca_financas/integrations/google_drive/backup_profile.dart';
import 'package:biluca_financas/integrations/google_drive/google_drive_credentials_mapper.dart';
import 'package:biluca_financas/integrations/google_drive/google_drive_remote_storage.dart';
import 'package:biluca_financas/integrations/google_drive/google_oauth_credentials.dart';
import 'package:biluca_financas/integrations/google_drive/google_oauth_flow.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/oauth2/v2.dart' as oauth2;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

typedef GoogleDrivePrompt = void Function(String url);

void ensureDriveScopeGranted(List<String> grantedScopes) {
  if (grantedScopes.contains(GoogleDriveConnector.driveScope)) return;
  throw const BackupException(
    'O Google não concedeu permissão de acesso ao Google Drive. '
    'Verifique se o escopo https://www.googleapis.com/auth/drive.file está '
    'habilitado na tela de consentimento OAuth do projeto e conecte novamente.',
  );
}

class GoogleDriveConnector implements BackupConnector {
  static const String driveScope = drive.DriveApi.driveFileScope;
  static const String userInfoEmailScope =
      'https://www.googleapis.com/auth/userinfo.email';
  static const List<String> scopes = [driveScope, userInfoEmailScope];
  static final Uri _revokeUri = Uri.parse('https://oauth2.googleapis.com/revoke');

  final GoogleOAuthCredentialsProvider credentialsProvider;
  final GoogleDrivePrompt prompt;
  final Client Function() httpClientFactory;
  final String backupFileName;
  final String profile;
  final Duration authorizationTimeout;
  final Logger _log;

  GoogleDriveConnector({
    required this.credentialsProvider,
    required this.backupFileName,
    required this.prompt,
    this.profile = defaultBackupProfile,
    this.authorizationTimeout = GoogleOAuthLoopbackFlow.defaultTimeout,
    Client Function()? httpClientFactory,
    Logger? logger,
  })  : httpClientFactory = httpClientFactory ?? Client.new,
        _log = logger ?? Logger('GoogleDriveConnector');

  @override
  Future<BackupSettings> connect() async {
    final clientCredentials = await _loadClientCredentials();
    final clientId = ClientId(
      clientCredentials.clientId,
      clientCredentials.clientSecret,
    );

    final flow = GoogleOAuthLoopbackFlow(
      clientId: clientId,
      scopes: scopes,
      timeout: authorizationTimeout,
      httpClientFactory: httpClientFactory,
      launchBrowser: (url) async {
        prompt(url.toString());
      },
    );

    final credentials = await flow.run();
    _log.info('Requested scopes: ${scopes.join(', ')}');
    _log.info('Granted scopes: ${credentials.scopes.join(', ')}');
    ensureDriveScopeGranted(credentials.scopes);

    final authClient = autoRefreshingClient(
      clientId,
      credentials,
      httpClientFactory(),
    );
    try {
      final email = await _fetchAccountEmail(authClient);
      return BackupSettings(
        configured: true,
        accountEmail: email,
        connectedAt: DateTime.now().toUtc(),
        credentials: toBackupCredentials(authClient.credentials),
      );
    } finally {
      authClient.close();
    }
  }

  @override
  Future<void> revoke(BackupCredentials credentials) async {
    final token = credentials.refreshToken ?? credentials.accessToken;
    final client = httpClientFactory();
    try {
      final response = await client.post(
        _revokeUri,
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'token': token},
      );
      if (response.statusCode >= 400) {
        throw const BackupException(
          'Não foi possível revogar o acesso ao Google Drive.',
        );
      }
    } finally {
      client.close();
    }
  }

  @override
  Future<BackupRemoteStorage> openStorage(
    BackupCredentials credentials, {
    void Function(BackupCredentials refreshed)? onCredentialsRefreshed,
  }) async {
    final clientCredentials = await _loadClientCredentials();
    final authClient = autoRefreshingClient(
      ClientId(clientCredentials.clientId, clientCredentials.clientSecret),
      toAccessCredentials(credentials),
      httpClientFactory(),
    );

    return GoogleDriveRemoteStorage(
      api: drive.DriveApi(authClient),
      authClient: authClient,
      backupFileName: backupFileName,
      profile: profile,
      onCredentialsRefreshed: onCredentialsRefreshed,
    );
  }

  Future<GoogleOAuthClientCredentials> _loadClientCredentials() async {
    try {
      return await credentialsProvider.load();
    } on GoogleOAuthCredentialsException catch (error) {
      throw BackupException(error.message);
    }
  }

  Future<String?> _fetchAccountEmail(AutoRefreshingAuthClient authClient) async {
    try {
      final userInfo = await oauth2.Oauth2Api(authClient).userinfo.get();
      return userInfo.email;
    } catch (_) {
      return null;
    }
  }
}
