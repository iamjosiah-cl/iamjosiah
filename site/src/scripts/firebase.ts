import { firebaseConfig } from '../data/site';

type Lite = typeof import('firebase/firestore/lite');

let ready: Promise<{ db: import('firebase/firestore/lite').Firestore; fs: Lite }> | undefined;

/**
 * Firestore (SDK "lite") cargado de forma diferida: el SDK solo se descarga en las
 * páginas que lo usan. Con PUBLIC_FIRESTORE_EMULATOR=host:puerto al compilar, apunta
 * al emulador local en vez de a producción.
 */
export function firestore() {
  ready ??= (async () => {
    const [{ initializeApp, getApps }, fs] = await Promise.all([
      import('firebase/app'),
      import('firebase/firestore/lite'),
    ]);
    const db = fs.getFirestore(getApps()[0] ?? initializeApp(firebaseConfig));
    const emulator: string | undefined = import.meta.env.PUBLIC_FIRESTORE_EMULATOR;
    if (emulator) {
      const [host, port] = emulator.split(':');
      fs.connectFirestoreEmulator(db, host, Number(port));
    }
    return { db, fs };
  })();
  return ready;
}
