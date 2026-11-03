# OFFLINE GAMES: Agent Brief

**Package name:** `offline_games` (decided by the human; unclaimed on pub.dev as of 2026-11-03).
**License:** MIT (decided).
**Audience:** the coding agent building this package. Read the whole file before writing code.
**Status of this file:** source of truth. If code and this file disagree, ask the human, then update this file.

---

## 0. One-paragraph summary

A pure-Flutter package that gives any app a tiny arcade for when the network drops. Drop it in once and, with **zero parameters**, the app shows a dismissible card when the device goes offline; the player taps **Spin** and a random mini game opens. Developers can instead choose a **game picker** or force a **single game**. Games are tiny, dependency-free, fully offline, and every game credits its **author** inside the UI. The project is also a small open platform: contributors add games through a documented, low-friction process and get visible credit.

**The win-win-win:**
- **App developers:** a polished "you're offline" experience in one line of code.
- **Contributors:** a friendly place to ship a small game, with their name shown to real users.
- **End users:** something fun instead of a dead error screen.

---

## 1. Constitution (non-negotiable rules)

Rules are numbered so they can be cited in reviews and PRs. Break one only with explicit human approval.

### 1.1 Package principles
- **C1. Plug and play.** `OfflineGames(child: child!)` with no other argument must work and give the full default experience.
- **C2. Lightweight.** Runtime dependencies are: the Flutter SDK and, at most, `internet_connection_checker_plus` (default reachability only). No Flame, no state-management packages (Riverpod, GetX, Provider, Bloc, hooks), no storage, audio or analytics packages. Anything else needs explicit human approval.
- **C3. Pure Dart and Flutter.** No platform channels, no native code, no permissions beyond what the app already has. Must run on every platform Flutter supports.
- **C4. Fully offline games.** No game may touch the network, ever. No telemetry, no ads, no tracking, no remote assets.
- **C5. No binary assets in v0.x.** Draw with `CustomPainter`, widgets, emoji and `IconData`. If assets become necessary, require human approval and a size budget.
- **C6. Never hijack the app.** The offline UI must be dismissible, shown at most once per offline episode, and suppressible via controller. It must never block a critical flow.
- **C7. Credit is mandatory.** Every game declares at least one author. CI fails if any game has none. Credit is visible in the UI (§6.5).
- **C8. Originality and legality.** Games use original names and art. No clones that use trademarked names or assets (e.g. Tetris, Flappy Bird, Pac-Man). Generic mechanics are fine; branding is not. Contributions are licensed under the package license.
- **C9. Accessible by default.** Semantics labels on interactive game elements, respect `MediaQuery.disableAnimations`, tap targets of at least 44 dp, and no colour-only signalling.
- **C10. Honest reachability.** "Offline" means *no real internet access*, not "no Wi-Fi interface". Use real reachability checks with debouncing.

### 1.2 Engineering principles
- **E1. Logic and UI are separate.** Every game's rules live in pure Dart (no `BuildContext`, no widgets) and are unit tested.
- **E2. Deterministic where random.** Anything random takes an injected `Random`, so tests can seed it.
- **E3. Small, reviewable steps.** One feature per PR/commit. No sweeping refactors mixed with features.
- **E4. Public API is a promise.** Everything exported from `lib/offline_games.dart` is public API. Keep it small. Internals live under `lib/src/` and are not exported.
- **E5. Docs ship with code.** Any public API change updates dartdoc, README and CHANGELOG in the same change.
- **E6. Don't invent.** If this file doesn't specify something material, ask the human. Don't silently choose.
- **E7. Tests before "done".** `flutter analyze`, `dart format`, and `flutter test` must pass before any step is reported complete.

### 1.3 Agent behaviour rules
- Never add a dependency without asking.
- Never delete or rewrite a user-authored file without asking.
- Report what you changed, what you tested, and what you did **not** do.
- If a requirement conflicts with another, stop and ask. Don't pick a side.

---

## 2. Experience spec (what users and developers see)

### 2.1 Developer: three ways to use it

