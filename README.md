# offline_games

A plug-and-play mini arcade for Flutter apps when the device goes offline. Zero configuration, zero heavy game engines, and full creator attribution.

[![pub package](https://img.shields.io/pub/v/offline_games.svg)](https://pub.dev/packages/offline_games)
[![CI](https://github.com/aslamambiloly/offline_games/actions/workflows/ci.yaml/badge.svg)](https://github.com/aslamambiloly/offline_games/actions/workflows/ci.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Platforms](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-blue.svg)](https://flutter.dev)

---

## Why `offline_games`?

Most apps greet disconnected users with an empty screen, a sad gray dinosaur, or a broken spinner. `offline_games` turns network downtime into an engaging, lightweight mini-arcade:

- 🎮 **Zero Configuration**: Drop `OfflineGames(child: child!)` in your `MaterialApp.builder` and you're done. No `navigatorKey` required.
- 📴 **Honest Reachability**: Uses real reachability checking (not just interface Wi-Fi toggles) with debouncing to ignore fleeting network blips.
- 🎰 **Spin, Picker, or Single**: Let players spin an animated lucky wheel, browse a retro-modern catalog grid, or launch a direct game.
- 🛡️ **Never Hijacks Your App**: Non-intrusive card, shown once per offline episode, easily dismissible, and suppressible on critical screens (e.g. checkout).
- 🏆 **Mandatory Creator Credit**: Every game proudly credits its author across the picker, spinner, and in-game frame.
- 👾 **Vintage Pixel Vector Aesthetic**: Pure vector-rendered 5x7 typography, CRT phosphor scanlines, and 8-bit glyph sprites with zero font files (.ttf) and zero extra dependencies.
- ⚡ **Pure Flutter & Featherweight (< 45 KB)**: Zero Flame, zero audio blobs, zero bundled binary assets. Games render crisply at any DPI using widgets and `CustomPainter`.

---

## Quick Start (30 Seconds)

Add `offline_games` to your `pubspec.yaml`:

```yaml
dependencies:
  offline_games: ^0.1.0
```

Wrap your app inside `MaterialApp.builder`:

```dart
import 'package:flutter/material.dart';
import 'package:offline_games/offline_games.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      // That's it! Zero config arcade overlay:
      builder: (context, child) => OfflineGames(child: child!),
      home: const MyHomePage(),
    );
  }
}
```

When internet connectivity drops, a sleek offer card slides in: *"You're offline. Play a quick game while you wait?"*. Tapping **Spin** launches a random game! When connection is restored, a subtle top banner appears letting the player keep playing or return to the app.

---

## Presentation Modes

Choose how players discover games using the `mode` parameter:

### 1. Spin Mode (Default)
Spins an animated wheel to select a random game, guaranteeing the same game is never picked twice consecutively:
```dart
OfflineGames(
  mode: const GamesMode.spin(),
  child: child!,
)
```

### 2. Picker Catalog Mode
Presents a clean grid of all available games with high scores and author credits:
```dart
OfflineGames(
  mode: const GamesMode.picker(),
  child: child!,
)
```

### 3. Single Game Mode
Launches directly into a specific game:
```dart
OfflineGames(
  mode: const GamesMode.single(SnakeGame()),
  child: child!,
)
```

---

## Standalone APIs & Custom Triggers

Want to launch the arcade from a custom drawer item, error screen, or button?

### Imperative Launcher
```dart
// Opens the arcade inside a smooth modal route
showOfflineGames(context);
```

### Controller Control
```dart
final controller = OfflineGamesController();

// Pass to your host widget:
OfflineGames(
  controller: controller,
  child: child!,
)

// Open or close programmatically:
controller.open();
controller.close();
```

### Suppressing on Critical Screens
Prevent games from popping up during sensitive flows like payments or camera capture:
```dart
OfflineGames(
  suppress: isCheckingOut,
  child: child!,
)
```

### Standalone Widgets
Every component is completely decoupled and can be used directly anywhere in your widget tree:

```dart
// Standalone lucky wheel spinner
GameSpinner(
  games: GameCatalog.builtIn,
  onResult: (game) => print('Selected: ${game.meta.title}'),
);

// Standalone arcade catalog picker
GamePicker(
  games: GameCatalog.builtIn,
  onSelected: (game) => print('Picked: ${game.meta.title}'),
);

// Standalone embedded game player
GamePlayer(
  game: const BreakoutGame(),
  onExit: () => Navigator.of(context).pop(),
);
```

---

## Customizing Theme

Customize accent colors, card corners, and gradients via `OfflineGamesTheme`:

```dart
OfflineGames(
  theme: OfflineGamesTheme(
    primaryColor: Colors.deepPurpleAccent,
    borderRadius: BorderRadius.circular(24),
    accentGradient: const LinearGradient(
      colors: [Colors.purple, Colors.pinkAccent],
    ),
  ),
  child: child!,
)
```

---

## Built-in Games

<!-- GAMES_TABLE_START -->
| Game | ID | Author | Description |
|---|---|---|---|
| **Breakout** | `breakout` | [Aslam Ambiloly](https://github.com/aslamambiloly) | Bounce the pixel ball to smash glowing brick walls and clear the grid. |
| **Memory Match** | `memory_match` | [Aslam Ambiloly](https://github.com/aslamambiloly) | Flip and match 8-bit pixel cards with the fewest possible moves. |
| **Snake** | `snake` | [Aslam Ambiloly](https://github.com/aslamambiloly) | Navigate the grid, collect apples, and grow without colliding. |
<!-- GAMES_TABLE_END -->

See [GAMES.md](GAMES.md) for more details.

---

## Contributing Games

We welcome new mini-games from the community! Writing and adding a game takes **less than 1 hour**:

1. Check out our [< 1 Hour Contribution Guide](doc/CONTRIBUTING_GAMES.md).
2. Copy the boilerplate from [`tool/game_template/`](tool/game_template/).
3. Add your logic, widgets, tests, and **your name** to `meta.authors`.
4. Open a PR — once merged, your game and author credit will ship with the package!

---

## Authors & Maintainers

- **Aslam Ambiloly** ([@aslamambiloly](https://github.com/aslamambiloly)) — Creator and Maintainer

See [AUTHORS.md](AUTHORS.md) for full contributor credits.

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
