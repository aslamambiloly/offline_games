# Changelog

All notable changes to `offline_games` will be documented in this file.

## 0.1.0

### Added
- **Zero-Config Arcade Host (`OfflineGames`)**:
  - Simple `MaterialApp.builder` drop-in (`OfflineGames(child: child!)`).
  - Non-intrusive, dismissible offer card shown once per offline episode.
  - Subtle "Back online • Keep playing / Return to app" banner when connection restores during gameplay.
  - Intercepts system back buttons to cleanly dismiss game overlays before popping the host app.
  - Safe suppression support via `suppress` parameter (e.g. during payment checkouts).
- **Presentation Modes (`GamesMode`)**:
  - `GamesMode.spin()`: Animated slot wheel with guaranteed no-repeat selection.
  - `GamesMode.picker()`: Modern arcade grid catalog showcasing high scores and author credits.
  - `GamesMode.single(game)`: Directly launches a specific chosen mini-game.
- **Three Built-in Launch Mini-Games**:
  - ❌ ⭕ **Tic Tac Toe**: Clean 3x3 grid vs. unbeatable Minimax AI.
  - 🃏 **Memory Match**: Emoji pair flip matching with turn scoring.
  - 🐍 **Snake**: Classic arcade snake with smooth motion, directional swipes, and D-pad controls.
- **Mandatory Author Attribution (Constitution C7)**:
  - Every game openly attributes its creator(s) in picker cards, spin highlights, and the in-game credits modal.
- **Standalone Component APIs**:
  - `GameSpinner`: Standalone random game selector widget with reduce-motion accessibility.
  - `GamePicker`: Standalone game catalog grid.
  - `GamePlayer`: Standalone player widget for embedding games into custom views.
  - `showOfflineGames()`: Imperative helper to push the arcade over any modal route.
- **Contributor System**:
  - `tool/game_template/`: Copy-pasteable boilerplate for new games.
  - `tool/check_authors.dart`: Automated CI guard enforcing author attribution, unique IDs, and metadata validity.
  - `tool/gen_gallery.dart`: Automated markdown gallery generator.
  - `doc/CONTRIBUTING_GAMES.md`: Comprehensive <1 hour contribution guide.
