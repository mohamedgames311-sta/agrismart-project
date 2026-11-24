import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrismart/screens/suivi_eau_page.dart';
import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/theme/app_theme.dart';
import 'package:agrismart/widgets/resume_exploitation.dart';
import 'package:agrismart/widgets/meteo_card.dart';

class StatistiquesPage extends StatelessWidget {
  const StatistiquesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Read the shared zones from Provider.
    final zones = context.watch<ZonesProvider>().zones;

    // Sort zones from driest to wettest.
    final tri = [...zones]
      ..sort((a, b) => a.humidite.compareTo(b.humidite));

    final aIrriguer =
        zones.where((z) => z.besoinIrrigation).length;

    // Calculate the percentage safely.
    final pourcentage =
    zones.isEmpty ? 0 : (aIrriguer * 100 / zones.length).round();

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
        Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Statistiques'),
      ),
      body: ListView(
        children: [
          const MeteoCard(),

          // Carte d'accès au Suivi de la consommation d'eau
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.water_drop, color: Colors.white),
              ),
              title: const Text(
                'Suivi de la consommation d\'eau',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Consulter par jour, semaine et mois'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SuiviEauPage()),
                );
              },
            ),
          ),

          if (zones.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Aucune donnée à afficher'),
              ),
            )
          else ...[
            ResumeExploitation(zones: zones),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                '$aIrriguer zone(s) sur ${zones.length} à irriguer '
                    '($pourcentage %)',
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Humidité par zone',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            for (final z in tri)
              ListTile(
                title: Text(z.nom),
                subtitle: LinearProgressIndicator(
                  value: (z.humidite / 100).clamp(0.0, 1.0),
                  color: z.besoinIrrigation
                      ? AppTheme.echec
                      : AppTheme.succes,
                ),
                trailing: Text(
                  '${z.humidite.toStringAsFixed(0)} %',
                ),
              ),
          ],
        ],
      ),
    );
  }
}