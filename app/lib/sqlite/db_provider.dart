import 'dart:io' as io;
import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBProvider {
  DBProvider();
  static final DBProvider instance = DBProvider();
  static DBProvider get i => instance;

  Database? _database;
  Logger log = GetIt.I<LoggerManager>().instance("DBProvider");

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await open();
    return _database!;
  }

  void init() {
    if (io.Platform.isWindows || io.Platform.isLinux) sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Future<Database> open() async {
    return await databaseFactory.openDatabase(
      await getDBPath(),
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) => create(db, initialSQL),
        onUpgrade: (db, oldVersion, newVersion) async {
          log.info("Tabelas atualizadas");
          // await migrate(migrationsSQL);
        },
      ),
    );
  }

  Future<String> getDBPath() async {
    var dir = io.Directory.current;
    if (kReleaseMode) {
      dir = await getApplicationDocumentsDirectory();
    }

    String dbPath = p.join(dir.path, "Biluca Finanças", "myDb.db");
    log.info("Caminho para o banco de dados: $dbPath");
    return dbPath;
  }

  Future create(Database db, List<String> migrationsSQL) async {
    log.info("Migrando tabelas...");
    for (final migration in migrationsSQL) {
      await db.execute(migration);
    }
    log.info("Migrations concluídas");
  }

  Future clear(Database db) async {
    log.info("Limpando banco de dados...");
    await databaseFactory.deleteDatabase(db.path);
    _database = null;
    log.info("Banco de dados limpo");
  }

  final initialSQL = [
    '''
    CREATE TABLE accountability (
        id INTEGER PRIMARY KEY,
        description TEXT,
        value REAL,
        createdAt TEXT,
        insertedAt TEXT,
        updatedAt TEXT,
        identification_id TEXT,

        CONSTRAINT fk_identification,
        FOREIGN KEY (identification_id) 
        REFERENCES accountability_identifications(id)
        ON DELETE SET NULL
    )
    ''',
    '''
    CREATE TABLE accountability_identifications (
      id TEXT PRIMARY KEY,
      description TEXT,
      color INTEGER,
      insertedAt TEXT,
      updatedAt TEXT
    )
    '''
  ];

  final migrationsSQL = [];
}
