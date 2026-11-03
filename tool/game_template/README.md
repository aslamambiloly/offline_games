# Game Contributor Template

Welcome! Follow this quick step-by-step checklist to contribute a brand new mini-game to `offline_games` in under an hour:

## Step-by-Step Instructions

1. **Copy this folder**:
   Copy `tool/game_template/` into `lib/src/games/<your_game_id>/`
   (e.g., `lib/src/games/flappy_bird/`).

2. **Move the test file**:
   Move `lib/src/games/<your_game_id>/test/my_game_logic_test.dart` to
   `test/games/<your_game_id>/<your_game_id>_logic_test.dart`.

3. **Fill in Metadata & Author**:
   Open `my_game.dart`, rename the class, set a unique `id` in `lower_snake_case`, and add your name to `authors:` (this is mandatory and will be displayed in-app!).

4. **Implement Logic**:
   Write your game rules in `logic/`. Keep it pure Dart without any `BuildContext` or Flutter widget imports.

5. **Build the UI**:
   Build your interactive widget in `ui/`.
   - Honour `session.paused`
   - Use `session.random`
   - Call `session.reportScore(...)`
   - Ensure touch targets are at least 44dp

6. **Register the Game**:
   Add your game instance to `GameCatalog.builtIn` in `lib/src/core/game_catalog.dart`.
   Export your game class in `lib/offline_games.dart`.

7. **Verify & Test**:
   ```bash
   dart format .
   flutter analyze
   flutter test
   flutter test tool/check_authors.dart
   ```

8. **Submit a Pull Request**:
   Use `feat(game): add <Title> by <Your Name>` as your commit and PR title!
