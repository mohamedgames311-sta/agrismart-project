enum TypeTache { plantation, fertilisation, arrosage, recolte }

class CropTask {
  final String id;
  final String zoneNom;
  final String titre;
  final TypeTache type;
  final DateTime date;
  bool estFaite;

  CropTask({
    required this.id,
    required this.zoneNom,
    required this.titre,
    required this.type,
    required this.date,
    this.estFaite = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'zoneNom': zoneNom,
    'titre': titre,
    'type': type.index,
    'date': date.toIso8601String(),
    'estFaite': estFaite,
  };

  factory CropTask.fromJson(Map<String, dynamic> json) => CropTask(
    id: json['id'],
    zoneNom: json['zoneNom'],
    titre: json['titre'],
    type: TypeTache.values[json['type'] as int],
    date: DateTime.parse(json['date']),
    estFaite: json['estFaite'] ?? false,
  );
}