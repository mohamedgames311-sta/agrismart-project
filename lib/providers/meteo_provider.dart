import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrismart/models/meteo.dart';
import 'package:agrismart/services/meteo_service.dart';

enum EtatMeteo { chargement, succes, erreur }

class MeteoProvider extends ChangeNotifier {
  static const _cleMeteo = 'meteo_json';
  static const _cleDate = 'meteo_date';

  final SharedPreferences _prefs;
  final MeteoService _service;

  MeteoProvider(
      this._prefs, {
        MeteoService? service,
      }) : _service = service ?? MeteoService();

  EtatMeteo _etat = EtatMeteo.chargement;
  Meteo? _meteo;
  String _erreur = '';

  bool _horsLigne = false;
  DateTime? _miseAJour;

  EtatMeteo get etat => _etat;
  Meteo? get meteo => _meteo;
  String get erreur => _erreur;
  bool get horsLigne => _horsLigne;
  DateTime? get miseAJour => _miseAJour;

  Future<void> charger() async {
    _etat = EtatMeteo.chargement;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 5));

      _meteo = await _service.charger();
      _etat = EtatMeteo.succes;
      _horsLigne = false;
      _miseAJour = DateTime.now();

      await _enregistrer(_meteo!, _miseAJour!);
    } on MeteoException catch (e) {
      _echec(e.message);
    } catch (_) {
      _echec('Erreur inattendue');
    }

    notifyListeners();
  }

  void _echec(String message) {
    final enCache = _lireCache();

    if (enCache != null) {
      _meteo = enCache;
      _etat = EtatMeteo.succes;
      _horsLigne = true;
      return;
    }

    _erreur = message;
    _etat = EtatMeteo.erreur;
  }

  Future<void> _enregistrer(
      Meteo meteo,
      DateTime date,
      ) async {
    await _prefs.setString(
      _cleMeteo,
      jsonEncode(meteo.toJson()),
    );

    await _prefs.setString(
      _cleDate,
      date.toIso8601String(),
    );
  }

  Meteo? _lireCache() {
    final texte = _prefs.getString(_cleMeteo);

    if (texte == null) return null;

    try {
      _miseAJour = DateTime.tryParse(
        _prefs.getString(_cleDate) ?? '',
      );

      return Meteo.fromJson(
        jsonDecode(texte) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  /// Conseiller d'Irrigation Intelligent pour une zone agricole
  ZoneIrrigationAdvice analyserIrrigationZone({
    required String zoneName,
    required double humiditeSol,
    required double seuilIrrigation,
    required bool vanneOuverte,
  }) {
    final previsions = _meteo?.previsions ?? const <PrevisionJour>[];
    final prochainJour = previsions.isNotEmpty ? previsions.first : null;
    final pluieProchaine = prochainJour?.pluie ?? 0.0;
    final probaPluie = prochainJour?.probabilitePluie ??
        (_meteo?.pluieTotale != null && _meteo!.pluieTotale > 0 ? 70 : 10);
    final tempMaxProchaine =
        prochainJour?.tMax ?? (_meteo?.temperature ?? 25.0);

    if ((probaPluie >= 60 || pluieProchaine >= 3.0) &&
        humiditeSol >= seuilIrrigation - 10) {
      return ZoneIrrigationAdvice(
        zoneName: zoneName,
        decision: IrrigationDecision.postponeRain,
        title: "Reporter l'arrosage",
        recommendation:
        'Pluie prévue (${pluieProchaine.toStringAsFixed(1)} mm, prob. $probaPluie%). Gardez la vanne fermée pour économiser l’eau.',
        suggestedValveOpen: false,
      );
    }

    if (humiditeSol < seuilIrrigation && tempMaxProchaine >= 34) {
      return ZoneIrrigationAdvice(
        zoneName: zoneName,
        decision: IrrigationDecision.heatStressAlert,
        title: 'Stress hydrique & forte chaleur',
        recommendation:
        'Sol à ${humiditeSol.toStringAsFixed(0)}% (seuil ${seuilIrrigation.toStringAsFixed(0)}%) avec max ${tempMaxProchaine.toStringAsFixed(0)}°C. Arrosez tôt le matin.',
        suggestedValveOpen: true,
      );
    }

    if (humiditeSol < seuilIrrigation) {
      return ZoneIrrigationAdvice(
        zoneName: zoneName,
        decision: IrrigationDecision.irrigateNow,
        title: 'Arrosage recommandé',
        recommendation:
        'Humidité du sol (${humiditeSol.toStringAsFixed(0)}%) sous le seuil (${seuilIrrigation.toStringAsFixed(0)}%).',
        suggestedValveOpen: true,
      );
    }

    return ZoneIrrigationAdvice(
      zoneName: zoneName,
      decision: IrrigationDecision.optimalHold,
      title: vanneOuverte ? 'Seuil atteint — fermer vanne' : 'Humidité optimale',
      recommendation:
      'Sol à ${humiditeSol.toStringAsFixed(0)}% (seuil ${seuilIrrigation.toStringAsFixed(0)}%). Aucun arrosage nécessaire.',
      suggestedValveOpen: false,
    );
  }

  /// Évaluation du risque de maladies fongiques à partir des prévisions
  FungalRiskAssessment evaluerRisqueFongique() {
    final actuel = _meteo;
    if (actuel == null) {
      return const FungalRiskAssessment(
        level: FungalRiskLevel.low,
        label: 'Risque fongique faible',
        details: 'Données météo indisponibles pour le moment.',
      );
    }

    final previsions = actuel.previsions;
    final humiditeMoyenne = previsions.isNotEmpty
        ? previsions
        .map((p) => p.humidite ?? actuel.humiditeAir.toDouble())
        .reduce((a, b) => a + b) /
        previsions.length
        : actuel.humiditeAir.toDouble();

    final tempMaxMoyenne = previsions.isNotEmpty
        ? previsions.map((p) => p.tMax).reduce((a, b) => a + b) /
        previsions.length
        : actuel.temperature;

    if (humiditeMoyenne >= 75 && tempMaxMoyenne >= 18 && tempMaxMoyenne <= 32) {
      return FungalRiskAssessment(
        level: FungalRiskLevel.high,
        label: 'Risque fongique élevé',
        details:
        'Humidité moyenne ${humiditeMoyenne.toStringAsFixed(0)}% et max ${tempMaxMoyenne.toStringAsFixed(0)}°C : vérifiez les feuilles (Détection Maladie).',
      );
    }

    if (humiditeMoyenne >= 65 && tempMaxMoyenne >= 15 && tempMaxMoyenne <= 34) {
      return FungalRiskAssessment(
        level: FungalRiskLevel.moderate,
        label: 'Risque fongique modéré',
        details:
        'Humidité moyenne ${humiditeMoyenne.toStringAsFixed(0)}%. Évitez d’arroser le feuillage en fin de journée.',
      );
    }

    return FungalRiskAssessment(
      level: FungalRiskLevel.low,
      label: 'Risque fongique faible',
      details:
      'Humidité moyenne ${humiditeMoyenne.toStringAsFixed(0)}% et max ${tempMaxMoyenne.toStringAsFixed(0)}°C : conditions peu favorables aux champignons.',
    );
  }
}