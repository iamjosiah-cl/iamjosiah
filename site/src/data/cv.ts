export interface Experience {
  title: string;
  org: string;
  period: string;
  bullets: string[];
  tech: string[];
}

export const experience: Experience[] = [
  {
    title: 'Community Manager',
    org: 'Colegio Adventista de Copiapó',
    period: 'Mayo 2025 - Actualidad',
    bullets: [
      'Gestión estratégica de redes sociales institucionales (Instagram, YouTube, X y Facebook), logrando una comunicación más fluida y profesional.',
      'Implementación de una nueva visión comunicacional que resultó en una mejor recepción de la identidad del colegio, tanto por parte de la comunidad interna como del público externo.',
      'Creación y curación de contenido multimedia para fortalecer la presencia digital y el engagement con la audiencia.',
    ],
    tech: ['Instagram', 'YouTube', 'Facebook', 'X (Twitter)', 'Gestión de Contenidos'],
  },
  {
    title: "Proyecto 'Ñuble Conecta'",
    org: 'Hospital Clínico Herminda Martín',
    period: '2024 - Actualidad',
    bullets: [
      'Desarrollo de una aplicación móvil multiplataforma (iOS y Android) para brindar información en tiempo real sobre servicios de urgencia, filas en hospitales y farmacias de turno en la región de Ñuble.',
      'Diseño e implementación de funcionalidades para la optimización de consultas en bases de datos y presentaciones de datos visuales, asegurando precisión y confiabilidad en la información para los usuarios.',
    ],
    tech: ['Flutter', 'Firebase', 'Bases de Datos', 'UI/UX'],
  },
  {
    title: "Tesis de Grado: 'Vamos Tito'",
    org: 'Proyecto UBB y UnACh',
    period: '2024 - Actualidad',
    bullets: [
      'Diseño y desarrollo de "Vamos Tito", una plataforma educativa integral utilizando Flutter y Firebase para incentivar el consumo de agua en niños.',
      'Implementación de un ecosistema educativo completo que incluye minijuegos, videos didácticos y lecturas interactivas.',
      'Enfoque en gamificación y experiencia de usuario infantil para fomentar hábitos saludables de manera divertida.',
    ],
    tech: ['Flutter', 'Firebase', 'Gamificación', 'Contenido Multimedia'],
  },
  {
    title: 'Práctica Profesional',
    org: 'Empresa 2080 Sistemas y Servicios',
    period: 'Enero – Abril 2025',
    bullets: [
      'Desarrollo de una API REST con Laravel y PostgreSQL para la gestión de contactos en un call center (Docker para entorno de desarrollo, Postman para pruebas).',
      'Implementación de operaciones CRUD, autenticación con Laravel Sanctum y registro de logs para trazabilidad, mejorando la eficiencia y precisión de la información.',
    ],
    tech: ['Laravel', 'PostgreSQL', 'Docker', 'Postman'],
  },
  {
    title: 'Práctica Intermedia',
    org: 'Biblioteca Institucional UnACh',
    period: 'Primer Semestre 2024',
    bullets: [
      'Administración y optimización de recursos en Moodle, gestionando contenidos multimedia e integrándolos con Google Drive.',
      'Gestión de plataformas de aprendizaje en línea, asegurando la funcionalidad y accesibilidad para los usuarios.',
      'Participación en el desarrollo e implementación de la plataforma "Dspace" para el repositorio universitario con PHP y PostgreSQL.',
      'Actualizaciones y ajustes técnicos en la plataforma de búsqueda bibliográfica "VuFind", integrando nuevas colecciones de libros digitales.',
    ],
    tech: ['Moodle', 'PHP', 'PostgreSQL', 'VuFind', 'Dspace'],
  },
  {
    title: 'Práctica Inicial',
    org: 'Educación a distancia UnACh',
    period: 'Segundo Semestre 2022',
    bullets: [
      'Administración y optimización de recursos en Moodle, incluyendo la gestión de contenidos multimedia y su integración con plataformas de almacenamiento como Google Drive.',
      'Adquirí experiencia en gestión de plataformas de aprendizaje en línea, asegurando la funcionalidad y accesibilidad para los usuarios.',
    ],
    tech: ['E-learning', 'Soporte TI'],
  },
];

export interface SkillItem {
  name: string;
  description: string;
  url?: string;
}

export interface SkillGroup {
  title: string;
  icon: string;
  items: SkillItem[];
}

