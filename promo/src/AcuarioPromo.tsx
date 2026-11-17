import type { CSSProperties, ReactNode } from 'react';
import { AbsoluteFill, Sequence, interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion';
import { loadFont } from '@remotion/google-fonts/PixelifySans';
import { ACCESSORIES, COLORS, SPECIES, labelOf, type FishDesign } from '../../site/src/acuario/catalog';
import { Aquarium, FishSprite, SCHOOL } from './Aquarium';

const { fontFamily } = loadFont('normal', { weights: ['500', '700'], subsets: ['latin'] });

export const FPS = 30;
// Escenas (en fotogramas): título, crear, liberar, llamado final.
const INTRO = 90;
const CREATE = 150;
const RELEASE = 105;
const CTA = 135;
export const DURATION = INTRO + CREATE + RELEASE + CTA;

const INK = '#071a2e';
const SAND = '#f3d79a';
const CORAL = '#ff8a5c';
const AQUA = '#5fe3d0';

const text = (size: number, color = '#ffffff'): CSSProperties => ({
  fontFamily,
  fontWeight: 700,
  fontSize: size,
  lineHeight: 1.05,
  color,
  textAlign: 'center',
  fontVariantLigatures: 'none',
  WebkitTextStroke: `${Math.round(size / 6)}px ${INK}`,
  paintOrder: 'stroke fill',
  textShadow: `0 ${Math.round(size / 12)}px 0 ${INK}`,
  margin: 0,
});

/** Texto oscuro sobre fondo claro: sin contorno. */
const flat: CSSProperties = { textShadow: 'none', WebkitTextStroke: '0' };

const panel: CSSProperties = {
  background: 'rgb(13 42 69 / 0.92)',
  border: '8px solid #2b5c85',
  boxShadow: `0 0 0 8px ${INK}`,
  borderRadius: 12,
};

/** Aparece al inicio de la escena y se va en sus últimos fotogramas. */
const Scene: React.FC<{ duration: number; children: ReactNode }> = ({ duration, children }) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 8, duration - 8, duration], [0, 1, 1, 0], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' });
  return (
    // Zona segura de historias: nada importante en los ~270 px de arriba ni en los ~340 de abajo.
    <AbsoluteFill style={{ opacity, padding: '280px 70px 360px', alignItems: 'center', justifyContent: 'center', gap: 48 }}>{children}</AbsoluteFill>
  );
};

const Pop: React.FC<{ delay?: number; children: ReactNode; style?: CSSProperties }> = ({ delay = 0, children, style }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = spring({ frame: frame - delay, fps, config: { damping: 14, stiffness: 140 } });
  return <div style={{ transform: `translateY(${(1 - s) * 60}px) scale(${0.85 + s * 0.15})`, opacity: Math.min(1, s * 1.5), ...style }}>{children}</div>;
};

const Intro = () => {
  const frame = useCurrentFrame();
  return (
    <Scene duration={INTRO}>
      <Pop>
        <div style={{ transform: `translateY(${Math.sin(frame / 9) * 14}px)` }}>
          <FishSprite design={SCHOOL[0]} scale={15} />
        </div>
      </Pop>
      <Pop delay={8}>
        <h1 style={text(170, SAND)}>Mi Acuario</h1>
      </Pop>
      <Pop delay={18}>
        <p style={text(62)}>Un océano hecho entre todos</p>
      </Pop>
    </Scene>
  );
};

// Diseños que va mostrando el "creador": cambia una cosa a la vez.
const BUILDS: FishDesign[] = [
  { species: 'round', color: 'orange', finColor: 'yellow', eyeStyle: 'normal', accessory: 'none' },
  { species: 'round', color: 'blue', finColor: 'yellow', eyeStyle: 'normal', accessory: 'none' },
  { species: 'round', color: 'pink', finColor: 'purple', eyeStyle: 'normal', accessory: 'none' },
  { species: 'angel', color: 'pink', finColor: 'purple', eyeStyle: 'normal', accessory: 'none' },
  { species: 'puffer', color: 'green', finColor: 'purple', eyeStyle: 'normal', accessory: 'none' },
  { species: 'puffer', color: 'green', finColor: 'orange', eyeStyle: 'happy', accessory: 'none' },
  { species: 'puffer', color: 'green', finColor: 'orange', eyeStyle: 'happy', accessory: 'glasses' },
  { species: 'long', color: 'red', finColor: 'white', eyeStyle: 'happy', accessory: 'hat' },
  { species: 'angel', color: 'purple', finColor: 'pink', eyeStyle: 'surprised', accessory: 'bow' },
  { species: 'round', color: 'yellow', finColor: 'red', eyeStyle: 'happy', accessory: 'crown' },
];

const Chip: React.FC<{ children: ReactNode }> = ({ children }) => (
  <span style={{ ...text(44), ...flat, padding: '10px 26px', background: '#123a5c', border: `5px solid ${AQUA}`, borderRadius: 8 }}>{children}</span>
);

