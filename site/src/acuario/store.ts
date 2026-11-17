// Servicio de peces. Por ahora guarda en este navegador (localStorage); la interfaz
// FishService es la que luego implementará la versión con Firebase (Sprint 4).
import {
  ACCESSORIES,
  COLORS,
  EYES,
  MESSAGES,
  PERSONALITIES,
  SPECIES,
  inCatalog,
  type Fish,
  type FishDesign,
  type MessageId,
  type PersonalityId,
} from './catalog';
import { DEMO_FISH } from './demo';

export interface NewFish extends FishDesign {
  name: string;
  creatorName: string;
  personality: PersonalityId;
  messageId: MessageId;
}

export type FieldErrors = Partial<Record<keyof NewFish, string>>;

export type PublishResult = { ok: true; fish: Fish } | { ok: false; message: string; errors?: FieldErrors };

export interface FishService {
  list(): Fish[];
  get(id: string): Fish | undefined;
  /** Pez creado desde este navegador (RF-13). */
  mine(): Fish | undefined;
  publish(input: NewFish): PublishResult;
  /** Avisa cuando cambian los peces, p. ej. al publicar desde otra pestaña (RF-07). */
  subscribe(cb: () => void): () => void;
}

const KEY = 'acuario:v1';
const CODE_CHARS = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

interface Saved {
  fishes: Fish[];
  mine?: string;
}

/** Minúsculas, sin tildes y con espacios simples (búsqueda y moderación). */
export function normalize(text: string): string {
  return text.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase().replace(/\s+/g, ' ').trim();
}

export function cleanName(text: string): string {
  return text.replace(/\s+/g, ' ').trim();
}

// Moderación básica en el cliente. La versión con servidor debe repetir esta validación.
const BLOCKED_ANYWHERE = ['conchetumare', 'culiao', 'maricon', 'hitler', 'nigger', 'nigga', 'porno', 'xxx'];
const BLOCKED_WORDS = [
  'puta', 'puto', 'putas', 'mierda', 'pico', 'chucha', 'ctm', 'verga', 'pene', 'nazi', 'sexo', 'idiota',
  'imbecil', 'estupido', 'estupida', 'fuck', 'shit', 'bitch', 'cunt', 'dick', 'ass',
];
const LEET: Record<string, string> = { '0': 'o', '1': 'i', '3': 'e', '4': 'a', '5': 's', '7': 't', '@': 'a', $: 's' };

export function isOffensive(text: string): boolean {
  const flat = normalize(text).replace(/[013457@$]/g, (c) => LEET[c] ?? c);
  const joined = flat.replace(/[^a-z]/g, '');
  if (BLOCKED_ANYWHERE.some((w) => joined.includes(w))) return true;
  const words = flat.split(/[^a-z]+/);
  return words.some((w) => BLOCKED_WORDS.includes(w));
}

const NAME_RE = /^[\p{L}\p{N} ._'-]+$/u;

function checkName(value: string, noun: 'nombre' | 'apodo'): string | undefined {
  const v = cleanName(value);
  if (v.length < 2) return `El ${noun} debe tener al menos 2 caracteres.`;
  if (v.length > 20) return `El ${noun} puede tener como máximo 20 caracteres.`;
  if (!NAME_RE.test(v)) return `El ${noun} solo puede tener letras, números, espacios y . _ ' -`;
  if (isOffensive(v)) return `Ese ${noun} no está permitido. Prueba con otro.`;
  return undefined;
}

/** RF-05: rechaza datos inválidos o fuera del catálogo. */
export function validate(input: NewFish): FieldErrors {
  const errors: FieldErrors = {};
  const name = checkName(input.name, 'nombre');
  if (name) errors.name = name;
  const creator = checkName(input.creatorName, 'apodo');
  if (creator) errors.creatorName = creator;
  if (!inCatalog(SPECIES, input.species)) errors.species = 'Elige una especie.';
  if (!inCatalog(COLORS, input.color)) errors.color = 'Elige un color.';
  if (!inCatalog(COLORS, input.finColor)) errors.finColor = 'Elige un color de aletas.';
  if (!inCatalog(EYES, input.eyeStyle)) errors.eyeStyle = 'Elige unos ojos.';
  if (!inCatalog(ACCESSORIES, input.accessory)) errors.accessory = 'Elige un accesorio.';
  if (!inCatalog(PERSONALITIES, input.personality)) errors.personality = 'Elige una personalidad.';
  if (!inCatalog(MESSAGES, input.messageId)) errors.messageId = 'Elige un mensaje.';
  return errors;
}

function read(): Saved {
  try {
    const raw = localStorage.getItem(KEY);
    const data = raw ? (JSON.parse(raw) as Saved) : null;
    return data && Array.isArray(data.fishes) ? data : { fishes: [] };
  } catch {
    return { fishes: [] };
  }
}

function newCode(taken: Set<string>): string {
  for (;;) {
    const bytes = crypto.getRandomValues(new Uint8Array(6));
    const code = [...bytes].map((b) => CODE_CHARS[b % CODE_CHARS.length]).join('');
    if (!taken.has(code)) return code;
  }
}

export const localFishService: FishService = {
  list() {
    return [...DEMO_FISH, ...read().fishes].filter((f) => f.status === 'approved');
  },
  get(id) {
    const code = id.trim().toUpperCase();
    return this.list().find((f) => f.id === code);
  },
  mine() {
    const saved = read();
    return saved.mine ? saved.fishes.find((f) => f.id === saved.mine) : undefined;
  },
  publish(input) {
    const errors = validate(input);
    if (Object.keys(errors).length) return { ok: false, message: 'Revisa los datos marcados.', errors };

    const saved = read();
    if (saved.mine && saved.fishes.some((f) => f.id === saved.mine)) {
      return { ok: false, message: 'Desde este navegador ya liberaste un pez.' };
    }
    const fish: Fish = {
      id: newCode(new Set([...DEMO_FISH, ...saved.fishes].map((f) => f.id))),
      species: input.species,
      color: input.color,
      finColor: input.finColor,
      eyeStyle: input.eyeStyle,
      accessory: input.accessory,
      name: cleanName(input.name),
      creatorName: cleanName(input.creatorName),
      personality: input.personality,
      messageId: input.messageId,
      zoneId: 'reef',
      status: 'approved',
      createdAt: new Date().toISOString(),
    };
    try {
      localStorage.setItem(KEY, JSON.stringify({ fishes: [...saved.fishes, fish], mine: fish.id }));
    } catch {
      return { ok: false, message: 'No pudimos guardar tu pez en este navegador. Revisa que no esté en modo privado e inténtalo otra vez.' };
    }
    return { ok: true, fish };
  },
  subscribe(cb) {
    const onStorage = (e: StorageEvent) => {
      if (e.key === KEY) cb();
    };
    addEventListener('storage', onStorage);
    return () => removeEventListener('storage', onStorage);
  },
};

export function search(fishes: Fish[], query: string): Fish[] {
  const q = normalize(query);
  if (!q) return fishes;
  const code = q.toUpperCase().replace(/[^A-Z0-9]/g, '');
  const exact = fishes.filter((f) => f.id === code);
  const rest = fishes.filter((f) => f.id !== code && (normalize(f.name).includes(q) || normalize(f.creatorName).includes(q)));
  return [...exact, ...rest];
}
