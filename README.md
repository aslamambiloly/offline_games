<p align="center">
  <a href="https://pub.dev/packages/offline_games"><img src="https://img.shields.io/pub/v/offline_games.svg" alt="pub version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.19%2B-blue?logo=flutter" alt="Flutter"></a>
  <br>
  <a href="https://github.com/aslamambiloly/offline_games/actions/workflows/ci.yaml"><img src="https://github.com/aslamambiloly/offline_games/actions/workflows/ci.yaml/badge.svg" alt="CI"></a>
  <a href="https://pub.dev/packages/offline_games"><img src="https://img.shields.io/badge/style-neo--brutalist-black?style=flat" alt="Neo-Brutalist"></a>
  <a href="https://pub.dev/packages/offline_games"><img src="https://img.shields.io/badge/size-%3C120KB-green" alt="Size"></a>
</p>

<p align="center">
  <a href="https://ko-fi.com/N7K021PF59"><img src="https://raw.githubusercontent.com/aslamambiloly/curved_navigation_bar_pro/main/doc/coffee.png" alt="Support me on Ko-fi" width="400"></a>
</p>

A plug-and-play mini-arcade for Flutter apps when the device goes offline. Zero configuration, zero heavy engines, and authentic 8-bit retro vibes in **under 120 KB**.

## The Offline Dread

Airplane mode, elevator rides, subway tunnels, or lost signals: users usually see a sad blank screen or frozen spinner 🥲. **`offline_games`** turns that downtime into instant retro entertainment with **1 line of code**.

## Happy News : )

<!-- > [!NOTE] -->
- **100% pure Dart & Flutter**:
 - **Zero Heavy Engines**: No Flame, Unity, or Godot.
 - **Zero Font Overhead**: No `.ttf` or `.otf` assets. 
 - **Zero Asset Binaries**: All sprites, scanlines, and glyphs render via Flutter `Canvas`.
 - **Native Safe**: 100% compatible with iOS SPM and Android AGP 8/9.

## Features

