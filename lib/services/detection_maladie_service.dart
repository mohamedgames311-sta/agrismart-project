import 'dart:async';
import '../models/maladie_plante.dart';

class DetectionMaladieService {
  // Simule l'analyse de l'image de la plante
  static Future<MaladiePlante> analyserImagePlante(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2));

    return MaladiePlante(
      nomPlante: 'Tomate',
      nomMaladie: 'Mildiou (Phytophthora infestans)',
      confiance: 0.94,
      description: 'Présence de taches brunes desséchées sur les feuilles avec un léger feutrage blanc au revers.',
      traitementConseille: 'Retirer et brûler les feuilles atteintes. Appliquer de la bouillie bordelaise et éviter de mouiller le feuillage lors de l\'arrosage.',
    );
  }
}