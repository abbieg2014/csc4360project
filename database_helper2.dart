import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'homepage.dart';  // Import your TransactionItem model

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'transactions.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        amount REAL,
        type TEXT,
        dateAdded TEXT
      )
    ''');
  }

  Future<int> insertTransaction(TransactionItem transaction) async {
    Database db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionItem>> getTransactions() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) {
      return TransactionItem(
        name: maps[i]['name'],
        amount: maps[i]['amount'],
        type: maps[i]['type'],
        dateAdded: DateTime.parse(maps[i]['dateAdded']),
      );
    });
  }

  Future<void> deleteTransaction(int id) async {
    Database db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTransaction(TransactionItem transaction) async {
    Database db = await database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }
}

extension on TransactionItem {
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'type': type,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }
}
