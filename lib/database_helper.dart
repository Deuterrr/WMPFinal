import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'enrollment.db');

    print("Database path: $path");

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE loginstatus (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        credit INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE enrollments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER,
        subject_id INTEGER,
        FOREIGN KEY (student_id) REFERENCES students (id),
        FOREIGN KEY (subject_id) REFERENCES subjects (id)
      )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // insert subjects
    await db.insert('subjects', {'name': 'Math 101', 'description': 'Basic Mathematics', 'credit': 3});
    await db.insert('subjects', {'name': 'Math 102', 'description': 'Calculus I', 'credit': 3});
    await db.insert('subjects', {'name': 'Math 103', 'description': 'Calculus II', 'credit': 3});
    await db.insert('subjects', {'name': 'Math 104', 'description': 'Statistics', 'credit': 3});
    await db.insert('subjects', {'name': 'Math 105', 'description': 'Linear Algebra', 'credit': 3});
    await db.insert('subjects', {'name': 'Physics 101', 'description': 'Introduction to Physics', 'credit': 3});
    await db.insert('subjects', {'name': 'Physics 102', 'description': 'Thermodynamics I', 'credit': 3});
    await db.insert('subjects', {'name': 'Physics 103', 'description': 'Classical Mechanics', 'credit': 3});
    await db.insert('subjects', {'name': 'Chemistry 101', 'description': 'Basics of Chemistry', 'credit': 3});
    await db.insert('subjects', {'name': 'Comp-Sci 104', 'description': 'Database', 'credit': 3});
    await db.insert('subjects', {'name': 'Comp-Sci 103', 'description': 'Software Engineering', 'credit': 3});
    await db.insert('subjects', {'name': 'Comp-Sci 101', 'description': 'Android App Development', 'credit': 5});
    await db.insert('subjects', {'name': 'Comp-Sci 102', 'description': 'Computer Architecture', 'credit': 3});

    await db.insert('students', {
      'name': 'Test Student',
      'email': 'test@student.com',
      'password': '123456',
    });
  }

  Future<int> getTotalCredits(String studentEmail) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(subjects.credit) as total_credits
      FROM enrollments
      INNER JOIN subjects ON enrollments.subject_id = subjects.id
      WHERE enrollments.student_id = ?
    ''', [studentEmail]);

    final totalCredits = result.isNotEmpty ? result.first['total_credits'] as int? : null;
    return totalCredits ?? 0;
  }
}
