class PrevisionJour {
  final DateTime date;
  final double tMax;
  final double tMin;
  final double pluie;
  final double? humidite;
  final int? probabilitePluie;

  const PrevisionJour({
    required this.date,
    required this.tMax,
    required this.tMin,
    required this.pluie,
    this.humidite,
    this.probabilitePluie,
  });
}

class Meteo {
  final double temperature;
  final int humiditeAir;
  final double vent;
  final List<PrevisionJour> previsions;

  const Meteo({
    required this.temperature,
    required this.humiditeAir,
    required this.vent,
    required this.previsions,
  });

  double get pluieTotale =>
      previsions.fold(0.0, (somme, p) => somme + p.pluie);

  Map<String, dynamic> toJson() {
    return {
      'current': {
        'temperature_2m': temperature,
        'relative_humidity_2m': humiditeAir,
        'wind_speed_10m': vent,
      },
      'daily': {
        'time': previsions
            .map((p) => p.date.toIso8601String())
            .toList(),
        'temperature_2m_max':
        previsions.map((p) => p.tMax).toList(),
        'temperature_2m_min':
        previsions.map((p) => p.tMin).toList(),
        'precipitation_sum':
        previsions.map((p) => p.pluie).toList(),
        'relative_humidity_2m_mean': previsions
            .map((p) => p.humidite ?? humiditeAir.toDouble())
            .toList(),
        'precipitation_probability_max': previsions
            .map((p) =>
        p.probabilitePluie ?? (p.pluie > 0 ? 70 : 10))
            .toList(),
      },
    };
  }

  factory Meteo.fromJson(Map<String, dynamic> json) {
    final current = (json['current'] as Map<String, dynamic>?) ?? {};
    final daily = (json['daily'] as Map<String, dynamic>?) ?? {};

    final dates = (daily['time'] as List<dynamic>?) ?? const [];
    final tMax = (daily['temperature_2m_max'] as List<dynamic>?) ?? const [];
    final tMin = (daily['temperature_2m_min'] as List<dynamic>?) ?? const [];
    final pluie = (daily['precipitation_sum'] as List<dynamic>?) ?? const [];
    final humidites =
        (daily['relative_humidity_2m_mean'] as List<dynamic>?) ?? const [];
    final rainProbs =
        (daily['precipitation_probability_max'] as List<dynamic>?) ?? const [];

    final currentHumidity =
    ((current['relative_humidity_2m'] as num?) ?? 40).round();

    final List<PrevisionJour> previsions = [];

    for (var i = 0; i < dates.length; i++) {
      final rainMm = i < pluie.length ? (pluie[i] as num).toDouble() : 0.0;
      final humVal = i < humidites.length
          ? (humidites[i] as num).toDouble()
          : currentHumidity.toDouble();
      final probVal = i < rainProbs.length
          ? (rainProbs[i] as num).round()
          : (rainMm > 0 ? 70 : 10);

      previsions.add(
        PrevisionJour(
          date: DateTime.parse(dates[i] as String),
          tMax: i < tMax.length ? (tMax[i] as num).toDouble() : 0.0,
          tMin: i < tMin.length ? (tMin[i] as num).toDouble() : 0.0,
          pluie: rainMm,
          humidite: humVal,
          probabilitePluie: probVal,
        ),
      );
    }

    return Meteo(
      temperature: ((current['temperature_2m'] as num?) ?? 0.0).toDouble(),
      humiditeAir: currentHumidity,
      vent: ((current['wind_speed_10m'] as num?) ?? 0.0).toDouble(),
      previsions: previsions,
    );
  }
}

enum IrrigationDecision {
  postponeRain,
  irrigateNow,
  heatStressAlert,
  optimalHold,
}

enum FungalRiskLevel {
  low,
  moderate,
  high,
}

class ZoneIrrigationAdvice {
  final String zoneName;
  final IrrigationDecision decision;
  final String title;
  final String recommendation;
  final bool suggestedValveOpen;

  const ZoneIrrigationAdvice({
    required this.zoneName,
    required this.decision,
    required this.title,
    required this.recommendation,
    required this.suggestedValveOpen,
  });
}

class FungalRiskAssessment {
  final FungalRiskLevel level;
  final String label;
  final String details;

  const FungalRiskAssessment({
    required this.level,
    required this.label,
    required this.details,
  });
}