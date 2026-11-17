import { Composition } from 'remotion';
import { AcuarioPromo, DURATION, FPS } from './AcuarioPromo';

// Historia de Instagram: 1080×1920 (9:16).
export const Root = () => (
  <Composition id="AcuarioPromo" component={AcuarioPromo} durationInFrames={DURATION} fps={FPS} width={1080} height={1920} />
);
