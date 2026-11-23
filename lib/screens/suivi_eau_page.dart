import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/consommation_provider.dart';

class SuiviEauPage extends StatelessWidget {
  const SuiviEauPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConsommationProvider>(); //[cite: 106]

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consommation d\'eau par Zone'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 3,
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Consommation Globale',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatGlobal('Aujourd\'hui', '${provider.totalJour.toStringAsFixed(1)} L'),
                      _buildStatGlobal('Cette semaine', '${provider.totalSemaine.toStringAsFixed(1)} L'),
                      _buildStatGlobal('Ce mois', '${provider.totalMois.toStringAsFixed(1)} L'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Détail par zone (Cliquez sur +10L pour faire varier)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...provider.consommations.map((item) => Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.water_drop, color: Colors.white),
              ),
              title: Text(item.nomZone, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Jour: ${item.consommationJour.toStringAsFixed(1)} L | Sem.: ${item.consommationSemaine.toStringAsFixed(1)} L',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.consommationMois.toStringAsFixed(1)} L/mois',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  // Bouton d'action pour simuler une augmentation
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                    tooltip: 'Ajouter 10 Litres',
                    onPressed: () {
                      context.read<ConsommationProvider>().ajouterConsommation(item.zoneId, 10.0); //[cite: 106]
                    },
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatGlobal(String titre, String valeur) {
    return Column(
      children: [
        Text(titre, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(valeur, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
      ],
    );
  }
}