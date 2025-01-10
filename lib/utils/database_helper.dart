import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'password_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE passwords(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        website TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertPassword(PasswordItem password) async {
    final Database db = await database;
    return await db.insert(
      'passwords',
      password.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PasswordItem>> getAllPasswords() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'passwords',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return PasswordItem.fromMap(maps[i]);
    });
  }

  Future<PasswordItem?> getPassword(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PasswordItem.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePassword(PasswordItem password) async {
    final Database db = await database;
    return await db.update(
      'passwords',
      password.toMap(),
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  Future<int> deletePassword(int id) async {
    final Database db = await database;
    return await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllPasswords() async {
    final Database db = await database;
    await db.delete('passwords');
  }

  Future<void> close() async {
    final Database db = await database;
    db.close();
  }
}
