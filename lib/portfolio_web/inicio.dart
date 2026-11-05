import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Added
import 'package:portafolio/styles/beacon_style.dart';
import 'package:portafolio/beacon.dart';
import 'package:portafolio/widgets/animations.dart';
import 'package:portafolio/widgets/ui.dart';

class HeroTextSection extends StatelessWidget {
  final VoidCallback onContactPressed;
  final VoidCallback onPortfolioPressed;

  const HeroTextSection({
    super.key,
    required this.onContactPressed,
    required this.onPortfolioPressed,
  });

  Future<void> _downloadCV() async {
    final url = Uri.parse('assets/CV_Josias_Jofre.pdf');
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final nameSize = width >= 1000 ? 64.0 : (width >= 600 ? 52.0 : 40.0);
    final buttonPadding = const EdgeInsets.symmetric(horizontal: 22, vertical: 18);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    return FadeInAnimation(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EyebrowChip('Ingeniero Civil en Informática', icon: Icons.terminal_rounded),
          const SizedBox(height: 20),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                'Josías ',
                style: TextStyle(
                  fontSize: nameSize,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -1.5,
                  color: BeaconStyle.textPrimary,
                ),
              ),
              GradientText(
                'Jofré',
                style: TextStyle(
                  fontSize: nameSize,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: const Text(
              'Apasionado por el desarrollo de software y la innovación tecnológica, '
              'buscando contribuir a proyectos desafiantes con soluciones creativas.',
              style: TextStyle(fontSize: 18, color: BeaconStyle.textSecondary, height: 1.6),
            ),
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onContactPressed,
                icon: const Icon(Icons.mail_outline_rounded, size: 18),
                label: const Text('Contáctame', style: TextStyle(fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: BeaconStyle.accent,
                  foregroundColor: BeaconStyle.backgroundColor,
                  padding: buttonPadding,
                  shape: shape,
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: _downloadCV,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Descargar CV'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0x1AFFFFFF),
                  foregroundColor: BeaconStyle.textPrimary,
                  padding: buttonPadding,
                  shape: shape,
                ),
              ),
              OutlinedButton(
                onPressed: onPortfolioPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: BeaconStyle.textPrimary,
                  side: const BorderSide(color: BeaconStyle.cardBorder),
                  padding: buttonPadding,
                  shape: shape,
                ),
                child: const Text('Ver Curriculum'),
              ),
              TextButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const BeaconHome()),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Volver a beacon'),
                style: TextButton.styleFrom(
                  foregroundColor: BeaconStyle.accent,
                  padding: buttonPadding,
                  shape: shape,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
