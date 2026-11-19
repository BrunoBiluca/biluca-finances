abstract class DatabaseFileController {
  Future<String> get databasePath;

  int get databaseVersion;

  Future<void> close();

  Future<void> reopen();
}
