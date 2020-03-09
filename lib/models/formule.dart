class Formule {
  final String id;
  String title;
  int prix;
  int nombreDePersonne;

  Formule({this.id, this.title, this.prix, this.nombreDePersonne});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'prix': prix,
      'nombreDePersonne': nombreDePersonne,
    };
  }


  factory Formule.fromMap(Map data, String documentId) {
    return Formule(
        id: documentId,
        title: data['title'] ?? '',
        prix: data['prix'] ?? '',
        nombreDePersonne: data['nombreDePersonne'] ?? 0);
  }
}