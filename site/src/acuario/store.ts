// Datos de Mi Acuario. En Firestore (colección `fishes`) solo se guardan los datos de
// cada pez; el dibujo y el movimiento se generan en el navegador de cada visitante.
// firestore.rules repite la validación de este archivo: deben cambiar juntos.
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
import { firestore } from '../scripts/firebase';

export interface NewFish extends FishDesign {
  name: string;
  creatorName: string;
  personality: PersonalityId;
  messageId: MessageId;
}

export type FieldErrors = Partial<Record<keyof NewFish, string>>;

export type PublishResult = { ok: true; fish: Fish } | { ok: false; message: string; errors?: FieldErrors };

const COLLECTION = 'fishes';
/** Peces más recientes que se descargan al entrar (también es el tope de firestore.rules). */
export const PAGE_SIZE = 150;
const KEY = 'acuario:v2';
const LEGACY_KEY = 'acuario:v1';
// Sin I, L, O, 0 ni 1 para que el código no se confunda al dictarlo.
const CODE_CHARS = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
const CODE_RE = /^[A-HJKMNP-Z2-9]{6}$/;

/** Minúsculas, sin tildes y con espacios simples (búsqueda y moderación). */
export function normalize(text: string): string {
  return text.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase().replace(/\s+/g, ' ').trim();
}

export function cleanName(text: string): string {
  return text.replace(/\s+/g, ' ').trim();
}

export function toCode(text: string): string {
  return text.toUpperCase().replace(/[^A-Z0-9]/g, '');
}

// Moderación básica. BLOCKED_ANYWHERE también está en firestore.rules.
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
  return flat.split(/[^a-z]+/).some((w) => BLOCKED_WORDS.includes(w));
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

/**
 * Convierte datos externos (Firestore o localStorage) en un pez, o null si no son válidos.
 * Nada de lo que llega se dibuja sin pasar por aquí: un valor fuera del catálogo o un
 * nombre no permitido simplemente no aparece.
 */
function toFish(id: string, d: Record<string, unknown>, createdAt: string): Fish | null {
  const input = d as unknown as NewFish;
  if (typeof d.name !== 'string' || typeof d.creatorName !== 'string') return null;
  if (d.status !== 'approved' || Object.keys(validate(input)).length) return null;
  return {
    id,
    name: cleanName(d.name),
    creatorName: cleanName(d.creatorName),
    species: input.species,
    color: input.color,
    finColor: input.finColor,
    eyeStyle: input.eyeStyle,
    accessory: input.accessory,
    personality: input.personality,
    messageId: input.messageId,
    zoneId: 'reef',
    status: 'approved',
    createdAt,
  };
}

function readMine(): Fish | undefined {
  try {
    const d = JSON.parse(localStorage.getItem(KEY) ?? 'null') as Record<string, unknown> | null;
    if (!d || typeof d.id !== 'string' || typeof d.createdAt !== 'string') return undefined;
    return toFish(d.id, d, d.createdAt) ?? undefined;
  } catch {
    return undefined;
  }
}

function newCode(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(6));
  return [...bytes].map((b) => CODE_CHARS[b % CODE_CHARS.length]).join('');
}

const isDenied = (err: unknown) => (err as { code?: string }).code === 'permission-denied';

type Snap = { id: string; data(): Record<string, unknown> | undefined };

function fromDoc(snap: Snap): Fish | null {
  const d = snap.data();
  if (!d) return null;
  const ts = d.createdAt as { toDate?: () => Date } | undefined;
  const date = typeof ts?.toDate === 'function' ? ts.toDate() : new Date();
  return toFish(snap.id, d, date.toISOString());
}

async function approved(...extra: ((fs: Awaited<ReturnType<typeof firestore>>['fs']) => unknown)[]): Promise<Fish[]> {
  const { db, fs } = await firestore();
  const constraints = [fs.where('status', '==', 'approved'), ...extra.map((f) => f(fs)), fs.orderBy('createdAt', 'desc')];
  const snap = await fs.getDocs(fs.query(fs.collection(db, COLLECTION), ...(constraints as Parameters<typeof fs.query>[1][])));
  return snap.docs.map(fromDoc).filter((f): f is Fish => f !== null);
}

