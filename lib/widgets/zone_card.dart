
import 'package:flutter/material.dart';
import 'package:agrismart/models/zone.dart';
import 'package:agrismart/theme/app_theme.dart';

class ZoneCard extends StatelessWidget {
  final Zone zone;
  final VoidCallback onAugmenter;
  final VoidCallback onDiminuer;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ZoneCard({
    super.key,
    required this.zone,
    required this.onAugmenter,
    required this.onDiminuer,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final couleur =
    zone.besoinIrrigation ? AppTheme.echec : AppTheme.succes;

    final culture = zone.culture;
    final initiales =
    culture.length >= 4 ? culture.substring(0, 4) : culture;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(
                  initiales,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      diagnostic(zone),
                      style: TextStyle(color: couleur),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: (zone.humidite / 100).clamp(0.0, 1.0),
                      color: couleur,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          zone.vanneOuverte
                              ? Icons.water
                              : Icons.water_drop_outlined,
                          size: 16,
                          color: zone.vanneOuverte
                              ? Colors.green
                              : null,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          zone.vanneOuverte
                              ? 'Vanne ouverte'
                              : 'Vanne fermée',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${zone.humidite.toStringAsFixed(0)} %',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onDiminuer,
                        icon: const Icon(Icons.remove),
                      ),
                      IconButton(
                        onPressed: onAugmenter,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
