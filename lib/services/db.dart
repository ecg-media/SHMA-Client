import 'dart:io';

import 'package:path/path.dart';
import 'package:shma_client/migrations/migration.dart';
import 'package:shma_client/migrations/v1.dart';
import 'package:shma_client/models/connection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

/// Service that handles the databse of the client.
class DBService {
  /// Instance of the service.
  static final DBService _instance = DBService._();

  /// the databse name on device.
  final String _dbName = 'wekode_shma_client.db';

  final String _tConnection = 'connection';

  // Actual version number.
  final int _actualVersion = 1;

  /// The databse instance.
  Database? _db;

  /// Returns the singleton instance of the [DBService].
  static DBService getInstance() {
    return _instance;
  }

  /// Holds all information for the migrations of the versions of the databse.
  final Map<int, DBMigration Function()> _migrations = {
    1: () => V1Migration(),
  };

  /// Private constructor of the service.
  DBService._();

  /// Returns the database.
  ///
  /// If the database is not initialized and opened it will be done before returning the insatnce of the databse.
  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  /// Configures the databse.
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Is called on creation of database.
  Future _onCreate(Database db, int version) async {
    if (!_migrations.containsKey(version)) {
      return;
    }
    var batch = db.batch();
    _migrations[version]!().onCreate(batch);
    await batch.commit();
  }

  /// Is called on upgrading the database.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    var batch = db.batch();
    for (var actualVersion = oldVersion + 1;
        actualVersion <= newVersion;
        actualVersion++) {
      _migrations[actualVersion]!().onUpdate(batch);
    }
    await batch.commit();
  }

  /// Inits the databse and opens the databse.
  Future<Database> _initDB() async {
    databaseFactory = databaseFactoryFfi;
    final Directory dbPath = await getApplicationDocumentsDirectory();
  
    final path = join(dbPath.path, _dbName);

    try {
      await Directory(dbPath.path).create(recursive: true);
    } catch (_) {}

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _actualVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
        onDowngrade: onDatabaseDowngradeDelete,
      ),
    );
  }

  Future<Connection> loadConfig() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tConnection,
      limit: 1,
    );

    if (maps.isEmpty) {
      return Connection();
    }

    var result = maps.first;
    return Connection(
        id: result['id'],
        host: result['host'],
        mode: _getConnectionMode(result['mode']),
        port: result['port']);
  }

  ConnectionMode _getConnectionMode(String value) {
    switch (value) {
      case "lan":
        return ConnectionMode.lan;
      case "hotspot":
        return ConnectionMode.hotspot;
      default:
        return ConnectionMode.lan;
    }
  }

  Future<void> deleteConfig(Connection config) async {
    final db = await _database;
    await db.delete(
      _tConnection,
    );
  }

  /// creates a new entry.
  Future createConfig(Connection config) async {
    final db = await _database;
    await db.insert(
      _tConnection,
      config.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
