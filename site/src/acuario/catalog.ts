// Catálogo autorizado de Mi Acuario (RN-04): solo se aceptan valores de estas listas.

export const SPECIES = [
  { id: 'round', label: 'Redondito' },
  { id: 'long', label: 'Veloz' },
  { id: 'puffer', label: 'Globito' },
  { id: 'angel', label: 'Ángel' },
] as const;

export interface Palette {
  base: string;
  shade: string;
  light: string;
  outline: string;
}

export const COLORS = [
  { id: 'orange', label: 'Naranja', base: '#f7922c', shade: '#c95f1a', light: '#ffc46b', outline: '#5a2412' },
  { id: 'blue', label: 'Azul', base: '#3b9cf0', shade: '#2563b8', light: '#8fd3ff', outline: '#142a5c' },
  { id: 'pink', label: 'Rosa', base: '#f27bb5', shade: '#c24a8a', light: '#ffc0dd', outline: '#5a1a3d' },
  { id: 'green', label: 'Verde', base: '#4cc46a', shade: '#2a8a4a', light: '#a6ee8a', outline: '#123d24' },
  { id: 'purple', label: 'Morado', base: '#9b6bf2', shade: '#6a40c2', light: '#cdb4ff', outline: '#2c1a5a' },
  { id: 'yellow', label: 'Amarillo', base: '#f5d23c', shade: '#c99a1e', light: '#fff19a', outline: '#5a4210' },
  { id: 'red', label: 'Rojo', base: '#e84a4a', shade: '#a82a36', light: '#ff9a8a', outline: '#4a1018' },
  { id: 'white', label: 'Blanco', base: '#e8eef5', shade: '#a9b6c8', light: '#ffffff', outline: '#34405a' },
] as const satisfies readonly (Palette & { id: string; label: string })[];

export const EYES = [
  { id: 'normal', label: 'Normal' },
  { id: 'happy', label: 'Feliz' },
  { id: 'surprised', label: 'Sorprendido' },
  { id: 'sleepy', label: 'Dormilón' },
] as const;

export const ACCESSORIES = [
  { id: 'none', label: 'Ninguno' },
  { id: 'crown', label: 'Corona' },
  { id: 'bow', label: 'Moño' },
  { id: 'hat', label: 'Sombrero' },
  { id: 'glasses', label: 'Lentes' },
  { id: 'flower', label: 'Flor' },
] as const;

/** speed y rest modifican el nado: velocidad y cuánto descansa entre trayectos. */
export const PERSONALITIES = [
  { id: 'curious', label: 'Curioso', speed: 1, rest: 1 },
  { id: 'shy', label: 'Tímido', speed: 0.8, rest: 1.6 },
  { id: 'playful', label: 'Juguetón', speed: 1.45, rest: 0.5 },
  { id: 'sleepy', label: 'Dormilón', speed: 0.55, rest: 2.4 },
  { id: 'adventurous', label: 'Aventurero', speed: 1.25, rest: 0.7 },
  { id: 'hungry', label: 'Glotón', speed: 1.05, rest: 1.1 },
] as const;

export const MESSAGES = [
  { id: 'loves_exploring', label: 'Me encanta explorar' },
  { id: 'looking_friends', label: 'Busco nuevos amigos' },
  { id: 'bubble_king', label: 'Soy el rey de las burbujas' },
  { id: 'nap_time', label: 'Siempre estoy en mi siesta' },
  { id: 'snack_time', label: '¿Alguien trajo comida?' },
  { id: 'hello_ocean', label: '¡Hola, océano!' },
] as const;

type Id<T extends readonly { id: string }[]> = T[number]['id'];

export type SpeciesId = Id<typeof SPECIES>;
export type ColorId = Id<typeof COLORS>;
export type EyesId = Id<typeof EYES>;
export type AccessoryId = Id<typeof ACCESSORIES>;
export type PersonalityId = Id<typeof PERSONALITIES>;
export type MessageId = Id<typeof MESSAGES>;

export interface FishDesign {
  species: SpeciesId;
  color: ColorId;
  finColor: ColorId;
  eyeStyle: EyesId;
  accessory: AccessoryId;
}

/** Mismo modelo que fishes/{fishId} del plan, más el código público. */
export interface Fish extends FishDesign {
  id: string;
  name: string;
  creatorName: string;
  personality: PersonalityId;
  messageId: MessageId;
  zoneId: 'reef';
  status: 'approved' | 'hidden';
  createdAt: string;
  demo?: boolean;
}

export function labelOf(list: readonly { id: string; label: string }[], id: string): string {
  return list.find((x) => x.id === id)?.label ?? id;
}

export function inCatalog(list: readonly { id: string }[], id: unknown): boolean {
  return typeof id === 'string' && list.some((x) => x.id === id);
}

export const MAX_VISIBLE_FISH = 50;
