// Sprites pixel art generados por capas: cuerpo y aletas (por especie), ojos y accesorio.
// Cada especie se describe con formas simples; el contorno y el sombreado se calculan.
import { COLORS, type FishDesign, type SpeciesId } from './catalog';

export const SPRITE_W = 32;
export const SPRITE_H = 28;
export const FRAMES = 4;

type Pt = [number, number];

interface Shape {
  body: (x: number, y: number) => boolean;
  fins: Pt[][];
  /** Columnas a la izquierda de este x forman la cola (se mueve al nadar). */
  tailCut: number;
  spikes?: { cx: number; cy: number; r: number };
}

const ellipse = (cx: number, cy: number, rx: number, ry: number) => (x: number, y: number) =>
  ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1;

function inPoly(poly: Pt[], x: number, y: number): boolean {
  let inside = false;
  for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    const [xi, yi] = poly[i];
    const [xj, yj] = poly[j];
    if (yi > y !== yj > y && x < ((xj - xi) * (y - yi)) / (yj - yi) + xi) inside = !inside;
  }
  return inside;
}

const SHAPES: Record<SpeciesId, Shape> = {
  round: {
    body: ellipse(18, 17, 8, 6.5),
    fins: [
      [[11, 17], [3, 11], [5.5, 17], [3, 23]],
      [[15, 12], [19, 7.5], [22, 12]],
      [[16, 22], [18, 25.5], [20, 22]],
    ],
    tailCut: 10,
  },
  long: {
    body: ellipse(18, 17, 11, 4.2),
    fins: [
      [[8, 17], [2, 12], [4.5, 17], [2, 22]],
      [[14, 13.5], [18, 10], [23, 13.5]],
    ],
    tailCut: 8,
  },
  puffer: {
    body: ellipse(18, 17, 7.6, 7.6),
    fins: [[[11, 17], [5, 13.5], [5, 20.5]]],
    tailCut: 10,
    spikes: { cx: 18, cy: 17, r: 9.3 },
  },
  angel: {
    body: (x, y) => inPoly([[10, 17], [18, 8.5], [27, 17], [18, 25.5]], x, y),
    fins: [
      [[14, 12], [11, 4.5], [20, 10]],
      [[14, 22], [11, 27.5], [20, 24]],
      [[10, 17], [4, 12.5], [6, 17], [4, 21.5]],
    ],
    tailCut: 9,
  },
};

interface Layer {
  rows: string[];
  ox: number;
  oy: number;
}

const EYE_LAYERS: Record<FishDesign['eyeStyle'], Layer> = {
  normal: { rows: ['ww', 'wk'], ox: 0, oy: 0 },
  happy: { rows: ['.k.', 'k.k'], ox: -1, oy: 0 },
  surprised: { rows: ['www', 'wkw', 'www'], ox: -1, oy: -1 },
  sleepy: { rows: ['kkk'], ox: -1, oy: 1 },
};

/** Accesorios sobre la cabeza: la última fila se apoya en la cabeza. */
const HEAD_LAYERS: Partial<Record<FishDesign['accessory'], Layer>> = {
  crown: { rows: ['y..r..y', 'yy.y.yy', 'yyyyyyy', 'YYYYYYY'], ox: -3, oy: -3 },
  bow: { rows: ['pp.pp', 'pPPPp', 'pp.pp'], ox: -2, oy: -2 },
  hat: { rows: ['.kkkk.', '.kkkk.', '.rrrr.', 'kkkkkk'], ox: -3, oy: -3 },
  flower: { rows: ['.p.', 'pyp', '.p.', '.G.'], ox: -1, oy: -3 },
};

const GLASSES: Layer = { rows: ['kkkkkkk', '...k..k', '...k..k', '...kkkk'], ox: -4, oy: -1 };

const FIXED: Record<string, string> = {
  w: '#ffffff',
  k: '#10131c',
  y: '#f5c542',
  Y: '#b8860b',
  r: '#e0404a',
  p: '#ff7eb6',
  P: '#c2457f',
  G: '#3fae5a',
};

const WAG = [0, 1, 0, -1];

function palette(id: FishDesign['color']) {
  return COLORS.find((c) => c.id === id) ?? COLORS[0];
}