```dart
// 1) ZERO CONFIG (the default): spin for a random game when offline
MaterialApp(
  builder: (context, child) => OfflineGames(child: child!),
  home: const HomePage(),
);

// 2) PICKER: player chooses from a grid of games
OfflineGames(mode: const GamesMode.picker(), child: child!);

// 3) SINGLE: always open one specific game
OfflineGames(mode: GamesMode.single(SnakeGame()), child: child!);
```

**Default (no params) = `GamesMode.spin()` + `OfflineTrigger.auto` + all built-in games.**

### 2.2 Standalone widgets (usable without the offline trigger, e.g. loading screens)

```dart
GameSpinner(games: ..., onResult: (game) {...})   // the spin UI
GamePicker(games: ..., onSelected: (game) {...})  // the grid UI
GamePlayer(game: SnakeGame())                     // play a game in a framed view
showOfflineGames(context, mode: ...);             // manual launch
```

### 2.3 Player flow (default)
1. Connection is truly lost for at least `offlineDelay` (default 3 s).
2. A card slides in: "You're offline. Feeling lucky?" with **Spin** and **Dismiss**.
3. Spin plays a short, tasteful wheel/slot animation and lands on a random game.
4. The game opens in a framed panel with: exit button, pause, best score, **"by <Author>"** chip.
5. If the connection returns: do **not** kick the player out. Show a small "You're back online" prompt: **Keep playing** or **Back to app**.
6. Dismissed once = not shown again until the next offline episode.

### 2.4 Spin behaviour
- Random pick, **never the same game twice in a row** (if more than one game exists).
- Skip animation if `MediaQuery.disableAnimations` is true (go straight to the result).
- Spin result shows game title, emoji and author before the game starts, with a **Spin again** option.
- Randomness is injectable (`Random`) for tests.

---

## 3. Public API (target shape)

Treat as a spec. Names may be refined with human approval, but the shape and defaults hold.

```dart
// lib/offline_games.dart (exports only)

/// Wraps your app. Zero params = default experience.
class OfflineGames extends StatefulWidget {
  const OfflineGames({
    super.key,
    required this.child,
    this.games,                                   // null => GameCatalog.builtIn
    this.mode = const GamesMode.spin(),           // DEFAULT
    this.trigger = OfflineTrigger.auto,           // DEFAULT
    this.offlineDelay = const Duration(seconds: 3),
    this.connectivity,                            // null => default checker
    this.scoreStore,                              // null => in-memory
    this.controller,
    this.theme,                                   // OfflineGamesTheme?
    this.random,                                  // Random? (tests)
  });
}

sealed class GamesMode {
  const GamesMode();
  const factory GamesMode.spin() = SpinMode;
  const factory GamesMode.picker() = PickerMode;
  factory GamesMode.single(OfflineGame game) = SingleMode;
}

enum OfflineTrigger {
  auto,     // card appears automatically when offline (DEFAULT)
  banner,   // small non-intrusive strip with "Play?"
  manual,   // never automatic; app calls controller.open()
}

class OfflineGamesController extends ChangeNotifier {
  bool get isOpen;
  void open();
  void close();
  void suppress();   // e.g. during checkout/payment
  void allow();
}

abstract class OfflineGame {
  GameMeta get meta;
  Widget build(BuildContext context, GameSession session);
}

class GameMeta {
  const GameMeta({
    required this.id,            // unique, lower_snake_case, stable forever
    required this.title,
    required this.emoji,         // lightweight icon
    required this.authors,       // non-empty (C7)
    this.description = '',
    this.version = '1.0.0',
    this.tags = const [],
    this.iconBuilder,            // optional custom icon
  });
}

class GameAuthor {
  const GameAuthor({required this.name, this.github, this.url});
  final String name;      // shown in UI
  final String? github;   // handle, optional
  final String? url;      // optional link/text only; no auto-opening
}

class GameSession {
  final int? bestScore;
  final ValueListenable<bool> paused;      // game must honour this
  final Random random;                     // use this, never Random() directly
  final void Function(int score) reportScore;
  final VoidCallback exit;
}

abstract class ConnectivitySource {
  Stream<bool> get onlineStream;           // true = really online
  Future<bool> isOnline();
}

abstract class ScoreStore {
  Future<int?> read(String gameId);
  Future<void> write(String gameId, int score);
}

class GameCatalog {
  static const List<OfflineGame> builtIn = [/* ... */];
}
```

