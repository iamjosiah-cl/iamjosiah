import 'package:flutter/material.dart';

class HeroTextSection extends StatelessWidget {
  // NUEVO: callbacks para los botones
  final VoidCallback onContactPressed;
  final VoidCallback onPortfolioPressed;

  const HeroTextSection({
    super.key,
    required this.onContactPressed,
    required this.onPortfolioPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text.rich(
          TextSpan(
            text: 'Josías ',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: 'Jofré',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Estudiante de Ingeniería Civil en Informática',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        const SizedBox(height: 20),
        const Text(
          'Apasionado por el desarrollo de software y la innovación tecnológica, '
              'buscando contribuir a proyectos desafiantes con soluciones creativas.',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            ElevatedButton(
              // LLAMAMOS AL CALLBACK
              onPressed: onContactPressed,
              child: const Text('Contáctame'),
            ),
            const SizedBox(width: 20),
            OutlinedButton(
              // LLAMAMOS AL CALLBACK
              onPressed: onPortfolioPressed,
              child: const Text('Ver Portafolio'),
            ),
          ],
        ),
      ],
    );
  }
}
