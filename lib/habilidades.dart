import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
        color: Colors.deepPurple,
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
        color: Colors.deepPurple,
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
        color: Colors.deepPurple,
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
          color: const Color(0xFFF8F9FA),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Mis Habilidades',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(height: 2, width: 120, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Estas son las habilidades que he ido desarrollando a lo largo de mi formación académica y experiencia profesional.',
                style: TextStyle(fontSize: 16),
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
                children: showSoftSkills ? softSkills : technicalSkills,
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
            color: selected ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.black : Colors.black54,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 12),
          if (title.isNotEmpty)
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          avatar: Icon(Icons.check_circle, size: 16, color: color),
          backgroundColor: const Color(0xFFE7EDF8),
          labelStyle: TextStyle(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}