import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "tidytask.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL,
        deadline INTEGER,
        priority TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        tags TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE task_tags (
        task_id TEXT,
        tag_id TEXT,
        PRIMARY KEY (task_id, tag_id),
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_tasks_priority ON tasks(priority)');
    await db.execute('CREATE INDEX idx_tasks_deadline ON tasks(deadline)');
    await db.execute('CREATE INDEX idx_tasks_completed ON tasks(is_completed)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}
}