const Create = () => {
  const frame = useCurrentFrame();
  const step = Math.min(BUILDS.length - 1, Math.floor(Math.max(0, frame - 14) / 13));
  const design = BUILDS[step];
  const pulse = 1 + Math.max(0, 1 - ((Math.max(0, frame - 14) % 13) / 5)) * 0.06;
  return (
    <Scene duration={CREATE}>
      <Pop>
        <h1 style={text(130, SAND)}>Crea tu pez</h1>
      </Pop>
      <Pop delay={6} style={{ ...panel, padding: 44, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 36 }}>
        <div style={{ background: 'radial-gradient(circle at 50% 40%, #1f78a8, #0d3d64 70%)', border: `8px solid ${INK}`, borderRadius: 8, padding: '36px 44px' }}>
          <div style={{ transform: `scale(${pulse})` }}>
            <FishSprite design={design} scale={17} />
          </div>
        </div>
        <div style={{ display: 'flex', gap: 14 }}>
          {COLORS.map((c) => (
            <div
              key={c.id}
              style={{
                width: 78,
                height: 78,
                background: c.base,
                border: `6px solid ${INK}`,
                borderRadius: 8,
                boxShadow: 'inset -8px -8px 0 rgb(0 0 0 / 0.2)',
                outline: c.id === design.color ? `7px solid ${AQUA}` : 'none',
                outlineOffset: 4,
              }}
            />
          ))}
        </div>
        <div style={{ display: 'flex', gap: 18 }}>
          <Chip>{labelOf(SPECIES, design.species)}</Chip>
          <Chip>{labelOf(ACCESSORIES, design.accessory)}</Chip>
        </div>
      </Pop>
      <Pop delay={14}>
        <p style={text(56)}>Especie, colores, ojos y accesorios</p>
      </Pop>
    </Scene>
  );
};

const HERO: FishDesign = BUILDS[BUILDS.length - 1];
const NAME = 'Burbujín';

const Release = () => {
  const frame = useCurrentFrame();
  const { fps, width } = useVideoConfig();
  const swim = spring({ frame: frame - 18, fps, config: { damping: 18, stiffness: 55 } });
  const typed = NAME.slice(0, Math.max(0, Math.floor((frame - 34) / 3)));
  return (
    <Scene duration={RELEASE}>
      <Pop>
        <h1 style={text(120, SAND)}>Ponle nombre</h1>
      </Pop>
      <div style={{ transform: `translate(${(swim - 1) * width}px, ${Math.sin(frame / 8) * 16}px)`, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 20 }}>
        <span
          style={{
            ...text(70, INK),
            ...flat,
            minWidth: 90,
            minHeight: 86,
            padding: '6px 28px',
            background: '#fff6a8',
            border: `7px solid ${INK}`,
            borderRadius: 8,
            visibility: typed ? 'visible' : 'hidden',
          }}
        >
          {typed}
        </span>
        <FishSprite design={HERO} scale={18} />
      </div>
      <Pop delay={50}>
        <p style={text(64)}>
          y libéralo con los
          <br />
          peces de todos
        </p>
      </Pop>
    </Scene>
  );
};

const Cta = () => {
  const frame = useCurrentFrame();
  const beat = 1 + Math.sin(frame / 5) * 0.035;
  return (
    <Scene duration={CTA + 10}>
      <Pop>
        <div style={{ display: 'flex', gap: 10, alignItems: 'flex-end' }}>
          <FishSprite design={SCHOOL[3]} scale={8} />
          <FishSprite design={HERO} scale={11} />
          <FishSprite design={SCHOOL[6]} scale={8} flip />
        </div>
      </Pop>
      <Pop delay={6}>
        <h1 style={{ ...text(132, SAND), whiteSpace: 'nowrap' }}>¡Crea el tuyo!</h1>
      </Pop>
      <Pop delay={16}>
        <div
          style={{
            ...text(84, '#2b0e04'),
            ...flat,
            transform: `scale(${beat})`,
            padding: '34px 60px',
            background: CORAL,
            border: '9px solid #8a2f12',
            borderRadius: 12,
            boxShadow: 'inset -9px -9px 0 rgb(0 0 0 / 0.18), inset 9px 9px 0 rgb(255 255 255 / 0.3), 0 14px 0 #8a2f12',
          }}
        >
          Link en mi perfil
        </div>
      </Pop>
      <Pop delay={26}>
        <p style={text(66)}>@iamjosiah.cl</p>
      </Pop>
      <Pop delay={34}>
        <p style={text(48, AQUA)}>Gratis · sin registro</p>
      </Pop>
    </Scene>
  );
};

export const AcuarioPromo = () => (
  <AbsoluteFill style={{ background: '#0a3052' }}>
    <Aquarium />
    <AbsoluteFill style={{ background: 'linear-gradient(rgb(7 26 46 / 0.4), rgb(7 26 46 / 0.28) 45%, rgb(7 26 46 / 0.4))' }} />
    <Sequence durationInFrames={INTRO}>
      <Intro />
    </Sequence>
    <Sequence from={INTRO} durationInFrames={CREATE}>
      <Create />
    </Sequence>
    <Sequence from={INTRO + CREATE} durationInFrames={RELEASE}>
      <Release />
    </Sequence>
    <Sequence from={INTRO + CREATE + RELEASE} durationInFrames={CTA}>
      <Cta />
    </Sequence>
  </AbsoluteFill>
);
