// Los tres puzzles. El estado vive en cada closure, así se conserva al cambiar de pared.
import { h, type Game, type GameApi, type Scene } from './engine';
import { closableCard, doorWall, paper, pinpad } from './scenes';

function codigoSecreto(): Game {
  const animals: Record<string, { emoji: string; name: string }> = {
    hormiga: { emoji: '🐜', name: 'Hormiga' },
    raton: { emoji: '🐭', name: 'Ratón' },
    elefante: { emoji: '🐘', name: 'Elefante' },
    ballena: { emoji: '🐋', name: 'Ballena' },
  };
  const correct = ['hormiga', 'raton', 'elefante', 'ballena'].join();
  const order = ['hormiga', 'ballena', 'elefante', 'raton'];

  function checkOrder(g: GameApi) {
    if (order.join() !== correct) return;
    void g.alert(
      '¡Correcto!',
      '¡Excelente! Has ordenado los animales correctamente de menor a mayor tamaño.\n\nLa contraseña es: 0368',
    );
  }

  /** Lista horizontal que se reordena arrastrando o con las flechas del teclado. */
  function sortable(g: GameApi): HTMLElement {
    const list = h('div.g-sort', { role: 'group', 'aria-label': 'Animales para ordenar' });

    const commit = () => {
      const next = [...list.children].map((el) => (el as HTMLElement).dataset.id!);
      if (next.join() === order.join()) return;
      order.splice(0, order.length, ...next);
      checkOrder(g);
    };
    const centerX = (el: Element) => {
      const r = el.getBoundingClientRect();
      return r.left + r.width / 2;
    };
    // Se mueven los vecinos y no el elemento arrastrado: sacarlo del DOM soltaría el puntero.
    const moveAfter = (item: Element) => {
      if (item.nextElementSibling) list.insertBefore(item.nextElementSibling, item);
    };
    const moveBefore = (item: Element) => {
      if (item.previousElementSibling) list.insertBefore(item.previousElementSibling, item.nextSibling);
    };

    for (const id of order) {
      const item = h(
        'button.g-sort-item',
        {
          'data-id': id,
          'aria-label': animals[id].name,
          onpointerdown: (e: PointerEvent) => {
            item.setPointerCapture(e.pointerId);
            item.classList.add('is-drag');
          },
          onpointermove: (e: PointerEvent) => {
            if (!item.hasPointerCapture(e.pointerId)) return;
            // En bucle: un arrastre rápido puede cruzar varias casillas en un solo evento.
            while (item.nextElementSibling && e.clientX > centerX(item.nextElementSibling)) moveAfter(item);
            while (item.previousElementSibling && e.clientX < centerX(item.previousElementSibling)) moveBefore(item);
          },
          onlostpointercapture: () => {
            item.classList.remove('is-drag');
            commit();
          },
          onkeydown: (e: KeyboardEvent) => {
            if (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight') return;
            e.preventDefault();
            if (e.key === 'ArrowRight') moveAfter(item);
            else moveBefore(item);
            commit();
          },
        },
        animals[id].emoji,
      );
      item.dataset.id = id;
      list.append(item);
    }
    return list;
  }

  return {
    title: 'Puzzle 1',
    subtitle: '"Niveles de azúcar"',
    start: 'front',
    intro: (g) =>
      void g.alert('Escapa de la Mansión', 'Encuentra el código para poder salir.', { ok: 'Empezar', dismiss: 'none' }),
    scenes: {
      front: (g) => ({
        node: doorWall(() => void g.go('pinpad', 'up')),
        left: 'left',
        right: 'right',
        labelled: true,
        help: () => void g.alert('Pista', '¿Encontraste: "📄"?', { ok: 'OK' }),
      }),
      left: (g) => ({
        right: 'front',
        node: h(
          'div.g-wall.g-wall-end',
          {},
          h(
            'button.g-item',
            {
              'aria-label': 'Recoger el papel',
              onclick: () =>
                void g.sheet((close) =>
                  paper(
                    h('h2', {}, '¿Código de acceso?'),
                    h('p.g-paper-clue', {}, 'Ordena del más pequeño al más grande'),
                    h('button.g-link.g-link-dark', { onclick: close }, 'Volver'),
                  ),
                ),
            },
            '📄',
          ),
        ),
      }),
      right: (g) => ({
        left: 'front',
        node: h(
          'div.g-wall',
          {},
          h(
            'div.g-sort-box',
            {},
            h('p', {}, 'Puedes deslizar los elementos'),
            sortable(g),
            h('button.g-link', { onclick: () => void g.go('front', 'left') }, 'Volver'),
          ),
        ),
      }),
      pinpad: (g) => pinpad(g, '0368', 'front'),
    },
  };
}

function buscandoNumeros(): Game {
  const posters = [
    { emoji: '📣', title: 'Volante', content: '¡Gran evento este fin de semana!\nNo te lo pierdas.' },
    { emoji: '💡', title: 'Nota Curiosa', content: 'El número 1 es clave...\npero cuidado con el orden.\n\n□-1-□-□' },
    { emoji: '⚠️', title: 'Aviso', content: 'Piso resbaladizo.\nTenga precaución.\n\n5 -□-□-□' },
    { emoji: 'ℹ️', title: 'Información', content: 'Horario de atención:\nLunes a Viernes 9:00 - 18:00' },
  ];
  const drawers = 5 * 6;
  const opened = new Set<number>();
  const hintDrawer = Math.floor(Math.random() * drawers);
  let boardRevealed = false;

  const intro = (g: GameApi) =>
    void g.alert('Desafío 2', 'Este es tu segundo desafío. Intenta escapar, no hay más información.', { ok: 'OK' });

  function showPoster(g: GameApi, poster: (typeof posters)[number]) {
    void g.sheet(
      () =>
        h(
          'div.g-box.g-poster-open',
          {},
          h('div.g-poster-emoji', {}, poster.emoji),
          h('h2', {}, poster.title),
          h('p', {}, poster.content),
          h('small', {}, '(Toca para cerrar)'),
        ),
      { dismiss: 'anywhere' },
    );
  }

  function showHint(g: GameApi) {
    void g.sheet(
      () =>
        paper(
          h('div.g-poster-emoji', {}, '📄'),
          h('h2', {}, 'PISTA ENCONTRADA'),
          h('p.g-paper-code', {}, '□-□-3-□'),
          h('small', {}, '(Toca para cerrar)'),
        ),
      { dismiss: 'anywhere' },
    );
  }

  function drawer(g: GameApi, index: number): HTMLElement {
    const paint = () => {
      const open = opened.has(index);
      el.classList.toggle('is-open', open);
      el.textContent = open && index === hintDrawer ? '📄' : '';
      el.setAttribute('aria-label', open ? 'Cajón abierto' : 'Abrir cajón');
    };
    const el = h('button.g-drawer', {
      onclick: () => {
        opened.add(index);
        paint();
        if (index === hintDrawer) showHint(g);
      },
    });
    paint();
    return el;
  }

  function board(): HTMLElement {
    const clue = () =>
      h('div.g-board-clue', {}, h('h2', {}, 'CLAVE SECRETA'), h('p', {}, '□-□-□-8'));
    const el = h(
      'button.g-board',
      {
        'aria-label': 'Mirar la pizarra',
        onclick: () => {
          if (boardRevealed) return;
          boardRevealed = true;
          el.replaceChildren(clue());
        },
      },
      boardRevealed ? clue() : h('span.g-board-hint', {}, '?'),
    );
    return el;
  }

  return {
    title: 'Puzzle 2',
    subtitle: '"Buscando los números"',
    start: 'front',
    intro,
    scenes: {
      front: (g) => ({
        node: doorWall(() => void g.go('pinpad', 'up')),
        left: 'left',
        right: 'right',
        labelled: true,
        help: () => intro(g),
      }),
      left: (g) => ({
        left: 'back',
        right: 'front',
        node: h(
          'div.g-wall',
          {},
          h('h2.g-wall-title', {}, '🔍 Puedes ver información en los carteles'),
          h(
            'div.g-posters',
            {},
            ...posters.map((p) =>
              h(
                'button.g-poster',
                { onclick: () => showPoster(g, p) },
                h('span.g-poster-emoji', {}, p.emoji),
                h('strong', {}, p.title),
              ),
            ),
          ),
        ),
      }),
      right: (g) => ({
        left: 'front',
        right: 'back',
        node: h(
          'div.g-wall',
          {},
          h('h2.g-wall-title', {}, 'Busca entre los cajones'),
          h('div.g-drawers', {}, ...Array.from({ length: drawers }, (_, i) => drawer(g, i))),
        ),
      }),
      back: (): Scene => ({
        left: 'right',
        right: 'left',
        node: h('div.g-wall', {}, board()),
      }),
      pinpad: (g) => pinpad(g, '5138', 'front'),
    },
  };
}

function patronesColores(): Game {
  const cycle = [
    { name: 'Negro', css: '#000000' },
    { name: 'Verde', css: '#4caf50' },
    { name: 'Rojo', css: '#f44336' },
    { name: 'Ámbar', css: '#ffc107' },
    { name: 'Azul', css: '#2196f3' },
  ];
  // Índices de `cycle` que replican el patrón de emojis de la pared trasera.
  const solution = [1, 2, 4, 3, 4, 2, 1, 3, 1];
  const pattern = ['🥝', '🍎', '🧊', '🍋', '📘', '🚗', '🧩', '🌻', '🪴'];
  const cells = Array<number>(9).fill(0);

  const help = (g: GameApi) => void g.alert('Pista', 'Fíjate bien de los colores.', { ok: 'OK' });

  function cell(g: GameApi, index: number): HTMLElement {
    const paint = () => {
      const color = cycle[cells[index]];
      el.style.setProperty('--c', color.css);
      el.setAttribute('aria-label', `Casilla ${index + 1}: ${color.name}`);
    };
    const el = h('button.g-color', {
      onclick: async () => {
        cells[index] = (cells[index] + 1) % cycle.length;
        paint();
        if (cells.join() !== solution.join()) return;
        await g.alert('¡Correcto!', 'Has ordenado los colores correctamente.', { dismiss: 'none' });
        g.exit();
      },
    });
    paint();
    return el;
  }

  return {
    title: 'Puzzle 3',
    subtitle: '"Patrones y colores"',
    start: 'front',
    scenes: {
      front: (g) => ({
        node: doorWall(() => void g.go('colors', 'up'), 'PINPAD'),
        left: 'back',
        right: 'back',
        labelled: true,
        help: () => help(g),
      }),
      back: (g) => ({
        left: 'front',
        right: 'front',
        help: () => help(g),
        node: h(
          'div.g-wall.g-wall-wood',
          {},
          h('div.g-pattern', {}, ...pattern.map((emoji) => h('span', {}, emoji))),
        ),
      }),
      colors: (g) => ({
        node: closableCard(
          g,
          'front',
          h(
            'div.g-pin',
            {},
            h('p.g-pin-title', {}, 'Cambia los colores para que sean como el patrón'),
            h('div.g-colors', {}, ...cells.map((_, i) => cell(g, i))),
          ),
        ),
      }),
    },
  };
}

export const puzzles: Record<string, () => Game> = {
  'codigo-secreto': codigoSecreto,
  'buscando-numeros': buscandoNumeros,
  'patrones-colores': patronesColores,
};
