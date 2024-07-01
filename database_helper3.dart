import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'finance_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budget_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        date_added TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE investment_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        date_added TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future<int> addUser(String username, String password) async {
    final db = await database;
    return await db.insert('users', {
      'username': username,
      'password': password,
    });
  }

  Future<int> addBudgetItem(int userId, double amount, String type, String description, String dateAdded) async {
    final db = await database;
    return await db.insert('budget_items', {
      'user_id': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'date_added': dateAdded,
    });
  }

  Future<int> addInvestmentItem(int userId, double amount, String type, String description, String dateAdded) async {
    final db = await database;
    return await db.insert('investment_items', {
      'user_id': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'date_added': dateAdded,
    });
  }

  Future<List<Map<String, dynamic>>> getBudgetItems(int userId) async {
    final db = await database;
    return await db.query(
      'budget_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getInvestmentItems(int userId) async {
    final db = await database;
    return await db.query(
      'investment_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteBudgetItem(int id) async {
    final db = await database;
    return await db.delete(
      'budget_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteInvestmentItem(int id) async {
    final db = await database;
    return await db.delete(
      'investment_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateBudgetItem(int id, double amount, String type, String description, String dateAdded) async {
    final db = await database;
    return await db.update(
      'budget_items',
      {
        'amount': amount,
        'type': type,
        'description': description,
        'date_added': dateAdded,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateInvestmentItem(int id, double amount, String type, String description, String dateAdded) async {
    final db = await database;
    return await db.update(
      'investment_items',
      {
        'amount': amount,
        'type': type,
        'description': description,
        'date_added': dateAdded,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class BudgetItem {
  final int id;
  final int userId;
  final double amount;
  final String type;
  final String description;
  final DateTime dateAdded;

  BudgetItem({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'date_added': dateAdded.toIso8601String(),
    };
  }
}

class InvestmentItem {
  final int id;
  final int userId;
  final double amount;
  final String type;
  final String description;
  final DateTime dateAdded;

  InvestmentItem({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'date_added': dateAdded.toIso8601String(),
    };
  }
}
