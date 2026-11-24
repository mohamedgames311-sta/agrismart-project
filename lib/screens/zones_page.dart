
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:agrismart/models/zone.dart';
import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/screens/zone_detail_page.dart';
import 'package:agrismart/screens/zone_form_page.dart';
import 'package:agrismart/widgets/fiche_exploitation.dart';
import 'package:agrismart/widgets/resume_exploitation.dart';
import 'package:agrismart/widgets/zone_card.dart';

class ZonesPage extends StatefulWidget {
  const ZonesPage({super.key});

  @override
  State<ZonesPage> createState() => _ZonesPageState();
}

class _ZonesPageState extends State<ZonesPage> {
  final TextEditingController _rechercheCtrl = TextEditingController();

  String _filtre = 'Toutes';

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte)),
    );
  }

  Future<void> _ajouter() async {
    final noms = context.read<ZonesProvider>().noms();

    final nouvelle = await Navigator.push<Zone>(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneFormPage(nomsExistants: noms),
      ),
    );

    if (nouvelle == null || !mounted) return;

    context.read<ZonesProvider>().ajouter(nouvelle);
    _message('Zone ajoutée');
  }

  Future<void> _ouvrirDetail(Zone zone) async {
    final noms = context.read<ZonesProvider>().noms(sauf: zone);

    final modifiee = await Navigator.push<Zone>(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneDetailPage(
          zone: zone,
          nomsAutres: noms,
        ),
      ),
    );

    if (modifiee == null || !mounted) return;

    context.read<ZonesProvider>().remplacer(zone, modifiee);
    _message('Zone modifiée');
  }

  Future<void> _confirmerSuppression(Zone zone) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la zone ?'),
        content: Text(
          'La zone ${zone.nom} sera supprimée définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    context.read<ZonesProvider>().supprimer(zone);
    _message('Zone supprimée');
  }

  List<Zone> _filtrer(List<Zone> zones) {
    final recherche = _rechercheCtrl.text.trim().toLowerCase();

    return zones.where((zone) {
      final correspondRecherche =
          zone.nom.toLowerCase().contains(recherche) ||
              zone.culture.toLowerCase().contains(recherche);

      final correspondFiltre = switch (_filtre) {
        'À irriguer' => zone.besoinIrrigation,
        'Sol correct' => !zone.besoinIrrigation,
        _ => true,
      };

      return correspondRecherche && correspondFiltre;
    }).toList();
  }

  Widget _carte(Zone zone) {
    return ZoneCard(
      zone: zone,
      onAugmenter: () =>
          context.read<ZonesProvider>().modifierHumidite(zone, 5),
      onDiminuer: () =>
          context.read<ZonesProvider>().modifierHumidite(zone, -5),
      onTap: () => _ouvrirDetail(zone),
      onLongPress: () => _confirmerSuppression(zone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zones = context.watch<ZonesProvider>().zones;
    final zonesFiltrees = _filtrer(zones);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('AgriSmart'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouter,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          FicheExploitation(
            humiditeMoyenne: humiditeMoyenne(zones),
          ),
          ResumeExploitation(zones: zones),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _rechercheCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Rechercher une zone ou une culture...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _rechercheCtrl.text.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _rechercheCtrl.clear();
                    setState(() {});
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Wrap(
              spacing: 8,
              children: [
                _boutonFiltre('Toutes'),
                _boutonFiltre('À irriguer'),
                _boutonFiltre('Sol correct'),
              ],
            ),
          ),
          Expanded(
            child: zonesFiltrees.isEmpty
                ? Center(
              child: Text(
                zones.isEmpty
                    ? 'Aucune zone pour le moment'
                    : 'Aucun résultat trouvé',
              ),
            )
                : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 600) {
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: zonesFiltrees.length,
                    itemBuilder: (context, index) =>
                        _carte(zonesFiltrees[index]),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: zonesFiltrees.length,
                  separatorBuilder: (context, index) =>
                  const Divider(),
                  itemBuilder: (context, index) =>
                      _carte(zonesFiltrees[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _boutonFiltre(String valeur) {
    return ChoiceChip(
      label: Text(valeur),
      selected: _filtre == valeur,
      onSelected: (_) {
        setState(() {
          _filtre = valeur;
        });
      },
    );
  }
}
