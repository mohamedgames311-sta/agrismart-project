import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrismart/models/crop_task.dart';
import 'package:agrismart/providers/calendar_provider.dart';
import 'package:agrismart/providers/zones_provider.dart';

class CropCalendarPage extends StatelessWidget {
  const CropCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final calendar = context.watch<CalendarProvider>();
    final zones = context.watch<ZonesProvider>().zones;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Calendrier des Cultures'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _afficherFormulaireAjout(context, zones),
        child: const Icon(Icons.add),
      ),
      body: calendar.taches.isEmpty
          ? const Center(
        child: Text('Aucune tâche enregistrée dans le calendrier'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: calendar.taches.length,
        itemBuilder: (ctx, index) {
          final tache = calendar.taches[index];
          return Card(
            child: CheckboxListTile(
              title: Text(
                tache.titre,
                style: TextStyle(
                  decoration: tache.estFaite
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Text(
                '${tache.zoneNom} • ${_nomType(tache.type)} • ${_formaterDate(tache.date)}',
              ),
              secondary: _iconeType(tache.type),
              value: tache.estFaite,
              onChanged: (_) {
                context.read<CalendarProvider>().basculerEtat(tache.id);
              },
            ),
          );
        },
      ),
    );
  }

  Icon _iconeType(TypeTache type) {
    switch (type) {
      case TypeTache.plantation:
        return const Icon(Icons.eco, color: Colors.green);
      case TypeTache.fertilisation:
        return const Icon(Icons.science, color: Colors.orange);
      case TypeTache.arrosage:
        return const Icon(Icons.water_drop, color: Colors.blue);
      case TypeTache.recolte:
        return const Icon(Icons.agriculture, color: Colors.amber);
    }
  }

  String _nomType(TypeTache type) {
    switch (type) {
      case TypeTache.plantation:
        return 'Plantation';
      case TypeTache.fertilisation:
        return 'Fertilisation';
      case TypeTache.arrosage:
        return 'Arrosage';
      case TypeTache.recolte:
        return 'Récolte';
    }
  }

  String _formaterDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  void _afficherFormulaireAjout(BuildContext context, List zones) {
    final titreCtrl = TextEditingController();
    String? zoneSelectionnee = zones.isNotEmpty ? zones.first.nom : null;
    TypeTache typeSelectionne = TypeTache.arrosage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nouvelle Tâche Agricole',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titreCtrl,
              decoration: const InputDecoration(
                labelText: 'Titre de la tâche',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: zoneSelectionnee,
              decoration: const InputDecoration(
                labelText: 'Zone',
                border: OutlineInputBorder(),
              ),
              items: zones
                  .map<DropdownMenuItem<String>>((z) => DropdownMenuItem(
                value: z.nom,
                child: Text(z.nom),
              ))
                  .toList(),
              onChanged: (v) => zoneSelectionnee = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TypeTache>(
              value: typeSelectionne,
              decoration: const InputDecoration(
                labelText: 'Type d\'activité',
                border: OutlineInputBorder(),
              ),
              items: TypeTache.values
                  .map((t) => DropdownMenuItem(
                value: t,
                child: Text(_nomType(t)),
              ))
                  .toList(),
              onChanged: (v) {
                if (v != null) typeSelectionne = v;
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (titreCtrl.text.trim().isNotEmpty &&
                    zoneSelectionnee != null) {
                  context.read<CalendarProvider>().ajouterTache(
                    CropTask(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      zoneNom: zoneSelectionnee!,
                      titre: titreCtrl.text.trim(),
                      type: typeSelectionne,
                      date: DateTime.now(),
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Ajouter au calendrier'),
            ),
          ],
        ),
      ),
    );
  }
}