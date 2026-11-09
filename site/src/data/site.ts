// Datos generales del sitio. Todo el contenido vive en src/data/ para
// que editar textos no requiera tocar componentes.

export const profile = {
  name: 'Josías',
  lastName: 'Jofré',
  handle: '@iamjosiah.cl',
  role: 'Ingeniero Civil en Informática',
  tagline: 'Programador, editor e ingeniero',
  heroText:
    'Apasionado por el desarrollo de software y la innovación tecnológica, ' +
    'buscando contribuir a proyectos desafiantes con soluciones creativas.',
  cvUrl: '/assets/CV_Josias_Jofre.pdf',
  cvUpdated: '29/01/2026',
  email: 'josiasjofre@gmail.com',
  emails: ['josiasjofre@gmail.com', 'josiasjofre@alu.unach.cl'],
  phone: '+56 9 6727 9093',
  location: 'Chillán, Región de Ñuble, Chile',
};

export type SocialIcon =
  | 'linkedin'
  | 'instagram'
  | 'tiktok'
  | 'youtube'
  | 'github'
  | 'twitch'
  | 'mail';

export interface Social {
  label: string;
  icon: SocialIcon;
  url: string;
}

// Redes de la landing (/)
export const socials: Social[] = [
  { label: 'LinkedIn', icon: 'linkedin', url: 'https://www.linkedin.com/in/josias-alexis-jofre-pol-a98688341/' },
  { label: 'Instagram', icon: 'instagram', url: 'https://www.instagram.com/iamjosiah.cl/' },
  { label: 'TikTok', icon: 'tiktok', url: 'https://www.tiktok.com/@jota_windu' },
  { label: 'YouTube', icon: 'youtube', url: 'https://www.youtube.com/@iamjosiah-cl' },
  { label: 'GitHub', icon: 'github', url: 'https://github.com/iamjosiah-cl' },
  { label: 'Twitch', icon: 'twitch', url: 'https://www.twitch.tv/jotawindu' },
];

// Redes de la sección Contacto del portafolio
export const contactSocials: Social[] = [
  { label: 'GitHub', icon: 'github', url: 'https://github.com/iamjosiah-cl' },
  { label: 'LinkedIn', icon: 'linkedin', url: 'https://www.linkedin.com/in/josias-alexis-jofre-pol-a98688341/' },
  { label: 'Instagram', icon: 'instagram', url: 'https://www.instagram.com/iamjosiah.cl/' },
  { label: 'Email', icon: 'mail', url: 'mailto:josiasjofre@gmail.com' },
];

export const about = {
  paragraphs: [
    'Ingeniero Civil en Informática titulado de la Universidad Adventista de Chile. ' +
      'Desde pequeño, me ha gustado mostrar al mundo quién soy y las cosas que disfruto hacer en mi vida. ' +
      'Te invito a conocerme desde aquí; no dudes en revisar todo lo que desees.',
    'Poseo conocimientos en PHP, bases de datos SQL (incluyendo PostgreSQL) y desarrollo web. ' +
      'Me motiva aprender y adaptarme rápidamente a nuevas herramientas, aportando con soluciones creativas y eficientes.',
    'Mi objetivo es integrarme a un equipo de desarrollo para aportar en la construcción de software de calidad ' +
      'y fortalecer mis competencias profesionales en el ámbito informático.',
  ],
  features: [
    { icon: 'code', title: 'Desarrollo de Software', text: 'Experiencia en múltiples lenguajes y frameworks para crear soluciones efectivas.' },
    { icon: 'database', title: 'Bases de Datos', text: 'Conocimientos en PostgreSQL, MySQL y Firebase para almacenamiento y gestión de datos.' },
    { icon: 'graduation', title: 'Aprendizaje Continuo', text: 'Compromiso con la adquisición de nuevas habilidades y actualización constante.' },
    { icon: 'users', title: 'Trabajo Colaborativo', text: 'Capacidad para integrarse y contribuir efectivamente en equipos multidisciplinarios.' },
  ],
} as const;

export const firebaseConfig = {
  // Configuración pública del cliente web (no es un secreto; la seguridad
  // la definen las reglas de Firestore).
  apiKey: 'AIzaSyDh5wVvE5dIrx_TVUtm2R6147iX2VcJpTc',
  authDomain: 'iamjosiah-2b6be.firebaseapp.com',
  projectId: 'iamjosiah-2b6be',
  storageBucket: 'iamjosiah-2b6be.firebasestorage.app',
  messagingSenderId: '243368828308',
  appId: '1:243368828308:web:dc7192fd9806f3f7c28381',
};
