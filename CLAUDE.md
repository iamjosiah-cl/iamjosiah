# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal site "I Am Josiah" (iamjosiah.cl), a Flutter app whose main target is **Flutter Web**, hosted on Firebase Hosting (project `iamjosiah-2b6be`). UI text and most code comments are in Spanish.

The repo now holds **two apps**:
- `site/`: the new **Astro 5 + TypeScript** static site (landing `/`, `/portafolio/`, `/proyectos/`, `/proyectos/<slug>/`). It replaces the Flutter landing and portfolio.
- The Flutter app (`lib/`): still the only home of the games (`/juegos`) and the 80mm print tool (`/print`). It is **no longer deployed**: `firebase.json` now publishes the Astro build, so `/juegos` and `/print` 404 on the live site until the Flutter app is hosted somewhere else and `flutterAppUrl` points to it.

## Astro site (`site/`)

```bash
cd site
npm install
npm run dev       # http://localhost:4321
npm run build     # astro check (types) + static build into site/dist
npm run preview   # serve site/dist

# from the repo root:
firebase emulators:start --only hosting   # test firebase.json rules against site/dist
firebase deploy --only hosting            # deploy (run `npm run build` in site/ first; deploy does not build)
```

- `firebase.json` hosting serves `site/dist` statically with `trailingSlash: true` (Astro emits `page/index.html`), long-lived cache headers on `/_astro/**`, and the old apex→www redirect.
- `site/public/flutter_service_worker.js` is a kill-switch that replaces the old Flutter service worker: returning visitors' browsers clear the Flutter cache and unregister it. Keep it for a while after the switch.

- Astro is pinned to v5 because the local Node is 22.13; Astro 7 needs Node ≥ 22.23.4.
- All content (texts, links, CV data, projects) lives in `site/src/data/` (`site.ts`, `cv.ts`, `projects.ts`). Edit text there, not in components.
- `flutterAppUrl` in `site/src/data/site.ts` controls the links to the Flutter-only features (games, print). While it is `null`, those links are hidden.
- Styling: plain CSS with tokens in `site/src/styles/global.css` plus scoped `<style>` per component. No CSS framework. Icons are inline SVG in `site/src/components/Icon.astro`.
- Interactivity is small vanilla TS in component `<script>` tags (nav menu, skills tabs, experience tabs, contact form). Entrance animation is the `.reveal` class + an IntersectionObserver in `layouts/Base.astro`; keep it short.
- Gotchas: component CSS that sets `display` overrides the `hidden` attribute, which is why `global.css` forces `[hidden] { display: none !important }`. `:global(.class)` compounds on a scoped selector don't match reliably, so toggle state with data attributes (e.g. `.nav[data-open]`).
- The contact form writes `{name, email, message, createdAt}` to Firestore `contact_messages` (same shape as the Flutter version) via `site/src/scripts/contact.ts`. The Firebase SDK (`firestore/lite`) is dynamically imported only on submit. Testing the submit writes to the **production** Firestore.
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
  - `/print` → `ChecklistPage` (`lib/impresora/`): checklist + 80mm thermal-printer text editor (uses `pdf`/`printing`; see `EDITOR_80MM_README.md`).
  - `/juegos` → `GamesPage` (`lib/jugar/dashboard_juegos.dart`): mini-games / escape-room style puzzles (`puzzle1..3`, each split into `titulo`/`left`/`right`/`back`/`pinpad` screens navigated with `Navigator.push`/`pushReplacement`).
- Most in-app navigation uses `Navigator.push(MaterialPageRoute(...))` directly rather than named routes, so the URL doesn't always reflect the page.
- `MyPortfolio` wraps its own nested `MaterialApp`; `HomePage` is one `SingleChildScrollView` with a `GlobalKey` per section and `Scrollable.ensureVisible` for nav. Each section is a widget in `lib/portfolio_web/` (`inicio` hero, `sobremi`, `habilidades`, `experiencia`, `educacion`, `proyectos`, `contacto`, `footer`).
- Shared styling: `lib/styles/beacon_style.dart` (`BeaconStyle` palette: slate background, cyan→violet accent gradient; `BeaconStyle.theme()` dark Material 3 theme; `fastTransitions` page transitions; `AnimatedBackgroundOrbs`, which despite its name is now a **static** radial-gradient background). `BeaconHome` duplicates the same palette constants inline.
- The dark theme is applied **per page** (`MyPortfolio`, `BeaconHome`, `ProjectsPage`, `ProjectDetailPage` wrap themselves in `Theme(data: BeaconStyle.theme())`), not globally, so the games and print pages keep the default light theme they were built against.
- Shared UI pieces: `lib/widgets/ui.dart` (`AccentBar` under section titles, `GradientText`, `EyebrowChip`, `HoverCard`).
- Shared animations: `lib/widgets/animations.dart`. `FadeInAnimation` clamps duration (≤380 ms), offset and delay (`MotionConfig`: requested delays ×0.2, max 150 ms) and respects reduced-motion; `TypingText` no longer animates (renders text immediately). Keep entrance motion fast. Don't nest fades or reintroduce per-frame animated/blurred backgrounds; that was what made the site feel slow. `main.dart` sets the `VisibilityDetectorController` update interval to 50 ms (the 500 ms default delayed every scroll-triggered animation).
- `web/index.html` shows a loader that is removed on Flutter's `flutter-first-frame` event (8 s fallback).
- Firestore: the contact form writes to `contact_messages` (`contacto.dart`); the print checklist uses the `checklists` collection (`impresora.dart`).
- Assets are all under `assets/` (declared as a directory in `pubspec.yaml`), including the CV PDF and project preview images.
