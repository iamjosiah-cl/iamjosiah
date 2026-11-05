import 'package:flutter/material.dart';
import 'package:portafolio/widgets/ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portafolio/styles/beacon_style.dart';
import 'package:portafolio/widgets/animations.dart';

/// Modelo que representa cada habilidad individual.
class SkillItem {
  final String name;
  final String description;
  final String? url;
  const SkillItem({
    required this.name,
    required this.description,
    this.url,
  });
}

/// Sección de habilidades con descripción y enlaces opcionales.
class SkillsSection extends StatefulWidget {
  const SkillsSection({super.key});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  bool showSoftSkills = false;

  @override
  Widget build(BuildContext context) {
    // Lista de habilidades técnicas.
    final technicalSkills = [
      SkillCard(
        title: 'Lenguajes de Programación',
        items: const [
          SkillItem(
            name: 'PHP',
            description:
            'Lenguaje de scripting de uso general diseñado para el desarrollo web.',
            url: 'https://www.php.net',
          ),
          SkillItem(
            name: 'Java',
            description:
            'Lenguaje de programación orientado a objetos ampliamente utilizado.',
            url: 'https://www.oracle.com/java',
          ),
          SkillItem(
            name: 'Dart (Flutter)',
            description:
            'Lenguaje optimizado para apps móviles y de escritorio usando Flutter.',
            url: 'https://dart.dev',
          ),
        ],
        icon: Icons.code,
      ),
      SkillCard(
        title: 'Bases de Datos',
        items: const [
          SkillItem(
            name: 'PostgreSQL',
            description:
            'Sistema de bases de datos relacional y de objetos, open-source.',
            url: 'https://www.postgresql.org',
          ),
          SkillItem(
            name: 'MySQL',
            description:
            'Sistema de gestión de bases de datos relacional popular.',
            url: 'https://www.mysql.com',
          ),
          SkillItem(
            name: 'Firebase',
            description:
            'Plataforma de desarrollo de apps con base de datos NoSQL en tiempo real.',
            url: 'https://firebase.google.com',
          ),
        ],
        icon: Icons.storage,
      ),
      SkillCard(
        title: 'Desarrollo Web',
        items: const [
          SkillItem(
            name: 'HTML',
            description:
            'Lenguaje de marcado estándar para la creación de páginas web.',
            url: 'https://developer.mozilla.org/docs/Web/HTML',
          ),
          SkillItem(
            name: 'CSS',
            description:
            'Lenguaje de hojas de estilo utilizado para describir la presentación de documentos HTML.',
            url: 'https://developer.mozilla.org/docs/Web/CSS',
          ),
          SkillItem(
            name: 'JavaScript',
            description:
            'Lenguaje de programación que permite implementar funcionalidades complejas en páginas web.',
            url: 'https://developer.mozilla.org/docs/Web/JavaScript',
          ),
        ],
        icon: Icons.web,
      ),
      SkillCard(
        title: 'Control de Versiones',
        items: const [
          SkillItem(
            name: 'Git',
            description: 'Sistema de control de versiones distribuido.',
            url: 'https://git-scm.com',
          ),
          SkillItem(
            name: 'GitHub',
            description: 'Plataforma para alojamiento de repositorios Git.',
            url: 'https://github.com',
          ),
        ],
        icon: Icons.merge_type,
      ),
      SkillCard(
        title: 'Frameworks',
        items: const [
          SkillItem(
            name: 'Laravel',
            description: 'Framework PHP para aplicaciones web robustas.',
            url: 'https://laravel.com',
          ),
          SkillItem(
            name: 'Flutter',
            description:
            'SDK de UI de código abierto para crear apps nativas multiplataforma.',
            url: 'https://flutter.dev',
          ),
        ],
        icon: Icons.layers,
      ),
      SkillCard(
        title: 'Sistemas Operativos',
        items: const [
          SkillItem(
            name: 'Linux',
            description:
            'Familia de sistemas operativos tipo Unix de código abierto.',
            url: 'https://kernel.org',
          ),
          SkillItem(
            name: 'Windows',
            description: 'Sistema operativo de Microsoft para equipos personales.',
            url: 'https://www.microsoft.com/windows',
          ),
        ],
        icon: Icons.computer,
      ),
    ];

    // Lista de habilidades blandas.
    final softSkills = [
      SkillCard(
        title: 'Habilidades Blandas',
        items: const [
          SkillItem(
            name: 'Liderazgo',
            description:
            'Capacidad para guiar equipos y proyectos hacia objetivos claros.',
          ),
          SkillItem(
            name: 'Comunicación asertiva',
            description:
            'Habilidad de expresar ideas y necesidades de forma clara y respetuosa.',
          ),
        ],
        icon: Icons.group,
        color: Colors.purpleAccent,
      ),
      SkillCard(
        title: '',
        items: const [
          SkillItem(
            name: 'Gestión de activos',
            description:
            'Administrar eficientemente recursos y herramientas de trabajo.',
          ),
          SkillItem(
            name: 'Resolución de problemas',
            description:
            'Identificar causas raíz y plantear soluciones efectivas.',
          ),
        ],
        icon: Icons.analytics_outlined,
        color: Colors.purpleAccent,
      ),
      SkillCard(
        title: '',
        items: const [
          SkillItem(
            name: 'Elaboración de reportes',
            description:
            'Capacidad para presentar información técnica de forma comprensible.',
          ),
          SkillItem(
            name: 'Trabajo en equipo',
            description:
            'Colaboración y coordinación efectiva con otros miembros del equipo.',
          ),
        ],
        icon: Icons.handshake_outlined,
        color: Colors.purpleAccent,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;
        double childAspectRatio;

        if (width >= 1200) {
          crossAxisCount = 3;
          childAspectRatio = 2.2;
        } else if (width >= 800) {
          crossAxisCount = 2;
          childAspectRatio = 2.0;
        } else {
          crossAxisCount = 1;
          childAspectRatio = 1.8;
        }

        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: width >= 800 ? 40 : 16, vertical: 40),
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Mis Habilidades',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: BeaconStyle.textPrimary),
              ),
              const SizedBox(height: 12),
              const AccentBar(),
              const SizedBox(height: 16),
              const Text(
                'Estas son las habilidades que he ido desarrollando a lo largo de mi formación académica y experiencia profesional.',
                style: TextStyle(fontSize: 16, color: BeaconStyle.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _Tabs(
                showSoftSkills: showSoftSkills,
                onSelect: (isSoft) => setState(() => showSoftSkills = isSoft),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: childAspectRatio,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: (showSoftSkills ? softSkills : technicalSkills).asMap().entries.map((entry) {
                  return FadeInAnimation(
                    animateInView: true,
                    delay: Duration(milliseconds: 100 + (entry.key * 100)),
                    child: entry.value,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Pestañas para cambiar entre habilidades técnicas y blandas.
class _Tabs extends StatelessWidget {
  final bool showSoftSkills;
  final ValueChanged<bool> onSelect;
  const _Tabs({required this.showSoftSkills, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    Widget tab(String title, bool selected, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.cyanAccent.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected ? Border.all(color: Colors.cyanAccent) : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.cyanAccent : BeaconStyle.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: BeaconStyle.cardBgGlass,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BeaconStyle.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          tab('Habilidades Técnicas', !showSoftSkills, () => onSelect(false)),
          const SizedBox(width: 8),
          tab('Habilidades Blandas', showSoftSkills, () => onSelect(true)),
        ],
      ),
    );
  }
}

/// Tarjeta que agrupa chips de habilidades.
class SkillCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<SkillItem> items;
  final Color color;
  const SkillCard({
    super.key,
    required this.title,
    required this.items,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BeaconStyle.cardBgGlass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BeaconStyle.cardBorder),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color == Colors.blue ? Colors.cyanAccent : color),
          const SizedBox(height: 12),
          if (title.isNotEmpty)
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: BeaconStyle.textPrimary),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((item) => _SkillChip(item: item, color: color))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// Chip individual con tooltip y enlace opcional.
class _SkillChip extends StatelessWidget {
  final SkillItem item;
  final Color color;
  const _SkillChip({required this.item, required this.color});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.description,
      child: InkWell(
        onTap: item.url == null ? null : () => _launchUrl(item.url!),
        borderRadius: BorderRadius.circular(8),
        child: Chip(
          label: Text(item.name),
          backgroundColor: const Color(0x14FFFFFF),
          labelStyle: const TextStyle(color: BeaconStyle.textPrimary, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: BeaconStyle.cardBorder)),
        ),
      ),
    );
  }
}