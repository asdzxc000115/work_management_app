//데이터베이스 서비스
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workplace.dart';
import '../models/work.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('work_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 근무지 테이블
    await db.execute('''
      CREATE TABLE workplaces (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        payday INTEGER NOT NULL,
        color INTEGER NOT NULL,
        deduct_tax INTEGER NOT NULL DEFAULT 0,
        deduct_insurance INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 근무 테이블
    await db.execute('''
      CREATE TABLE works (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workplace_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        pay_type TEXT NOT NULL,
        hourly_wage REAL NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        break_minutes INTEGER NOT NULL DEFAULT 0,
        extra_pay REAL NOT NULL DEFAULT 0,
        extra_pay_note TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (workplace_id) REFERENCES workplaces (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> initializeDatabase() async {
    await database;
  }

  // 근무지 관련 메소드
  Future<int> insertWorkplace(Workplace workplace) async {
    final db = await database;
    return await db.insert('workplaces', workplace.toMap());
  }

  Future<List<Workplace>> getWorkplaces() async {
    final db = await database;
    final result = await db.query(
      'workplaces',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return result.map((map) => Workplace.fromMap(map)).toList();
  }

  Future<int> updateWorkplace(Workplace workplace) async {
    final db = await database;
    return await db.update(
      'workplaces',
      workplace.toMap(),
      where: 'id = ?',
      whereArgs: [workplace.id],
    );
  }

  Future<int> deleteWorkplace(int id) async {
    final db = await database;
    // 관련된 근무 기록도 함께 삭제
    await db.delete(
      'works',
      where: 'workplace_id = ?',
      whereArgs: [id],
    );
    return await db.delete(
      'workplaces',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 근무 관련 메소드
  Future<int> insertWork(Work work) async {
    final db = await database;
    return await db.insert('works', work.toMap());
  }

  Future<List<Work>> getWorks() async {
    final db = await database;
    final result = await db.query(
      'works',
      orderBy: 'date DESC, start_time DESC',
    );
    return result.map((map) => Work.fromMap(map)).toList();
  }

  Future<List<Work>> getWorksByMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0).toIso8601String();

    final result = await db.query(
      'works',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC, start_time DESC',
    );

    return result.map((map) => Work.fromMap(map)).toList();
  }

  Future<int> updateWork(Work work) async {
    final db = await database;
    return await db.update(
      'works',
      work.toMap(),
      where: 'id = ?',
      whereArgs: [work.id],
    );
  }

  Future<int> deleteWork(int id) async {
    final db = await database;
    return await db.delete(
      'works',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteWorksByWorkplace(int workplaceId) async {
    final db = await database;
    return await db.delete(
      'works',
      where: 'workplace_id = ?',
      whereArgs: [workplaceId],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}