import 'package:flutter/material.dart';
import 'package:portafolio/widgets/ui.dart';
import 'package:portafolio/styles/beacon_style.dart';
import 'package:portafolio/widgets/animations.dart';

/// Responsive section that displays academic formation and achievements.
///
/// Breakpoints:
///   • Mobile (< 600 px)   : vertical layout with safe horizontal padding.
///   • Tablet (600‑999 px) : vertical layout but with wider padding.
///   • Desktop (≥ 1000 px) : two‑column layout, capped to 1200 px total width.
///
/// Drop this widget anywhere in your Flutter web (or desktop/mobile) app.
class EducationAndAchievementsSection extends StatelessWidget {
  const EducationAndAchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;

        // ———————— BREAKPOINTS ———————— //
        final bool isDesktop = maxWidth >= 1000;
        final bool isTablet = maxWidth >= 600 && maxWidth < 1000;

        // —————— CARDS LAYOUT WIDGET ————— //
        Widget cards() {
          final double cardMaxWidth = isDesktop ? (maxWidth / 2) - 24 : maxWidth;

          return Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              FadeInAnimation(
                animateInView: true,
                delay: const Duration(milliseconds: 200),
                child: _ConstrainedCard(
                  maxWidth: cardMaxWidth,
                  child: _AcademicCard(palette: palette),
                ),
              ),
              FadeInAnimation(
                animateInView: true,
                delay: const Duration(milliseconds: 400),
                child: _ConstrainedCard(
                  maxWidth: cardMaxWidth,
                  child: _AchievementsCard(palette: palette),
                ),
              ),
            ],
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop
                    ? 32
                    : isTablet
                    ? 24
                    : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  _SectionTitle(title: 'Educación y Logros', palette: palette),
                  const SizedBox(height: 32),
                  cards(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _Palette _palette(BuildContext context) {
  return _Palette(
    primary: const Color(0xFF22D3EE), // Cyan principal
    background: BeaconStyle.backgroundColor, // Fondo global
    onCard: BeaconStyle.textPrimary, // Texto sobre cards

    // Superficies suaves (glass / hover / highlights)
    lightBlue: const Color(0xFF22D3EE).withOpacity(0.08),
    lightGreen: const Color(0xFF14B8A6).withOpacity(0.10), // teal
    lightPurple: const Color(0xFF8B5CF6).withOpacity(0.10), // violet
    lightOrange: const Color(0xFFF59E0B).withOpacity(0.10), // amber
  );
}
}



//////////////////////////////////////////////////////////////////////
//  SMALL, REUSABLE PIECES                                         //
//////////////////////////////////////////////////////////////////////

class _SectionTitle extends StatelessWidget {
  final String title;
  final _Palette palette;
  const _SectionTitle({required this.title, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: BeaconStyle.textPrimary,
            fontSize: 36,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const AccentBar(),
      ],
    );
  }
}

// 2. Simplifica la clase _ConstrainedCard
class _ConstrainedCard extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const _ConstrainedCard({
    required this.maxWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        // No uses minWidth: double.infinity aquí
      ),
      child: child,
    );
  }
}




