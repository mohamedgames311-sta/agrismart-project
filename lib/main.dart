
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrismart/firebase_options.dart';
import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/providers/auth_provider.dart';
import 'package:agrismart/providers/meteo_provider.dart';
import 'package:agrismart/providers/reglages_provider.dart';
import 'package:agrismart/screens/auth_gate.dart';
import 'package:agrismart/services/auth_service.dart';
import 'package:agrismart/services/firebase_auth_service.dart';
import 'package:agrismart/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final AuthService authService = FirebaseAuthService();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
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
