import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crop_task.dart';

class CalendarProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final List<CropTask> _taches = [];

  CalendarProvider(this._prefs) {
    _charger();
  }

  List<CropTask> get taches => List.unmodifiable(_taches);

  List<CropTask> tachesParZone(String zoneNom) {
    return _taches.where((t) => t.zoneNom == zoneNom).toList();
  }

  void ajouterTache(CropTask tache) {
    _taches.add(tache);
    _sauvegarder();
    notifyListeners();
  }

  void basculerEtat(String id) {
    final index = _taches.indexWhere((t) => t.id == id);
    if (index != -1) {
      _taches[index].estFaite = !_taches[index].estFaite;
      _sauvegarder();
      notifyListeners();
    }
  }

  void _charger() {
    final raw = _prefs.getString('crop_tasks');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      _taches.clear();
      _taches.addAll(decoded.map((e) => CropTask.fromJson(e)).toList());
    }
  }

  void _sauvegarder() {
    _prefs.setString('crop_tasks', jsonEncode(_taches.map((t) => t.toJson()).toList()));
  }
}