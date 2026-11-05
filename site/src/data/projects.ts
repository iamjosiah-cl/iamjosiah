import type { ImageMetadata } from 'astro';
import vamosTito from '../assets/vamos_tito_preview.png';
import presupuesto from '../assets/presupuesto_diario_preview.png';

export interface Project {
  slug: string;
  title: string;
  description: string;
  longDescription?: string;
  tags: string[];
  /** Imagen local (optimizada en el build) o URL remota. */
  image: ImageMetadata | string;
  demoUrl?: string;
  /** Ruta dentro de la app Flutter (ver flutterAppUrl en site.ts). */
  flutterPath?: string;
}

export const projects: Project[] = [
  {
    slug: 'nuble-conecta',
    title: 'Ñuble Conecta',
    description:
      'Aplicación móvil que brinda información en tiempo real sobre servicios de urgencia, filas en hospitales y farmacias de turno en la región de Ñuble. Hecha en colaboración con el Hospital "Herminda Martin" de Chillán.',
    longDescription:
      'Esta aplicación fue desarrollada para mejorar el acceso a la información de salud pública. Utiliza Firebase para la actualización en tiempo real de los tiempos de espera y geolocalización para encontrar la farmacia más cercana.',
    tags: ['Flutter', 'Firebase', 'Dart', 'UI/UX'],
    image:
      'https://wsrv.nl/?url=https://hospitaldechillan.cl/web/wp-content/uploads/2023/07/Fotos-Tamano-web-640x360.png',
    demoUrl: 'https://conecta-91e60.web.app/',
  },
  {
    slug: 'vamos-tito',
    title: 'Vamos Tito',
    description:
      'Tesis de Grado: Plataforma integral de hidratación para niños, con juegos, videos y lecturas interactivas.',
    longDescription:
      'Este proyecto fue mi tesis de grado, diseñada para fomentar el consumo de agua en niños mediante una experiencia integral. "Vamos Tito" incluye videos educativos, lecturas entretenidas y minijuegos interactivos que hacen que aprender sobre la hidratación sea divertido y efectivo.',
    tags: ['Flutter', 'Firebase', 'Tesis', 'Gamificación', 'Educación'],
    image: vamosTito,
    demoUrl: 'https://gotita-a234d.web.app/',
  },
  {
    slug: 'impresora-tickets',
    title: 'Impresora de tickets',
    description: 'Sistema de gestión y emisión de tickets de 80mm con editor de texto enriquecido.',
    longDescription:
      'Desarrollo de una herramienta integral para la creación de tickets térmicos. Incluye un editor de texto avanzado que permite personalizar fuentes, estilos y alineación, además de generar vistas previas precisas de 80mm antes de la impresión.',
    tags: ['Flutter', 'PDF Generation', 'Thermal Printing', 'UI Components'],
    image: 'https://images.unsplash.com/photo-1556742044-3c52d6e88c62?fit=crop&w=800&q=80',
    flutterPath: '/print',
  },
  {
    slug: 'presupuesto-diario',
    title: 'Presupuesto Diario',
    description:
      'Aplicación de finanzas personales con sistema inteligente de rollover que recalcula tu presupuesto diario en tiempo real según tu comportamiento de gasto.',
    longDescription:
      'Full-Stack Flutter & Firebase Finance App que elimina la rigidez de los presupuestos mensuales tradicionales. ' +
      'Implementa un algoritmo dinámico de arrastre de saldo (rollover): si ahorras hoy, el excedente se suma automáticamente a mañana; ' +
      'si te excedes, el sistema ajusta tus días restantes para mantenerte dentro de tu meta.' +
      '\n\nCaracterísticas técnicas:\n' +
      '• Arquitectura limpia con gestión de estado avanzada usando Riverpod 3.0\n' +
      '• Sincronización en tiempo real con Cloud Firestore\n' +
      '• Autenticación segura con Firebase Auth (email, Google, Apple)\n' +
      '• Gestión de ciclos personalizados (quincenal, mensual, personalizado)\n' +
      '• Diseño premium Material 3 con soporte para temas e internacionalización\n' +
      '• Visualización intuitiva con cards informativas y indicadores de estado por color\n' +
      '\nNació de una necesidad real: optimizar el gasto diario sin perder de vista la meta mensual, ' +
      'un problema común que resolví con lógica matemática aplicada al código.',
    tags: ['Flutter', 'Firebase', 'Riverpod', 'Material 3', 'Firestore', 'Clean Architecture'],
    image: presupuesto,
    demoUrl: 'https://rollback-deaa8.web.app/',
  },
];
