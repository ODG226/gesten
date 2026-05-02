// lib/data/repositories/sale_repository.dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/sale.dart';
import '../../core/database/local_database.dart';

class SaleRepository {
  final LocalDatabase _localDatabase;

  SaleRepository(this._localDatabase);

  Future<List<Sale>> getSales() async {
    final db = await _localDatabase.database;
    final results = await db.query('sales', orderBy: 'created_at DESC');
    
    List<Sale> sales = [];
    for (var saleData in results) {
      final saleLines = await _getSaleLines(db, saleData['id'] as int);
      sales.add(Sale.fromJson({...saleData, 'lignes': saleLines}));
    }
    return sales;
  }

  Future<Sale?> getSaleById(int id) async {
    final db = await _localDatabase.database;
    final results = await db.query(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    
    final saleLines = await _getSaleLines(db, id);
    return Sale.fromJson({...results.first, 'lignes': saleLines});
  }

  Future<int> createSale(Sale sale) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toIso8601String();
    
    final saleId = await db.insert('sales', {
      'numero': sale.numero,
      'client_id': sale.clientId,
      'montant_ht': sale.montantTtc,
      'montant_ttc': sale.montantTtc,
      'montant_recu': sale.montantRecu,
      'montant_rendu': sale.montantRendu,
      'mode_paiement': sale.modePaiement,
      'user_id': sale.userId,
      'created_at': now,
      'updated_at': now,
    });

    // Insérer les lignes de vente
    for (var line in sale.lignes) {
      await db.insert('sale_lines', {
        'sale_id': saleId,
        'product_id': line.productId,
        'quantite': line.quantite,
        'prix_unitaire': line.prixUnitaire,
        'montant': line.montant,
        'created_at': now,
      });
    }

    return saleId;
  }

  Future<bool> updateSale(Sale sale) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toIso8601String();
    
    final result = await db.update(
      'sales',
      {
        'numero': sale.numero,
        'client_id': sale.clientId,
        'montant_ht': sale.montantTtc,
        'montant_ttc': sale.montantTtc,
        'montant_recu': sale.montantRecu,
        'montant_rendu': sale.montantRendu,
        'mode_paiement': sale.modePaiement,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [sale.id],
    );
    return result > 0;
  }

  Future<bool> deleteSale(int id) async {
    final db = await _localDatabase.database;
    final result = await db.delete(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

  Future<List<Map<String, dynamic>>> _getSaleLines(Database db, int saleId) async {
    final results = await db.query(
      'sale_lines',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
    return results;
  }

  Future<List<Sale>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _localDatabase.database;
    final results = await db.query(
      'sales',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    
    List<Sale> sales = [];
    for (var saleData in results) {
      final saleLines = await _getSaleLines(db, saleData['id'] as int);
      sales.add(Sale.fromJson({...saleData, 'lignes': saleLines}));
    }
    return sales;
  }

  Future<Map<String, dynamic>> getSalesStatistics() async {
    final db = await _localDatabase.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total_sales, SUM(montant_ttc) as total_amount FROM sales'
    );
    
    return {
      'total_sales': result.first['total_sales'] ?? 0,
      'total_amount': result.first['total_amount'] ?? 0.0,
    };
  }
}