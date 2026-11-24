import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:agrismart/models/zone.dart';
import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/screens/zone_detail_page.dart';

class ScanResult {
  final String code;
  final DateTime timestamp;
  final String categorie;
  final String description;

  ScanResult({
    required this.code,
    required this.timestamp,
    required this.categorie,
    required this.description,
  });
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scanAnimation;

  bool _flashActive = false;
  bool _enNumerisation = true;
  ScanResult? _dernierResultat;

  final List<ScanResult> _historique = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _manualCodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _manualCodeCtrl.dispose();
    super.dispose();
  }

  void _traiterCodeScanne(String codeBrut) {
    if (codeBrut.trim().isEmpty) return;

    final code = codeBrut.trim();
    String categorie = 'Code inconnu';
    String description = 'Code barres / QR scanné avec succès';

    final zones = context.read<ZonesProvider>().zones;
    final matchZone = zones.firstWhere(
          (z) => z.nom.toLowerCase() == code.toLowerCase() ||
          code.toLowerCase().contains(z.nom.toLowerCase()) ||
          'zone-${z.nom}'.toLowerCase() == code.toLowerCase(),
      orElse: () => Zone('', '', 0, 0),
    );

    if (matchZone.nom.isNotEmpty) {
      categorie = 'Zone Agricole (${matchZone.nom})';
      description =
      'Culture: ${matchZone.culture} | Humidité: ${matchZone.humidite.toStringAsFixed(0)}% | Seuil: ${matchZone.seuil.toStringAsFixed(0)}%';
    } else if (code.toUpperCase().startsWith('CAPTEUR') ||
        code.toUpperCase().contains('SENSOR')) {
      categorie = 'Capteur Sol / IoT';
      description = 'Capteur d\'humidité et de température synchronisé.';
    } else if (code.toUpperCase().startsWith('NPK') ||
        code.toUpperCase().contains('ENGRAIS') ||
        code.toUpperCase().contains('FERTIL')) {
      categorie = 'Produit / Engrais';
      description = 'Substance fertilisante homologuée AgriSmart.';
    } else if (code.toUpperCase().startsWith('POMPE') ||
        code.toUpperCase().contains('VANNE') ||
        code.toUpperCase().contains('PUMP')) {
      categorie = 'Équipement d\'irrigation';
      description = 'Vanne motorisée / Système de pompage d\'eau.';
    }

    final nouveauResultat = ScanResult(
      code: code,
      timestamp: DateTime.now(),
      categorie: categorie,
      description: description,
    );

    setState(() {
      _dernierResultat = nouveauResultat;
      _historique.insert(0, nouveauResultat);
      _enNumerisation = false;
    });
  }

  Future<void> _prendrePhotoAvecCamera() async {
    try {
      final zonesProvider = context.read<ZonesProvider>();
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        if (!mounted) return;
        final zones = zonesProvider.zones;
        String codeExtrait;
        if (zones.isNotEmpty) {
          final sampleCodes = [
            ...zones.map((z) => z.nom),
            'CAPTEUR-SOL-01',
            'NPK-20-20-20',
            'VANNE-POMPE-01'
          ];
          codeExtrait = (sampleCodes..shuffle()).first;
        } else {
          codeExtrait = 'CAPTEUR-SOL-01';
        }

        _traiterCodeScanne(codeExtrait);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo prise avec succès ! Code scanné : $codeExtrait'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ouverture de la caméra : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _scannerDepuisGalerie() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      // Simuler l'extraction de code QR à partir d'une image choisie dans la galerie
      final fakeCodes = [
        'ZONE-001',
        'Capteur-Humidité-A1',
        'NPK-20-20-20',
        'Vanne-Pompe-Sud'
      ];
      final codeExtrait = (fakeCodes..shuffle()).first;

      _traiterCodeScanne(codeExtrait);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code détecté dans la photo : $codeExtrait'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _saisirCodeManuellement() {
    _manualCodeCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.keyboard, color: Colors.green),
            SizedBox(width: 8),
            Text('Saisie manuelle de code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entrez le code QR ou le code-barres de la zone, du capteur ou du produit :',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _manualCodeCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Code (ex: Zone Nord, CAPTEUR-01, NPK-15)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final val = _manualCodeCtrl.text.trim();
              Navigator.pop(ctx);
              if (val.isNotEmpty) {
                _traiterCodeScanne(val);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _recommencerScan() {
    setState(() {
      _enNumerisation = true;
      _dernierResultat = null;
    });
  }

  Future<void> _ouvrirDetailZoneAssociee(Zone zone) async {
    final provider = context.read<ZonesProvider>();
    final noms = provider.noms(sauf: zone);

    final modifiee = await Navigator.push<Zone>(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneDetailPage(
          zone: zone,
          nomsAutres: noms,
        ),
      ),
    );

    if (modifiee != null && mounted) {
      provider.remplacer(zone, modifiee);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zone mise à jour après scan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zones = context.watch<ZonesProvider>().zones;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner),
            SizedBox(width: 8),
            Text('Scanner Code'),
          ],
        ),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'Prendre photo (Caméra)',
            icon: const Icon(Icons.camera_alt),
            onPressed: _prendrePhotoAvecCamera,
          ),
          IconButton(
            tooltip: _flashActive ? 'Désactiver Flash' : 'Activer Flash',
            icon: Icon(
              _flashActive ? Icons.flash_on : Icons.flash_off,
              color: _flashActive ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                _flashActive = !_flashActive;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _flashActive ? 'Flash activé' : 'Flash désactivé',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Galerie photo',
            icon: const Icon(Icons.photo_library),
            onPressed: _scannerDepuisGalerie,
          ),
        ],
      ),
      body: Column(
        children: [
          // Section Viseur de Caméra / Viseur de Scan
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _enNumerisation ? 280 : 160,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arrière-plan simulation caméra
                Opacity(
                  opacity: 0.15,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?q=80&w=600&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => Container(color: Colors.black54),
                  ),
                ),

                if (_enNumerisation) ...[
                  // Cadre de numérisation QR
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _flashActive ? Colors.amber : Colors.greenAccent,
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  // Ligne de balayage animée
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 50 + (_scanAnimation.value * 160),
                        child: Container(
                          width: 180,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withValues(alpha: 0.8),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Alignez le code QR dans le cadre',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ] else ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.greenAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Scan Effectué avec succès !',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _recommencerScan,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Scanner à nouveau'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Options Caméra, Galerie & Saisie manuelle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _prendrePhotoAvecCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Caméra'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _scannerDepuisGalerie,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galerie'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saisirCodeManuellement,
                    icon: const Icon(Icons.keyboard),
                    label: const Text('Saisir'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Raccourcis de simulation de codes pour test instantané
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Codes rapides : ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ...zones.take(3).map((z) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    avatar: const Icon(Icons.grass, size: 16),
                    label: Text(z.nom),
                    onPressed: () => _traiterCodeScanne(z.nom),
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    avatar: const Icon(Icons.sensors, size: 16),
                    label: const Text('CAPTEUR-01'),
                    onPressed: () => _traiterCodeScanne('CAPTEUR-01'),
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.sanitizer, size: 16),
                  label: const Text('NPK-ENGRAIS'),
                  onPressed: () => _traiterCodeScanne('NPK-20-20-20'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Contenu principal : Résultat du scan OU Historique
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _dernierResultat != null
                  ? _buildResultCard(context, _dernierResultat!, zones)
                  : _buildHistoriqueList(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
      BuildContext context, ScanResult resultat, List<Zone> zones) {
    // Vérifier si le code correspond à une zone
    Zone? zoneMatch;
    for (final z in zones) {
      if (z.nom.toLowerCase() == resultat.code.toLowerCase() ||
          resultat.code.toLowerCase().contains(z.nom.toLowerCase())) {
        zoneMatch = z;
        break;
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(
                    zoneMatch != null
                        ? Icons.grass
                        : Icons.qr_code_2,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resultat.categorie,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Code : ${resultat.code}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copier le code',
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: resultat.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copié dans le presse-papiers'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              resultat.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Si c'est une zone reconnue, proposer les actions directes !
            if (zoneMatch != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      zoneMatch.besoinIrrigation
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle,
                      color: zoneMatch.besoinIrrigation
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        zoneMatch.besoinIrrigation
                            ? 'Irrigation recommandée (Humidité: ${zoneMatch.humidite.toStringAsFixed(0)}%)'
                            : 'Niveau d\'humidité optimal (${zoneMatch.humidite.toStringAsFixed(0)}%)',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _ouvrirDetailZoneAssociee(zoneMatch!),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Voir la Zone'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      context
                          .read<ZonesProvider>()
                          .modifierHumidite(zoneMatch!, 10);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Humidité de ${zoneMatch.nom} augmentée (+10%)'),
                        ),
                      );
                      setState(() {});
                    },
                    icon: const Icon(Icons.water_drop, color: Colors.blue),
                    label: const Text('+10% Eau'),
                  ),
                ],
              ),
            ],

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _recommencerScan,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scanner un autre code'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoriqueList(BuildContext context) {
    if (_historique.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Aucun code scanné pour l\'instant',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Scannez un QR code ou choisissez un code rapide ci-dessus.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Historique des Scans',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _historique.clear();
                });
              },
              child: const Text('Effacer', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _historique.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _historique[index];
              return ListTile(
                leading: const CircleAvatar(
                  radius: 18,
                  child: Icon(Icons.qr_code, size: 18),
                ),
                title: Text(item.code,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${item.categorie} • ${_formaterHeure(item.timestamp)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  setState(() {
                    _dernierResultat = item;
                    _enNumerisation = false;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formaterHeure(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

