import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NoteDatabase {
  NoteDatabase._();

  static final NoteDatabase noteDatabase = NoteDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE `notes` (
            `id` INTEGER PRIMARY KEY AUTOINCREMENT,
            `title` TEXT NOT NULL,
            `content` TEXT,
            `color` INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute("ALTER TABLE `notes` ADD COLUMN `content` TEXT;");
          } catch (_) {}
        }
      },
    );
  }
}