class ConsommationEau {
  final String zoneId;
  final String nomZone;
  final double consommationJour;
  final double consommationSemaine;
  final double consommationMois;

  ConsommationEau({
    required this.zoneId,
    required this.nomZone,
    required this.consommationJour,
    required this.consommationSemaine,
    required this.consommationMois,
  });
}