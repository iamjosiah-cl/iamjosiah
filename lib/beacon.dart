// lib/beacon.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:portafolio/portfolio_web/portafolio.dart';
import 'package:portafolio/portfolio_web/proyectos.dart';
import 'package:portafolio/jugar/dashboard_juegos.dart';
import 'package:portafolio/widgets/animations.dart';
import 'package:portafolio/styles/beacon_style.dart';

class BeaconHome extends StatelessWidget {
  const BeaconHome({super.key});

  // ✅ Paleta unificada (slate + indigo/cyan)
  static const backgroundColor = Color(0xFF0B1220); // más profundo y consistente

  static const cardBg = Color(0xFF0F172A); // slate-900
  static const cardBgGlass = Color(0xCC0F172A); // glass
  static const cardBorder = Color(0x33475569); // slate-600 @ 20%

  static const textPrimary = Color(0xFFE2E8F0); // slate-200
  static const textSecondary = Color(0xFF94A3B8); // slate-400

  static const iconMuted = Color(0xFFCBD5E1); // slate-300

  // Gradiente marca (cyan -> violet)
  static const accentGrad = LinearGradient(
    colors: [Color(0xFF22D3EE), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    // For local assets in Flutter Web, we can try to use the raw path if it's an asset
    if (url.startsWith('assets/')) {
      final assetPath = url;
      await launchUrl(
        Uri.parse(assetPath),
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    final ok = await canLaunchUrl(uri);
    if (!ok) return;

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Widget _socialIcon(IconData icon, String url) {
    return IconButton(
      icon: Icon(icon, color: iconMuted, size: 24),
      onPressed: () => _openUrl(url),
      tooltip: url,
      splashRadius: 22,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _linkCardUnified({
    required Widget leading,
    required String title,
    required String subtitle,
    String url = '',
    VoidCallback? onTap,
    IconData trailingIcon = Icons.open_in_new,
  }) {
    return _HoverableLinkCard(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailingIcon: trailingIcon,
      onTap: () {
        if (url.isNotEmpty) {
          _openUrl(url);
          return;
        }
        onTap?.call();
      },
    );
  }

  Widget _letterAvatar(String letter, Color color) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 20,
      child: Text(
        letter,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _iconAvatar(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 20,
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) =>
      Theme(data: BeaconStyle.theme(), child: Builder(builder: _build));

  Widget _build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackgroundOrbs()),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: FadeInAnimation(
                    child: Card(
                    color: cardBgGlass, // ✅ glass slate
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: cardBorder, width: 1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),

                          // Banner + Avatar
                          Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF2563EB), Color(0xFF22D3EE), Color(0xFF8B5CF6)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                const Positioned(
                                  bottom: -50,
                                  child: CircleAvatar(
                                      radius: 54,
                                      backgroundColor: Color(0xFF0B1220),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Color(0xFF22D3EE),
                                        child: CircleAvatar(
                                          radius: 47,
                                          backgroundImage:
                                              AssetImage('assets/iamjosiahiconfondo.png'),
                                        ),
                                      ),
                                    ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 60),

                          const TypingText(
                              animateInView: true,
                              text: '@iamjosiah.cl',
                              duration: Duration(seconds: 1),
                              startDelay: Duration(milliseconds: 800),
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          const SizedBox(height: 4),
                          const Text(
                              'Programador, editor e ingeniero',
                              style: TextStyle(color: textSecondary, fontSize: 14),
                            ),

                          const SizedBox(height: 24),

                          // Redes
                          Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              children: [
                                _socialIcon(
                                  LucideIcons.linkedin,
                                  'https://www.linkedin.com/in/josias-alexis-jofre-pol-a98688341/',
                                ),
                                _socialIcon(
                                  LucideIcons.instagram,
                                  'https://www.instagram.com/iamjosiah.cl/',
                                ),
                                _socialIcon(
                                  LucideIcons.video,
                                  'https://www.tiktok.com/@jota_windu',
                                ),
                                _socialIcon(
                                  LucideIcons.youtube,
                                  'https://www.youtube.com/@iamjosiah-cl',
                                ),
                                _socialIcon(
                                  LucideIcons.github,
                                  'https://github.com/iamjosiah',
                                ),
                                _socialIcon(
                                  LucideIcons.twitch,
                                  'https://www.twitch.tv/jotawindu',
                                ),
                              ],
                            ),

                          const SizedBox(height: 32),

                          Column(
                              children: [
                                _sectionTitle('Mis Proyectos'),
                                _linkCardUnified(
                                  leading: _letterAvatar('P', const Color(0xFF6366F1)),
                                  title: 'Mis Proyectos',
                                  subtitle: 'Documentación y detalles independientes',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ProjectsPage()),
                                  ),
                                ),
                                  _linkCardUnified(
                                    leading: _letterAvatar('C', const Color(0xFF8B5CF6)),
                                    title: 'Curriculum Web',
                                    subtitle: 'Ver mi experiencia y formación interactiva',
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const MyPortfolio()),
                                    ),
                                  ),
                                  _linkCardUnified(
                                    leading: _iconAvatar(Icons.download, const Color(0xFF10B981)),
                                    title: 'Descargar CV',
                                    subtitle: 'Obtener versión en PDF para impresión \nActualizado el 29/01/2026',
                                    onTap: () => _openUrl('assets/CV_Josias_Jofre.pdf'),
                                  ),
                              ],
                            ),

                          Column(
                              children: [
                                _sectionTitle('Zona de Juegos'),
                                _linkCardUnified(
                                  leading: _iconAvatar(
                                    Icons.videogame_asset,
                                    const Color(0xFF14B8A6),
                                  ),
                                  title: 'Puzzles',
                                  subtitle: 'Ver todos los desafíos disponibles',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const GamesPage()),
                                  ),
                                  trailingIcon: Icons.arrow_forward,
                                ),
                              ],
                            ),

