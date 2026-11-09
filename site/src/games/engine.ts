// Motor mínimo de los puzzles: escenas DOM, transiciones, diálogos y barra superior.

type Child = Node | string | null | false | undefined;

export function h(tag: string, props: Record<string, unknown> = {}, ...children: Child[]): HTMLElement {
  const [name, ...classes] = tag.split('.');
  const el = document.createElement(name || 'div');
  if (classes.length) el.className = classes.join(' ');
  if (name === 'button') el.setAttribute('type', 'button');
  for (const [key, value] of Object.entries(props)) {
    if (key.startsWith('on')) el.addEventListener(key.slice(2), value as EventListener);
    else el.setAttribute(key, String(value));
  }
  el.append(...children.filter((c): c is Node | string => !!c));
  return el;
}

/** SVG propios del juego (cadenas constantes, nunca contenido externo). */
export function svg(path: string, size = 24): HTMLElement {
  const box = h('span.g-icon');
  box.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${path}</svg>`;
  return box;
}

export const icons = {
  left: '<path d="m15 18-6-6 6-6"/>',
  right: '<path d="m9 18 6-6-6-6"/>',
  help: '<circle cx="12" cy="12" r="10"/><path d="M9.1 9a3 3 0 0 1 5.8 1c0 2-3 3-3 3"/><path d="M12 17h.01"/>',
  home: '<path d="m3 10 9-7 9 7v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><path d="M9 22V12h6v10"/>',
  expand: '<path d="M8 3H5a2 2 0 0 0-2 2v3M21 8V5a2 2 0 0 0-2-2h-3M3 16v3a2 2 0 0 0 2 2h3M16 21h3a2 2 0 0 0 2-2v-3"/>',
  shrink: '<path d="M8 3v3a2 2 0 0 1-2 2H3M21 8h-3a2 2 0 0 1-2-2V3M3 16h3a2 2 0 0 1 2 2v3M16 21v-3a2 2 0 0 1 2-2h3"/>',
  grid: '<rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M3 15h18M9 3v18M15 3v18"/>',
};

export type Dir = 'left' | 'right' | 'up' | 'fade';

export interface Scene {
  node: HTMLElement;
  /** Nombre de la escena a la que lleva cada flecha. */
  left?: string;
  right?: string;
  /** Muestra el texto junto a las flechas. */
  labelled?: boolean;
  help?: () => void;
}

/** none: solo con sus botones · backdrop: también al tocar fuera · anywhere: al tocar en cualquier parte. */
export type Dismiss = 'none' | 'backdrop' | 'anywhere';

export interface GameApi {
  go(to: string, dir?: Dir): Promise<void>;
  alert(title: string, text: string, opts?: { ok?: string; dismiss?: Dismiss }): Promise<void>;
  sheet(build: (close: () => void) => Node, opts?: { dismiss?: Dismiss; className?: string }): Promise<void>;
  /** Vuelve al menú de juegos. */
  exit(): void;
}

export interface Game {
  title: string;
  subtitle: string;
  start: string;
  scenes: Record<string, (g: GameApi) => Scene>;
  intro?: (g: GameApi) => void;
}

const frames: Record<Dir, Keyframe[] | PropertyIndexedKeyframes> = {
  left: { transform: ['translateX(-100%)', 'none'] },
  right: { transform: ['translateX(100%)', 'none'] },
  up: { transform: ['translateY(100%)', 'none'] },
  fade: { opacity: [0, 1] },
};

const MENU_URL = '/juegos/';

export function startGame(root: HTMLElement, game: Game): void {
  const layer = h('div.g-layer');
  const helpBtn = hudButton(icons.help, 'Pista');
  const homeBtn = hudButton(icons.home, 'Salir al menú de juegos');
  const hud = h('div.g-hud', {}, helpBtn, homeBtn);
  const stage = h('div.g-stage', {}, layer, hud);

  let current: HTMLElement | null = null;
  let busy = false;
  let onTitle = true;
  let help: (() => void) | undefined;

  const reduced = () => matchMedia('(prefers-reduced-motion: reduce)').matches;

  function dialog(build: (close: () => void) => Node, dismiss: Dismiss, className = ''): Promise<void> {
    return new Promise((resolve) => {
      const d = document.createElement('dialog');
      d.className = `g-dialog ${className}`;
      const close = () => d.close();
      d.append(build(close));
      d.addEventListener('cancel', (e) => {
        if (dismiss === 'none') e.preventDefault();
      });
      d.addEventListener('click', (e) => {
        if (dismiss === 'anywhere' || (dismiss === 'backdrop' && e.target === d)) close();
      });
      d.addEventListener('close', () => {
        d.remove();
        resolve();
      });
      stage.append(d);
      d.showModal();
    });
  }

  function textDialog(title: string, text: string, actions: Node[]): Node {
    return h('div.g-box', {}, h('h2', {}, title), h('p', {}, text), h('div.g-actions', {}, ...actions));
  }

  const api: GameApi = {
    go,
    alert: (title, text, { ok = 'Aceptar', dismiss = 'backdrop' } = {}) =>
      dialog((close) => textDialog(title, text, [h('button.g-text-btn', { onclick: close }, ok)]), dismiss),
    sheet: (build, { dismiss = 'backdrop', className = '' } = {}) => dialog(build, dismiss, className),
    exit: () => {
      location.href = MENU_URL;
    },
  };

  function render(scene: Scene, dir: Dir): Promise<void> {
    const wrap = h(
      'section.g-scene',
      {},
      scene.node,
      scene.left && arrow('left', scene.left, scene.labelled),
      scene.right && arrow('right', scene.right, scene.labelled),
    );
    layer.append(wrap);
    help = scene.help;
    helpBtn.hidden = !help;

    const old = current;
    current = wrap;
    if (!old || reduced()) {
      old?.remove();
      return Promise.resolve();
    }
    busy = true;
    return wrap
      .animate(frames[dir], { duration: 220, easing: 'cubic-bezier(0.2, 0.8, 0.2, 1)' })
      .finished.catch(() => undefined)
      .then(() => {
        old.remove();
        busy = false;
      });
  }

  function go(to: string, dir: Dir = 'fade'): Promise<void> {
    if (busy) return Promise.resolve();
    onTitle = false;
    return render(game.scenes[to](api), dir);
  }

  function arrow(side: 'left' | 'right', to: string, labelled?: boolean): HTMLElement {
    const label = side === 'left' ? 'Ir hacia la izquierda' : 'Ir hacia la derecha';
    return h(
      `button.g-arrow.g-arrow-${side}`,
      { 'aria-label': label, onclick: () => go(to, side) },
      svg(side === 'left' ? icons.left : icons.right, 36),
      labelled && h('span', {}, label),
    );
  }

  function hudButton(path: string, label: string): HTMLElement {
    return h('button.g-hud-btn', { 'aria-label': label, title: label }, svg(path));
  }

  helpBtn.addEventListener('click', () => help?.());

  homeBtn.addEventListener('click', () => {
    if (onTitle) return api.exit();
    let leave = false;
    void dialog(
      (close) =>
        textDialog('¿Salir al menú de juegos?', '¿Estás seguro de que quieres salir del desafío?', [
          h('button.g-text-btn', { onclick: close }, 'Cancelar'),
          h('button.g-text-btn', { onclick: () => ((leave = true), close()) }, 'Salir'),
        ]),
      'backdrop',
    ).then(() => leave && api.exit());
  });

  // iPhone no ofrece pantalla completa para elementos: ahí no se muestra el botón.
  if ('requestFullscreen' in stage) {
    const label = () => (document.fullscreenElement ? 'Salir de pantalla completa' : 'Pantalla completa');
    const btn = hudButton(icons.expand, label());
    btn.addEventListener('click', () => {
      if (document.fullscreenElement) void document.exitFullscreen();
      else stage.requestFullscreen().catch(() => undefined);
    });
    document.addEventListener('fullscreenchange', () => {
      btn.replaceChildren(svg(document.fullscreenElement ? icons.shrink : icons.expand));
      btn.setAttribute('aria-label', label());
      btn.title = label();
    });
    hud.append(btn);
  }

  const title = h(
    'div.g-title',
    {},
    h('div.g-light', { 'aria-hidden': 'true' }),
    h('h1', {}, game.title),
    h('p', {}, game.subtitle),
    h(
      'button.g-continue',
      {
        onclick: () => {
          void go(game.start).then(() => game.intro?.(api));
        },
      },
      'Continuar',
    ),
  );

  root.replaceChildren(stage);
  void render({ node: title }, 'fade');
}
