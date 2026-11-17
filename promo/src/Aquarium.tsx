// El acuario de fondo. Reutiliza los sprites y el escenario del sitio, pero el movimiento
// es una función pura del fotograma: Remotion renderiza cuadros sueltos y en cualquier orden,
// así que no puede depender de un estado acumulado como el motor en vivo.
import { useLayoutEffect, useMemo, useRef } from 'react';
import { useCurrentFrame, useVideoConfig } from 'remotion';
import type { FishDesign } from '../../site/src/acuario/catalog';
import { FRAMES, SPRITE_H, SPRITE_W, fishFrames } from '../../site/src/acuario/sprites';
import { buildLayout, drawBubble, drawPlants, renderBackground, rng } from '../../site/src/acuario/scene';

const SCALE = 6;

export const SCHOOL: FishDesign[] = [
  { species: 'round', color: 'orange', finColor: 'yellow', eyeStyle: 'happy', accessory: 'crown' },
  { species: 'long', color: 'blue', finColor: 'white', eyeStyle: 'normal', accessory: 'none' },
  { species: 'puffer', color: 'yellow', finColor: 'orange', eyeStyle: 'surprised', accessory: 'none' },
  { species: 'angel', color: 'purple', finColor: 'pink', eyeStyle: 'normal', accessory: 'bow' },
  { species: 'round', color: 'green', finColor: 'blue', eyeStyle: 'sleepy', accessory: 'hat' },
  { species: 'angel', color: 'pink', finColor: 'red', eyeStyle: 'happy', accessory: 'flower' },
  { species: 'puffer', color: 'white', finColor: 'blue', eyeStyle: 'normal', accessory: 'glasses' },
  { species: 'long', color: 'red', finColor: 'yellow', eyeStyle: 'happy', accessory: 'none' },
  { species: 'round', color: 'purple', finColor: 'white', eyeStyle: 'surprised', accessory: 'flower' },
  { species: 'long', color: 'green', finColor: 'orange', eyeStyle: 'normal', accessory: 'hat' },
  { species: 'angel', color: 'yellow', finColor: 'blue', eyeStyle: 'happy', accessory: 'none' },
  { species: 'puffer', color: 'pink', finColor: 'purple', eyeStyle: 'happy', accessory: 'crown' },
];

export const Aquarium: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height, fps } = useVideoConfig();
  const ref = useRef<HTMLCanvasElement>(null);
  const w = width / SCALE;
  const h = height / SCALE;

  const world = useMemo(() => {
    const layout = buildLayout(w, h);
    const rand = rng(2026);
    const top = 34;
    const bottom = layout.sandTop - SPRITE_H / 2;
    const fish = SCHOOL.map((design, i) => ({
      frames: fishFrames(design),
      cy: top + ((i + 0.5) / SCHOOL.length) * (bottom - top),
      ax: 45 + rand() * 30,
      ay: 5 + rand() * 9,
      wx: 0.28 + rand() * 0.3,
      wy: 0.5 + rand() * 0.6,
      px: rand() * Math.PI * 2,
      py: rand() * Math.PI * 2,
    }));
    const bubbles = Array.from({ length: 46 }, () => ({
      x: layout.vents[Math.floor(rand() * layout.vents.length)] + (rand() - 0.5) * 60,
      speed: 14 + rand() * 16,
      offset: rand() * 400,
      phase: rand() * 6,
      size: (rand() < 0.55 ? 1 : 2) as 1 | 2,
    }));
    return { layout, bg: renderBackground(layout), fish, bubbles };
  }, [w, h]);

  useLayoutEffect(() => {
    const ctx = ref.current!.getContext('2d')!;
    const t = frame / fps;
    const { layout, bg, fish, bubbles } = world;
    ctx.imageSmoothingEnabled = false;
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.drawImage(bg, 0, 0);
    drawPlants(ctx, layout, t, false, 1);

    for (const f of fish) {
      const a = t * f.wx + f.px;
      const x = w / 2 + Math.sin(a) * f.ax;
      const y = f.cy + Math.sin(t * f.wy + f.py) * f.ay;
      // La derivada de x da la dirección; al pasar por 0 el pez se "da vuelta".
      const turn = Math.max(-1, Math.min(1, Math.cos(a) * 5));
      const sx = Math.abs(turn) < 0.15 ? 0.15 * Math.sign(turn || 1) : turn;
      ctx.save();
      ctx.translate(Math.round(x), 0);
      ctx.scale(sx, 1);
      ctx.drawImage(f.frames[Math.floor(t * 6 + f.px) % FRAMES], -SPRITE_W / 2, Math.round(y - SPRITE_H / 2));
      ctx.restore();
    }

    drawPlants(ctx, layout, t, true, 1);
    const range = layout.sandTop + 12;
    for (const b of bubbles) {
      const y = layout.sandTop - ((t * b.speed + b.offset) % range);
      drawBubble(ctx, { x: b.x + Math.sin(t * 3 + b.phase) * 2, y, speed: b.speed, phase: b.phase, size: b.size });
    }
  }, [frame, fps, world, w]);

  return <canvas ref={ref} width={w} height={h} style={{ position: 'absolute', inset: 0, width, height, imageRendering: 'pixelated' }} />;
};

/** Un pez suelto, ampliado con píxeles nítidos. */
export const FishSprite: React.FC<{ design: FishDesign; scale: number; flip?: boolean }> = ({ design, scale, flip }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const ref = useRef<HTMLCanvasElement>(null);
  const key = Object.values(design).join('|');

  useLayoutEffect(() => {
    const ctx = ref.current!.getContext('2d')!;
    ctx.clearRect(0, 0, SPRITE_W, SPRITE_H);
    ctx.drawImage(fishFrames(design)[Math.floor((frame / fps) * 6) % FRAMES], 0, 0);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [frame, fps, key]);

  return (
    <canvas
      ref={ref}
      width={SPRITE_W}
      height={SPRITE_H}
      style={{ width: SPRITE_W * scale, height: SPRITE_H * scale, imageRendering: 'pixelated', transform: flip ? 'scaleX(-1)' : undefined, display: 'block' }}
    />
  );
};
