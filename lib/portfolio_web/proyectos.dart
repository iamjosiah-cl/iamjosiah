import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:portafolio/widgets/ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portafolio/styles/beacon_style.dart';
import 'package:portafolio/widgets/animations.dart';

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
        final grid = _gridConfigFor(width);

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
                    itemCount: sampleProjects.length,
                    itemBuilder: (context, index) => FadeInAnimation(
                      animateInView: true,
                      delay: Duration(milliseconds: 200 + (index * 150)),
                      child: ProjectCard(
                        project: sampleProjects[index],
                        palette: palette,
                      ),
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
    return _Palette(
      primary: const Color(0xFF22D3EE), // Cyan
      subtitle: BeaconStyle.textSecondary,
      chipBackground: Colors.white.withOpacity(0.1),
    );
  }

  _GridConfig _gridConfigFor(double width) {
    if (width >= 1440) {
      return const _GridConfig(crossAxisCount: 4, cardHeight: 480);
    } else if (width >= 1200) {
      return const _GridConfig(crossAxisCount: 3, cardHeight: 460);
    } else if (width >= 800) {
      return const _GridConfig(crossAxisCount: 2, cardHeight: 440);
    } else {
      return const _GridConfig(crossAxisCount: 1, cardHeight: 420, horizontalPadding: 16);
    }
  }
}

/// A full-screen page to show projects independently.
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      Theme(data: BeaconStyle.theme(), child: Builder(builder: _build));

  Widget _build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeaconStyle.backgroundColor,
      appBar: AppBar(
        title: const Text('Mis Proyectos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackgroundOrbs()),
          const SingleChildScrollView(
            child: FeaturedProjectsSection(),
          ),
        ],
      ),
    );
  }
}

/// A detailed view for a single project (Documentation page).
class ProjectDetailPage extends StatelessWidget {
  final Project project;
  const ProjectDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) =>
      Theme(data: BeaconStyle.theme(), child: Builder(builder: _build));

  Widget _build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: BeaconStyle.backgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackgroundOrbs()),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: BeaconStyle.cardBg,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 56, right: 16, bottom: 14),
                  title: Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      project.imageUrl.startsWith('http')
                          ? Image.network(project.imageUrl, fit: BoxFit.cover)
                          : Image.asset(project.imageUrl, fit: BoxFit.cover),
                      // Overlay para mejorar contraste
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.15),
                              Colors.black.withOpacity(0.75),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chips de tecnologías
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: project.tags.map((t) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                                ),
                                child: Text(
                                  t,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 18),

                          // Intro / resumen (mejor tipografía)
                          Text(
                            project.description,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.92),
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Enlaces / acciones
                          _GlassSection(
                            title: 'Acciones',
                            child: Column(
                              children: [
                                if (project.internalAppBuilder != null)
                                  _PrimaryActionButton(
                                    icon: Icons.launch,
                                    label: 'Probar aplicación',
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: project.internalAppBuilder!),
                                    ),
                                  ),
                                if (project.demoUrl != null) ...[
                                  if (project.internalAppBuilder != null) const SizedBox(height: 12),
                                  _SecondaryActionButton(
                                    icon: Icons.language,
                                    label: 'Ver demo online',
                                    onPressed: () => _launchUrl(project.demoUrl!),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Sobre el proyecto
                          _GlassSection(
                            title: 'Sobre el proyecto',
                            child: Text(
                              project.description,
                              style: const TextStyle(
                                color: BeaconStyle.textSecondary,
                                fontSize: 16,
                                height: 1.7,
                              ),
                            ),
                          ),

                          // Detalles técnicos (si existe)
                          if (project.longDescription != null) ...[
                            const SizedBox(height: 16),
                            _GlassSection(
                              title: 'Detalles técnicos',
                              child: Text(
                                project.longDescription!,
                                style: const TextStyle(
                                  color: BeaconStyle.textSecondary,
                                  fontSize: 16,
                                  height: 1.7,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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

/// Sección tipo “card glass” para agrupar contenido.
class _GlassSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _GlassSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: BeaconStyle.cardBgGlass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF22D3EE).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22D3EE),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white.withOpacity(0.92)),
        label: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.92))),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.18)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.white.withOpacity(0.04),
        ),
      ),
    );
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
            color: BeaconStyle.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const AccentBar(),
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

