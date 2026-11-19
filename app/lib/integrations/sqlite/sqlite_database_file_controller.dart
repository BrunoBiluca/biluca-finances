import 'package:biluca_financas/core/backup/services/database_file_controller.dart';
import 'package:biluca_financas/integrations/sqlite/db_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteDatabaseFileController implements DatabaseFileController {
  @override
  Future<String> get databasePath => DBProvider.i.getDBPath();

  @override
  int get databaseVersion => DBProvider.i.schemaVersion;

  @override
  Future<void> close() => DBProvider.i.close();

  @override
  Future<void> reopen() async {
    final database = await DBProvider.i.database;
    final getIt = GetIt.instance;
    if (getIt.isRegistered<Database>()) {
      getIt.unregister<Database>();
    }
    getIt.registerSingleton<Database>(database);
  }
}
