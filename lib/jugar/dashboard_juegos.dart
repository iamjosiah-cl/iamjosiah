
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:portafolio/portfolio_web/portafolio.dart'; // Para volver al inicio si es necesario
import 'package:portafolio/jugar/game_wrapper.dart';
// Importamos los juegos existentes
import 'package:portafolio/jugar/puzzle1/titulo.dart';
import 'package:portafolio/jugar/puzzle2/titulo.dart';
import 'package:portafolio/jugar/puzzle3/titulo.dart';
import 'package:url_launcher/url_launcher.dart';



import 'package:flutter/services.dart';
import 'package:portafolio/styles/beacon_style.dart';
import 'package:portafolio/widgets/animations.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final String _displayName = "Iam Josiah"; // Nombre por defecto

  void _goToHome() {
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyPortfolio()));
  }

  List<Map<String, dynamic>> _obtenerJuegos() {
    return [
      {
        'title': 'El Código Secreto',
        'icon': Icons.vpn_key,
        'color': Colors.deepPurple,
        'widget': const Inicio1(),
      },
      {
        'title': 'Buscando los números',
        'icon': Icons.find_in_page,
        'color': Colors.blue,
        'widget': const Inicio2(),
      },
      {
        'title': 'Patrones y colores',
        'icon': Icons.grid_3x3,
        'color': Colors.green,
        'widget': const Inicio3(),
      },
    
    ];
  }

  @override
  void initState() {
    super.initState();
    // Aseguramos que al volver al dashboard la orientación y UI sean normales
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Para que el fondo cubra todo
      backgroundColor: BeaconStyle.backgroundColor,
      appBar: _buildAppBar(context),
      body: Stack( // Stack para el fondo animado
        children: [
           const Positioned.fill(child: AnimatedBackgroundOrbs()),
           SafeArea( // SafeArea para evitar solapamiento con AppBar si no es transparente total
             child: FutureBuilder<List<bool>>(
              future: _cargarEstadosDeJuegos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.cyanAccent),
                  );
                }
                return _buildContenidoJuegos(snapshot.data!);
              },
            ),
           ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // Transparente sobre el fondo animado
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white), // Iconos blancos
      automaticallyImplyLeading: false, 
      title: Text(
        _displayName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.cyanAccent), // Color marca
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home, size: 26, color: Colors.white),
          tooltip: 'Volver al inicio',
          onPressed: _goToHome,
        ),
        // Menu simplificado para portafolio
        if (MediaQuery.of(context).size.width > 800) ...[
          _buildTextButton(context, 'Juegos', const GamesPage()),
        ],
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildContenidoJuegos(List<bool> estados) {
    final juegos = _obtenerJuegos();
    // Aseguramos que la lista de estados coincida con juegos
    final estadosRecortados = List<bool>.filled(juegos.length, true);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth > 600 ? 32.0 : 16.0,
              vertical: 24.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   FadeInAnimation(
                     animateInView: true,
                     delay: const Duration(milliseconds: 200),
                     child: _buildHeroSection(),
                   ),
                  const SizedBox(height: 40),

                  FadeInAnimation(
                    animateInView: true,
                    delay: const Duration(milliseconds: 400),
                    child: _buildSectionWithGames(
                      'Puzzles Disponibles 🧩',
                      'Desafía tu mente con estos juegos',
                      juegos,
                      estadosRecortados,
                      screenWidth,
                      Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: BeaconStyle.cardBgGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BeaconStyle.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.games, size: 64, color: Colors.cyanAccent),
          const SizedBox(height: 16),
          const Text(
            '¡Bienvenido a la Zona de Juegos!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: BeaconStyle.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Todos los juegos están desbloqueados para ti',
            style: TextStyle(fontSize: 18, color: BeaconStyle.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionWithGames(
      String titulo,
      String descripcion,
      List<Map<String, dynamic>> juegos,
      List<bool> estados,
      double screenWidth,
      Color backgroundColor,
      ) {
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth > 1200) {
      crossAxisCount = 5;
      childAspectRatio = 0.75;
    } else if (screenWidth > 900) {
      crossAxisCount = 4;
      childAspectRatio = 0.8;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
      childAspectRatio = 0.85;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.9;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BeaconStyle.cardBgGlass, // Glass background for section
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BeaconStyle.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: BeaconStyle.textPrimary)),
          const SizedBox(height: 8),
          Text(descripcion, style: const TextStyle(fontSize: 16, color: BeaconStyle.textSecondary)),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: juegos.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              return FadeInAnimation(
                animateInView: true,
                delay: Duration(milliseconds: 600 + (index * 100)),
                child: _buildGameCard(
                  context,
                  juegos[index],
                  estados[index],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
      BuildContext context,
      Map<String, dynamic> gameData,
      bool isEnabled,
      ) {
    // Variable para estado hover local si se desea implementar separado, 
    // pero aquí usamos InkWell simple
    return Card(
      elevation: 4,
      color: BeaconStyle.cardBg.withOpacity(0.5), // Dark transparent card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: BeaconStyle.cardBorder, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => GameWrapper(child: gameData['widget'] as Widget)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: (gameData['color'] as Color? ?? Colors.grey).withOpacity(0.1), // More subtle background
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Center(
                  child: Icon(
                    gameData['icon'] as IconData? ?? Icons.gamepad,
                    size: 64,
                    color: gameData['color'] as Color? ?? Colors.grey,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    gameData['title'] as String,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: BeaconStyle.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Siempre retorna true para todo
  Future<List<bool>> _cargarEstadosDeJuegos() async {
    final count = _obtenerJuegos().length;
    return List<bool>.filled(count, true);
  }
  // Removed extra brace

  TextButton _buildTextButton(BuildContext context, String label, Widget page) {
    return TextButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Text(label, style: const TextStyle(color: Colors.cyanAccent)),
    );
  }
}

/// Widget placeholder para juegos no implementados
class PlaceholderGame extends StatelessWidget {
  final String title;
  const PlaceholderGame({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text('El juego "$title" está en construcción.', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