/** Sube el pez con un código nuevo. El servidor fija la fecha y las reglas validan todo otra vez. */
async function upload(input: NewFish): Promise<Fish> {
  const { db, fs } = await firestore();
  const data = {
    species: input.species,
    color: input.color,
    finColor: input.finColor,
    eyeStyle: input.eyeStyle,
    accessory: input.accessory,
    name: cleanName(input.name),
    creatorName: cleanName(input.creatorName),
    personality: input.personality,
    messageId: input.messageId,
    zoneId: 'reef' as const,
    status: 'approved' as const,
  };
  // Si el código ya existe, las reglas rechazan la escritura (sería una edición): se reintenta con otro.
  for (let attempt = 0; ; attempt++) {
    const id = newCode();
    try {
      await fs.setDoc(fs.doc(db, COLLECTION, id), { ...data, createdAt: fs.serverTimestamp() });
      return { id, ...data, createdAt: new Date().toISOString() };
    } catch (err) {
      if (!isDenied(err) || attempt >= 1) throw err;
    }
  }
}

function saveMine(fish: Fish) {
  try {
    localStorage.setItem(KEY, JSON.stringify(fish));
    localStorage.removeItem(LEGACY_KEY);
  } catch {
    // Sin almacenamiento (modo privado): el pez queda publicado igual, solo no se recuerda como propio.
  }
}

export const fishService = {
  /** Pez creado desde este navegador (RF-13). */
  mine: readMine,

  /** Peces disponibles sin conexión: los de muestra y el propio. */
  local(): Fish[] {
    const mine = readMine();
    return mine ? [...DEMO_FISH, mine] : [...DEMO_FISH];
  },

  /** Los peces más recientes de todos los visitantes. */
  load: () => approved((fs) => fs.limit(PAGE_SIZE)),

  /** Peces publicados después de `since` (ISO), para sincronizar sin recargar (RF-07). */
  newer: (since: string) =>
    approved(
      (fs) => fs.where('createdAt', '>', fs.Timestamp.fromDate(new Date(since))),
      (fs) => fs.limit(50),
    ),

  /** Busca un pez por código aunque no esté entre los más recientes. */
  async get(code: string): Promise<Fish | undefined> {
    const id = toCode(code);
    const known = this.local().find((f) => f.id === id);
    if (known || !CODE_RE.test(id)) return known;
    const { db, fs } = await firestore();
    try {
      const snap = await fs.getDoc(fs.doc(db, COLLECTION, id));
      return (snap.exists() && fromDoc(snap)) || undefined;
    } catch (err) {
      if (isDenied(err)) return undefined; // no existe o fue ocultado
      throw err;
    }
  },

  async publish(input: NewFish): Promise<PublishResult> {
    const errors = validate(input);
    if (Object.keys(errors).length) return { ok: false, message: 'Revisa los datos marcados.', errors };
    if (readMine()) return { ok: false, message: 'Desde este navegador ya liberaste un pez.' };
    try {
      const fish = await upload(input);
      saveMine(fish);
      return { ok: true, fish };
    } catch (err) {
      return {
        ok: false,
        message: isDenied(err)
          ? 'El acuario no aceptó este pez. Prueba con otro nombre o apodo.'
          : 'No pudimos conectar con el acuario. Revisa tu conexión e inténtalo otra vez.',
      };
    }
  },

  /**
   * Los peces creados cuando el acuario aún guardaba solo en el navegador (acuario:v1)
   * se suben una vez para que los vean los demás.
   */
  async migrateLegacy(): Promise<Fish | undefined> {
    if (readMine()) return undefined;
    try {
      const old = JSON.parse(localStorage.getItem(LEGACY_KEY) ?? 'null') as { fishes?: Record<string, unknown>[]; mine?: string } | null;
      const d = old?.fishes?.find((f) => f.id === old.mine);
      if (!d || !toFish('legacy', d, '')) return undefined;
      const fish = await upload(d as unknown as NewFish);
      saveMine(fish);
      return fish;
    } catch {
      return undefined; // se reintenta en la próxima visita
    }
  },
};

/** Une listas de peces sin repetir códigos (gana la primera aparición). */
export function merge(...lists: Fish[][]): Fish[] {
  const byId = new Map<string, Fish>();
  for (const f of lists.flat()) if (!byId.has(f.id)) byId.set(f.id, f);
  return [...byId.values()];
}

export function search(fishes: Fish[], query: string): Fish[] {
  const q = normalize(query);
  if (!q) return fishes;
  const code = toCode(query);
  const exact = fishes.filter((f) => f.id === code);
  const rest = fishes.filter((f) => f.id !== code && (normalize(f.name).includes(q) || normalize(f.creatorName).includes(q)));
  return [...exact, ...rest];
}
