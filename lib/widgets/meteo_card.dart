
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:agrismart/providers/meteo_provider.dart';

class MeteoCard extends StatelessWidget {
  const MeteoCard({super.key});

  static String _deux(int n) => n.toString().padLeft(2, '0');

  String _libelleMiseAJour(MeteoProvider provider) {
    final d = provider.miseAJour;

    if (d == null) {
      return provider.horsLigne ? 'Données hors ligne' : '';
    }

    final quand =
        '${_deux(d.day)}/${_deux(d.month)} à '
        '${_deux(d.hour)}:${_deux(d.minute)}';

    return provider.horsLigne
        ? 'Hors ligne : données du $quand'
        : 'Mis à jour le $quand';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MeteoProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _construireContenu(context, provider),
          ),
        );
      },
    );
  }

  Widget _construireContenu(
      BuildContext context,
      MeteoProvider provider,
      ) {
    switch (provider.etat) {
      case EtatMeteo.chargement:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );

      case EtatMeteo.erreur:
        return Column(
          children: [
            const Icon(
              Icons.cloud_off,
              size: 40,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            const Text(
              'Impossible de charger la météo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(provider.erreur),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.charger(),
              child: const Text('Réessayer'),
            ),
          ],
        );

      case EtatMeteo.succes:
        final meteo = provider.meteo;

        if (meteo == null) {
          return const Text('Aucune donnée météo disponible');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.wb_sunny,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'Météo de Kébili',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            Text(
              '${meteo.temperature.toStringAsFixed(1)} °C',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoMeteo(
                  Icons.water_drop,
                  'Humidité',
                  '${meteo.humiditeAir} %',
                ),
                _infoMeteo(
                  Icons.air,
                  'Vent',
                  '${meteo.vent.toStringAsFixed(1)} km/h',
                ),
                _infoMeteo(
                  Icons.umbrella,
                  'Pluie',
                  '${meteo.pluieTotale.toStringAsFixed(1)} mm',
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Prévisions des prochains jours',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ...meteo.previsions.map((prevision) {
              final date =
                  '${_deux(prevision.date.day)}/'
                  '${_deux(prevision.date.month)}';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(date),
                subtitle: Text(
                  'Min : ${prevision.tMin.toStringAsFixed(1)} °C'
                      '  |  Max : ${prevision.tMax.toStringAsFixed(1)} °C',
                ),
                trailing: Text(
                  '${prevision.pluie.toStringAsFixed(1)} mm',
                ),
              );
            }),

            const SizedBox(height: 12),

            Text(
              _libelleMiseAJour(provider),
              style: Theme.of(context).textTheme.bodySmall,
            ),

            if (provider.horsLigne)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => provider.charger(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ),
          ],
        );
    }
  }

  Widget _infoMeteo(
      IconData icon,
      String titre,
      String valeur,
      ) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(titre),
        const SizedBox(height: 4),
        Text(
          valeur,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
