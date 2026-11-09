export interface GameInfo {
  slug: string;
  title: string;
  emoji: string;
  color: string;
}

export const games: GameInfo[] = [
  { slug: 'codigo-secreto', title: 'El Código Secreto', emoji: '🔑', color: '#8b5cf6' },
  { slug: 'buscando-numeros', title: 'Buscando los números', emoji: '🔍', color: '#38bdf8' },
  { slug: 'patrones-colores', title: 'Patrones y colores', emoji: '🎨', color: '#4ade80' },
];
