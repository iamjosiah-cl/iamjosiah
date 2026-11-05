import 'package:flutter/material.dart';
import 'package:portafolio/styles/beacon_style.dart';
import 'package:portafolio/widgets/animations.dart';
import 'package:portafolio/widgets/ui.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Sobre Mí',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: BeaconStyle.textPrimary),
          ),
          const SizedBox(height: 12),
          const AccentBar(),
          const SizedBox(height: 32),

          // Texto principal
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Ingeniero Civil en Informática titulado de la Universidad Adventista de Chile, '
                  'Desde pequeño, me ha gustado mostrar al mundo quién soy y las cosas que disfruto hacer en mi vida. '
                  'Te invito a conocerme desde aquí; no dudes en revisar todo lo que desees\n\n'
                  'Poseo conocimientos en PHP, bases de datos SQL (incluyendo PostgreSQL) y desarrollo web. '
                  'Me motiva aprender y adaptarme rápidamente a nuevas herramientas, aportando con soluciones creativas y eficientes.\n\n'
                  'Mi objetivo es integrarme a un equipo de desarrollo para aportar en la construcción de software de calidad '
                  'y fortalecer mis competencias profesionales en el ámbito informático.',
              style: TextStyle(fontSize: 17, height: 1.75, color: BeaconStyle.textSecondary),
            ),
          ),
          const SizedBox(height: 32),

          // Tarjetas
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: const [
              FadeInAnimation(
                animateInView: true,
                delay: Duration(milliseconds: 200),
                child: FeatureCard(
                  icon: Icons.code,
                  title: 'Desarrollo de Software',
                  description: 'Experiencia en múltiples lenguajes y frameworks para crear soluciones efectivas.',
                ),
              ),
              FadeInAnimation(
                animateInView: true,
                delay: Duration(milliseconds: 400),
                child: FeatureCard(
                  icon: Icons.storage,
                  title: 'Bases de Datos',
                  description: 'Conocimientos en PostgreSQL, MySQL y Firebase para almacenamiento y gestión de datos.',
                ),
              ),
              FadeInAnimation(
                animateInView: true,
                delay: Duration(milliseconds: 600),
                child: FeatureCard(
                  icon: Icons.school,
                  title: 'Aprendizaje Continuo',
                  description: 'Compromiso con la adquisición de nuevas habilidades y actualización constante.',
                ),
              ),
              FadeInAnimation(
                animateInView: true,
                delay: Duration(milliseconds: 800),
                child: FeatureCard(
                  icon: Icons.groups,
                  title: 'Trabajo Colaborativo',
                  description: 'Capacidad para integrarse y contribuir efectivamente en equipos multidisciplinarios.',
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      width: 270,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BeaconStyle.accent.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: BeaconStyle.accent),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: BeaconStyle.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 14, height: 1.5, color: BeaconStyle.textSecondary),
          ),
        ],
      ),
    );
  }
}
