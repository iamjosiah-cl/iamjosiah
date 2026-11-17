import { firestore } from './firebase';

export interface ContactMessage {
  name: string;
  email: string;
  message: string;
}

/**
 * Guarda el mensaje en la colección `contact_messages` de Firestore, con los
 * mismos campos que usaba la versión Flutter (name, email, message, createdAt).
 * firestore.rules valida estos campos y sus largos: si cambian aquí, cambian allá.
 */
export async function sendContactMessage(msg: ContactMessage): Promise<void> {
  const { db, fs } = await firestore();
  await fs.addDoc(fs.collection(db, 'contact_messages'), {
    ...msg,
    createdAt: new Date().toISOString(),
  });
}
