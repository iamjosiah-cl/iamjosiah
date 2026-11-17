// Escenario pixel art: fondo estático (agua, rayos, arena, rocas, corales) y capas animadas
// (algas y burbujas). Todo se dibuja a la resolución lógica y se escala sin suavizado.

export function rng(seed: number) {
  return () => {
    seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

const WATER = ['#3fa7d6', '#2f93c6', '#2580b4', '#1d6ea1', '#165c8c', '#114c78', '#0d3d64', '#0a3052'];

export interface Plant {
  x: number;
  height: number;
  phase: number;
  color: string;
  dark: string;
  front: boolean;
}

export interface Layout {
  width: number;
  height: number;
  sandTop: number;
  plants: Plant[];
  /** Puntos que los peces exploradores visitan (corales y algas). */
  interest: { x: number; y: number }[];
  vents: number[];
}

export function sandLine(x: number, sandTop: number): number {
  return sandTop + Math.round(Math.sin(x * 0.13) * 1.4 + Math.sin(x * 0.041 + 1) * 2);
}

export function buildLayout(width: number, height: number): Layout {
  const rand = rng(width * 31 + height);
  const sandTop = height - Math.max(16, Math.round(height * 0.12));
  const plants: Plant[] = [];
  const count = Math.max(4, Math.round(width / 26));
  for (let i = 0; i < count; i++) {
    const front = i % 4 === 3;
    plants.push({
      x: Math.round(((i + 0.3 + rand() * 0.4) / count) * width),
      height: Math.round((front ? 0.22 : 0.28 + rand() * 0.2) * height),
      phase: rand() * Math.PI * 2,
      color: front ? '#2fa35a' : '#1f7a4a',
      dark: front ? '#1d6b3b' : '#145236',
      front,
    });
  }
  const interest = plants.filter((p) => !p.front).map((p) => ({ x: p.x, y: sandTop - p.height * 0.6 }));
  const vents = [0.18, 0.55, 0.83].map((f) => Math.round(f * width));
  return { width, height, sandTop, plants, interest, vents };
}

function px(ctx: CanvasRenderingContext2D, color: string, x: number, y: number, w = 1, h = 1) {
  ctx.fillStyle = color;
  ctx.fillRect(x, y, w, h);
}

function coral(ctx: CanvasRenderingContext2D, rand: () => number, x: number, base: number, size: number) {
  const palettes = [
    ['#ff7b8a', '#c94a64'],
    ['#ffb35c', '#d47a2a'],
    ['#c58bff', '#8c55d4'],
  ];
  const [main, dark] = palettes[Math.floor(rand() * palettes.length)];
  // Ramas en Y que se bifurcan hacia arriba.
  const branch = (bx: number, by: number, len: number, dir: number, depth: number) => {
    let cx = bx;
    for (let i = 0; i < len; i++) {
      px(ctx, i % 3 === 0 ? dark : main, cx, by - i, 2, 1);
      if (i % 2 === 1) cx += dir;
    }
    if (depth > 0) {
      branch(cx, by - len, Math.max(2, len - 2), -1, depth - 1);
      branch(cx + 1, by - len, Math.max(2, len - 2), 1, depth - 1);
    }
  };
  branch(x, base, size, 0, 2);
}

function brain(ctx: CanvasRenderingContext2D, x: number, base: number, r: number) {
  for (let y = -r; y <= 0; y++) {
    for (let dx = -r; dx <= r; dx++) {
      if (dx * dx + y * y > r * r) continue;
      const edge = dx * dx + y * y > (r - 1) * (r - 1);
      px(ctx, edge ? '#3d8a7a' : (dx + y * 2) % 4 === 0 ? '#58b39c' : '#7fd6bd', x + dx, base + y);
    }
  }
}

/** Fondo estático, renderizado una vez por tamaño. */
export function renderBackground(layout: Layout): HTMLCanvasElement {
  const { width, height, sandTop } = layout;
  const canvas = document.createElement('canvas');
  canvas.width = width;
  canvas.height = height;
  const ctx = canvas.getContext('2d')!;
  const rand = rng(width * 7 + height * 13);

  // Agua en bandas, con una fila de tramado entre bandas.
  const band = Math.ceil(height / WATER.length);
  WATER.forEach((c, i) => px(ctx, c, 0, i * band, width, band));
  for (let i = 1; i < WATER.length; i++) {
    for (let x = 0; x < width; x += 2) px(ctx, WATER[i - 1], x + (i % 2), i * band, 1, 1);
  }

  // Rayos de luz diagonales.
  ctx.globalAlpha = 0.07;
  for (let r = 0; r < 4; r++) {
    const start = Math.round(width * (0.1 + r * 0.26));
    for (let y = 0; y < sandTop; y++) px(ctx, '#ffffff', start + Math.round(y * 0.35), y, 5 + r, 1);
  }
  ctx.globalAlpha = 1;

  // Rocas lejanas.
  for (let i = 0; i < 4; i++) {
    const cx = Math.round(rand() * width);
    const r = Math.round(height * (0.08 + rand() * 0.06));
    for (let dx = -r * 2; dx <= r * 2; dx++) {
      const h = Math.round(Math.sqrt(Math.max(0, 1 - (dx / (r * 2)) ** 2)) * r);
      px(ctx, '#0e4468', cx + dx, sandTop - h + 2, 1, h);
    }
  }

  // Arena con bordes ondulados y granos.
  for (let x = 0; x < width; x++) {
    const top = sandLine(x, sandTop);
    px(ctx, '#c9a25c', x, top, 1, 1);
    px(ctx, '#e6c27a', x, top + 1, 1, height - top);
  }
  for (let i = 0; i < width * 0.6; i++) {
    const x = Math.floor(rand() * width);
    const y = sandLine(x, sandTop) + 2 + Math.floor(rand() * (height - sandTop));
    px(ctx, rand() < 0.5 ? '#f3d79a' : '#c9a25c', x, y);
  }

  // Rocas y corales sobre la arena.
  for (let i = 0; i < Math.max(2, Math.round(width / 70)); i++) {
    const x = Math.round(rand() * width);
    const base = sandLine(x, sandTop) + 1;
    const w = 5 + Math.round(rand() * 5);
    for (let dx = 0; dx < w; dx++) {
      const h = Math.round(Math.sin((dx / (w - 1)) * Math.PI) * (w * 0.45)) + 1;
      px(ctx, dx < w / 2 ? '#8a94a6' : '#6b7486', x + dx, base - h, 1, h);
    }
  }
  const corals = Math.max(3, Math.round(width / 45));
  for (let i = 0; i < corals; i++) {
    const x = Math.round(((i + 0.5) / corals) * width + (rand() - 0.5) * 20);
    const base = sandLine(x, sandTop) + 1;
    if (i % 3 === 1) brain(ctx, x, base, 4 + Math.round(rand() * 2));
    else coral(ctx, rand, x, base, 3 + Math.round(rand() * 3));
  }
  return canvas;
}

/** Algas que se mecen. */
export function drawPlants(ctx: CanvasRenderingContext2D, layout: Layout, t: number, front: boolean, motion: number) {
  for (const p of layout.plants) {
    if (p.front !== front) continue;
    const base = sandLine(p.x, layout.sandTop) + 1;
    for (let i = 0; i < p.height; i++) {
      const sway = Math.round(Math.sin(t * 1.3 + p.phase + i * 0.18) * (i / p.height) * 3 * motion);
      const x = p.x + sway;
      px(ctx, i % 4 === 0 ? p.dark : p.color, x, base - i, 2, 1);
      if (i % 5 === 2 && i > 3) px(ctx, p.color, x + (i % 10 === 2 ? 2 : -1), base - i, 1, 1);
    }
  }
}

export interface Bubble {
  x: number;
  y: number;
  speed: number;
  phase: number;
  size: 1 | 2;
}

export function drawBubble(ctx: CanvasRenderingContext2D, b: Bubble) {
  const x = Math.round(b.x);
  const y = Math.round(b.y);
  if (b.size === 1) return px(ctx, '#c9f1ff', x, y);
  px(ctx, '#9fdcf5', x, y, 2, 2);
  px(ctx, '#ffffff', x, y);
}
