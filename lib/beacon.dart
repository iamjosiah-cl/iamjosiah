// lib/beacon.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:portafolio/impresora.dart';
import 'package:url_launcher/url_launcher.dart';

import 'portafolio.dart'; // pantalla de portafolio
import 'package:portafolio/jugar/dashboard_juegos.dart';
import 'package:portafolio/jugar/game_wrapper.dart';
import 'package:portafolio/jugar/puzzle1/titulo.dart';
import 'package:portafolio/jugar/puzzle2/titulo.dart';
import 'package:portafolio/jugar/puzzle3/titulo.dart';

class Beacon extends StatelessWidget {
  const Beacon({super.key});

  @override
  Widget build(BuildContext context) {
    // Meta-etiquetas eliminadas
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BeaconHome(),
    );
  }
}

String? nullableValue;

class BeaconHome extends StatelessWidget {
  const BeaconHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // Banner
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.white],
                      ),
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),

                  // Avatar
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 47,
                      backgroundImage:
                      AssetImage('assets/iamjosiahiconfondo.png'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nombre / descripción
                  const Text(
                    '@iamjosiah.cl',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const Text(
                    'Programador, editor e ingeniero',
                    style: TextStyle(color: Colors.white38),
                  ),

                  const SizedBox(height: 12),

                  // Redes sociales
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _socialIcon(LucideIcons.instagram,
                          'https://www.instagram.com/iamjosiah.cl/'),
                      _socialIcon(
                          Icons.tiktok, 'https://www.tiktok.com/@jota_windu'),
                      _socialIcon(LucideIcons.youtube,
                          'https://www.youtube.com/@iamjosiah-cl'),
                      _socialIcon(
                          LucideIcons.github, 'https://github.com/iamjosiah'),
                      _socialIcon(LucideIcons.twitch,
                          'https://www.twitch.tv/jotawindu'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle('Mi Portafolio'),
                  _portfolioLinkCard(context),
                  _impresoraLinkCard(context),
                  
                  _sectionTitle('Zona de Juegos'),
                  _linkCardWithIcon(
                    Icons.videogame_asset,
                    'Puzzles',
                    'Ver todos los desafíos disponibles',
                    '', // Navegación interna
                    const Color(0xFFF59E0B), // Amber/Orange
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GamesPage()),
                    ),
                  ),
            

                  _sectionTitle('Mis Redes'),
                  _linkCardWithIcon(
                    LucideIcons.instagram,
                    'Instagram',
                    'Contenido de mi vida personal',
                    'https://www.instagram.com/iamjosiah.cl/',
                    const Color(0xFFEC4899),
                  ),
                  _linkCardWithIcon(
                    Icons.play_arrow,
                    'YouTube',
                    'Videos de los proyectos en los que he estado',
                    'https://youtube.com',
                    const Color(0xFFEF4444),
                  ),

                  const SizedBox(height: 32),
                  const Text('📧 josiasjofre@gmail.com',
                      style: TextStyle(color: Colors.white54)),
                  const Text('© 2025 Iam Josiah',
                      style: TextStyle(color: Colors.white30)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* ──────────────────────────  HELPERS  ────────────────────────── */

  // Ícono de red social
  Widget _socialIcon(IconData icon, String url) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70),
      onPressed: () => launchUrl(Uri.parse(url)),
    );
  }

  // Tarjeta del portafolio
  Widget _portfolioLinkCard(BuildContext context) {
    return _linkCard(
      'P',
      'Portafolio Completo',
      'Mis trabajos más recientes',
      '', // navegación interna
      const Color(0xFF8B5CF6),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyPortfolio()),
      ),
    );
  }
  Widget _impresoraLinkCard(BuildContext context) {
    return _linkCard(
      'I',
      'Impresora de ticket',
      'Implementación actual de un proyecto personal.',
      '', // navegación interna
      const Color(0xFF8B5CF6),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChecklistPage()),
      ),
    );
  }

  // Sección
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.folder, color: Colors.white30),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta genérica
  Widget _linkCard(String iconLetter, String title, String subtitle, String url,
      Color color,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: url.isNotEmpty ? () => launchUrl(Uri.parse(url)) : onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white12,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
            child: Text(iconLetter, style: const TextStyle(color: Colors.white)),
          ),
          title: Text(title, style: const TextStyle(color: Colors.white70)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38)),
          trailing: const Icon(Icons.open_in_new, color: Colors.white24),
        ),
      ),
    );
  }

  // Tarjeta con ícono y enlace externo (o interno si se prosee onTap)
  Widget _linkCardWithIcon(
      IconData icon, String title, String subtitle, String url, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
        if (url.isNotEmpty) {
          launchUrl(Uri.parse(url));
        } else if (onTap != null) {
          onTap();
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white12,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title, style: const TextStyle(color: Colors.white70)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38)),
          trailing: const Icon(Icons.open_in_new, color: Colors.white24),
        ),
      ),
    );
  }
}
