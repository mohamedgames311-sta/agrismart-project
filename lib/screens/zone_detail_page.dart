
import 'package:flutter/material.dart';
import 'package:agrismart/models/zone.dart';
import 'package:agrismart/screens/zone_form_page.dart';
import 'package:agrismart/theme/app_theme.dart';

class ZoneDetailPage extends StatefulWidget {
  final Zone zone;
  final List<String> nomsAutres;

  const ZoneDetailPage({
    super.key,
    required this.zone,
    this.nomsAutres = const [],
  });

  @override
  State<ZoneDetailPage> createState() => _ZoneDetailPageState();
}

class _ZoneDetailPageState extends State<ZoneDetailPage> {
  late Zone _zone;

  @override
  void initState() {
    super.initState();

    _zone = Zone(
      widget.zone.nom,
      widget.zone.culture,
      widget.zone.humidite,
      widget.zone.seuil,
      vanneOuverte: widget.zone.vanneOuverte,
    );
  }

  Future<void> _modifier(BuildContext context) async {
    final nouvelle = await Navigator.push<Zone>(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneFormPage(
          zone: _zone,
          nomsExistants: widget.nomsAutres,
        ),
      ),
    );

    if (nouvelle == null || !mounted) return;

    setState(() {
      _zone = nouvelle;
    });
  }

  void _enregistrer() {
    Navigator.pop(context, _zone);
  }

  @override
  Widget build(BuildContext context) {
    final couleur =
    _zone.besoinIrrigation ? AppTheme.echec : AppTheme.succes;

    final longueur =
    _zone.culture.length < 4 ? _zone.culture.length : 4;

    final texte = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_zone.nom),
        actions: [
          IconButton(
            onPressed: _enregistrer,
            tooltip: 'Enregistrer',
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                child: Text(
                  _zone.culture.substring(0, longueur),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_zone.nom, style: texte.headlineSmall),
                    Text(_zone.culture, style: texte.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${_zone.humidite.toStringAsFixed(0)} %',
              style: texte.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_zone.humidite / 100).clamp(0.0, 1.0),
            color: couleur,
            minHeight: 10,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              diagnostic(_zone),
              style: TextStyle(color: couleur, fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.water_drop),
                  title: const Text('Humidité actuelle'),
                  trailing: Text(
                    '${_zone.humidite.toStringAsFixed(0)} %',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text("Seuil d'irrigation"),
                  trailing: Text(
                    '${_zone.seuil.toStringAsFixed(0)} %',
                  ),
                ),
                ListTile(
                  leading: Icon(
                    _zone.vanneOuverte
                        ? Icons.toggle_on
                        : Icons.toggle_off,
                  ),
                  title: const Text('Vanne'),
                  trailing: Text(
                    _zone.vanneOuverte ? 'Ouverte' : 'Fermée',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contrôle manuel de l’irrigation',
                    style: texte.titleMedium,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ouvrir la vanne'),
                    subtitle: Text(
                      _zone.vanneOuverte
                          ? 'Irrigation activée'
                          : 'Irrigation désactivée',
                    ),
                    value: _zone.vanneOuverte,
                    onChanged: (valeur) {
                      setState(() {
                        _zone.vanneOuverte = valeur;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Réglage du seuil d'humidité",
                    style: texte.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seuil minimum : '
                        '${_zone.seuil.toStringAsFixed(0)} %',
                  ),
                  Slider(
                    value: _zone.seuil.clamp(0.0, 100.0),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${_zone.seuil.toStringAsFixed(0)} %',
                    onChanged: (valeur) {
                      setState(() {
                        _zone.seuil = valeur;
                      });
                    },
                  ),
                  const Text(
                    'Une alerte sera affichée lorsque '
                        'l’humidité du sol descend sous ce seuil.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _modifier(context),
            icon: const Icon(Icons.edit),
            label: const Text('Modifier les informations de la zone'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _enregistrer,
            icon: const Icon(Icons.save),
            label: const Text('Enregistrer les modifications'),
          ),
        ],
      ),
    );
  }
}
