import 'package:biluca_financas/core/backup/models/backup_credentials.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

BackupCredentials toBackupCredentials(AccessCredentials credentials) {
  final token = credentials.accessToken;
  return BackupCredentials(
    accessToken: token.data,
    tokenType: token.type,
    expiry: token.expiry,
    refreshToken: credentials.refreshToken,
    scopes: credentials.scopes,
  );
}

AccessCredentials toAccessCredentials(BackupCredentials credentials) {
  return AccessCredentials(
    AccessToken(credentials.tokenType, credentials.accessToken, credentials.expiry),
    credentials.refreshToken,
    credentials.scopes,
  );
}
