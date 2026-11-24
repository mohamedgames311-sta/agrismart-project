import 'package:agrismart/models/zone.dart';

List<Zone> jeuDeDonnees() {
  return [
    Zone('Parcelle Nord', 'Tomates', 28, 35),
    Zone('Parcelle Sud', 'Oliviers', 42, 30),
    Zone('Serre 1', 'Fraises', 55, 50, vanneOuverte: true),
    Zone('Parcelle Est', 'Blé', 20, 35),
  ];
}