class ProjectCard extends StatefulWidget {
  final Project project;
  final _Palette palette;
  const ProjectCard({required this.project, required this.palette});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final card = Card(
      elevation: 4,
      color: BeaconStyle.cardBgGlass,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: BeaconStyle.cardBorder)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProjectDetailPage(project: project)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image + project title overlay
            Stack(
              children: [
                Ink.image(
                  image: project.imageUrl.startsWith('http')
                      ? NetworkImage(project.imageUrl) as ImageProvider
                      : AssetImage(project.imageUrl) as ImageProvider,
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
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: BeaconStyle.textSecondary)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: project.tags
                          .take(3)
                          .map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 10)),
                        backgroundColor: widget.palette.chipBackground,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                          .toList(),
                    ),
                    const Spacer(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ver detalles →',
                            style: TextStyle(color: widget.palette.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Hover effect only for desktop / web.
    return kIsWeb
        ? MouseRegion(
      cursor: SystemMouseCursors.click,
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

//////////////////////////////////////////////////////////////////////
//  DATA & HELPERS                                                 //
//////////////////////////////////////////////////////////////////////

class Project {
  final String title;
  final String description;
  final String? longDescription;
  final List<String> tags;
  final String imageUrl;
  final String? repoUrl;
  final String? demoUrl;
  final WidgetBuilder? internalAppBuilder;
  final VoidCallback? detailsCallback;

  const Project({
    required this.title,
    required this.description,
    this.longDescription,
    required this.tags,
    required this.imageUrl,
    this.repoUrl,
    this.demoUrl,
    this.internalAppBuilder,
    this.detailsCallback,
  });
}

// Sample placeholder data; replace with your own.
final List<Project> sampleProjects = [
  const Project(
    title: 'Ñuble Conecta',
    description:
    'Aplicación móvil que brinda información en tiempo real sobre servicios de urgencia, filas en hospitales y farmacias de turno en la región de Ñuble. Hecha en colaboración con el Hospital "Herminda Martin" de Chillán.',
    longDescription: 'Esta aplicación fue desarrollada para mejorar el acceso a la información de salud pública. Utiliza Firebase para la actualización en tiempo real de los tiempos de espera y geolocalización para encontrar la farmacia más cercana.',
    tags: ['Flutter', 'Firebase', 'Dart', 'UI/UX'],
    imageUrl:
    'https://wsrv.nl/?url=https://hospitaldechillan.cl/web/wp-content/uploads/2023/07/Fotos-Tamano-web-640x360.png',
    repoUrl: 'https://github.com/tuUsuario/nuble-conecta',
    demoUrl: 'https://conecta-91e60.web.app/',
  ),
  const Project(
    title: 'Vamos Tito',
    description:
    'Tesis de Grado: Plataforma integral de hidratación para niños, con juegos, videos y lecturas interactivas.',
    longDescription: 'Este proyecto fue mi tesis de grado, diseñada para fomentar el consumo de agua en niños mediante una experiencia integral. "Vamos Tito" incluye videos educativos, lecturas entretenidas y minijuegos interactivos que hacen que aprender sobre la hidratación sea divertido y efectivo.',
    tags: ['Flutter', 'Firebase', 'Tesis', 'Gamificación', 'Educación'],
    imageUrl: 'assets/vamos_tito_preview.png',
    repoUrl: 'https://github.com/tuUsuario/hidratacion-platform',
    demoUrl: 'https://gotita-a234d.web.app/',
  ),
];

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
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
