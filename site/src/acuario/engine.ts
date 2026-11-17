// Motor del acuario en Canvas 2D, independiente de la interfaz.
// Los peces deciden solos a dónde nadar; sus posiciones no se guardan en ningún lado (RN-05).
import { MAX_VISIBLE_FISH, PERSONALITIES, type Fish } from './catalog';
import { FRAMES, SPRITE_H, SPRITE_W, fishFrames } from './sprites';
import { buildLayout, drawBubble, drawPlants, renderBackground, rng, type Bubble, type Layout } from './scene';

type State = 'idle' | 'swim' | 'explore' | 'enter' | 'leave';

interface Swimmer {
  fish: Fish;
  frames: HTMLCanvasElement[];
  x: number;
  y: number;
  vx: number;
  vy: number;
  dir: 1 | -1;
  /** Escala horizontal actual: pasa por 0 al girar (turn). */
  flip: number;
  state: State;
  tx: number;
  ty: number;
  timer: number;
  speed: number;
  rest: number;
  frameT: number;
  bobT: number;
  hop: number;
  onArrive?: () => void;
}

export interface EngineOptions {
  /** Alto en px CSS de la barra superior, para que los peces no naden debajo. */
  topInset: () => number;
  onSelect: (fish: Fish) => void;
  onHover?: (fish: Fish | null) => void;
}

const motionQuery = matchMedia('(prefers-reduced-motion: reduce)');
const reducedMotion = () => motionQuery.matches;

export class AquariumEngine {
  private ctx: CanvasRenderingContext2D;
  private scale = 3;
  private layout!: Layout;
  private bg!: HTMLCanvasElement;
  private swimmers: Swimmer[] = [];
  private pool: Fish[] = [];
  private bubbles: Bubble[] = [];
  private raf = 0;
  private last = 0;
  private time = 0;
  private rotateT = 0;
  private marked: string | null = null;
  private markT = 0;
  private rand = rng(Date.now() % 100000);
  private ro: ResizeObserver;

  constructor(
    private canvas: HTMLCanvasElement,
    private opts: EngineOptions,
  ) {
    this.ctx = canvas.getContext('2d')!;
    this.resize();
    this.ro = new ResizeObserver(() => this.resize());
    this.ro.observe(canvas.parentElement!);
    canvas.addEventListener('pointerup', (e) => {
      const fish = this.fishAt(e.clientX, e.clientY);
      if (fish) this.select(fish.id);
    });
    canvas.addEventListener('pointermove', (e) => {
      if (e.pointerType !== 'mouse') return;
      const fish = this.fishAt(e.clientX, e.clientY);
      canvas.style.cursor = fish ? 'pointer' : '';
      this.opts.onHover?.(fish);
    });
    document.addEventListener('visibilitychange', () => (document.hidden ? this.stop() : this.start()));
  }

  get count() {
    return this.pool.length;
  }

  /** Escala entera: el pixel art se mantiene nítido. */
  private resize() {
    const box = this.canvas.parentElement!.getBoundingClientRect();
    // ~190 px lógicos de alto en pantallas altas, sin dejar menos de ~110 de ancho en celulares.
    this.scale = Math.min(6, Math.max(2, Math.min(Math.round(box.height / 190), Math.round(box.width / 110))));
    const w = Math.ceil(box.width / this.scale);
    const h = Math.ceil(box.height / this.scale);
    if (this.layout && w === this.layout.width && h === this.layout.height) return;
    this.canvas.width = w;
    this.canvas.height = h;
    this.canvas.style.width = `${w * this.scale}px`;
    this.canvas.style.height = `${h * this.scale}px`;
    this.ctx.imageSmoothingEnabled = false;
    this.layout = buildLayout(w, h);
    this.bg = renderBackground(this.layout);
    for (const s of this.swimmers) this.clamp(s);
  }

  private bounds() {
    const top = Math.ceil(this.opts.topInset() / this.scale) + SPRITE_H / 2;
    return {
      minX: SPRITE_W / 2,
      maxX: Math.max(SPRITE_W / 2 + 1, this.layout.width - SPRITE_W / 2),
      minY: Math.min(top, this.layout.sandTop - SPRITE_H),
      maxY: this.layout.sandTop - SPRITE_H / 2 + 2,
    };
  }