**API discipline:** don't export anything else without approval. `build(context, session)` is the only way games render.

---

## 4. Architecture

### 4.1 Layers (dependencies point downward only)

```
┌───────────────────────────────────────────────┐
│ host/      OfflineGames widget, overlay,       │  app-facing
│            controller, offline-episode logic   │
├───────────────────────────────────────────────┤
│ ui/        spinner, picker, game frame,        │  presentation
│            credits sheet, back-online prompt  │
├───────────────────────────────────────────────┤
│ core/      OfflineGame, GameMeta, GameAuthor,  │  contracts (pure Dart
│            GameSession, GameCatalog, modes     │  where possible)
├───────────────┬───────────────┬───────────────┤
│ connectivity/ │ storage/      │ games/        │  implementations
│ default       │ in-memory     │ built-ins     │
│ checker       │ ScoreStore    │ (logic + ui)  │
└───────────────┴───────────────┴───────────────┘
```

### 4.2 Folder layout

```
offline_games/
  lib/
    offline_games.dart                 // public exports only
    src/
      core/
      host/
      ui/
      connectivity/
      storage/
      games/
        tic_tac_toe/
          tic_tac_toe_game.dart        // OfflineGame implementation
          logic/                       // pure Dart, no Flutter imports
          ui/
        memory_match/
        snake/
  example/                             // minimal demo app
  test/
    core/ host/ ui/ games/             // games: logic tests mandatory
  tool/
    game_template/                     // copy-paste starter for contributors
    check_authors.dart                 // CI: every game has an author
    gen_gallery.dart                   // (later) generates GAMES.md
  doc/
    CONTRIBUTING_GAMES.md
  README.md  CHANGELOG.md  CONTRIBUTING.md  LICENSE  AUTHORS.md  GAMES.md
  .github/
    workflows/ci.yaml
    PULL_REQUEST_TEMPLATE.md
```

### 4.3 Host state machine (offline-episode logic)

```
            online                         offline >= offlineDelay
 [Idle] ───────────────► [Idle]  ◄──────────────────────────────┐
   │ real reachability lost                                     │
   ▼                                                            │
[PendingOffline] --(timer = offlineDelay, still offline)--► [Offered]
   │ back online before timer: cancel                          │ user taps Spin/Play
   ▼                                                            ▼
 [Idle]                                                     [Playing]
                                                                │ back online
                                                                ▼
                                                        [PlayingOnline]
                                                      (prompt: keep / return)
```
Rules:
- One offer per offline episode. Dismiss = `Dismissed` until next episode.
- `suppress()` forces `Idle`; `allow()` re-enables.
- Debounce online/offline flapping (use `offlineDelay`, and require stable online before calling it "back").
- State machine lives in pure Dart (`OfflineEpisode`) and is tested with a fake `ConnectivitySource` and fake clock.

### 4.3.1 Rendering approach
- The host builds a `Stack`: `[child, overlay layer]` inside `MaterialApp.builder`. **No `navigatorKey` required.**
- The overlay layer provides its own `Material` and `Directionality`-safe context.
- Handle system back: close the game panel first (`PopScope`).
- Pause games on `AppLifecycleState.paused/inactive` via `GameSession.paused`.

### 4.4 Connectivity
- Interface: `ConnectivitySource` (§3). The default uses `internet_connection_checker_plus` through `InternetConnection.createInstance()`, **not** the singleton, because this is a library.
- Dispose the instance on host dispose.
- Users may pass their own `ConnectivitySource` (e.g. wrapping their existing network layer).

### 4.5 Storage
- Interface: `ScoreStore`. Default in-memory (`MemoryScoreStore`). Persistence is the app's choice; document a 10-line `shared_preferences` adapter in README. Do **not** depend on it.

### 4.6 Theming
- Default look follows the host app's `Theme.of(context)` (colour scheme, text theme). `OfflineGamesTheme` is optional and small (card shape, accent, wheel style).
- No hard-coded fonts.

---

## 5. Built-in games (v0.1 scope)

Each game: ≤ 30 s to understand, one-handed, portrait-friendly, pauses correctly, reports score, has logic tests.

