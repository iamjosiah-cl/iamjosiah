import 'package:flutter/material.dart';

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
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(height: 2, width: 80, color: Colors.blue),
          const SizedBox(height: 32),

          // Texto principal
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Estudiante avanzado de Ingeniería Civil en Informática en la Universidad Adventista de Chile, '
                  'Desde pequeño, me ha gustado mostrar al mundo quién soy y las cosas que disfruto hacer en mi vida. '
                  'Te invito a conocerme desde aquí; no dudes en revisar todo lo que desees\n\n'
                  'Poseo conocimientos en PHP, bases de datos SQL (incluyendo PostgreSQL) y desarrollo web. '
                  'Me motiva aprender y adaptarme rápidamente a nuevas herramientas, aportando con soluciones creativas y eficientes.\n\n'
                  'Mi objetivo es integrarme a un equipo de desarrollo para aportar en la construcción de software de calidad '
                  'y fortalecer mis competencias profesionales en el ámbito informático.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
          const SizedBox(height: 32),

          // Tarjetas
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: const [
              FeatureCard(
                icon: Icons.code,
                title: 'Desarrollo de Software',
                description:
                'Experiencia en múltiples lenguajes y frameworks para crear soluciones efectivas.',
              ),
              FeatureCard(
                icon: Icons.storage,
                title: 'Bases de Datos',
                description:
                'Conocimientos en PostgreSQL, MySQL y Firebase para almacenamiento y gestión de datos.',
              ),
              FeatureCard(
                icon: Icons.school,
                title: 'Aprendizaje Continuo',
                description:
                'Compromiso con la adquisición de nuevas habilidades y actualización constante.',
              ),
              FeatureCard(
                icon: Icons.groups,
                title: 'Trabajo Colaborativo',
                description:
                'Capacidad para integrarse y contribuir efectivamente en equipos multidisciplinarios.',
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
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Colors.blue),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
