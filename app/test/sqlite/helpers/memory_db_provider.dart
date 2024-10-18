import 'package:biluca_financas/sqlite/db_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MemoryDBProvider extends DBProvider {
  MemoryDBProvider();
  static final MemoryDBProvider instance = MemoryDBProvider();
  static MemoryDBProvider get i => instance;

  @override
  Future<String> getDBPath() async {
    return inMemoryDatabasePath;
  }
}