  private clamp(s: Swimmer) {
    if (s.state === 'enter' || s.state === 'leave') return;
    const b = this.bounds();
    s.x = Math.min(b.maxX, Math.max(b.minX, s.x));
    s.y = Math.min(b.maxY, Math.max(b.minY, s.y));
  }

  private spawn(fish: Fish, place: 'inside' | 'edge'): Swimmer {
    const b = this.bounds();
    const p = PERSONALITIES.find((x) => x.id === fish.personality) ?? PERSONALITIES[0];
    const fromLeft = this.rand() < 0.5;
    const s: Swimmer = {
      fish,
      frames: fishFrames(fish),
      x: place === 'inside' ? b.minX + this.rand() * (b.maxX - b.minX) : fromLeft ? -SPRITE_W : this.layout.width + SPRITE_W,
      y: b.minY + this.rand() * (b.maxY - b.minY),
      vx: 0,
      vy: 0,
      dir: fromLeft ? 1 : -1,
      flip: fromLeft ? 1 : -1,
      state: 'idle',
      tx: 0,
      ty: 0,
      timer: this.rand() * 2,
      speed: (11 + this.rand() * 6) * p.speed,
      rest: p.rest,
      frameT: this.rand() * FRAMES,
      bobT: this.rand() * 10,
      hop: 0,
    };
    if (place === 'edge') this.goTo(s, 'enter', b.minX + this.rand() * (b.maxX - b.minX), s.y);
    return s;
  }

  /** Selección rotativa (RN-06): como máximo MAX_VISIBLE_FISH a la vez. */
  setFishes(list: Fish[]) {
    this.pool = list.filter((f) => f.status === 'approved');
    const ids = new Set(this.pool.map((f) => f.id));
    this.swimmers = this.swimmers.filter((s) => ids.has(s.fish.id));
    const shown = new Set(this.swimmers.map((s) => s.fish.id));
    const rest = this.shuffle(this.pool.filter((f) => !shown.has(f.id)));
    while (this.swimmers.length < MAX_VISIBLE_FISH && rest.length) this.swimmers.push(this.spawn(rest.pop()!, 'inside'));
  }

  /** Pez que llega mientras miras (lo publicó otra persona): entra nadando por un costado. */
  addFish(fish: Fish) {
    if (fish.status !== 'approved' || this.pool.some((f) => f.id === fish.id)) return;
    this.pool.push(fish);
    if (this.swimmers.length < MAX_VISIBLE_FISH) this.swimmers.push(this.spawn(fish, 'edge'));
  }

  /** Pez recién liberado: entra por un costado, nada al centro y saluda. */
  welcome(fish: Fish): Promise<void> {
    if (!this.pool.some((f) => f.id === fish.id)) this.pool.push(fish);
    this.swimmers = this.swimmers.filter((s) => s.fish.id !== fish.id);
    const s = this.spawn(fish, 'edge');
    this.swimmers.push(s);
    const b = this.bounds();
    return new Promise((resolve) => {
      this.goTo(s, 'enter', (b.minX + b.maxX) / 2, (b.minY + b.maxY) / 2);
      const cruise = s.speed;
      s.speed = Math.max(cruise, 45); // llega rápido al centro y luego vuelve a su ritmo
      s.onArrive = () => {
        s.speed = cruise;
        s.hop = 1;
        this.burst(s.x, s.y);
        this.mark(fish.id);
        resolve();
      };
    });
  }

  /** Ficha + marcador sobre el pez; si no estaba a la vista, entra al acuario. */
  select(id: string) {
    let s = this.swimmers.find((x) => x.fish.id === id);
    const fish = s?.fish ?? this.pool.find((f) => f.id === id);
    if (!fish) return;
    if (!s) {
      s = this.spawn(fish, 'edge');
      this.swimmers.push(s);
    } else if (s.state === 'leave') {
      // Iba saliendo por la rotación: se devuelve para que no desaparezca recién elegido.
      const b = this.bounds();
      this.goTo(s, 'enter', (b.minX + b.maxX) / 2, s.y);
    }
    s.hop = 1;
    this.mark(id);
    this.opts.onSelect(fish);
  }

