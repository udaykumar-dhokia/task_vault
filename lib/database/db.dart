import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_vault/database/theme.dart';
import 'package:task_vault/handler/task.dart';

class DBHelper {
  DBHelper._();

  static final DBHelper instance = DBHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        date TEXT,
        priority TEXT
      )
    ''');

    await db.execute('''
    CREATE TABLE theme(
      themeColor TEXT,
      switchValue TEXT
    )
''');
  }

  Future<int> themeChange(uiTheme theme) async {
    Database db = await database;
    return await db.insert('theme', theme.toMap());
  }

  Future<int> insertTask(Task task) async {
    Database db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<uiTheme>> getTheme() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('theme');
    return List.generate(maps.length, (index) {
      return uiTheme(
        switchValue: maps[index]['switchValue'],
        themeColor: maps[index]['themeColor'],
      );
    });
  }

  Future<int> updateTheme(uiTheme theme) async {
    Database db = await database;
    return await db.update('theme', theme.toMap());
  }

  Future<List<Task>> getTasks() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (index) {
      return Task(
        id: maps[index]['id'],
        title: maps[index]['title'],
        description: maps[index]['description'],
        date: maps[index]['date'],
        priority: maps[index]['priority'],
      );
    });
  }

  Future<int> updateTask(Task task) async {
    Database db = await database;
    return await db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
