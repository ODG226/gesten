// lib/data/models/client.dart
class Client {
  final int? id;
  final String nom;
  final String? email;
  final String? telephone;
  final String? adresse;
  final String? ville;
  final String? codePostal;

  Client({
    this.id,
    required this.nom,
    this.email,
    this.telephone,
    this.adresse,
    this.ville,
    this.codePostal,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: int.tryParse(json['id'].toString()),
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      ville: json['ville'],
      codePostal: json['code_postal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'ville': ville,
      'code_postal': codePostal,
    };
  }
}