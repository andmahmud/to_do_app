import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            isCompleted INTEGER DEFAULT 0,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Insert a new task
  Future<int> insertTask(String title) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('tasks', {
      'title': title,
      'isCompleted': 0, // Default value
      'createdAt': now,
    });
  }

  // Fetch all tasks
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'createdAt DESC');
  }

  // Update a task (only title and isCompleted)
  Future<int> updateTask(int id, String title, int isCompleted) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'title': title, 'isCompleted': isCompleted},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a task
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Close database
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
