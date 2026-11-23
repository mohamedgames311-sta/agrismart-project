import 'package:flutter/material.dart';

class AProposPage extends StatelessWidget {
  const AProposPage({super.key});

  @override
  Widget build(BuildContext context) {
    final texte = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AgriSmart', style: texte.headlineMedium),
            const SizedBox(height: 4),
            Text('Version 1.0.0', style: texte.bodyMedium),
            const SizedBox(height: 16),
            const Text(
              "AgriSmart est une application de suivi des zones d'une "
                  "exploitation agricole : humidité du sol, besoin d'irrigation "
                  "et état des vannes.",
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}