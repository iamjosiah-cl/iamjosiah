import 'package:flutter/material.dart';

// ---------------------------- Constantes ----------------------------
class AppColors {
  static const primary = Color(0xFF2166F0);
  static const dark = Color(0xFF0B132B);
  static const lightBg = Color(0xFFF4F6F8);
  static const lightBlue = Color(0xFFE3EDFF);
}

class AppConstants {
  static const desktopBreakpoint = 900.0;
  static const sectionPaddingDesktop = 64.0;
  static const sectionPaddingMobile = 20.0;
}

class AppStrings {
  static const title = 'Experiencia Laboral';
  static const subtitle = 'Mi trayectoria profesional y proyectos en los que he participado.';
  static const techLabel = 'Tecnologías utilizadas';
}

/// Pantalla de "Experiencia Laboral" con flechas de navegación.
class ExperienciaLaboralSection extends StatefulWidget {
  const ExperienciaLaboralSection({super.key});

  @override
  State<ExperienciaLaboralSection> createState() => _ExperienciaLaboralSectionState();
}

class _ExperienciaLaboralSectionState extends State<ExperienciaLaboralSection> {
  int _selected = 0;

  late final List<_Experiencia> _items = [
    _Experiencia(
      titulo: "Proyecto 'Ñuble Conecta'",
      institucion: 'Hospital Clínico Herminda Martín',
      periodo: '2024 - Actualidad',
      bullets: [
        'Desarrollo de una aplicación móvil multiplataforma (iOS y Android) para brindar información en tiempo real sobre servicios de urgencia, filas en hospitales y farmacias de turno en la región de Ñuble.',
        'Diseño e implementación de funcionalidades para la optimización de consultas en bases de datos y presentaciones de datos visuales, asegurando precisión y confiabilidad en la información para los usuarios.',
      ],
      tecnologias: ['Flutter', 'Firebase', 'Bases de Datos', 'UI/UX'],
    ),
    _Experiencia(
      titulo: 'Tesis de Grado',
      institucion: 'Proyecto UBB y UnACh',
      periodo: '2024 - Actualidad',
      bullets: [
        'Diseño y desarrollo de una plataforma educativa utilizando Flutter y Firebase para incentivar el consumo de agua en niños de 9 a 12 años.',
        'Incorporación de formularios interactivos y mini juegos infantiles para fomentar hábitos saludables.',
      ],
      tecnologias: ['Flutter', 'Firebase', 'UI/UX', 'Gamificación'],
    ),
    _Experiencia(
      titulo: 'Práctica Intermedia',
      institucion: 'Biblioteca Institucional UnACh',
      periodo: 'Primer Semestre 2024',
      bullets: [
        'Administración y optimización de recursos en Moodle, gestionando contenidos multimedia e integrándolos con Google Drive.',
        'Gestión de plataformas de aprendizaje en línea, asegurando la funcionalidad y accesibilidad para los usuarios.',
        'Participación en el desarrollo e implementación de la plataforma "Dspace" para el repositorio universitario con PHP y PostgreSQL.',
        'Actualizaciones y ajustes técnicos en la plataforma de búsqueda bibliográfica "VuFind", integrando nuevas colecciones de libros digitales.',
      ],
      tecnologias: ['Moodle', 'PHP', 'PostgreSQL', 'VuFind', 'Dspace'],
    ),
    _Experiencia(
      titulo: 'Práctica Inicial',
      institucion: 'Educación a distancia UnACh',
      periodo: 'Segundo Semestre 2022',
      bullets: [
        'Administración y optimización de recursos en Moodle, incluyendo la gestión de contenidos multimedia y su integración con plataformas de almacenamiento como Google Drive.',
        'Adquirí experiencia en gestión de plataformas de aprendizaje en línea, asegurando la funcionalidad y accesibilidad para los usuarios.',
      ],
      tecnologias: ['E-learning', 'Soporte TI'],
    ),
    _Experiencia(
      titulo: 'Práctica Profesional',
      institucion: 'Empresa 2080 Sistemas y Servicios',
      periodo: 'Enero – Abril 2025',
      bullets: [
        'Desarrollo de una API REST con Laravel y PostgreSQL para la gestión de contactos en un call center (Docker para entorno de desarrollo, Postman para pruebas).',
        'Implementación de operaciones CRUD, autenticación con Laravel Sanctum y registro de logs para trazabilidad, mejorando la eficiencia y precisión de la información.',
      ],
      tecnologias: ['Laravel', 'PostgreSQL', 'Docker', 'Postman'],
    ),
  ];

