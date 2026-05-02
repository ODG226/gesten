// lib/data/models/sale.dart
class Sale {
  final int? id;
  final String numero;
  final int? clientId;
  final double montantTtc;
  final double montantRecu;
  final double montantRendu;
  final String modePaiement;
  final int userId;
  final DateTime createdAt;
  final List<SaleLine> lignes;

  Sale({
    this.id,
    required this.numero,
    this.clientId,
    required this.montantTtc,
    required this.montantRecu,
    this.montantRendu = 0,
    required this.modePaiement,
    required this.userId,
    required this.createdAt,
    this.lignes = const [],
  });

  double get montantHt => montantTtc;

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: int.tryParse(json['id'].toString()),
      numero: json['numero'] ?? 'N/A',
      clientId: json['client_id'] != null ? int.tryParse(json['client_id'].toString()) : null,
      montantTtc: json['montant_ttc'] != null ? double.parse(json['montant_ttc'].toString()) : 0.0,
      montantRecu: json['montant_recu'] != null ? double.parse(json['montant_recu'].toString()) : 0.0,
      montantRendu: json['montant_rendu'] != null ? double.parse(json['montant_rendu'].toString()) : 0.0,
      modePaiement: json['mode_paiement'] ?? 'Espèces',
      userId: json['user_id'] != null ? int.parse(json['user_id'].toString()) : 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      lignes: json['lignes'] != null
          ? (json['lignes'] as List).map((e) => SaleLine.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'client_id': clientId,
      'montant_ht': montantTtc,
      'montant_ttc': montantTtc,
      'montant_recu': montantRecu,
      'montant_rendu': montantRendu,
      'mode_paiement': modePaiement,
      'user_id': userId,
      'lignes': lignes.map((e) => e.toJson()).toList(),
    };
  }
}

class SaleLine {
  final int? id;
  final int? saleId;
  final int productId;
  final int quantite;
  final double prixUnitaire;
  final double montant;

  SaleLine({
    this.id,
    this.saleId,
    required this.productId,
    required this.quantite,
    required this.prixUnitaire,
    required this.montant,
  });

  factory SaleLine.fromJson(Map<String, dynamic> json) {
    return SaleLine(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      saleId: json['sale_id'] != null ? int.tryParse(json['sale_id'].toString()) : null,
      productId: int.parse(json['product_id'].toString()),
      quantite: int.parse(json['quantite'].toString()),
      prixUnitaire: double.parse(json['prix_unitaire'].toString()),
      montant: double.parse(json['montant'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
      'montant': montant,
    };
  }
}