  mark(id: string | null) {
    this.marked = id;
    this.markT = 8;
  }

  /** Posición en px CSS del pez marcado, para poner su etiqueta. */
  markedPosition(): { x: number; y: number; name: string } | null {
    const s = this.swimmers.find((x) => x.fish.id === this.marked);
    if (!s) return null;
    return { x: s.x * this.scale, y: (s.y - SPRITE_H / 2 - 4) * this.scale, name: s.fish.name };
  }

  start() {
    if (this.raf) return;
    this.last = performance.now();
    const loop = (now: number) => {
      const dt = Math.min(0.05, (now - this.last) / 1000);
      this.last = now;
      this.update(dt);
      this.draw();
      this.raf = requestAnimationFrame(loop);
    };
    this.raf = requestAnimationFrame(loop);
  }

  stop() {
    cancelAnimationFrame(this.raf);
    this.raf = 0;
  }

  private shuffle<T>(arr: T[]): T[] {
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(this.rand() * (i + 1));
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
  }

  private goTo(s: Swimmer, state: State, tx: number, ty: number) {
    s.state = state;
    s.tx = tx;
    s.ty = ty;
    s.timer = 12;
  }

  private pickTarget(s: Swimmer) {
    const b = this.bounds();
    const spots = this.layout.interest;
    if (this.rand() < 0.25 && spots.length) {
      const p = spots[Math.floor(this.rand() * spots.length)];
      this.goTo(s, 'explore', Math.min(b.maxX, Math.max(b.minX, p.x + (this.rand() - 0.5) * 20)), Math.min(b.maxY, Math.max(b.minY, p.y)));
    } else {
      this.goTo(s, 'swim', b.minX + this.rand() * (b.maxX - b.minX), b.minY + this.rand() * (b.maxY - b.minY));
    }
  }

  private burst(x: number, y: number) {
    for (let i = 0; i < 10; i++) {
      this.bubbles.push({ x: x + (this.rand() - 0.5) * 16, y: y + (this.rand() - 0.5) * 8, speed: 14 + this.rand() * 14, phase: this.rand() * 6, size: this.rand() < 0.5 ? 1 : 2 });
    }
  }

  private update(dt: number) {
    const motion = reducedMotion() ? 0.5 : 1;
    this.time += dt;
    this.markT -= dt;
    if (this.markT <= 0) this.marked = null;

    for (const s of this.swimmers) {
      s.bobT += dt * 2.2;
      s.hop = Math.max(0, s.hop - dt * 2);
      s.timer -= dt;

      if (s.state === 'idle') {
        s.vx *= 1 - Math.min(1, dt * 3);
        s.vy *= 1 - Math.min(1, dt * 3);
        if (s.timer <= 0) this.pickTarget(s);
      } else {
        const dx = s.tx - s.x;
        const dy = s.ty - s.y;
        const dist = Math.hypot(dx, dy);
        const arrive = Math.min(1, dist / 12);
        const sp = s.speed * motion * arrive;
        s.vx += ((dx / (dist || 1)) * sp - s.vx) * Math.min(1, dt * 2.5);
        s.vy += ((dy / (dist || 1)) * sp * 0.6 - s.vy) * Math.min(1, dt * 2.5);
        // El tiempo límite solo aplica dentro del acuario: un pez que entra o sale
        // debe completar el trayecto, o aparecería de golpe en el borde.
        const timedOut = s.timer <= 0 && s.state !== 'enter' && s.state !== 'leave';
        if (dist < 3 || timedOut) {
          const cb = s.onArrive;
          s.onArrive = undefined;
          s.state = s.state === 'leave' ? 'leave' : 'idle';
          s.timer = (0.6 + this.rand() * 2.4) * s.rest;
          cb?.();
        }
      }
      s.x += s.vx * dt;
      s.y += s.vy * dt;
      if (s.vx > 1.5) s.dir = 1;
      else if (s.vx < -1.5) s.dir = -1;
      s.flip += Math.sign(s.dir - s.flip) * Math.min(Math.abs(s.dir - s.flip), dt * 7);
      s.frameT += dt * (2 + Math.abs(s.vx) * 0.35);
      if (s.state !== 'enter' && s.state !== 'leave') this.clamp(s);
      if (this.rand() < dt * 0.05) this.bubbles.push({ x: s.x + s.dir * 12, y: s.y - 1, speed: 10, phase: 0, size: 1 });
    }
    this.swimmers = this.swimmers.filter((s) => !(s.state === 'leave' && (s.x < -SPRITE_W || s.x > this.layout.width + SPRITE_W)));

    // Rotación: cada cierto tiempo unos peces se van y entran otros que no estaban visibles.
    this.rotateT += dt;
    if (this.rotateT > 40 && this.pool.length > this.swimmers.length) {
      this.rotateT = 0;
      const shown = new Set(this.swimmers.map((s) => s.fish.id));
      const waiting = this.shuffle(this.pool.filter((f) => !shown.has(f.id)));
      for (const s of this.shuffle([...this.swimmers]).slice(0, 3)) {
        if (s.fish.id === this.marked) continue;
        this.goTo(s, 'leave', s.x < this.layout.width / 2 ? -SPRITE_W * 2 : this.layout.width + SPRITE_W * 2, s.y);
        const next = waiting.pop();
        if (next) this.swimmers.push(this.spawn(next, 'edge'));
      }
    }

    // Burbujas desde la arena.
    if (this.rand() < dt * 2.2 * motion) {
      const vent = this.layout.vents[Math.floor(this.rand() * this.layout.vents.length)];
      this.bubbles.push({ x: vent + (this.rand() - 0.5) * 4, y: this.layout.sandTop, speed: 10 + this.rand() * 10, phase: this.rand() * 6, size: this.rand() < 0.6 ? 1 : 2 });
    }
    for (const b of this.bubbles) {
      b.y -= b.speed * dt;
      b.x += Math.sin(this.time * 3 + b.phase) * dt * 4;
    }
    this.bubbles = this.bubbles.filter((b) => b.y > 2).slice(-120);
  }