                          Column(
                              children: [
                                _sectionTitle('Mis Redes'),
                                _linkCardUnified(
                                  leading: _iconAvatar(
                                    LucideIcons.instagram,
                                    const Color(0xFFF472B6),
                                  ),
                                  title: 'Instagram',
                                  subtitle: 'Contenido de mi vida personal',
                                  url: 'https://www.instagram.com/iamjosiah.cl/',
                                ),
                                _linkCardUnified(
                                  leading: _iconAvatar(
                                    Icons.play_arrow,
                                    const Color(0xFF38BDF8),
                                  ),
                                  title: 'YouTube',
                                  subtitle: 'Videos de los proyectos en los que he estado',
                                  url: 'https://youtube.com',
                                ),
                              ],
                            ),

                          const SizedBox(height: 32),
                          const Text(
                            '📧 josiasjofre@gmail.com',
                            style: TextStyle(color: textSecondary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '© 2025 Iam Josiah',
                            style: TextStyle(color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}

class _HoverableLinkCard extends StatefulWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData trailingIcon;

  const _HoverableLinkCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingIcon = Icons.open_in_new,
  });

  @override
  State<_HoverableLinkCard> createState() => _HoverableLinkCardState();
}

class _HoverableLinkCardState extends State<_HoverableLinkCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSlide(
          offset: Offset(_isHovered ? 0.006 : 0, 0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: _isHovered ? const Color(0x14FFFFFF) : const Color(0x0AFFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isHovered ? BeaconStyle.cardBorderHover : BeaconStyle.cardBorder,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  widget.leading,
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: BeaconHome.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(color: BeaconHome.textSecondary, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  // Animated Icon Color
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    child: Icon(
                      widget.trailingIcon,
                      // Blanco al hover, muted (slate-300) si no
                      color: _isHovered ? BeaconStyle.accent : BeaconHome.iconMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
