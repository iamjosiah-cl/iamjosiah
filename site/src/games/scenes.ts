// Piezas compartidas entre puzzles: puerta con panel y teclado numérico.
import { h, icons, svg, type GameApi, type Scene } from './engine';

/** Pared frontal: puerta cerrada con el panel al centro. */
export function doorWall(onPanel: () => void, panelLabel?: string): HTMLElement {
  return h(
    'div.g-wall.g-wall-door',
    {},
    h('div.g-door', { 'aria-hidden': 'true' }, h('div.g-door-frame'), h('div.g-door-knob')),
    h(
      `button.g-panel${panelLabel ? '.g-panel-big' : ''}`,
      { 'aria-label': 'Usar el panel de la puerta', onclick: onPanel },
      !panelLabel && h('span.g-panel-screen'),
      svg(icons.grid, panelLabel ? 72 : 40),
      panelLabel && h('span.g-panel-label', {}, panelLabel),
    ),
  );
}

/** Teclado de 4 dígitos. Al acertar vuelve al menú de juegos. */
export function pinpad(g: GameApi, code: string, back: string): Scene {
  let digits = '';
  const screen = h('div.g-pin-screen', { role: 'status', 'aria-label': 'Números ingresados' });
  const set = (value: string) => {
    digits = value;
    screen.textContent = value;
  };

  async function press(key: string) {
    if (key === 'X') return set('');

    if (key === '✔') {
      if (digits.length !== 4) return g.alert('Combinación incompleta', 'Debes ingresar 4 números.');
      const ok = digits === code;
      set('');
      if (!ok) return g.alert('Error', 'Combinación incorrecta.');
      await g.alert('¡Superado!', 'Has ingresado la combinación correcta.', { dismiss: 'none' });
      return g.exit();
    }

    if (digits.length >= 4) {
      set('');
      return g.alert('Límite alcanzado', 'No se pueden agregar más que cuatro números.');
    }
    set(digits + key);
  }

  const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'X', '0', '✔'].map((key) =>
    h(
      `button.g-key${key === 'X' ? '.g-key-clear' : key === '✔' ? '.g-key-ok' : ''}`,
      {
        'aria-label': key === 'X' ? 'Borrar' : key === '✔' ? 'Confirmar' : key,
        onclick: () => void press(key),
      },
      key,
    ),
  );

  return {
    node: closableCard(g, back, h('div.g-pin', {}, screen, h('div.g-pin-keys', {}, ...keys))),
  };
}

/** Tarjeta sobre fondo oscuro que se cierra al tocar fuera o con «Volver». */
export function closableCard(g: GameApi, back: string, card: HTMLElement): HTMLElement {
  const leave = () => void g.go(back, 'fade');
  card.addEventListener('click', (e) => e.stopPropagation());
  card.append(h('button.g-link', { onclick: leave }, 'Volver'));
  return h('div.g-wall.g-wall-dim', { onclick: leave }, card);
}

export function paper(...children: (Node | string)[]): HTMLElement {
  return h('div.g-paper', {}, ...children);
}
