import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:portafolio/beacon.dart';
import 'package:portafolio/impresora.dart';
import 'package:portafolio/portafolio.dart';
import 'package:portafolio/jugar/dashboard_juegos.dart';
import 'firebase_options.dart';                      // Generado por FlutterFire

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'I Am Josiah',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => BeaconHome());
          case '/portafolio':
            return MaterialPageRoute(builder: (_) => const MyPortfolio());
          case '/print':
            return MaterialPageRoute(builder: (_) => const ChecklistPage());
          case '/juegos':
            return MaterialPageRoute(builder: (_) => const GamesPage());
          default:
            return MaterialPageRoute(builder: (_) => BeaconHome());
        }
      },
    );
  }
}
