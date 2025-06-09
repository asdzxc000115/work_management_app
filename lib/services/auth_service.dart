import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static final DatabaseService _db = DatabaseService.instance;

  static Future<User?> login(String email, String password) async {
    final db = await _db.database;

    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  static Future<bool> signup(String name, String email, String password) async {
    final db = await _db.database;

    try {
      final user = User(
        name: name,
        email: email,
        password: password,
      );

      await db.insert('users', user.toMap());
      return true;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  static Future<User?> getUserByEmail(String email) async {
    final db = await _db.database;

    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  static Future<User?> getUserById(int id) async {
    final db = await _db.database;

    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }
}