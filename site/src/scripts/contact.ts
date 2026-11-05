import { firebaseConfig } from '../data/site';

export interface ContactMessage {
  name: string;
  email: string;
  message: string;
}

/**
 * Guarda el mensaje en la colección `contact_messages` de Firestore, con los
 * mismos campos que usaba la versión Flutter (name, email, message, createdAt).
 *
 * Firebase se importa de forma diferida: el SDK solo se descarga cuando alguien
 * envía el formulario, así no pesa en la carga inicial de la página.
 */
export async function sendContactMessage(msg: ContactMessage): Promise<void> {
  const [{ initializeApp, getApps }, { getFirestore, collection, addDoc }] = await Promise.all([
    import('firebase/app'),
    import('firebase/firestore/lite'),
  ]);
  const app = getApps()[0] ?? initializeApp(firebaseConfig);
  const db = getFirestore(app);
  await addDoc(collection(db, 'contact_messages'), {
    ...msg,
    createdAt: new Date().toISOString(),
  });
}
