// lib/data/repositories/user_repository.dart
import '../models/user.dart';
import '../../core/database/local_database.dart';

class UserRepository {
  final LocalDatabase _localDatabase;

  UserRepository(this._localDatabase);

  Future<User?> login(String email, String password) async {
    final db = await _localDatabase.database;
    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return User.fromJson(results.first);
  }

  Future<User?> getUserById(int id) async {
    final db = await _localDatabase.database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return User.fromJson(results.first);
  }

  Future<List<User>> getAllUsers() async {
    final db = await _localDatabase.database;
    final results = await db.query('users');
    return results.map((json) => User.fromJson(json)).toList();
  }

  Future<int> createUser(String email, String password, String nom, String role) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toIso8601String();
    
    return await db.insert('users', {
      'email': email,
      'password': password,
      'nom': nom,
      'role': role,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<bool> updateUser(int id, String nom, String role) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toIso8601String();
    
    final result = await db.update(
      'users',
      {
        'nom': nom,
        'role': role,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    return result > 0;
  }

  Future<bool> deleteUser(int id) async {
    final db = await _localDatabase.database;
    final result = await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }
}