class _AcademicCard extends StatelessWidget {
  final _Palette palette;
  const _AcademicCard({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: BeaconStyle.cardBgGlass,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: BeaconStyle.cardBorder)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(icon: Icons.school, title: 'Formación Académica', palette: palette),
            const SizedBox(height: 16),
            _TimelineEntry(
              title: 'Ingeniería Civil en Informática',
              subtitle: 'Universidad Adventista de Chile',
              period: '2020 - 2025 (Titulado)',
              description:
              'Formación con énfasis en programación, bases de datos, desarrollo web y móvil, y gestión de proyectos informáticos.',
              palette: palette,
            ),
            const SizedBox(height: 24),
            _AdditionalKnowledge(palette: palette),
          ],
        ),
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  final _Palette palette;
  const _AchievementsCard({required this.palette});

  @override
  Widget build(BuildContext context) {
    final items = [
      _AchievementItem(
        title: 'Ganador del Concurso de Innovación 2022',
        description:
        'Reconocido como parte del equipo ganador del Concurso de Innovación 2022 en la Universidad Adventista de Chile.',
        background: palette.lightBlue,
      ),
      _AchievementItem(
        title: 'Proyectos Tecnológicos Innovadores',
        description:
        'Reconocido por la Universidad Adventista de Chile por participación en proyectos tecnológicos innovadores que benefician a la comunidad.',
        background: palette.lightGreen,
      ),
      _AchievementItem(
        title: 'Enseñanza de Robótica',
        description:
        'Participación activa en programas de enseñanza de robótica para estudiantes escolares, fomentando el interés por la tecnología en jóvenes.',
        background: palette.lightPurple,
      ),
      _AchievementItem(
        title: 'Participación en Concursos de Innovación',
        description:
        'Participante habitual en concursos de innovación, impulsando soluciones creativas a problemas reales.',
        background: palette.lightOrange,
      ),
    ];

    return Card(
      elevation: 4,
      color: BeaconStyle.cardBgGlass,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: BeaconStyle.cardBorder)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(icon: Icons.emoji_events, title: 'Logros y Reconocimientos', palette: palette),
            const SizedBox(height: 16),
            ...items
                .map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _AchievementTile(item: i),
            ))
                .toList(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final IconData icon;
  final String title;
  final _Palette palette;
  const _Header({required this.icon, required this.title, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: palette.primary.withOpacity(.1),
          child: Icon(icon, color: palette.primary),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: BeaconStyle.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////////
//  ACADEMIC SUB‑COMPONENTS                                        //
//////////////////////////////////////////////////////////////////////
class _TimelineEntry extends StatelessWidget {
  final String title;
  final String subtitle;
  final String period;
  final String description;
  final _Palette palette;

  const _TimelineEntry({
    required this.title,
    required this.subtitle,
    required this.period,
    required this.description,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(                 // ⬅️ NUEVO
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: palette.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(                    // ⬅️ vuelve a ser seguro
                child: Container(
                  width: 2,
                  color: palette.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600, color: BeaconStyle.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500, color: BeaconStyle.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(period,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: BeaconStyle.iconMuted)),
                const SizedBox(height: 12),
                Text(description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: BeaconStyle.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _AdditionalKnowledge extends StatelessWidget {
  final _Palette palette;
  const _AdditionalKnowledge({required this.palette});

  @override
  Widget build(BuildContext context) {
    final skills = [
      'Gestión en redes sociales',
      'Edición de videos para contenido digital',
      'Uso avanzado de Canva para diseño gráfico',
      'Oratoria y presentación en público',
      'Creación de prompts efectivos para herramientas de IA',
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.lightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conocimientos Adicionales:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: BeaconStyle.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...skills.map(
                (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: palette.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: BeaconStyle.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////
//  ACHIEVEMENT SUB‑COMPONENTS                                     //
//////////////////////////////////////////////////////////////////////

class _AchievementItem {
  final String title;
  final String description;
  final Color background;
  const _AchievementItem({
    required this.title,
    required this.description,
    required this.background,
  });
}

class _AchievementTile extends StatelessWidget {
  final _AchievementItem item;
  const _AchievementTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: item.background,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: BeaconStyle.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(item.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: BeaconStyle.textSecondary)),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////
//  SIMPLE PALETTE HOLDER                                          //
//////////////////////////////////////////////////////////////////////

class _Palette {
  final Color primary;
  final Color background;
  final Color onCard;
  final Color lightBlue;
  final Color lightGreen;
  final Color lightPurple;
  final Color lightOrange;
  const _Palette({
    required this.primary,
    required this.background,
    required this.onCard,
    required this.lightBlue,
    required this.lightGreen,
    required this.lightPurple,
    required this.lightOrange,
  });
}
