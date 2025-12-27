import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._();
  static Database? _database;

  DBHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'office_expense.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            isIncome INTEGER,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertExpense(ExpenseModel expense) async {
    final db = await database;
    await db.insert('expenses', expense.toMap());
  }

  Future<List<ExpenseModel>> getExpensesByMonth(DateTime month) async {
    final db = await database;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final res = await db.query(
      'expenses',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );

    return res.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