export const technicalSkills: SkillGroup[] = [
  {
    title: 'Lenguajes de Programación',
    icon: 'code',
    items: [
      { name: 'PHP', description: 'Lenguaje de scripting de uso general diseñado para el desarrollo web.', url: 'https://www.php.net' },
      { name: 'Java', description: 'Lenguaje de programación orientado a objetos ampliamente utilizado.', url: 'https://www.oracle.com/java' },
      { name: 'Dart (Flutter)', description: 'Lenguaje optimizado para apps móviles y de escritorio usando Flutter.', url: 'https://dart.dev' },
    ],
  },
  {
    title: 'Bases de Datos',
    icon: 'database',
    items: [
      { name: 'PostgreSQL', description: 'Sistema de bases de datos relacional y de objetos, open-source.', url: 'https://www.postgresql.org' },
      { name: 'MySQL', description: 'Sistema de gestión de bases de datos relacional popular.', url: 'https://www.mysql.com' },
      { name: 'Firebase', description: 'Plataforma de desarrollo de apps con base de datos NoSQL en tiempo real.', url: 'https://firebase.google.com' },
    ],
  },
  {
    title: 'Desarrollo Web',
    icon: 'globe',
    items: [
      { name: 'HTML', description: 'Lenguaje de marcado estándar para la creación de páginas web.', url: 'https://developer.mozilla.org/docs/Web/HTML' },
      { name: 'CSS', description: 'Lenguaje de hojas de estilo utilizado para describir la presentación de documentos HTML.', url: 'https://developer.mozilla.org/docs/Web/CSS' },
      { name: 'JavaScript', description: 'Lenguaje de programación que permite implementar funcionalidades complejas en páginas web.', url: 'https://developer.mozilla.org/docs/Web/JavaScript' },
    ],
  },
  {
    title: 'Control de Versiones',
    icon: 'git',
    items: [
      { name: 'Git', description: 'Sistema de control de versiones distribuido.', url: 'https://git-scm.com' },
      { name: 'GitHub', description: 'Plataforma para alojamiento de repositorios Git.', url: 'https://github.com' },
    ],
  },
  {
    title: 'Frameworks',
    icon: 'layers',
    items: [
      { name: 'Laravel', description: 'Framework PHP para aplicaciones web robustas.', url: 'https://laravel.com' },
      { name: 'Flutter', description: 'SDK de UI de código abierto para crear apps nativas multiplataforma.', url: 'https://flutter.dev' },
    ],
  },
  {
    title: 'Sistemas Operativos',
    icon: 'monitor',
    items: [
      { name: 'Linux', description: 'Familia de sistemas operativos tipo Unix de código abierto.', url: 'https://kernel.org' },
      { name: 'Windows', description: 'Sistema operativo de Microsoft para equipos personales.', url: 'https://www.microsoft.com/windows' },
    ],
  },
];

export const softSkills: SkillItem[] = [
  { name: 'Liderazgo', description: 'Capacidad para guiar equipos y proyectos hacia objetivos claros.' },
  { name: 'Comunicación asertiva', description: 'Habilidad de expresar ideas y necesidades de forma clara y respetuosa.' },
  { name: 'Gestión de activos', description: 'Administrar eficientemente recursos y herramientas de trabajo.' },
  { name: 'Resolución de problemas', description: 'Identificar causas raíz y plantear soluciones efectivas.' },
  { name: 'Elaboración de reportes', description: 'Capacidad para presentar información técnica de forma comprensible.' },
  { name: 'Trabajo en equipo', description: 'Colaboración y coordinación efectiva con otros miembros del equipo.' },
];

export const education = {
  degree: {
    title: 'Ingeniería Civil en Informática',
    org: 'Universidad Adventista de Chile',
    period: '2020 - 2025 (Titulado)',
    text: 'Formación con énfasis en programación, bases de datos, desarrollo web y móvil, y gestión de proyectos informáticos.',
  },
  extras: [
    'Gestión en redes sociales',
    'Edición de videos para contenido digital',
    'Uso avanzado de Canva para diseño gráfico',
    'Oratoria y presentación en público',
    'Creación de prompts efectivos para herramientas de IA',
  ],
  achievements: [
    { title: 'Ganador del Concurso de Innovación 2022', text: 'Reconocido como parte del equipo ganador del Concurso de Innovación 2022 en la Universidad Adventista de Chile.' },
    { title: 'Proyectos Tecnológicos Innovadores', text: 'Reconocido por la Universidad Adventista de Chile por participación en proyectos tecnológicos innovadores que benefician a la comunidad.' },
    { title: 'Enseñanza de Robótica', text: 'Participación activa en programas de enseñanza de robótica para estudiantes escolares, fomentando el interés por la tecnología en jóvenes.' },
    { title: 'Participación en Concursos de Innovación', text: 'Participante habitual en concursos de innovación, impulsando soluciones creativas a problemas reales.' },
  ],
};
