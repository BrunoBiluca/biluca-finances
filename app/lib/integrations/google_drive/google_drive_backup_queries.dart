const String rootBackupFolderName = 'biluca.com';
const String backupFolderName = 'Biluca Finanças';
const String driveFolderMimeType = 'application/vnd.google-apps.folder';

List<String> backupFolderPath(String profile) {
  return [rootBackupFolderName, backupFolderName, profile];
}

String topLevelFolderQuery(String name) {
  return "name = '${_escape(name)}' and mimeType = '$driveFolderMimeType' "
      'and trashed = false';
}

String childFolderQuery(String name, String parentId) {
  return "name = '${_escape(name)}' and mimeType = '$driveFolderMimeType' "
      "and '${_escape(parentId)}' in parents and trashed = false";
}

String backupFileQuery(String name, String parentId) {
  return "name = '${_escape(name)}' and '${_escape(parentId)}' in parents "
      'and trashed = false';
}

String _escape(String value) => value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