  private draw() {
    const { ctx } = this;
    const motion = reducedMotion() ? 0.4 : 1;
    ctx.drawImage(this.bg, 0, 0);
    drawPlants(ctx, this.layout, this.time, false, motion);

    for (const s of this.swimmers) {
      const frame = s.frames[Math.floor(s.frameT) % FRAMES];
      const lift = Math.sin(s.hop * Math.PI) * 5;
      const y = Math.round(s.y - SPRITE_H / 2 + Math.sin(s.bobT) * 0.8 - lift);
      ctx.save();
      ctx.translate(Math.round(s.x), 0);
      const sx = Math.abs(s.flip) < 0.15 ? 0.15 * Math.sign(s.flip || 1) : s.flip;
      ctx.scale(sx, 1);
      ctx.drawImage(frame, -SPRITE_W / 2, y);
      ctx.restore();
    }

    drawPlants(ctx, this.layout, this.time, true, motion);
    for (const b of this.bubbles) drawBubble(ctx, b);

    // Marcador sobre el pez seleccionado.
    const m = this.swimmers.find((s) => s.fish.id === this.marked);
    if (m) {
      const x = Math.round(m.x) - 2;
      const y = Math.round(m.y - SPRITE_H / 2 - 6 + Math.sin(this.time * 6) * 1.5);
      ctx.fillStyle = '#fff6a8';
      ctx.fillRect(x, y, 5, 1);
      ctx.fillRect(x + 1, y + 1, 3, 1);
      ctx.fillRect(x + 2, y + 2, 1, 1);
    }
  }

  private fishAt(clientX: number, clientY: number): Fish | null {
    const r = this.canvas.getBoundingClientRect();
    const x = (clientX - r.left) / this.scale;
    const y = (clientY - r.top) / this.scale;
    let best: Swimmer | null = null;
    let bestD = Infinity;
    for (const s of this.swimmers) {
      const dx = Math.abs(x - s.x);
      const dy = Math.abs(y - s.y);
      if (dx > SPRITE_W / 2 || dy > SPRITE_H / 2 - 2) continue;
      const d = dx + dy;
      if (d < bestD) {
        best = s;
        bestD = d;
      }
    }
    return best?.fish ?? null;
  }
}
