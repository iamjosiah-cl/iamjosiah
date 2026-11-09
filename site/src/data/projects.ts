import type { ImageMetadata } from 'astro';
import vamosTito from '../assets/vamos_tito_preview.png';

export interface Project {
  slug: string;
  title: string;
  description: string;
  longDescription?: string;
  tags: string[];
  /** Imagen local (optimizada en el build) o URL remota. */
  image: ImageMetadata | string;
  demoUrl?: string;
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
];
