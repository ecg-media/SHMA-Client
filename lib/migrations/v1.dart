
import 'package:shma_client/migrations/migration.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// First version of the databse.
class V1Migration implements DBMigration {
  @override
  void onCreate(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS Connection');

    // cretae playlists
    batch.execute('''CREATE TABLE Connection (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      mode INTEGER UNIQUE,
      host TEXT NULL,
      port INTEGER
    )''');
  }

  @override
  void onUpdate(Batch batch) {
    // nothing to update since first version.
  }
}