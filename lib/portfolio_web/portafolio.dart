import 'package:flutter/material.dart';

// Secciones individuales
import 'package:portafolio/portfolio_web/contacto.dart';
import 'package:portafolio/portfolio_web/educacion.dart';
import 'package:portafolio/portfolio_web/experiencia.dart';
import 'package:portafolio/portfolio_web/proyectos.dart';
import 'package:portafolio/portfolio_web/sobremi.dart';
import 'package:portafolio/portfolio_web/habilidades.dart';
import 'package:portafolio/portfolio_web/inicio.dart';   // contiene HeroTextSection
import 'package:portafolio/jugar/dashboard_juegos.dart';
import 'package:portafolio/portfolio_web/footer.dart';
import 'package:portafolio/styles/beacon_style.dart';
import 'package:portafolio/widgets/animations.dart';

/// Widget raíz que se muestra en la ruta "/portafolio"
class MyPortfolio extends StatelessWidget {
  const MyPortfolio({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(data: BeaconStyle.theme(), child: const HomePage());
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

  static const double _maxContentWidth = 1200;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll suave a la sección indicada
  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _section(GlobalKey key, Widget child) {
    return Center(
      key: key,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: child,
      ),
    );
  }

  Widget _avatar(double radius) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: BeaconStyle.accentGrad,
        boxShadow: [
          BoxShadow(color: Color(0x4022D3EE), blurRadius: 60, spreadRadius: 4),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: BeaconStyle.backgroundColor,
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundImage: const AssetImage('assets/iamjosiahiconfondo.png'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeaconStyle.backgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackgroundOrbs()),
          Column(
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
                child: Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ---------- PORTADA ----------
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth >= 800;
                            final hero = HeroTextSection(
                              onContactPressed: () => _scrollTo(_contactKey),
                              onPortfolioPressed: () => _scrollTo(_aboutKey),
                            );

                            return _section(
                              _homeKey,
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: isDesktop
                                      ? MediaQuery.sizeOf(context).height - 72
                                      : 0,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 40 : 20,
                                  vertical: isDesktop ? 40 : 32,
                                ),
                                alignment: Alignment.center,
                                child: isDesktop
                                    ? Row(
                                        children: [
                                          Expanded(flex: 3, child: hero),
                                          const SizedBox(width: 40),
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: FadeInAnimation(
                                                offset: const Offset(0.04, 0),
                                                child: _avatar(120),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          _avatar(72),
                                          const SizedBox(height: 28),
                                          hero,
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),

                        _section(_aboutKey, const AboutSection()),
                        _section(_skillsKey, const SkillsSection()),
                        _section(_experienceKey, const ExperienciaLaboralSection()),
                        _section(_educationKey, const EducationAndAchievementsSection()),
                        _section(_projectKey, const FeaturedProjectsSection()),
                        _section(_contactKey, const ContactSection()),
                        const Footer(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Barra de navegación superior
class NavBar extends StatelessWidget {
  final void Function(String section) onItemSelected;
  const NavBar({super.key, required this.onItemSelected});

  // Secciones + iconos
  static const Map<String, IconData> _icons = {
    'Inicio':      Icons.home_rounded,
    'Sobre Mí':    Icons.person_rounded,
    'Habilidades': Icons.build_rounded,
    'Experiencia': Icons.work_rounded,
    'Educación':   Icons.school_rounded,
    'Proyectos':   Icons.folder_rounded,
    'Contacto':    Icons.mail_rounded,
  };

  void _showPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.sports_esports_rounded, color: BeaconStyle.accent, size: 36),
        title: const Text('¿Quieres jugar?'),
        content: const Text(
          'Holaa, me gustan mucho los juegos,\n¿quieres jugar? ¡Encuéntrame!',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.pop(c),
          ),
          FilledButton(
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
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            ..._icons.keys.map((t) => _sheetItem(context, t)),
            const Divider(color: BeaconStyle.cardBorder),
            ListTile(
              leading: const Icon(Icons.sports_esports_rounded, color: BeaconStyle.accent),
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
      leading: Icon(_icons[title], color: BeaconStyle.iconMuted),
      title: Text(title, style: const TextStyle(color: BeaconStyle.textPrimary)),
      onTap: () {
        Navigator.pop(context);
        onItemSelected(title);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xD90B1220), // fondo @ 85%: legible sobre el contenido
        border: Border(bottom: BorderSide(color: BeaconStyle.cardBorder)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onItemSelected('Inicio'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Text.rich(
                      TextSpan(
                        text: 'I Am ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: BeaconStyle.accent,
                          letterSpacing: -0.3,
                        ),
                        children: [
                          TextSpan(
                            text: 'Josiah',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: BeaconStyle.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                if (isDesktop)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _icons.keys
                          .map((t) => _HoverNavItem(title: t, onTap: () => onItemSelected(t)))
                          .toList(),
                    ),
                  )
                else
                  const Spacer(),
                IconButton(
                  tooltip: '¿Quieres jugar?',
                  icon: const Icon(Icons.sports_esports_rounded, color: BeaconStyle.iconMuted),
                  onPressed: () => _showPlayDialog(context),
                ),
                if (!isDesktop)
                  IconButton(
                    tooltip: 'Menú',
                    icon: const Icon(Icons.menu_rounded, color: BeaconStyle.iconMuted),
                    onPressed: () => _openNavSheet(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ítem del menú con estado hover
class _HoverNavItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _HoverNavItem({required this.title, required this.onTap});

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
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovering ? const Color(0x14FFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _isHovering ? Colors.white : BeaconStyle.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
