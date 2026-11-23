import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zones_provider.dart';
import '../providers/meteo_provider.dart';

class SmartNotificationCard extends StatelessWidget {
  const SmartNotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final zones = context.watch<ZonesProvider>().zones;
    final meteoProvider = context.watch<MeteoProvider>();

    final zonesBesoinEau = zones.where((z) => z.besoinIrrigation).toList();
    final pluiePrevue = (meteoProvider.meteo?.pluieTotale ?? 0.0) >= 5.0;

    if (zonesBesoinEau.isEmpty && !pluiePrevue) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.amber.shade50,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.notifications_active, color: Colors.amber),
                SizedBox(width: 8),
                Text('Notifications Intelligentes', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            if (pluiePrevue)
              const ListTile(
                dense: true,
                leading: Icon(Icons.umbrella, color: Colors.blue),
                title: Text('Pluie prévue prochainement'),
                subtitle: Text('Il est recommandé de reporter l\'irrigation.'),
              ),
            if (zonesBesoinEau.isNotEmpty)
              ListTile(
                dense: true,
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text('${zonesBesoinEau.length} zone(s) ont besoin d\'eau'),
                subtitle: Text(zonesBesoinEau.map((z) => z.nom).join(', ')),
              ),
          ],
        ),
      ),
    );
  }
}