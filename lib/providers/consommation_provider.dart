import 'package:flutter/foundation.dart';
import '../models/consommation_eau.dart';

class ConsommationProvider extends ChangeNotifier {
  final List<ConsommationEau> _donneesConsommation = [
    ConsommationEau(
      zoneId: '1',
      nomZone: 'Parcelle Nord',
      consommationJour: 120.5,
      consommationSemaine: 840.0,
      consommationMois: 3600.0,
    ),
    ConsommationEau(
      zoneId: '2',
      nomZone: 'Parcelle Sud',
      consommationJour: 85.0,
      consommationSemaine: 595.0,
      consommationMois: 2550.0,
    ),
    ConsommationEau(
      zoneId: '3',
      nomZone: 'Serre 1',
      consommationJour: 45.0,
      consommationSemaine: 315.0,
      consommationMois: 1350.0,
    ),
    ConsommationEau(
      zoneId: '4',
      nomZone: 'Parcelle Est',
      consommationJour: 200.0,
      consommationSemaine: 1400.0,
      consommationMois: 6000.0,
    ),
  ];

  List<ConsommationEau> get consommations => List.unmodifiable(_donneesConsommation);

  double get totalJour => _donneesConsommation.fold(0, (sum, item) => sum + item.consommationJour);
  double get totalSemaine => _donneesConsommation.fold(0, (sum, item) => sum + item.consommationSemaine);
  double get totalMois => _donneesConsommation.fold(0, (sum, item) => sum + item.consommationMois);

  // MÉTHODE DE SIMULATION : Ajouter de l'eau consommée à une zone
  void ajouterConsommation(String zoneId, double litres) {
    final index = _donneesConsommation.indexWhere((element) => element.zoneId == zoneId);
    if (index != -1) {
      final ancienne = _donneesConsommation[index];
      _donneesConsommation[index] = ConsommationEau(
        zoneId: ancienne.zoneId,
        nomZone: ancienne.nomZone,
        consommationJour: ancienne.consommationJour + litres,
        consommationSemaine: ancienne.consommationSemaine + litres,
        consommationMois: ancienne.consommationMois + litres,
      );
      // Prévient les écouteurs pour mettre à jour l'affichage
      notifyListeners(); //
    }
  }
}