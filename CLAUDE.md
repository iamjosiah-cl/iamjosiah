# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal site "I Am Josiah" (iamjosiah.cl), hosted on Firebase Hosting (project `iamjosiah-2b6be`). UI text and most code comments are in Spanish.

The repo holds **two apps**:
- `site/`: the **Astro 5 + TypeScript** static site (landing `/`, `/portafolio/`, `/proyectos/`, `/proyectos/<slug>/`, `/juegos/`, `/juegos/<slug>/`, `/acuario/`, `/acuario/crear/`). This is what gets deployed.
- The original Flutter app (`lib/`): **no longer deployed** and superseded by `site/`. The print tool and the Presupuesto Diario project were removed from both apps.
- `promo/`: a small **Remotion** project that renders the Instagram-story promo video for Mi Acuario (`npm run render` → `promo/out/mi-acuario-historia.mp4`, 1080×1920; `npm run studio` to preview). It imports the sprites and scenery from `site/src/acuario/`, but fish movement there is a pure function of the frame number, because Remotion renders frames independently.

## Astro site (`site/`)

```bash
cd site
npm install
npm run dev       # http://localhost:4321
npm run build     # astro check (types) + static build into site/dist
npm run preview   # serve site/dist

# from the repo root:
firebase emulators:start --only hosting   # test firebase.json rules against site/dist
firebase deploy --only hosting            # deploy the site (run `npm run build` in site/ first; deploy does not build)
firebase deploy --only firestore          # deploy firestore.rules + firestore.indexes.json (replaces the live rules)
firebase emulators:start --only firestore # local Firestore on :8080 (needs Java); build the site with
                                          # PUBLIC_FIRESTORE_EMULATOR=127.0.0.1:8080 to point it there
```

- `firebase.json` hosting serves `site/dist` statically with `trailingSlash: true` (Astro emits `page/index.html`) and long-lived cache headers on `/_astro/**`. The apex→www redirect is configured in the Firebase console, not here (hosting redirects only match paths).
- `site/public/flutter_service_worker.js` is a kill-switch that replaces the old Flutter service worker: returning visitors' browsers clear the Flutter cache and unregister it. Keep it for a while after the switch.

- Astro is pinned to v5 because the local Node is 22.13; Astro 7 needs Node ≥ 22.23.4.
- All content (texts, links, CV data, projects) lives in `site/src/data/` (`site.ts`, `cv.ts`, `projects.ts`). Edit text there, not in components.
- Games: `src/games/engine.ts` is a small DOM engine (scenes, transitions, native `<dialog>`s, top bar), `scenes.ts` has the shared door and keypad, and `puzzles.ts` defines the three puzzles and keeps their state in closures so it survives changing walls. The list shown on `/juegos/` is `src/data/games.ts`; a new puzzle needs an entry there and the same slug in `puzzles`. Styles are global in `src/styles/games.css` because the DOM is created at runtime.
- Mi Acuario (`src/acuario/`, pages in `src/pages/acuario/`): community pixel-art aquarium built from a requirements doc. Firestore stores **only fish data** (collection `fishes`, doc id = 6-char public code); drawing and movement are generated in each visitor's browser. `store.ts` is the data layer: it loads the 150 newest approved fish, polls every 60 s for newer ones (the lite SDK has no listeners), fetches a single fish by code for links/search, and publishes with `setDoc` + `serverTimestamp`. There is no auth and no Cloud Functions (Spark plan): the browser writes directly and `firestore.rules` is the real validation, so the catalog lists, name rules and blocked words in `firestore.rules` must be changed together with `catalog.ts` / `store.ts`. "One fish per person" is only a `localStorage` flag (`acuario:v2`). Everything read from Firestore goes through `toFish()`, which drops documents that fail validation. Moderation: set a fish's `status` to `hidden` (or delete it) in the Firebase console. Fish sprites are generated in code from shapes + layers in `sprites.ts` (no image assets). `engine.ts` renders at a low logical resolution with an integer CSS scale. Fish links are `/acuario/?pez=CODE`. The Browser pane throttles `requestAnimationFrame` while hidden, so animation timing can't be checked there; step `update()` manually when debugging.
- Styling: plain CSS with tokens in `site/src/styles/global.css` plus scoped `<style>` per component. No CSS framework. Icons are inline SVG in `site/src/components/Icon.astro`.
- Interactivity is small vanilla TS in component `<script>` tags (nav menu, skills tabs, experience tabs, contact form). Entrance animation is the `.reveal` class + an IntersectionObserver in `layouts/Base.astro`; keep it short.
- Gotchas: component CSS that sets `display` overrides the `hidden` attribute, which is why `global.css` forces `[hidden] { display: none !important }`. `:global(.class)` compounds on a scoped selector don't match reliably, so toggle state with data attributes (e.g. `.nav[data-open]`).
- The contact form writes `{name, email, message, createdAt}` to Firestore `contact_messages` via `site/src/scripts/contact.ts`; `firestore.rules` enforces those four fields and their max lengths. `site/src/scripts/firebase.ts` lazy-loads the Firebase SDK (`firestore/lite`) for both the form and the aquarium. Testing the submit on a normal build writes to the **production** Firestore.
- Local images in `site/src/assets/` are optimized by `astro:assets` at build time. Downloadable files (CV PDF) go in `site/public/assets/`.

