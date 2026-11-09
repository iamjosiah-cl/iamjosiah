import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:portafolio/beacon.dart';
import 'package:portafolio/portfolio_web/portafolio.dart';
import 'package:portafolio/jugar/dashboard_juegos.dart';
import 'package:portafolio/styles/beacon_style.dart';
import 'firebase_options.dart';                      // Generado por FlutterFire

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Por defecto es 500 ms: retrasaba todas las animaciones al hacer scroll.
  VisibilityDetectorController.instance.updateInterval =
      const Duration(milliseconds: 50);
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
      // Tema base: solo transiciones rápidas. Las páginas del portafolio
      // aplican BeaconStyle.theme() con un Theme propio.
      theme: ThemeData(pageTransitionsTheme: BeaconStyle.fastTransitions),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => BeaconHome());
          case '/portafolio':
            return MaterialPageRoute(builder: (_) => const MyPortfolio());
          case '/juegos':
            return MaterialPageRoute(builder: (_) => const GamesPage());
          default:
            return MaterialPageRoute(builder: (_) => BeaconHome());
        }
      },
    );
  }
}
