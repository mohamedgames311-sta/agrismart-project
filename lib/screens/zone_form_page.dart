import 'package:flutter/material.dart';
import 'package:agrismart/models/zone.dart';
import 'package:agrismart/widgets/zone_form.dart';

// Form screen: returns the entered zone to the previous screen
// with Navigator.pop(context, zone), or null if the user goes back.
class ZoneFormPage extends StatelessWidget {
  final Zone? zone;
  final List<String> nomsExistants;

  const ZoneFormPage({
    super.key,
    this.zone,
    this.nomsExistants = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(zone == null ? 'Nouvelle zone' : 'Modifier la zone'),
      ),
      body: SingleChildScrollView(
        child: ZoneForm(
          zone: zone,
          nomsExistants: nomsExistants,
          onEnregistrer: (nouvelle) => Navigator.pop(context, nouvelle),
        ),
      ),
    );
  }
}