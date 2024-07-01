import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const userTable = '''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''';

    await db.execute(userTable);
  }

  Future<bool> registerUser(String username, String password) async {
    final db = await instance.database;
    try {
      await db.insert('users', {'username': username, 'password': password});
      return true; // Registration successful
    } catch (e) {
      return false; // Username already exists or other database error
    }
  }

  // Modified authentication function to return userId if successful
  Future<int?> authenticateUser(String username, String password) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (results.isNotEmpty) {
      return results.first['id'] as int; // Return userId
    } else {
      return null; // Authentication failed
    }
  }

  // Helper function to get userId by username (if needed elsewhere)
  Future<int?> getUserIdByUsername(String username) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
    );

    if (results.isNotEmpty) {
      return results.first['id'] as int;
    } else {
      return null; // User not found
    }
  }
}
