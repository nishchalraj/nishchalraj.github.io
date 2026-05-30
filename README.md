# niyam

> **niyam** *(Sanskrit: rule · routine · discipline)* — a quiet, animation-rich breathing companion that helps you build a daily breath habit. Lives on the web at **[niyam.yoga](https://niyam.yoga)** and as a Flutter app for Android + iOS.

niyam is the *opposite* of a productivity tool. No fire-emoji streaks, no guilt nudges, no surveillance. Just a calm space, seven guided techniques, a mood dial, six nature soundscapes, and a gentle dot on your calendar that records you showing up.

Everything works offline. Nothing leaves your device. There is no account.

---

## What's inside

A breathing-habit product across two surfaces with feature parity and a shared lavender + cream brand:

| | Web (niyam.yoga) | App (Android + iOS) |
|---|---|---|
| Stack | Next.js 15 · TypeScript · Tailwind · Framer Motion | Flutter 3.27 · Riverpod 2 · Hive CE · go_router |
| Storage | localStorage (Zustand persist) | Hive CE boxes |
| Deploy | Static export → `/docs` → GitHub Pages | Play Store / TestFlight (manual) |
| Audio | Howler.js (lazy, gesture-gated) | just_audio |

### The breathing engine
The heart of the product. A four-phase pulse animation (inhale → hold → exhale → hold) with phase color interpolation, a hold-phase pie sweep, and a phase-text countdown. Originally a single canvas in `/index.html` — re-implemented twice:

- **Web:** `requestAnimationFrame` loop, DPR-aware canvas, lavender-constrained HSL palette, reduced-motion fallback.
- **App:** pure-Dart `BreathingEngine` (no Flutter imports → fully unit-testable) driving a `CustomPainter` `BreathingOrb` via Riverpod streams.

Both implementations port the same math from the original `index.html` (donut via `destination-out`, hold pie sweep, smallTextScale/largeTextScale).

### Feature set (v1)
- **Onboarding** — name · goal (calm/sleep/focus/energy) · notification permission · daily reminder time.
- **Home** — greeting · 7-day calendar strip with streak dots · today's recommended session · mood quick-check.
- **Mood dial** — circular check-in (Calm / Neutral / Anxious / Sad / Energetic) with optional note.
- **Techniques** — Relax 4-7-8 · Box 4-4-4-4 · Calm (4-0-8) · Coherent 5-5 · Energize · Strengthen 6-2-6-2 · Wim Hof (light). Plus a **custom builder** with sliders.
- **Session player** — full-screen orb · phase text · per-phase ring countdown · pause / skip / end · soundscape · haptics (app) · auto-saves to history + streak.
- **Plans** — multi-day programs: Morning Calm · Breathe with the Clouds · Deep Recovery · Monthly Stress Reflection.
- **Soundscapes** — Forest · Ocean · Rain · Fire · Wind · Waves. Standalone player with 5 / 10 / 20 / ∞ timer, or layer under any session.
- **Insights** — 8-week activity heatmap · 30-day mood line · totals (streak, best, minutes).
- **Learn** — short articles on why the techniques work.
- **Profile** — name · reminder time · theme · voice cues · export data (JSON) · reset everything.

---

## Repo layout

```
niyam/
├── web/              Next.js 15 source (TypeScript)
├── app/              Flutter source (Android + iOS)
├── docs/             Generated static export — what GitHub Pages serves at niyam.yoga
├── design-tokens/    Shared tokens.json (palette, motion, spacing)
├── sample-design/    Reference screenshots
├── CNAME             niyam.yoga (legacy root copy; canonical lives in /web/CNAME)
└── index.html        Legacy single-file breathing exercise (reference; superseded by /docs)
```

### Web (`/web`)
Next.js App Router with two route groups: `(marketing)` for the public landing pages and `(app)` for the product. State is split across five Zustand stores (`prefs`, `sessions`, `streak`, `mood`, `plans`), each persisted to its own `localStorage` slice with versioned migrations. The breathing engine is canvas-rendered for 60 fps; everything else uses Framer Motion (page transitions, modal in/out, stagger lists) or pure CSS (hovers, tab indicator).

Build outputs to `../docs` so GitHub Pages can serve niyam.yoga from `/docs` on `main`. A postbuild script copies `CNAME` and `.nojekyll` into the export.

### App (`/app`)
Feature-first clean architecture (`features/<name>/{data,domain,presentation}`) with cross-cutting `core/` (theme, routing, storage, audio, notifications). State via Riverpod 2 `Notifier`/`AsyncNotifier`. Storage via Hive CE with hand-rolled `TypeAdapter`s — no `build_runner` in v1 to keep the dev loop tight. Navigation via go_router with an onboarding redirect guard. Theme is Material 3 + two custom `ThemeExtension`s (`BreathingTokens` for phase colors, `BreathingMotion` for animation durations).

The orb is a `CustomPainter` wrapped in a `RepaintBoundary`; its `shouldRepaint` returns true only on tick changes. `flutter_displaymode` opts into 120 Hz on Android. Audio is best-effort — missing assets are caught and the UI keeps going.

### Shared tokens (`/design-tokens`)
`tokens.json` is the source of truth for colors (lavender + cream), motion durations, radius scale, typography scale. Tailwind reads it directly; Flutter's `BreathingTokens` mirrors the same values. Change a hex once, both surfaces update.

---

## Running locally

### Web
```bash
cd web
npm install
npm run dev          # http://localhost:3000
npm run build        # → ../docs/
npm run typecheck    # tsc --noEmit
```

### App
```bash
cd app
flutter pub get
flutter run          # connected device or emulator
flutter test         # unit tests (breathing engine)
flutter analyze
flutter build apk --debug
```

---

## Deploying the web

GitHub Pages serves `niyam.yoga` from the `/docs` directory on `main`. The build pipeline:

1. `npm run build` in `/web` exports static HTML to `/docs`.
2. Postbuild script writes `/docs/CNAME` (= `niyam.yoga`) and `/docs/.nojekyll`.
3. Commit `/docs`; push. Pages picks it up.

The repo-root `index.html` is the legacy single-file breathing exercise. It's kept as a reference but is no longer the published page — `/docs/index.html` is the new landing.

---

## Brand

| Token | Light | Dark |
|---|---|---|
| Primary | `#A78BFA` (lavender 400) | `#A78BFA` |
| Primary soft | `#C4B5FD` | `#8B69D7` |
| Surface | `#FAF7F2` (cream) | `#0F0E1F` |
| Ink | `#1E1B4B` | `#E9E7FF` |

Typography: **Fraunces** display · **Inter** sans · tabular numerals for counts.
Motion: 150 ms fast · 250 ms base · 450 ms slow · 350 ms page transitions · easing `cubic-bezier(0.16, 1, 0.3, 1)`.

Animations honor `prefers-reduced-motion` (web) and `MediaQuery.disableAnimations` (app) — the orb falls back to a static circle with a live-region countdown.

---

## Non-negotiables

- **Offline-first.** No accounts. No network calls outside font/CDN.
- **No jank.** Canvas/CustomPainter for the orb; everything else `transform`/`opacity` only. `will-change` added on enter and removed on exit. Per-frame budget ≤ 16.6 ms (≤ 8.3 ms on 120 Hz).
- **No ANRs.** All Hive I/O via async APIs, audio init wrapped in `try/catch`, no synchronous JSON decoding on the UI isolate.
- **No crashes.** `runZonedGuarded` + `FlutterError.onError` in the app; static export means no server failure modes on the web.
- **Accessible.** Reduced-motion support, semantic countdown via `aria-live` / `Semantics(liveRegion: true)`, keyboard focus styles, dark mode.

---

## Project status

v0.1.0 — initial build complete:

- ✅ Web: 22 routes static-exported, bundles 152–160 kB first-load (under 200 kB target)
- ✅ App: Android debug APK builds clean, `flutter analyze` 0 errors, engine unit test passing
- ⏳ Soundscape `.mp3` assets: license-pending, drop into `/web/public/sounds/` and `/app/assets/sounds/`
- ⏳ iOS verification on a physical device
- ⏳ Lighthouse CI + Playwright e2e wiring

See `web/public/sounds/README.md` and `app/assets/sounds/README.md` for the expected audio file list.

---

## License

TBD. Source available for personal use.

— *one minute, one breath, today.*
