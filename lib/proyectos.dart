import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Responsive “Proyectos Destacados” section that adapts gracefully from
/// mobile to large‑desktop widths.
///
/// Usage:
/// ```dart
/// Column(
///   children: const [
///     FeaturedProjectsSection(),
///   ],
/// )
/// ```
class FeaturedProjectsSection extends StatelessWidget {
  const FeaturedProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    const maxContentWidth = 1400.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Determine grid settings based on common Flutter Web break‑points.
        final _GridConfig grid = _gridConfigFor(width);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: grid.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  _SectionTitle(
                    title: 'Proyectos Destacados',
                    subtitle:
                    'Una selección de los proyectos en los que he trabajado durante mi carrera.',
                    palette: palette,
                  ),
                  const SizedBox(height: 32),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: grid.crossAxisCount,
                      mainAxisExtent: grid.cardHeight,
                      crossAxisSpacing: grid.spacing,
                      mainAxisSpacing: grid.spacing,
                    ),
                    itemCount: _sampleData.length,
                    itemBuilder: (context, index) => _ProjectCard(
                      project: _sampleData[index],
                      palette: palette,
                    ),
                  ),
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
    final theme = Theme.of(context);
    return _Palette(
      primary: theme.colorScheme.primary,
      subtitle: theme.textTheme.bodyMedium?.color ?? Colors.grey.shade600,
      chipBackground: theme.colorScheme.primary.withOpacity(.08),
    );
  }

  /// Returns granular grid settings for the current width.
  _GridConfig _gridConfigFor(double width) {
    if (width >= 1440) {
      return const _GridConfig(crossAxisCount: 4, cardHeight: 440);
    } else if (width >= 1200) {
      return const _GridConfig(crossAxisCount: 3, cardHeight: 420);
    } else if (width >= 800) {
      return const _GridConfig(crossAxisCount: 2, cardHeight: 400);
    } else {
      return const _GridConfig(crossAxisCount: 1, cardHeight: 380, horizontalPadding: 16);
    }
  }
}

//////////////////////////////////////////////////////////////////////
//  COMPONENTS                                                     //
//////////////////////////////////////////////////////////////////////

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final _Palette palette;
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(height: 4, width: 80, color: palette.primary),
        const SizedBox(height: 16),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.subtitle,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final _Project project;
  final _Palette palette;
  const _ProjectCard({required this.project, required this.palette});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final card = Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner image + project title overlay
          Stack(
            children: [
              Ink.image(
                image: NetworkImage(project.imageUrl),
                height: 170,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Text(
                  project.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // Description & footer
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.description,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: project.tags
                        .map((t) => Chip(
                      label: Text(t),
                      backgroundColor: widget.palette.chipBackground,
                      labelStyle: Theme.of(context).textTheme.bodySmall,
                    ))
                        .toList(),
                  ),
                  const Spacer(),
                  _Footer(project: project),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Hover effect only for desktop / web.
    return kIsWeb
        ? MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedScale(
        scale: _isHovering ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: card,
      ),
    )
        : card;
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.project});
  final _Project project;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: project.detailsCallback,
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 18),
              const SizedBox(width: 4),
              Text('Detalles',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Repositorio',
          icon: const Icon(Icons.star_outline),
          onPressed: project.repoUrl == null ? null : () => _launchUrl(project.repoUrl!),
        ),
        IconButton(
          tooltip: 'Demo / Sitio web',
          icon: const Icon(Icons.open_in_new),
          onPressed: project.demoUrl == null ? null : () => _launchUrl(project.demoUrl!),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////////
//  DATA & HELPERS                                                 //
//////////////////////////////////////////////////////////////////////

class _Project {
  final String title;
  final String description;
  final List<String> tags;
  final String imageUrl;
  final String? repoUrl;
  final String? demoUrl;
  final VoidCallback? detailsCallback;

  const _Project({
    required this.title,
    required this.description,
    required this.tags,
    required this.imageUrl,
    this.repoUrl,
    this.demoUrl,
    this.detailsCallback,
  });
}

// Sample placeholder data; replace with your own.
final List<_Project> _sampleData = [
  const _Project(
    title: 'Ñuble Conecta',
    description:
    'Aplicación móvil que brinda información en tiempo real sobre servicios de urgencia, filas en hospitales y farmacias de turno en la región de Ñuble.',
    tags: ['Flutter', 'Firebase', 'Dart', 'UI/UX'],
    imageUrl:
    'https://images.unsplash.com/photo-1498050108023-c5249f4df085?fit=crop&w=800&q=80',
    repoUrl: 'https://github.com/tuUsuario/nuble-conecta',
    demoUrl: 'https://nubleconecta.app',
  ),
  const _Project(
    title: 'Plataforma Educativa\nde Hidratación',
    description:
    'Plataforma educativa para incentivar el consumo de agua en niños de 9 a 12 años mediante mini juegos y actividades interactivas.',
    tags: ['Flutter', 'Firebase', 'Gamificación', 'UX Infantil'],
    imageUrl:
    'https://images.unsplash.com/photo-1503264116251-35a269479413?fit=crop&w=800&q=80',
    repoUrl: 'https://github.com/tuUsuario/hidratacion-platform',
    demoUrl: 'https://hidratacion.app',
  ),
];

void _launchUrl(String url) {
  // NOTE: In a real app you might inject `url_launcher` or a custom service.
  // For now we just print so the code compiles without additional dependencies.
  // ignore: avoid_print
  print('Open URL → $url');
}

//////////////////////////////////////////////////////////////////////
//  PALETTE                                                        //
//////////////////////////////////////////////////////////////////////

class _Palette {
  final Color primary;
  final Color subtitle;
  final Color chipBackground;
  const _Palette({
    required this.primary,
    required this.subtitle,
    required this.chipBackground,
  });
}

//////////////////////////////////////////////////////////////////////
//  GRID CONFIG                                                    //
//////////////////////////////////////////////////////////////////////

class _GridConfig {
  final int crossAxisCount;
  final double cardHeight;
  final double horizontalPadding;
  final double spacing;
  const _GridConfig({
    required this.crossAxisCount,
    required this.cardHeight,
    this.horizontalPadding = 0,
    this.spacing = 24,
  });
}
