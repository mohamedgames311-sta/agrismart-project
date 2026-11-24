import 'package:flutter/material.dart';

class StatBox extends StatelessWidget {
  final String valeur;
  final String libelle;

  const StatBox({super.key, required this.valeur, required this.libelle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            valeur,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(libelle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}