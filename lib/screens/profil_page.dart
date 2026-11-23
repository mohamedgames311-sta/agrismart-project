import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/providers/auth_provider.dart';
import 'package:agrismart/providers/reglages_provider.dart';
import 'package:agrismart/screens/crop_calendar_page.dart';

import 'a_propos_page.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  Future<void> _confirmerDeconnexion(BuildContext context) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirmation == true && context.mounted) {
      await context.read<AuthProvider>().deconnexion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final texte = Theme.of(context).textTheme;

    final nombreZones = context.select<ZonesProvider, int>(
          (p) => p.nombre,
    );

    final email = context.select<AuthProvider, String>(
          (a) => a.utilisateur?.email ?? '',
    );

    final themeMode = context.select<ReglagesProvider, ThemeMode>(
          (r) => r.themeMode,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 45,
                child: Icon(Icons.person, size: 50),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'AgriSmart',
                style: texte.headlineSmall,
              ),
            ),

            Center(child: Text(email)),

            const SizedBox(height: 30),

            Card(
              child: ListTile(
                leading: const Icon(Icons.grass),
                title: const Text('Zones suivies'),
                trailing: Text('$nombreZones'),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Calendrier des cultures'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CropCalendarPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            const ListTile(
              leading: Icon(Icons.brightness_6),
              title: Text('Thème'),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Système'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Clair'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Sombre'),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (choix) {
                  context
                      .read<ReglagesProvider>()
                      .changerTheme(choix.first);
                },
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('À propos'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AProposPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Se déconnecter'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _confirmerDeconnexion(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}