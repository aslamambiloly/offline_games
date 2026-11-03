<p align="center">
  <a href="https://pub.dev/packages/offline_games"><img src="https://img.shields.io/pub/v/offline_games.svg" alt="pub version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.3%2B-blue?logo=dart" alt="Dart"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.19%2B-blue?logo=flutter" alt="Flutter"></a>
  <br>
  <a href="https://github.com/aslamambiloly/offline_games/actions/workflows/ci.yaml"><img src="https://github.com/aslamambiloly/offline_games/actions/workflows/ci.yaml/badge.svg" alt="CI"></a>
  <a href="https://pub.dev/packages/offline_games"><img src="https://img.shields.io/badge/style-neo--brutalist-black?style=flat" alt="Neo-Brutalist"></a>
  <a href="https://pub.dev/packages/offline_games"><img src="https://img.shields.io/badge/size-%3C120KB-green" alt="Size"></a>
</p>

<p align="center">
  <a href="https://ko-fi.com/N7K021PF59"><img src="https://raw.githubusercontent.com/aslamambiloly/curved_navigation_bar_pro/main/doc/coffee.png" alt="Support me on Ko-fi" width="400"></a>
</p>

A plug-and-play mini arcade for Flutter apps when the device goes offline. Zero configuration, zero heavy game engines (< 120 KB package), and full creator attribution.

## The `Issue` : (

You build a modern, high-polish Flutter application with:

✅ Responsive layouts and 120fps fluid transitions.<br>
✅ Local caching and SQLite offline data persistence.<br>
✅ Reactive state management and real-time streams.<br>
✅ Push notifications and background workers.<br>

Do your users feel great when they board an airplane, enter an elevator, walk into a subway tunnel, or lose mobile signal?

Not really:

❌ **Users are greeted with an empty screen, a sad gray dinosaur, or a broken spinner**.<br>
❌ Adding a mini-game normally means pulling in heavy engines (Flame, Unity, Godot), ballooning your app bundle by 15-40+ MB.<br>
❌ Managing reachability detection, debouncing fleeting network blips, and showing dismissible UI without hijacking navigation stacks is messy and fragile.<br>

## The `Solution` : )

`offline_games` turns network downtime into an engaging, lightweight mini-arcade with **zero configuration**:

- 🎮 **Just 1 Line of Code**: Drop `OfflineGames(child: child!)` in your `MaterialApp.builder` and you're done. No `navigatorKey` required.
- 👾 **Authentic 8-Bit Neo-Brutalist Aesthetic**: Pure vector-rendered 5x7 typography, CRT monitor scanlines, and 8-bit glyph sprites with **zero `.ttf` font files** and **zero extra dependencies**.
- ⚡ **Featherweight (< 120 KB total package)**: 100% pure Flutter `Canvas` and `CustomPainter`. Zero Flame, zero audio blobs, zero binary image assets.
- 📴 **Honest Reachability & Cloud Wipe**: Real reachability checking (not just Wi-Fi toggles) with debouncing and an 8-bit pixel cloud wipe transition.
- 🎰 **Spin, Catalog Grid, or Direct Play**: Let players spin a retro animated slot wheel, browse an arcade catalog grid, or launch directly into a game.
- 🛡️ **Never Hijacks Your App**: Non-intrusive card shown once per offline episode, easily dismissible, and suppressible on critical screens (e.g. checkout).
- 🏆 **Mandatory Creator Credit**: Every game proudly attributes its creator in the picker and in-game credits modal.
- 🤖 **AI-Agent Ready**: Includes [`llms.txt`](llms.txt) for effortless integration and game development by AI coding assistants (Copilot, Cursor, Gemini, Claude).

---

## Happy News : )

> [!NOTE]
> `offline_games` is implemented entirely in **pure Dart and Flutter**. So don't worry about:
> - **Zero Engine Bloat**: No Flame, Unity, or Godot. Total package archive is under **120 KB**.
> - **Zero Font Overhead**: No `.ttf` or `.otf` assets. Pure 5x7 vector bitmask typography compiled in code.
> - **Zero Asset Binaries**: All arcade sprites, CRT overlays, and pixel glyphs render via Flutter `Canvas` and `CustomPainter`.
> - **Zero Native Config**: 100% compatible with iOS (Swift Package Manager / CocoaPods), Android (AGP 8.0+ / AGP 9.0+), Web, macOS, Windows, and Linux.

---

## Table of Contents

