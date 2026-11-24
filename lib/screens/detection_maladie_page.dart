import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agrismart/models/maladie_plante.dart';
import 'package:agrismart/services/detection_maladie_service.dart';

class DetectionMaladiePage extends StatefulWidget {
  const DetectionMaladiePage({super.key});

  @override
  State<DetectionMaladiePage> createState() => _DetectionMaladiePageState();
}

class _DetectionMaladiePageState extends State<DetectionMaladiePage> {
  XFile? _image;
  bool _chargement = false;
  MaladiePlante? _resultat;

  final ImagePicker _picker = ImagePicker();

  Future<void> _selectionnerImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = picked;
        _resultat = null;
        _chargement = true;
      });

      final res = await DetectionMaladieService.analyserImagePlante(picked.path);

      setState(() {
        _resultat = res;
        _chargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détection des Maladies'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: _image != null
                  ? (kIsWeb
                  ? Image.network(_image!.path, fit: BoxFit.cover)
                  : Image.file(File(_image!.path), fit: BoxFit.cover))
                  : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Prenez ou importez une photo de la plante'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _selectionnerImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Caméra'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectionnerImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galerie'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_chargement)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Analyse de la plante en cours...'),
                ],
              )
            else if (_resultat != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _resultat!.nomMaladie,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Plante : ${_resultat!.nomPlante} (${(_resultat!.confiance * 100).toStringAsFixed(0)}% certitude)'),
                      const Divider(),
                      const Text('Symptômes :', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_resultat!.description),
                      const SizedBox(height: 10),
                      const Text('Traitement conseillé :', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      Text(_resultat!.traitementConseille),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}