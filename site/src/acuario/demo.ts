// Peces de muestra para que el acuario no se vea vacío antes de conectar la nube.
import type { Fish } from './catalog';

type Demo = Pick<Fish, 'id' | 'name' | 'species' | 'color' | 'finColor' | 'eyeStyle' | 'accessory' | 'personality' | 'messageId'>;

const demos: Demo[] = [
  { id: 'BURBU1', name: 'Burbujín', species: 'round', color: 'orange', finColor: 'yellow', eyeStyle: 'happy', accessory: 'crown', personality: 'curious', messageId: 'bubble_king' },
  { id: 'AZULIT', name: 'Azulito', species: 'long', color: 'blue', finColor: 'white', eyeStyle: 'normal', accessory: 'none', personality: 'adventurous', messageId: 'loves_exploring' },
  { id: 'PINCHO', name: 'Pinchito', species: 'puffer', color: 'yellow', finColor: 'orange', eyeStyle: 'surprised', accessory: 'none', personality: 'shy', messageId: 'looking_friends' },
  { id: 'ANGELA', name: 'Angélica', species: 'angel', color: 'purple', finColor: 'pink', eyeStyle: 'normal', accessory: 'bow', personality: 'playful', messageId: 'hello_ocean' },
  { id: 'SIESTA', name: 'Don Siesta', species: 'round', color: 'green', finColor: 'blue', eyeStyle: 'sleepy', accessory: 'hat', personality: 'sleepy', messageId: 'nap_time' },
  { id: 'CORALI', name: 'Coralina', species: 'angel', color: 'pink', finColor: 'red', eyeStyle: 'happy', accessory: 'flower', personality: 'curious', messageId: 'loves_exploring' },
  { id: 'PROFE7', name: 'Profe Pez', species: 'puffer', color: 'white', finColor: 'blue', eyeStyle: 'normal', accessory: 'glasses', personality: 'hungry', messageId: 'snack_time' },
  { id: 'RAYO22', name: 'Rayo', species: 'long', color: 'red', finColor: 'yellow', eyeStyle: 'happy', accessory: 'none', personality: 'playful', messageId: 'hello_ocean' },
];

export const DEMO_FISH: Fish[] = demos.map((d) => ({
  ...d,
  creatorName: 'I Am Josiah',
  zoneId: 'reef',
  status: 'approved',
  createdAt: '2026-11-16T12:00:00.000Z',
  demo: true,
}));