| id | Title | Notes |
|---|---|---|
| `tic_tac_toe` | Tic Tac Toe | vs simple AI (minimax); logic fully pure |
| `memory_match` | Memory Match | emoji pairs, move counter as score |
| `snake` | Snake (original name/art) | `Ticker`-driven; swipe controls |

v0.2 candidates: reaction tap, 2048-style merge (original name), simple runner (original art), word scramble (bundled tiny word list requires approval per C5).

---

## 6. Contribution system (the "platform")

### 6.1 Principle
Contributing a game must be possible in **under an hour** by someone who has never seen the codebase.

### 6.2 Two contribution routes
1. **In-repo PR** into `lib/src/games/<id>/`: bundled with the package, credited in-app and in `GAMES.md`.
2. **Separate package** implementing `OfflineGame` (e.g. `offline_games_<name>`): developers add it to the `games:` list. Listed in a "Community packs" section of the README via PR.

### 6.3 Contributor documentation (`doc/CONTRIBUTING_GAMES.md`) must contain
1. Quick start: clone, run example, run tests.
2. **The game contract** with a minimal complete example (30-line game).
3. Step-by-step: copy `tool/game_template/`, rename, fill `GameMeta` (incl. **your name**), implement logic then UI, add tests, register in `GameCatalog`.
4. Rules: the constitution rules that apply to games (C2, C4, C5, C7, C8, C9, E1, E2), written in plain language.
5. Game checklist (also the PR template): logic tests, honours `paused`, uses `session.random`, reports score, semantics labels, no network, original name/art, author filled.
6. How credit works (§6.5) and how to update your own credit.
7. Review process and expected turnaround; code of conduct.
8. Licensing statement: contributions are under the package license.

### 6.4 Game template (`tool/game_template/`)
A copyable folder containing: an `OfflineGame` subclass with `TODO` markers, a pure-Dart logic file, a logic test file, and a README with the checklist. The author field is a required constructor argument in the template so it can't be forgotten.

### 6.5 Credit display (mandatory; satisfies C7)
- **Picker cards and spin result:** "by <name>".
- **In-game frame:** small chip "by <name>"; tapping opens a **Credits sheet** (all authors, optional GitHub handle, link text).
- **README + `GAMES.md`:** auto-generated table (title, author, version) via `tool/gen_gallery.dart`.
- **`AUTHORS.md`:** maintained list of contributors.
- Links are shown as text/selectable; the package never opens URLs on its own.

### 6.6 CI guard
`tool/check_authors.dart` instantiates every game in `GameCatalog.builtIn` and fails if `meta.authors` is empty, `meta.id` is duplicated or not `lower_snake_case`.

---

## 7. Workflow (how to build this)

### 7.1 Milestones with acceptance criteria

