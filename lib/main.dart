import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrismart/config.dart';
import 'package:agrismart/firebase_options.dart';
import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/providers/auth_provider.dart';
import 'package:agrismart/providers/meteo_provider.dart';
import 'package:agrismart/providers/reglages_provider.dart';
<<<<<<< HEAD
import 'package:agrismart/providers/calendar_provider.dart';
=======
import 'package:agrismart/providers/consommation_provider.dart'; // <-- IMPORT AJOUTÉ HERE
>>>>>>> origin/main
import 'package:agrismart/screens/auth_gate.dart';
import 'package:agrismart/services/auth_service.dart';
import 'package:agrismart/services/auth_locale_service.dart';
import 'package:agrismart/services/firebase_auth_service.dart';
import 'package:agrismart/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthService authService;

  if (utiliserFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    authService = FirebaseAuthService();
  } else {
    authService = AuthLocaleService();
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ConsommationProvider(), // <-- DÉCLARATION DU PROVIDER
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider(
          create: (context) => ZonesProvider(
            prefs,
            context.read<AuthProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MeteoProvider(prefs)..charger(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReglagesProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => CalendarProvider(prefs),
        ),
      ],
      child: const AgriSmartApp(),
    ),
  );
}

class AgriSmartApp extends StatelessWidget {
  const AgriSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriSmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clair(),
      darkTheme: AppTheme.sombre(),
      themeMode: context.watch<ReglagesProvider>().themeMode,
      home: const AuthGate(),
    );
  }
}