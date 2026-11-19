import 'package:biluca_financas/integrations/google_drive/google_drive_backup_queries.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('composes the remote folder path with the profile', () {
    expect(
      backupFolderPath('principal'),
      ['biluca.com', 'Biluca Finanças', 'principal'],
    );
    expect(
      backupFolderPath('desenvolvimento'),
      ['biluca.com', 'Biluca Finanças', 'desenvolvimento'],
    );
    expect(
      backupFolderPath('principal'),
      isNot(backupFolderPath('desenvolvimento')),
    );
  });

  test('searches the top level folder without referencing the drive root', () {
    final query = topLevelFolderQuery('biluca.com');

    expect(query, contains("name = 'biluca.com'"));
    expect(query, contains("mimeType = '$driveFolderMimeType'"));
    expect(query, contains('trashed = false'));
    expect(query, isNot(contains('in parents')));
    expect(query, isNot(contains("'root'")));
  });

  test('searches child folders by the parent created by the application', () {
    final query = childFolderQuery('Biluca Finanças', 'parent-id');

    expect(query, contains("name = 'Biluca Finanças'"));
    expect(query, contains("'parent-id' in parents"));
    expect(query, isNot(contains("'root'")));
  });

  test('searches the backup file inside the profile folder', () {
    final query = backupFileQuery('myDb.db', 'folder-id');

    expect(query, contains("name = 'myDb.db'"));
    expect(query, contains("'folder-id' in parents"));
    expect(query, isNot(contains("'root'")));
  });

  test('escapes quotes in the search terms', () {
    final query = childFolderQuery("perfil'dev", 'folder-id');

    expect(query, contains(r"perfil\'dev"));
  });
}
