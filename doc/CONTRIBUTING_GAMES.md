# Contributing a Game to `offline_games`

Thank you for your interest in contributing to `offline_games`! Our vision is to build an open, lightweight, high-quality mini-arcade for Flutter apps.

Contributing a game is designed to take **under an hour**, even if you have never seen this codebase before.

---

## 1. Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/aslamambiloly/offline_games.git
   cd offline_games
   ```

2. **Verify your setup:**
   ```bash
   flutter pub get
   flutter test
   ```

3. **Run the example app:**
   ```bash
   cd example
   flutter run
   ```

---

## 2. The Game Contract

Every mini-game implements the simple abstract class `OfflineGame`:

```dart
abstract class OfflineGame {
  const OfflineGame();

  GameMeta get meta;
  Widget build(BuildContext context, GameSession session);
}
```

### Minimal Complete Example (~30 lines)

```dart
import 'package:flutter/material.dart';
import 'package:offline_games/offline_games.dart';

class ClickerGame extends OfflineGame {
  const ClickerGame();

  @override
  GameMeta get meta => const GameMeta(
        id: 'tap_frenzy',
        title: 'Tap Frenzy',
        description: 'Tap as fast as you can to score points!',
        emoji: '👆',
        authors: [
          GameAuthor(name: 'Jane Doe', github: '@janedoe'),
        ],
      );

  @override
  Widget build(BuildContext context, GameSession session) {
    return _ClickerWidget(session: session);
  }
}

class _ClickerWidget extends StatefulWidget {
  final GameSession session;
  const _ClickerWidget({required this.session});

  @override
  State<_ClickerWidget> createState() => _ClickerWidgetState();
}

class _ClickerWidgetState extends State<_ClickerWidget> {
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size(120, 60)),
        onPressed: widget.session.paused.value
            ? null
            : () {
                setState(() => _score++);
                widget.session.reportScore(_score);
              },
        child: Text('Taps: $_score', style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
```

### The `GameSession` Object

Your game receives a `GameSession` containing:
- `bestScore`: The historical high score recorded on this device for this game.
- `reportScore(int score)`: Call whenever the player earns points.
- `paused`: A `ValueListenable<bool>`. When `true`, pause tickers, timers, and input.
- `random`: A seeded `Random` instance. **Always use this instead of raw `Random()`** so tests and replayability remain deterministic.
- `exit()`: Programmatically exit the game frame back to the host app.

---

## 3. Step-by-Step Contribution Guide

### Step 1: Copy the Template
Copy the starter template folder:
```bash
cp -r tool/game_template lib/src/games/<your_game_id>
```
*Example ID: `flappy_bird`, `brick_breaker`, `color_tap` (must be `lower_snake_case`).*

### Step 2: Relocate the Test
Move the unit test file to the test directory:
```bash
mkdir -p test/games/<your_game_id>
mv lib/src/games/<your_game_id>/test/my_game_logic_test.dart test/games/<your_game_id>/<your_game_id>_logic_test.dart
rmdir lib/src/games/<your_game_id>/test
```

### Step 3: Set Metadata and Mandatory Author Credit
Edit `lib/src/games/<your_game_id>/my_game.dart`:
- Set `id` to your `lower_snake_case` game identifier.
- Set `title`, `description`, and `icon`.
- **Add your name to `authors`**. Every game credits its author in the arcade spinner, picker cards, and in-game frame credits modal!

### Step 4: Implement Pure-Dart Logic
In `logic/<your_game_id>_state.dart`:
- Keep all game rules, boards, coordinates, and math 100% pure Dart.
- Do NOT import `flutter/material.dart` or depend on `BuildContext`.

### Step 5: Build the UI
In `ui/<your_game_id>_widget.dart`:
- Listen to `session.paused` to stop/start animations.
- Use `session.random` for all procedural elements.
- Report scores with `session.reportScore(score)`.
- Use Flutter's built-in widgets or `CustomPainter`.

### Step 6: Register Your Game
1. Add an instance to `GameCatalog.builtIn` in `lib/src/core/game_catalog.dart`.
2. Export your game class in `lib/offline_games.dart`.

### Step 7: Format, Analyze, and Test
```bash
dart format .
flutter analyze
flutter test
flutter test tool/check_authors.dart
```

### Step 8: Update Documentation
Run the gallery generator:
```bash
flutter test tool/gen_gallery.dart
```
Add your name to `AUTHORS.md`.

---

## 4. Constitution Rules for Games

To maintain top-tier stability, performance, and legal compliance across thousands of host apps, every game must adhere to these rules:

1. **No External Dependencies (C2):** Use only the Flutter SDK and package dependencies. No Flame, Bloc, or third-party physics engines.
2. **100% Offline (C4):** Absolutely zero network requests, analytics, tracking, or remote configuration.
3. **No Binary Assets in v0.x (C5):** No bundled PNGs, JPGs, or MP3s. Render everything with `CustomPainter`, widgets, emoji, or standard `IconData`.
4. **Mandatory Author Credit (C7):** You must credit yourself or your team in `meta.authors`.
5. **Originality & Legality (C8):** Do not clone trademarked titles or assets. Original names, gameplay variations, and art only.
6. **Accessible by Default (C9):** Ensure interactive elements have `Semantics` and touch targets of at least 44x44 dp.

---

## 5. Pull Request Checklist

Before submitting your PR, ensure:
- [ ] Logic is in pure Dart (no `BuildContext` in logic classes)
- [ ] Comprehensive unit tests cover game rules and edge cases
- [ ] Game properly pauses when `session.paused.value == true`
- [ ] `session.random` is used for all randomness
- [ ] Scores are reported using `session.reportScore`
- [ ] `authors` list is filled with valid contributor name(s)
- [ ] `flutter analyze` passes with 0 warnings
- [ ] `flutter test` passes
- [ ] `flutter test tool/check_authors.dart` passes

---

## 6. How Credit Works

- In the **Arcade Picker**: Each card shows `by <Author>`.
- In the **Lucky Wheel / Spinner**: The selected game highlights its author.
- In the **Game Frame**: A neat author badge appears in the top bar. Tapping it opens a credits sheet displaying your GitHub profile and website.
- In **`GAMES.md` & `README.md`**: Automatically listed with links to your profile.

---

## 7. Licensing

By contributing code to `offline_games`, you agree that your contributions will be licensed under the project's [MIT License](../LICENSE).