## Flutter app commands

```bash
flutter pub get
flutter run -d chrome            # local dev
flutter analyze                  # lints (flutter_lints)
flutter test                     # all tests
flutter test test/widget_test.dart --plain-name "<test name>"   # single test
flutter build web                # production build (into build/web)
```

Notes:
- The Flutter app used to be deployed through the Firebase web frameworks integration (`source: "."`); `.firebase/iamjosiah-2b6be/hosting/` is a leftover build artifact from that, don't edit by hand.
- `test/widget_test.dart` is the stale Flutter template (references a nonexistent `MyApp` and counter) and will fail; there is no real test suite.
- `.github/workflows/firebase-hosting-pull-request.yml` is a placeholder (`run: asd`) and is not a working CI pipeline.

## Flutter architecture

- `lib/main.dart` initializes Firebase (`firebase_options.dart`, FlutterFire-generated) and defines routes via `onGenerateRoute`:
  - `/` → `BeaconHome` (`lib/beacon.dart`): landing/link-hub page that leads to the rest.
  - `/portafolio` → `MyPortfolio` (`lib/portfolio_web/portafolio.dart`): the single-page CV/portfolio.
  - `/juegos` → `GamesPage` (`lib/jugar/dashboard_juegos.dart`): mini-games / escape-room style puzzles (`puzzle1..3`, each split into `titulo`/`left`/`right`/`back`/`pinpad` screens navigated with `Navigator.push`/`pushReplacement`).
- Most in-app navigation uses `Navigator.push(MaterialPageRoute(...))` directly rather than named routes, so the URL doesn't always reflect the page.
- `HomePage` (in `portafolio.dart`) is one `SingleChildScrollView` with a `GlobalKey` per section and `Scrollable.ensureVisible` for nav. Each section is a widget in `lib/portfolio_web/` (`inicio` hero, `sobremi`, `habilidades`, `experiencia`, `educacion`, `proyectos`, `contacto`, `footer`).
- Shared styling: `lib/styles/beacon_style.dart` (`BeaconStyle` palette: slate background, cyan→violet accent gradient; `BeaconStyle.theme()` dark Material 3 theme; `fastTransitions` page transitions; `AnimatedBackgroundOrbs`, which despite its name is now a **static** radial-gradient background). `BeaconHome` duplicates the same palette constants inline.
- The dark theme is applied **per page** (`MyPortfolio`, `BeaconHome`, `ProjectsPage`, `ProjectDetailPage` wrap themselves in `Theme(data: BeaconStyle.theme())`), not globally, so the games keep the default light theme they were built against.
- Shared UI pieces: `lib/widgets/ui.dart` (`AccentBar` under section titles, `GradientText`, `EyebrowChip`, `HoverCard`).
- Shared animations: `lib/widgets/animations.dart`. `FadeInAnimation` clamps duration (≤380 ms), offset and delay (`MotionConfig`: requested delays ×0.2, max 150 ms) and respects reduced-motion; `TypingText` no longer animates (renders text immediately). Keep entrance motion fast. Don't nest fades or reintroduce per-frame animated/blurred backgrounds; that was what made the site feel slow. `main.dart` sets the `VisibilityDetectorController` update interval to 50 ms (the 500 ms default delayed every scroll-triggered animation).
- `web/index.html` shows a loader that is removed on Flutter's `flutter-first-frame` event (8 s fallback).
- Firestore: the contact form writes to `contact_messages` (`contacto.dart`).
- Assets are all under `assets/` (declared as a directory in `pubspec.yaml`), including the CV PDF and project preview images.
