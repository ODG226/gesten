// lib/core/database/local_database.dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:async';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gesten_db.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    sqfliteFfiInit();
    final dbFactory = databaseFactoryFfi;
    
    final path = await dbFactory.getDatabasesPath();
    final fullPath = '$path/$fileName';

    final db = await dbFactory.openDatabase(
      fullPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
    return db;
  }

  Future<void> _createDB(Database db, int version) async {
    // Table Users
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        nom TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Table Clients
    await db.execute('''
      CREATE TABLE IF NOT EXISTS clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        email TEXT,
        telephone TEXT,
        adresse TEXT,
        ville TEXT,
        code_postal TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Table Produits
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference TEXT UNIQUE NOT NULL,
        nom TEXT NOT NULL,
        description TEXT,
        categorie_id INTEGER,
        prix_achat REAL NOT NULL,
        prix_vente REAL NOT NULL,
        stock_actuel INTEGER DEFAULT 0,
        stock_min INTEGER DEFAULT 0,
        fournisseur_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Table Ventes
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero TEXT UNIQUE NOT NULL,
        client_id INTEGER,
        montant_ht REAL NOT NULL,
        montant_ttc REAL NOT NULL,
        montant_recu REAL NOT NULL,
        montant_rendu REAL DEFAULT 0,
        mode_paiement TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
      )
    ''');

    // Table Lignes de Vente
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_lines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantite INTEGER NOT NULL,
        prix_unitaire REAL NOT NULL,
        montant REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
      )
    ''');

    // Insérer les utilisateurs par défaut
    await _insertDefaultUsers(db);

    // Insérer les produits et clients de démonstration
    await _insertDemoData(db);
  }

  Future<void> _insertDefaultUsers(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    await db.insert('users', {
      'email': 'admin@gesten.com',
      'password': 'admin123', // En production, utiliser bcrypt
      'nom': 'Administrateur',
      'role': 'admin',
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('users', {
      'email': 'user@gesten.com',
      'password': 'user123',
      'nom': 'Utilisateur',
      'role': 'user',
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _insertDemoData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Produits de démonstration
    const demoProducts = [
      {'reference': 'PROD001', 'nom': 'Laptop Dell', 'prix_achat': 500.0, 'prix_vente': 799.99},
      {'reference': 'PROD002', 'nom': 'Souris Logitech', 'prix_achat': 15.0, 'prix_vente': 29.99},
      {'reference': 'PROD003', 'nom': 'Clavier Mécanique', 'prix_achat': 80.0, 'prix_vente': 149.99},
    ];

    for (var product in demoProducts) {
      await db.insert(
        'products',
        {
          'reference': product['reference'],
          'nom': product['nom'],
          'description': '',
          'prix_achat': product['prix_achat'],
          'prix_vente': product['prix_vente'],
          'stock_actuel': 10,
          'stock_min': 2,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    // Clients de démonstration
    const demoClients = [
      {'nom': 'Entreprise ABC', 'email': 'contact@abc.com', 'telephone': '01234567890'},
      {'nom': 'Boutique XYZ', 'email': 'info@xyz.com', 'telephone': '09876543210'},
    ];

    for (var client in demoClients) {
      await db.insert(
        'clients',
        {
          'nom': client['nom'],
          'email': client['email'],
          'telephone': client['telephone'],
          'adresse': '',
          'ville': '',
          'code_postal': '',
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}