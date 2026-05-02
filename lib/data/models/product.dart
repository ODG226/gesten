// lib/data/models/product.dart
class Product {
  final int? id;
  final String reference;
  final String nom;
  final String? description;
  final int? categorieId;
  final double prixAchat;
  final double prixVente;
  final int stockActuel;
  final int stockMin;
  final int? fournisseurId;

  Product({
    this.id,
    required this.reference,
    required this.nom,
    this.description,
    this.categorieId,
    required this.prixAchat,
    required this.prixVente,
    this.stockActuel = 0,
    this.stockMin = 0,
    this.fournisseurId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id'].toString()),
      reference: json['reference'],
      nom: json['nom'],
      description: json['description'],
      categorieId: json['categorie_id'] != null ? int.tryParse(json['categorie_id'].toString()) : null,
      prixAchat: double.parse(json['prix_achat'].toString()),
      prixVente: double.parse(json['prix_vente'].toString()),
      stockActuel: int.parse(json['stock_actuel'].toString()),
      stockMin: int.parse(json['stock_min'].toString()),
      fournisseurId: json['fournisseur_id'] != null ? int.tryParse(json['fournisseur_id'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'nom': nom,
      'description': description,
      'categorie_id': categorieId,
      'prix_achat': prixAchat,
      'prix_vente': prixVente,
      'stock_actuel': stockActuel,
      'stock_min': stockMin,
      'fournisseur_id': fournisseurId,
    };
  }
}