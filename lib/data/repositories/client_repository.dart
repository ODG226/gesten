// lib/data/repositories/client_repository.dart
import '../models/client.dart';
import '../../core/database/local_database.dart';

class ClientRepository {
  final LocalDatabase _localDatabase;

  ClientRepository(this._localDatabase);

  Future<List<Client>> getClients() async {
    final db = await _localDatabase.database;
    final results = await db.query('clients', orderBy: 'nom ASC');
    return results.map((json) => Client.fromJson(json)).toList();
  }

  Future<Client?> getClientById(int id) async {
    final db = await _localDatabase.database;
    final results = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Client.fromJson(results.first);
  }

  Future<int> createClient(Client client) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toIso8601String();
    
    return await db.insert('clients', {
      'nom': client.nom,
      'email': client.email,
      'telephone': client.telephone,
      'adresse': client.adresse,
      'ville': client.ville,
      'code_postal': client.codePostal,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<bool> updateClient(Client client) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toIso8601String();
    
    final result = await db.update(
      'clients',
      {
        'nom': client.nom,
        'email': client.email,
        'telephone': client.telephone,
        'adresse': client.adresse,
        'ville': client.ville,
        'code_postal': client.codePostal,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [client.id],
    );
    return result > 0;
  }

  Future<bool> deleteClient(int id) async {
    final db = await _localDatabase.database;
    final result = await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }
}