**M0: Skeleton**
- Package scaffolded, `lib/offline_games.dart`, example app, CI, MIT LICENSE (with the maintainer's name), README stub.
- Accept: `flutter analyze`, `flutter test` green on an empty suite; CI runs.

**M1: Core contracts + connectivity + episode logic**
- `OfflineGame`, `GameMeta`, `GameAuthor`, `GameSession`, `GamesMode`, `ConnectivitySource` + default, `ScoreStore` + memory, `OfflineEpisode` state machine.
- Accept: state-machine unit tests cover: offline→offer after delay, quick flap ignored, one-offer-per-episode, suppress/allow, back-online-while-playing.

**M2: Host + UI shell**
- `OfflineGames` widget (builder-based overlay), offer card, game frame (exit/pause/author chip), back-online prompt, controller, `showOfflineGames`.
- Accept: widget tests with fake connectivity prove auto offer, dismiss, manual open, back-button closes panel, no navigatorKey needed.

**M3: Spin + Picker UI**
- `GameSpinner` (no-repeat random, reduce-motion path), `GamePicker` grid, credits sheet.
- Accept: tests with seeded `Random`; spin never repeats; picker shows author on each card.

**M4: First game: Tic Tac Toe** (proves the contract)
- Accept: logic tests (win/draw/AI never loses), widget test for tap flow, pause honoured.

**M5: Memory Match, Snake**
- Same acceptance pattern.

**M6: Contributor system**
- `doc/CONTRIBUTING_GAMES.md`, `tool/game_template/`, PR template, `check_authors.dart`, `gen_gallery.dart`, `AUTHORS.md`.
- Accept: a dry-run contribution (a throwaway "hello game") follows the docs from scratch successfully.

**M7: Polish + publish**
- README with GIFs/screenshots, dartdoc on all public API, CHANGELOG, example, `dart pub publish --dry-run` clean, aim for max pub points.
- Accept: publish checklist (§9) complete.

### 7.2 Per-step loop (agent must follow)
1. Restate the step and its acceptance criteria.
2. Write or adjust tests first when logic is involved.
3. Implement the smallest thing that satisfies them.
4. Run `dart format .`, `flutter analyze`, `flutter test`.
5. Update docs/CHANGELOG if public API changed.
6. Report: what changed, tests added, anything skipped or uncertain.

### 7.3 Branching and commits
- Branch per milestone item: `feat/<area>-<short-name>`.
- Conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `chore:`, `refactor:`.
- Games are added as `feat(game): add <title> by <author>`.

### 7.4 CI (`.github/workflows/ci.yaml`)
Runs on every PR: format check, `flutter analyze`, `flutter test`, `dart run tool/check_authors.dart`, `dart pub publish --dry-run`.

---

## 8. Quality bars

- `flutter analyze` clean with `flutter_lints` (strict, no ignores without a comment).
- Logic coverage for every game and for `OfflineEpisode`.
- Public API fully documented with dartdoc.
- Soft size budget: keep the package archive small (target under ~200 KB for v0.1; flag if exceeded).
- No frame jank in the spinner or games on a mid-range device (use `Ticker`/`AnimationController`; avoid rebuilding whole trees every frame, and use `RepaintBoundary` and `CustomPainter` where appropriate).
- Works in light and dark themes and with large text scale.

---

## 9. Publish checklist

- [ ] Re-verify `offline_games` is still unclaimed on pub.dev right before publishing
- [ ] `pubspec.yaml`: description, repository, issue tracker, topics, `environment` constraints
- [ ] LICENSE present (MIT, decided)
- [ ] README: 30-second quick start, three modes, screenshots, contribution link
- [ ] CHANGELOG with `0.1.0`
- [ ] Example app runs on at least Android and iOS
- [ ] `dart pub publish --dry-run` clean
- [ ] Screenshots listed in `pubspec.yaml`
- [ ] Verified publisher (optional, recommended)

---

## 10. Non-goals (v0.x)

- Multiplayer or networked play.
- Accounts, leaderboards, achievements, or any server component.
- Native code, platform channels, audio, or Flame-based engines.
- In-app purchases or ads.
- A web gallery site (post-v1 idea; the metadata design already supports generating one).

---

## 11. Risks and decisions already made

| Topic | Decision |
|---|---|
| "Online" detection | Real reachability, debounced; never trust interface status alone (C10) |
| Popup intrusiveness | Dismissible, once per episode, suppressible (C6) |
| `navigatorKey` | Not required; overlay inside `MaterialApp.builder` |
| Heavy game engines | Excluded (C2); use `Ticker` and `CustomPainter` |
| Contribution scaling | Two routes: in-repo PR or separate package (§6.2) |
| Trademarked clones | Forbidden (C8) |
| Library singletons | Create an isolated connectivity instance (§4.4) |

---

## 12. Open questions for the human (agent: ask, don't assume)

1. ~~Final package name~~ **Decided:** `offline_games`.
2. ~~License~~ **Decided:** MIT.
3. **GitHub organisation/repo** and the author credit format for the maintainer.
4. Should the maintainer's own games and community games be visually distinguished? (default: no)
5. Any brand identity (logo, mascot, palette) for the README and spinner?

---

## 13. Glossary

- **Offline episode:** the period from confirmed loss of internet until confirmed return.
- **Offer:** the dismissible card inviting the player to play.
- **Spin:** random game selection with a short animation.
- **Game session:** the object a game receives to report score, pause, exit and get randomness.
- **Credit:** the author's name shown in-app and in generated docs.