/** Devuelve la matriz de colores (o null) de un fotograma. */
function composeFrame(d: FishDesign, frame: number): (string | null)[] {
  const s = SHAPES[d.species];
  const body = palette(d.color);
  const fin = palette(d.finColor);
  const grid: (string | null)[] = new Array(SPRITE_W * SPRITE_H).fill(null);
  const kind: string[] = new Array(SPRITE_W * SPRITE_H).fill('');
  const wag = WAG[frame % FRAMES];

  // Límites verticales del cuerpo (para sombrear) y frente de la cabeza.
  let minY = SPRITE_H;
  let maxY = 0;
  let front = 0;
  for (let y = 0; y < SPRITE_H; y++) {
    for (let x = 0; x < SPRITE_W; x++) {
      if (!s.body(x + 0.5, y + 0.5)) continue;
      minY = Math.min(minY, y);
      maxY = Math.max(maxY, y);
      front = Math.max(front, x);
    }
  }
  const midY = Math.round((minY + maxY) / 2);

  for (let y = 0; y < SPRITE_H; y++) {
    for (let x = 0; x < SPRITE_W; x++) {
      const i = y * SPRITE_W + x;
      const py = y + 0.5 - (x < s.tailCut ? wag : 0);
      if (s.body(x + 0.5, py)) {
        const t = (y - minY) / Math.max(1, maxY - minY);
        kind[i] = 'b';
        grid[i] = t > 0.72 ? body.shade : t < 0.22 && x > s.tailCut + 2 ? body.light : body.base;
      } else if (s.fins.some((p) => inPoly(p, x + 0.5, py))) {
        kind[i] = 'f';
        grid[i] = (x + y) % 3 === 0 ? fin.shade : fin.base;
      }
    }
  }

  // Branquia y boca.
  const gill = front - 7;
  for (let y = midY - 2; y <= midY + 2; y++) {
    const i = y * SPRITE_W + gill;
    if (kind[i] === 'b') grid[i] = body.shade;
  }
  const mouth = midY * SPRITE_W + front - 1;
  if (kind[mouth] === 'b') grid[mouth] = body.outline;

  // Contorno: celdas vacías junto a una celda pintada.
  const filled = grid.map((c) => c !== null);
  for (let y = 0; y < SPRITE_H; y++) {
    for (let x = 0; x < SPRITE_W; x++) {
      const i = y * SPRITE_W + x;
      if (filled[i]) continue;
      const near =
        (x > 0 && filled[i - 1]) ||
        (x < SPRITE_W - 1 && filled[i + 1]) ||
        (y > 0 && filled[i - SPRITE_W]) ||
        (y < SPRITE_H - 1 && filled[i + SPRITE_W]);
      if (near) grid[i] = kind[i - 1] === 'f' || kind[i + 1] === 'f' ? fin.outline : body.outline;
    }
  }

  if (s.spikes) {
    for (let a = 0; a < 12; a++) {
      const ang = (a / 12) * Math.PI * 2;
      if (Math.cos(ang) < -0.6) continue; // sin púas sobre la cola
      const x = Math.round(s.spikes.cx + Math.cos(ang) * s.spikes.r - 0.5);
      const y = Math.round(s.spikes.cy + Math.sin(ang) * s.spikes.r - 0.5);
      if (x >= 0 && x < SPRITE_W && y >= 0 && y < SPRITE_H) grid[y * SPRITE_W + x] = body.outline;
    }
  }

  const stamp = (layer: Layer, ax: number, ay: number) => {
    layer.rows.forEach((row, ry) => {
      [...row].forEach((ch, rx) => {
        const x = ax + layer.ox + rx;
        const y = ay + layer.oy + ry;
        if (ch === '.' || x < 0 || y < 0 || x >= SPRITE_W || y >= SPRITE_H) return;
        grid[y * SPRITE_W + x] = FIXED[ch];
      });
    });
  };

  const eyeX = front - 4;
  const eyeY = midY - 2;
  stamp(EYE_LAYERS[d.eyeStyle], eyeX, eyeY);

  if (d.accessory === 'glasses') stamp(GLASSES, eyeX, eyeY);
  const head = HEAD_LAYERS[d.accessory];
  if (head) {
    const ax = front - 5;
    let top = 0;
    while (top < SPRITE_H && !s.body(ax + 0.5, top + 0.5)) top++;
    stamp(head, ax, top - 1);
  }
  return grid;
}

function toCanvas(grid: (string | null)[]): HTMLCanvasElement {
  const canvas = document.createElement('canvas');
  canvas.width = SPRITE_W;
  canvas.height = SPRITE_H;
  const ctx = canvas.getContext('2d')!;
  const img = ctx.createImageData(SPRITE_W, SPRITE_H);
  grid.forEach((hex, i) => {
    if (!hex) return;
    const n = parseInt(hex.slice(1), 16);
    img.data.set([(n >> 16) & 255, (n >> 8) & 255, n & 255, 255], i * 4);
  });
  ctx.putImageData(img, 0, 0);
  return canvas;
}

const cache = new Map<string, HTMLCanvasElement[]>();

export function designKey(d: FishDesign): string {
  return [d.species, d.color, d.finColor, d.eyeStyle, d.accessory].join('|');
}

/** Fotogramas de nado del pez (mirando a la derecha), cacheados por diseño. */
export function fishFrames(d: FishDesign): HTMLCanvasElement[] {
  const key = designKey(d);
  let frames = cache.get(key);
  if (!frames) {
    frames = Array.from({ length: FRAMES }, (_, f) => toCanvas(composeFrame(d, f)));
    cache.set(key, frames);
  }
  return frames;
}

/** Anima un pez dentro de un canvas propio (vista previa del creador y de la ficha). */
export function animatePreview(canvas: HTMLCanvasElement, design: () => FishDesign): () => void {
  canvas.width = SPRITE_W;
  canvas.height = SPRITE_H + 2;
  const ctx = canvas.getContext('2d')!;
  let raf = 0;
  const loop = (t: number) => {
    const frames = fishFrames(design());
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.drawImage(frames[Math.floor(t / 160) % FRAMES], 0, 1 + Math.round(Math.sin(t / 420)));
    raf = requestAnimationFrame(loop);
  };
  raf = requestAnimationFrame(loop);
  return () => cancelAnimationFrame(raf);
}
