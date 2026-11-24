import 'dart:io' as io;
import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqflite_logger.dart';

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

    final baseFactory = databaseFactoryFfi;

    if (kReleaseMode) {
      databaseFactory = baseFactory;
      return;
    }

    // SqfliteDatabaseFactoryLogger is experimental; it is intentionally used
    // only in debug builds to log SQL statements.
    // ignore: experimental_member_use
    databaseFactory = SqfliteDatabaseFactoryLogger(
      baseFactory,
      options: SqfliteLoggerOptions(
        type: SqfliteDatabaseFactoryLoggerType.all,
        log: (SqfliteLoggerEvent event) {
          if (event is SqfliteLoggerSqlEvent) {
            log.info('SQL: ${event.sql}');
            if (event.arguments != null) {
              log.info('ARGUMENTS: ${event.arguments}');
            }
          } else if (event is SqfliteLoggerBatchEvent) {
            for (var operation in event.operations) {
              log.info('BATCH SQL: ${operation.sql}');
            }
          }
        },
      ),
    );
  }

  Future<Database> open() async {
    try {
      return await databaseFactory.openDatabase(
        await getDBPath(),
        options: OpenDatabaseOptions(
          version: migrationsSQL.length,
          onCreate: (db, version) async {
            log.info("Creating tables at version $version...");
            await execute(db, migrationsSQL);
            log.info("Tables created");
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            log.info("Updating tables...");
            log.info("Current version: $oldVersion");
            await execute(db, migrationsSQL.sublist(oldVersion));
            log.info("Tables updated to version $newVersion");
          },
        ),
      );
    } catch (error, stackTrace) {
      log.severe("Failed to open the database.", error, stackTrace);
      rethrow;
    }
  }

  int get schemaVersion => migrationsSQL.length;

  Future<void> close() async {
    final db = _database;
    _database = null;
    await db?.close();
  }

  Future<String> getDBPath() async {
    var dirPath = io.Directory.current.path;
    if (kReleaseMode) {
      try {
        dirPath = (await getApplicationDocumentsDirectory()).path;
      } catch (e) {
        log.warning(
          "Failed to resolve the documents directory; using the current directory.",
          e,
        );
      }
    }

    String dbPath = p.join(dirPath, "Biluca Finanças", "myDb.db");
    log.info("Database path: $dbPath");
    return dbPath;
  }

  Future execute(Database db, List<String> migrationsSQL) async {
    log.info("Executing...");
    for (final migration in migrationsSQL) {
      log.info(migration);
      try {
        await db.execute(migration);
      } on DatabaseException catch (error) {
        if (!_isAlreadyApplied(migration, error)) rethrow;

        final statement = migration.trim().split('\n').first;
        log.warning("Migration already applied to the database, ignoring: $statement");
      }
    }
  }

  /// A migration is considered already applied when the database already has
  /// its effect (an existing column or table). This happens when the version
  /// recorded in the database lags behind the real schema, for example in a
  /// database restored from a backup. Ignoring only these cases allows the
  /// version update to finish without blocking the application from opening.
  bool _isAlreadyApplied(String migration, DatabaseException error) {
    final statement = migration.trimLeft().toUpperCase();
    final message = error.toString().toLowerCase();

    if (statement.startsWith("ALTER TABLE")) {
      return message.contains("duplicate column name");
    }

    if (statement.startsWith("CREATE TABLE")) {
      return message.contains("already exists");
    }

    return false;
  }

  Future clear(Database db) async {
    log.info("Cleaning up the database...");
    await databaseFactory.deleteDatabase(db.path);
    _database = null;
    log.info("Database cleaned");
  }

  final migrationsSQL = [
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
    ''',
    '''
    ALTER TABLE accountability_identifications ADD COLUMN icon TEXT
    ''',
    '''
    UPDATE accountability_identifications
    SET icon = '{"code":58123,"fontFamily":"MaterialIcons","fontPackage":null}'
    where icon is null
    ''',
    '''
    ALTER TABLE accountability ADD COLUMN description_alt TEXT
    ''',
    '''
    ALTER TABLE accountability_identifications ADD COLUMN type TEXT
    ''',
    '''
    UPDATE accountability_identifications
    SET type = 'expense'
    where type is null
    ''',
    '''
    ALTER TABLE accountability_identifications ADD COLUMN parent_id TEXT
    ''',
    '''
    ALTER TABLE accountability_identifications ADD COLUMN discontinued INTEGER NOT NULL DEFAULT 0
    ''',
    '''
    ALTER TABLE accountability_identifications ADD COLUMN description_detail TEXT NOT NULL DEFAULT ''
    '''
  ];
}