- **One Line Setup**.
- **Honest Reachability**: Real HTTP ping checks with debouncing (no false alarms).
- **Three Modes**: [`Spin`](#1-spin-mode-default), [`Picker`](#2-picker-catalog-mode), or [`Single Game`](#3-single-game-mode).
- **Built-in Games**
- **Adaptive Theming**.
- **AI-Agent Ready**: Includes [`llms.txt`](llms.txt) for Cursor, Copilot, and Claude.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Simulator Testing](#simulator-testing)
- [Modes](#modes)
  - [1. Spin Mode (Default)](#1-spin-mode-default)
  - [2. Picker Catalog Mode](#2-picker-catalog-mode)
  - [3. Single Game Mode](#3-single-game-mode)
- [Theming](#theming)
- [Standalone APIs](#standalone-apis)
- [Built-in Games](#built-in-games)
- [Shared Retro Primitives](#shared-retro-primitives)
- [API Reference](#api-reference)
  - [`OfflineGames`](#offlinegames)
  - [`OfflineGamesController`](#offlinegamescontroller)
- [Running the example](#running-the-example)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  offline_games: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:offline_games/offline_games.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      builder: (context, child) => OfflineGames(
        child: child!,
      ),
      home: const MyHomePage(),
    );
  }
}
```

When connection drops, a retro offer card slides in: *"You're offline. Play a quick game while you wait?"*. Tapping **Play** launches the arcade! When connection returns, a top banner offers to keep playing or return to where you left off.

## Simulator Testing

Simulate offline immediately without touching your Wi-Fi or airplane mode:

```dart
OfflineGames(
  debugForceOffline: true, // Instant offline test mode
  child: child!,
)
```

## Modes

Select how players discover games with `mode`:

### 1. Spin Mode (Default)

Animated slot machine wheel with no-repeat selection:

```dart
OfflineGames(
  mode: const GamesMode.spin(),
  child: child!,
)
```

### 2. Picker Catalog Mode

8-bit catalog grid with high scores:

```dart
OfflineGames(
  mode: const GamesMode.picker(),
  child: child!,
)
```

### 3. Single Game Mode

Launches directly into one specific game:

```dart
OfflineGames(
  mode: const GamesMode.single(SnakeGame()),
  child: child!,
)
```

## Theming

Supports **Dark**, **Light**, and **System** brightness out of the box:

```dart
OfflineGames(
  themeMode: ThemeMode.system, // ThemeMode.dark, ThemeMode.light, or ThemeMode.system
  // Optional custom palette overrides:
  theme: OfflineGamesTheme.dark(
    primaryColor: const Color(0xFF00F0FF),
  ),
  child: child!,
)
```

## Standalone APIs

Launch or control the arcade anywhere in your app:

```dart
// 1. Imperative modal route
showOfflineGames(context);

// 2. Programmatic controller
final controller = OfflineGamesController();
OfflineGames(controller: controller, child: child!);

controller.open();       // Open arcade UI
controller.close();      // Close arcade UI
controller.suppress();   // Mute during checkout / payments
controller.allow();      // Re-enable automatic triggers

// 3. Standalone widgets
GameSpinner(games: GameCatalog.builtIn, onResult: (g) => print(g.meta.title));
GamePicker(games: GameCatalog.builtIn, onSelected: (g) => print(g.meta.title));
GamePlayer(game: const BreakoutGame(), onExit: () => Navigator.pop(context));
```

## Built-in Games

| Game | ID | Genre | Description |
|---|---|---|---|
| **Breakout** | `breakout` | Action | Ball deflection physics, rainbow bricks, and tactile paddle steer. |
| **Memory Match** | `memory_match` | Puzzle | 4x4 card flip challenge with authentic vector glyph sprites. |
| **Snake** | `snake` | Arcade | Nokia-style classic serpent with directional swipes and D-pad. |

## Shared Retro Primitives

Exported for use in your own custom views:

- **`PixelText`**: 5x7 vector bitmask text with scaling and word-wrap. Zero font assets.
- **`PixelGlyphWidget`**: 8-bit glyph icons (`alien`, `apple`, `heart`, `star`, `sword`, `trophy`, `cloud`).
- **`RetroPixelCard`**: High-contrast cards with solid black borders and stepped drop shadows.
- **`RetroPixelButton`**: Chunky 8-bit tactile pressable arcade buttons.
- **`CrtScanlinesOverlay`**: CRT monitor overlay with scanlines and vignette.

## API Reference

### `OfflineGames`

| Property | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | **required** | Root or nested widget tree |
| `mode` | `GamesMode` | `GamesMode.spin()` | Play mode (`spin`, `picker`, or `single`) |
| `themeMode` | `ThemeMode` | `ThemeMode.system` | Brightness (`system`, `dark`, or `light`) |
| `theme` | `OfflineGamesTheme?` | `null` | Custom theme colors and borders |
| `debugForceOffline` | `bool?` | `null` | Forces immediate offline state for simulator testing |
| `games` | `List<OfflineGame>?` | `GameCatalog.builtIn` | Registered games list |
| `offlineDelay` | `Duration` | `1 second` | Delay before showing offline prompt |
| `connectivity` | `ConnectivitySource?` | `DefaultConnectivitySource` | Reachability checker provider |
| `controller` | `OfflineGamesController?` | `null` | Programmatic open/close/suppress controller |

### `OfflineGamesController`

| Method / Property | Description |
|---|---|
| `isOpen` | Whether the offline arcade overlay is currently visible |
| `isSuppressed` | Whether automatic offline prompts are currently muted |
| `open()` | Programmatically opens the offline games interface |
| `close()` | Programmatically closes the offline games interface |
| `suppress()` | Temporarily silences prompts (e.g. during payment flows) |
| `allow()` | Restores automatic offline prompts after suppression |

## Running the example

```bash
cd example
flutter run
```

## Contributing

PRs and new games are welcome! See [< 1 Hour Contribution Guide](doc/CONTRIBUTING_GAMES.md).

## License

Made with 💛 by [aslamambiloly](https://github.com/aslamambiloly) © 2026
