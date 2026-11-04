# Changelog

All notable changes to `offline_games` will be documented in this file.

## 1.0.1

- **Dependencies**:
  - Expanded `internet_connection_checker_plus` constraint to `'>=2.5.2 <4.0.0'` to support version 3.x and achieve a 160/160 pub score.

## 1.0.0

- **Production Release**:
  - Official 1.0.0 release of `offline_games`.
  - Zero-config mini arcade with automatic reachability detection and debouncing.
  - Three built-in games: Breakout, Memory Match, and Snake.
  - Neo-brutalist 8-bit vector UI with zero external fonts and zero engine dependencies (< 100 KB).
  - Standalone component APIs, themeMode support, and instant simulator testing via `debugForceOffline: true`.

## 0.1.0

### Added
- **Zero-Config Arcade Host (`OfflineGames`)**:
  - Simple `MaterialApp.builder` drop-in (`OfflineGames(child: child!)`).
  - Non-intrusive, dismissible offer card shown once per offline episode.
  - Subtle "Back online • Keep playing / Return to app" banner when connection restores during gameplay.
  - Intercepts system back buttons to cleanly dismiss game overlays before popping the host app.
  - Safe suppression support via `suppress` parameter (e.g. during payment checkouts).
  - Instant simulator testing via `debugForceOffline: true` without toggling device Wi-Fi.
- **Presentation Modes (`GamesMode`)**:
  - `GamesMode.spin()`: Animated slot wheel with guaranteed no-repeat selection.
  - `GamesMode.picker()`: Modern 8-bit arcade grid catalog showcasing high scores and author credits.
  - `GamesMode.single(game)`: Directly launches a specific chosen mini-game.
- **Three Built-in Launch Mini-Games**:
  - **Breakout**: Classic brick-breaker with angle deflection physics, multi-lives, rainbow brick rows, launch prompts, and touch steering.
  - **Memory Match**: Vintage 8-bit card pair flip matching with moves/pairs scoreboard HUD and stage cleared celebration.
  - **Snake**: Classic Nokia-style retro arcade snake with smooth motion, directional swipes, and tactile D-pad controls.
- **Balanced Neo-Brutalist 8-Bit Visual System**:
  - High-contrast pure white arcade cards (`#FFFFFF`) with solid 2-3px black borders (`#000000`) and hard stepped drop shadows across both dark and light modes.
  - CRT monitor atmosphere with subtle scanlines and radial perimeter vignette (`CrtScanlinesOverlay`).
  - Retro 8-bit pixel cloud wipe transition (`RetroCloudTransition`).
  - Pure vector 5x7 bitmask typography (`PixelText`) with zero `.ttf` or `.otf` font dependencies.
  - Pure vector 8-bit glyph sprites (`PixelGlyphWidget`) with zero Material icons and zero emoji literals.
- **Mandatory Author Attribution**:
  - Every game openly attributes its creator(s) in picker cards, spin highlights, and the in-game credits modal.
- **Standalone Component APIs**:
  - `GameSpinner`: Standalone random game selector widget with reduce-motion accessibility.
  - `GamePicker`: Standalone game catalog grid.
  - `GamePlayer`: Standalone player widget for embedding games into custom views.
  - `showOfflineGames()`: Imperative helper to push the arcade over any modal route.
  - `RetroPixelCard` & `RetroPixelButton`: Reusable neo-brutalist retro UI primitives.
- **Developer & Contributor System**:
  - `llms.txt`: Comprehensive AI assistant documentation for Copilot, Cursor, Gemini, and Claude.
  - `tool/game_template/`: Copy-pasteable boilerplate for new games.
  - `tool/check_authors.dart`: Automated CI guard enforcing author attribution, unique IDs, and metadata validity.
  - `tool/check_pixel_theme.dart`: Automated CI guard enforcing 100% pure pixel vector guidelines.
  - `tool/gen_gallery.dart`: Automated markdown gallery generator.
  - `doc/CONTRIBUTING_GAMES.md`: Comprehensive <1 hour contribution guide.
