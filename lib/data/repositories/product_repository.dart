// lib/data/repositories/product_repository.dart
import '../models/product.dart';
import '../../core/database/local_database.dart';

class ProductRepository {
  final LocalDatabase _localDatabase;

  ProductRepository(this._localDatabase);

  Future<List<Product>> getProducts() async {
    final db = await _localDatabase.database;
    final results = await db.query('products', orderBy: 'nom ASC');
    return results.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await _localDatabase.database;
    final results = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Product.fromJson(results.first);
  }

  Future<int> createProduct(Product product) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toIso8601String();
    
    return await db.insert('products', {
      'reference': product.reference,
      'nom': product.nom,
      'description': product.description,
      'categorie_id': product.categorieId,
      'prix_achat': product.prixAchat,
      'prix_vente': product.prixVente,
      'stock_actuel': product.stockActuel,
      'stock_min': product.stockMin,
      'fournisseur_id': product.fournisseurId,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<bool> updateProduct(Product product) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toIso8601String();
    
    final result = await db.update(
      'products',
      {
        'reference': product.reference,
        'nom': product.nom,
        'description': product.description,
        'categorie_id': product.categorieId,
        'prix_achat': product.prixAchat,
        'prix_vente': product.prixVente,
        'stock_actuel': product.stockActuel,
        'stock_min': product.stockMin,
        'fournisseur_id': product.fournisseurId,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
    return result > 0;
  }

  Future<bool> deleteProduct(int id) async {
    final db = await _localDatabase.database;
    final result = await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

  Future<bool> updateStock(int id, int newStock) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toIso8601String();
    
    final result = await db.update(
      'products',
      {
        'stock_actuel': newStock,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }
}