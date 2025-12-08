import 'package:flutter/material.dart';

// Secciones individuales
import 'package:portafolio/contacto.dart';
import 'package:portafolio/educacion.dart';
import 'package:portafolio/experiencia.dart';
import 'package:portafolio/proyectos.dart';
import 'package:portafolio/sobremi.dart';
import 'package:portafolio/habilidades.dart';
import 'package:portafolio/inicio.dart';   // contiene HeroTextSection
import 'package:portafolio/jugar/dashboard_juegos.dart';
import 'package:portafolio/footer.dart';

/// Widget raíz que se muestra en la ruta "/portafolio"
class MyPortfolio extends StatelessWidget {
  const MyPortfolio({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚠ Si prefieres no anidar otro `MaterialApp`, cambia esto por `return HomePage();`
    return MaterialApp(
      title: 'I Am Josiah',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

/// Página con scroll y navegación interna
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  // Claves para cada sección
  final _homeKey       = GlobalKey();
  final _aboutKey      = GlobalKey();
  final _skillsKey     = GlobalKey();
  final _experienceKey = GlobalKey();
  final _educationKey  = GlobalKey();
  final _projectKey    = GlobalKey();
  final _contactKey    = GlobalKey();

  // Scroll suave a la sección indicada
  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Barra de navegación superior
          NavBar(
            onItemSelected: (section) {
              switch (section) {
                case 'Inicio':       _scrollTo(_homeKey);       break;
                case 'Sobre Mí':     _scrollTo(_aboutKey);      break;
                case 'Habilidades':  _scrollTo(_skillsKey);     break;
                case 'Experiencia':  _scrollTo(_experienceKey); break;
                case 'Educación':    _scrollTo(_educationKey);  break;
                case 'Proyectos':    _scrollTo(_projectKey);    break;
                case 'Contacto':     _scrollTo(_contactKey);    break;
              }
            },
          ),

          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- PORTADA ----------
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 800;

                      return Container(
                        key: _homeKey,
                        height: isDesktop ? MediaQuery.of(context).size.height : null,
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 40 : 20,
                          vertical: 20,
                        ),
                        child: isDesktop
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Héroe (texto)
                            Expanded(
                              flex: 2,
                              child: HeroTextSection(
                                onContactPressed: () => _scrollTo(_contactKey),
                                onPortfolioPressed: () => _scrollTo(_aboutKey),
                              ),
                            ),
                            // Avatar
                            Expanded(
                              flex: 1,
                              child: CircleAvatar(
                                radius: 100,
                                backgroundColor: Colors.blueAccent,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: CircleAvatar(
                                    radius: 94,
                                    backgroundImage: const AssetImage(
                                      'assets/iamjosiahiconfondo.png',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                            : Column(
                          children: [
                            HeroTextSection(
                              onContactPressed: () => _scrollTo(_contactKey),
                              onPortfolioPressed: () => _scrollTo(_aboutKey),
                            ),
                            const SizedBox(height: 24),
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.blueAccent,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: CircleAvatar(
                                  radius: 76,
                                  backgroundImage: const AssetImage(
                                    'assets/iamjosiahiconfondo.png',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // ---------- SECCIONES ----------
                  Container(key: _aboutKey,      child: const AboutSection()),
                  Container(key: _skillsKey,     child: const SkillsSection()),
                  Container(key: _experienceKey, child: const ExperienciaLaboralSection()),
                  Container(key: _educationKey,  child: const EducationAndAchievementsSection()),
                  Container(key: _projectKey,    child: const FeaturedProjectsSection()),
                  Container(key: _contactKey,    child: const ContactSection()),
                  const Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de navegación superior
class NavBar extends StatelessWidget {
  final void Function(String section) onItemSelected;
  NavBar({super.key, required this.onItemSelected});

  // Secciones + iconos
  final Map<String, IconData> _icons = const {
    'Inicio':      Icons.home,
    'Sobre Mí':    Icons.person,
    'Habilidades': Icons.build,
    'Experiencia': Icons.work,
    'Educación':   Icons.school,
    'Proyectos':   Icons.folder,
    'Contacto':    Icons.mail,
  };

  void _showPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('¿Quieres jugar?'),
        content: const Text(
          'Holaa, me gustan mucho los juegos,\n¿quieres jugar? ¡Encuéntrame!',
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.pop(c),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('¡Ir a Juegos!'),
            onPressed: () {
              Navigator.pop(c);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GamesPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openNavSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            ..._icons.keys.map((t) => _sheetItem(context, t)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.sports_esports),
              title: const Text('¿Quieres jugar?'),
              onTap: () {
                Navigator.pop(context);
                _showPlayDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  ListTile _sheetItem(BuildContext context, String title) {
    return ListTile(
      leading: Icon(_icons[title]),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onItemSelected(title);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16),
      child: Row(
        children: [
          Text.rich(
            TextSpan(
              text: 'I Am ',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              children: const [
                TextSpan(
                  text: 'Josiah',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          if (isDesktop)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _icons.keys.map((t) => _navItem(t)).toList(),
              ),
            )
          else
            const Spacer(),
          IconButton(
            tooltip: '¿Quieres jugar?',
            icon: const Icon(Icons.sports_esports),
            onPressed: () => _showPlayDialog(context),
          ),
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _openNavSheet(context),
            ),
        ],
      ),
    );
  }

  Widget _navItem(String title) {
    // Usamos el widget con estado para el hover
    return _HoverNavItem(
      title: title,
      onTap: () => onItemSelected(title),
    );
  }
}

/// Widget interno para manejar el estado Hover de cada ítem del menú
class _HoverNavItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _HoverNavItem({
    required this.title,
    required this.onTap,
  });

  @override
  State<_HoverNavItem> createState() => _HoverNavItemState();
}

class _HoverNavItemState extends State<_HoverNavItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_)  => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovering ? Colors.blue.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 16,
              color: _isHovering ? Colors.blue : Colors.black,
              fontWeight: _isHovering ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
} // Closing _HoverNavItemState