- [Comparison](#comparison)
- [Installation](#installation)
- [Quick Start (30 Seconds)](#quick-start-30-seconds)
- [Instant Simulator Testing (`debugForceOffline`)](#instant-simulator-testing-debugforceoffline)
- [Presentation Modes](#presentation-modes)
  - [1. Spin Mode (Default)](#1-spin-mode-default)
  - [2. Picker Catalog Mode](#2-picker-catalog-mode)
  - [3. Single Game Mode](#3-single-game-mode)
- [Standalone APIs & Custom Triggers](#standalone-apis--custom-triggers)
  - [Imperative Launcher (`showOfflineGames`)](#imperative-launcher-showofflinegames)
  - [Controller Control (`OfflineGamesController`)](#controller-control-offlinegamescontroller)
  - [Suppressing on Critical Screens](#suppressing-on-critical-screens)
  - [Standalone Widgets](#standalone-widgets)
- [Dark Mode, Light Mode & Custom Themes](#dark-mode-light-mode--custom-themes)
- [Shared Retro Primitives](#shared-retro-primitives)
- [Built-in Games](#built-in-games)
- [Contributing Games (< 1 Hour Guide)](#contributing-games--1-hour-guide)
- [AI Pair Programming (`llms.txt`)](#ai-pair-programming-llmstxt)
- [API Reference](#api-reference)
- [Authors & Maintainers](#authors--maintainers)
- [License](#license)

---

## Comparison

| Metric / Feature | Standard No-Internet Handling | With `offline_games` |
|---|---|---|
| **User Experience** | Blank error screen, dead dinosaur, or endless spinner | Engaging, delightful 8-bit retro arcade |
| **Setup Complexity** | Complex custom network listeners & navigation keys | **1 line**: `OfflineGames(child: child!)` in `MaterialApp.builder` |
| **Bundle Size Overhead** | Minimal | **< 120 KB total archive** (0 assets, 0 fonts) |
| **Engine Dependencies** | Flame / Unity / Godot (15-40+ MB) | **Zero**: 100% Pure Flutter Canvas & Widgets |
| **Reachability Detection** | Naive Wi-Fi toggle checking (fails behind captive portals) | Honest ICMP/HTTP reachability checks with debounce |
| **Visual Polish** | Generic material dialogs | Balanced neo-brutalist white cards, solid black borders, CRT scanlines |
| **Reconnection UX** | Abruptly crashes or dismisses screen | Gentle banner: *"Keep playing"* or *"Return to app"* |
| **Back Button Safety** | Can pop the entire app accidentally | `PopScope` intercepts back gestures to cleanly exit arcade first |

---

## Installation

Add `offline_games` to your `pubspec.yaml`:

```yaml
dependencies:
  offline_games: ^0.1.0
```

Or run:

```bash
flutter pub add offline_games
```

Import in your Dart file:

```dart
import 'package:offline_games/offline_games.dart';
```

---

## Quick Start (30 Seconds)

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
      // Plug-and-play arcade overlay:
      builder: (context, child) => OfflineGames(child: child!),
      home: const MyHomePage(),
    );
  }
}
```

When internet connectivity drops, a sleek offer card slides in: *"You're offline. Play a quick game while you wait?"*. Tapping **Play** launches the arcade spinner! When connection is restored, a subtle top banner appears letting the player keep playing or return to the app.

---

## Instant Simulator Testing (`debugForceOffline`)

> [!TIP]
> **No Airplane Mode Needed:**
> Set `debugForceOffline: true` on `OfflineGames` to simulate an immediate offline state in your simulator or emulator without toggling device network settings:

```dart
OfflineGames(
  debugForceOffline: true, // Forces offline arcade overlay immediately
  child: child!,
)
```

---

## Presentation Modes

Choose how players discover games using the `mode` parameter:

### 1. Spin Mode (Default)
Spins an animated slot wheel to select a random game, guaranteeing the same game is never picked twice consecutively:
```dart
OfflineGames(
  mode: const GamesMode.spin(),
  child: child!,
)
```

### 2. Picker Catalog Mode
Presents a clean 8-bit grid of all available games with high scores and author credits:
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

### Imperative Launcher (`showOfflineGames`)
```dart
// Opens the arcade inside a smooth modal route
showOfflineGames(context);
```

### Controller Control (`OfflineGamesController`)
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

## Dark Mode, Light Mode & Custom Themes

`OfflineGames` features a **balanced neo-brutalist 8-bit aesthetic** that adapts seamlessly across dark and light modes via `themeMode`:
- **Dark Mode (`ThemeMode.dark`)**: Pure black (`#000000`) screen background with high-contrast white arcade cards, solid black borders, and authentic vibrant retro vector sprites.
- **Light Mode (`ThemeMode.light`)**: Pure white (`#FFFFFF`) screen background with crisp neo-brutalist cards and solid black borders.
- **System Mode (`ThemeMode.system`)**: Automatically follows device brightness (default).

```dart
OfflineGames(
  themeMode: ThemeMode.system, // ThemeMode.dark, ThemeMode.light, or ThemeMode.system
  child: child!,
)
```

You can also customize accent colors, card corners, and styles via `OfflineGamesTheme`:

```dart
OfflineGames(
  theme: OfflineGamesTheme.dark().copyWith(
    primaryColor: const Color(0xFF16A34A),
  ),
  child: child!,
)
```

---

## Shared Retro Primitives

The package exports its complete set of vector arcade UI primitives for you to use in your own views:

- **`PixelText`**: Pure vector 5x7 bitmask typography at any scale with word wrapping and optional phosphor glow. Zero font assets required.
- **`PixelGlyphWidget`**: 8-bit vector glyphs (`alien`, `apple`, `heart`, `star`, `sword`, `trophy`, `cloud`, `coin`, `arrowUp`, etc.).
- **`RetroPixelCard`**: Stepped hard-shadow pixel cards with solid black borders.
- **`RetroPixelButton`**: Chunky 8-bit pushable arcade buttons with tactile press mechanics.
- **`CrtScanlinesOverlay`**: CRT monitor overlay with subtle scanlines and radial perimeter vignette.

---

## Built-in Games

<!-- GAMES_TABLE_START -->
| Game | ID | Author | Description |
|---|---|---|---|
| **Breakout** | `breakout` | [Aslam Ambiloly](https://github.com/aslamambiloly) | Bounce the pixel ball to smash glowing brick walls and clear the grid. Features angle deflection physics, multi-lives, rainbow brick rows, and touch steering. |
| **Memory Match** | `memory_match` | [Aslam Ambiloly](https://github.com/aslamambiloly) | Flip and match 8-bit pixel cards with the fewest possible moves. Features vibrant glyph vectors, turn scoring, and stage cleared celebration. |
| **Snake** | `snake` | [Aslam Ambiloly](https://github.com/aslamambiloly) | Navigate the grid, collect apples, and grow without colliding. Classic Nokia-style retro arcade snake with smooth motion, directional swipes, and tactile D-pad controls. |
<!-- GAMES_TABLE_END -->

See [GAMES.md](GAMES.md) for more details.

---

## Contributing Games (< 1 Hour Guide)

We welcome new mini-games from the community! Writing and adding a game takes **less than 1 hour**:

1. Check out our [< 1 Hour Contribution Guide](doc/CONTRIBUTING_GAMES.md).
2. Copy the boilerplate from [`tool/game_template/`](tool/game_template/).
3. Add your logic, widgets, tests, and **your name** to `meta.authors`.
4. Run automated verification:
   ```bash
   dart run tool/check_pixel_theme.dart
   flutter test tool/check_authors.dart
   ```
5. Open a PR: once merged, your game and author credit will ship with the package!

See also [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`llms.txt`](llms.txt) for instructions tailored for AI pair programmers.

---

## AI Pair Programming (`llms.txt`)

This package includes a dedicated [`llms.txt`](llms.txt) at the root of the repository, structured specifically for AI coding assistants (GitHub Copilot, Cursor, Gemini, Claude, ChatGPT).

It provides agents with:
- Exact architecture contracts (`OfflineGame`, `GameSession`, `ConnectivitySource`).
- Strict 100% pixel vector rules (preventing unwanted `.ttf` or `Icons.*` imports).
- Verification test recipes for zero-regression game development.

---

## API Reference

### `OfflineGames`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | *required* | The underlying application widget tree. |
| `connectivity` | `ConnectivitySource?` | `DefaultConnectivitySource()` | Custom reachability provider for mocking or testing. |
| `controller` | `OfflineGamesController?` | `null` | Programmatic controller to open or close the arcade. |
| `mode` | `GamesMode` | `const GamesMode.spin()` | Presentation mode (`spin`, `picker`, or `single`). |
| `themeMode` | `ThemeMode` | `ThemeMode.system` | Brightness mode (`system`, `dark`, or `light`). |
| `theme` | `OfflineGamesTheme?` | `null` | Optional custom retro theme overrides. |
| `customGames` | `List<OfflineGame>` | `const []` | Additional community or custom mini-games to register. |
| `suppress` | `bool` | `false` | When true, suppresses the offline offer card (e.g. during checkout). |
| `debugForceOffline` | `bool` | `false` | When true, simulates offline state immediately without disabling Wi-Fi. |
| `offlineDelay` | `Duration` | `const Duration(seconds: 3)` | Time disconnected before showing the offer card. |
| `debounceDuration` | `Duration` | `const Duration(milliseconds: 1500)` | Debounce window to ignore fleeting network blips. |
| `onGameStarted` | `VoidCallback?` | `null` | Callback triggered when a game session starts. |
| `onGameExited` | `VoidCallback?` | `null` | Callback triggered when a game session ends. |

---

## Authors & Maintainers

- **Aslam Ambiloly** ([@aslamambiloly](https://github.com/aslamambiloly)) - Creator and Maintainer

See [AUTHORS.md](AUTHORS.md) for full contributor credits.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
