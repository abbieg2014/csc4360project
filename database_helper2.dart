import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'transaction_utils.dart'; // Import for TransactionItem and BudgetCategory

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'transactions.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        try{
        await _createTransactionsTable(db); 
        await _createBudgetCategoriesTable(db); 
        } catch (e) {
        print('Error creating tables: $e');
        }
      },
       onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {  // Check for previous version
          await _createBudgetCategoriesTable(db);
        }
        // Add more upgrade logic for future versions if needed
      },
    );
  }

  Future<void> _createTransactionsTable(Database db) async {
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

  Future<void> _createBudgetCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE budget_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        amount REAL
      )
    ''');
  }

  Future<int> insertTransaction(TransactionItem transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionItem>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');

    return List.generate(maps.length, (i) {
      return TransactionItem(
        id: maps[i]['id'],
        name: maps[i]['name'],
        amount: maps[i]['amount'],
        type: maps[i]['type'],
        dateAdded: DateTime.parse(maps[i]['dateAdded']),
      );
    });
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTransaction(TransactionItem transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Budget Category Methods
  Future<int> addBudgetCategory(String name, double amount) async {
    final db = await database;
    return await db.insert('budget_categories', {'name': name, 'amount': amount});
  }

  Future<List<BudgetCategory>> getBudgetCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('budget_categories');

    return List.generate(maps.length, (i) {
      return BudgetCategory(
        id: maps[i]['id'],
        name: maps[i]['name'],
        amount: maps[i]['amount'],
      );
    });
  }
}