  // Navegación con flechas
  void _next() => setState(() => _selected = (_selected + 1) % _items.length);
  void _prev() => setState(() => _selected = (_selected - 1 + _items.length) % _items.length);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= AppConstants.desktopBreakpoint;
        return Stack(
          children: [
            // CONTENIDO PRINCIPAL
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? AppConstants.sectionPaddingDesktop : AppConstants.sectionPaddingMobile,
                  vertical: AppConstants.sectionPaddingDesktop,
                ),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Encabezado
                    const Text(
                      AppStrings.title,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      width: 140,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.subtitle,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Contenido principal responsivo
                    isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
                    const SizedBox(height: 80), // espacio para las flechas
                  ],
                ),
              ),
            ),
            // FLECHAS DE NAVEGACIÓN (Bottom-Right)
            Positioned(
              bottom: 24,
              right: 24,
              child: _NavArrows(
                onNext: _next,
                onPrev: _prev,
                currentIndex: _selected,
                totalItems: _items.length,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Layout para pantallas ≥ 900 px.
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lista lateral
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: _ExperienceList(
            selected: _selected,
            items: _items,
            onTap: (i) => setState(() => _selected = i),
          ),
        ),
        const SizedBox(width: 32),
        // Detalle con animación
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _ExperienceDetail(
              key: ValueKey(_selected),
              item: _items[_selected],
            ),
          ),
        ),
      ],
    );
  }

  /// Layout para pantallas móviles.
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Lista horizontal
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final item = _items[i];
              final selected = i == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titulo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.institucion,
                        style: TextStyle(
                          fontSize: 14,
                          color: selected ? Colors.white70 : Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _ExperienceDetail(
            key: ValueKey(_selected),
            item: _items[_selected],
          ),
        ),
      ],
    );
  }
}

// ---------------------------- Flechas ----------------------------
class _NavArrows extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final int currentIndex;
  final int totalItems;

  const _NavArrows({
    required this.onNext,
    required this.onPrev,
    required this.currentIndex,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Navegación de experiencias, ${currentIndex + 1} de $totalItems',
      child: Row(
        children: [
          _arrowButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onPrev,
            label: 'Experiencia anterior',
          ),
          const SizedBox(width: 12),
          _arrowButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: onNext,
            label: 'Siguiente experiencia',
          ),
        ],
      ),
    );
  }

  Widget _arrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ---------------------------- Lista de Experiencias ----------------------------
class _ExperienceList extends StatelessWidget {
  final int selected;
  final List<_Experiencia> items;
  final ValueChanged<int> onTap;

  const _ExperienceList({
    required this.selected,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) {
          final item = items[i];
          final bool isSel = i == selected;
          return _ExperienceItem(
            item: item,
            isSelected: isSel,
            onTap: () => onTap(i),
          );
        },
      ),
    );
  }
}

// ---------------------------- Item de Experiencia ----------------------------
class _ExperienceItem extends StatefulWidget {
  final _Experiencia item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExperienceItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ExperienceItem> createState() => _ExperienceItemState();
}

class _ExperienceItemState extends State<_ExperienceItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isSel = widget.isSelected;
    final bgColor = isSel
        ? AppColors.primary
        : (_isHovering ? AppColors.lightBlue : Colors.white);

    final titleColor = isSel ? Colors.white : Colors.black87;
    final subtitleColor = isSel ? Colors.white70 : Colors.black54;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSel
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.titulo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.institucion,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------- Detalle de Experiencia ----------------------------
class _ExperienceDetail extends StatelessWidget {
  final _Experiencia item;

  const _ExperienceDetail({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titulo,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.institucion,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                item.periodo,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Bullets
          ...item.bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.arrow_right_alt,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      b,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Tecnologías
          const Text(
            AppStrings.techLabel,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.tecnologias
                .map(
                  (t) => Chip(
                    label: Text(t),
                    backgroundColor: AppColors.lightBlue,
                    labelStyle: const TextStyle(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------- Modelo ---------------------------------------
class _Experiencia {
  final String titulo;
  final String institucion;
  final String periodo;
  final List<String> bullets;
  final List<String> tecnologias;

  const _Experiencia({
    required this.titulo,
    required this.institucion,
    required this.periodo,
    required this.bullets,
    required this.tecnologias,
  });
}