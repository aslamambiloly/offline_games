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

A plug-and-play, zero-config mini arcade for Flutter applications when the device goes offline. Features an **authentic 8-bit neo-brutalist aesthetic**, **slot machine spinner**, **arcade catalog picker**, **real reachability detection**, and **pure vector graphics** with zero engine bloat (< 120 KB).

## The Offline Dread
Everyone knows the sinking feeling of losing internet connection. For some it was the Chrome dinosaur, for some the classic Nokia 3310 Snake under the school desk, for some blowing dust out of an NES cartridge, and for modern users it is the dread of a frozen spinner on an airplane 🥲. If you want to turn that dreadful offline moment into pure retro delight, you are in the right place. Welcome to the mini-arcade built right into your Flutter app!

## Happy News : )

<!-- > [!NOTE] -->
> `offline_games` is implemented entirely in **pure Dart and Flutter**. So don't worry about:
> - **iOS Swift Package Manager (SPM)**: 100% compatible. Requires no CocoaPods, native frameworks, or SPM configuration.
> - **Android Gradle Plugin (AGP 8.0+ / 9.0+)**: 100% immune to Kotlin Gradle Plugin (KGP) deprecations and breaking changes.
> - **Zero Heavy Engines**: No Flame, Unity, or Godot. Package archive is under **120 KB**.
> - **Zero Font Overhead**: No `.ttf` or `.otf` assets. Pure 5x7 vector bitmask typography compiled in code.
> - **Zero Binary Assets**: All arcade sprites, CRT overlays, and pixel glyphs render via Flutter `Canvas` and `CustomPainter`.

## Features

- **Just 1 line of code** to wrap your app in `MaterialApp.builder`
- **Authentic 8-bit neo-brutalist aesthetic** with CRT scanlines, 5x7 vector font, and solid black borders
- **Real reachability detection** (DNS lookup ping, not just Wi-Fi toggle) with debouncing
- **3 Presentation Modes**: Retro slot machine Spin, Catalog Grid, or Direct Single Game
- **Interactive Offline and Online Restoration popups** with pixel cloud wipe transitions
- **Instant Simulator Testing** via `debugForceOffline: true` (no airplane mode required)
- **Built-in Games**: Classic Snake, Memory Match, and Retro Breakout
- **Fully Customizable Themes**: Neo-brutalist light, dark, and custom palettes
- **Zero dependencies beyond Flutter** (featherweight < 120 KB)

## Table of Contents

- [Installation](#installation)
- [Quick start](#quick-start)
- [Instant Simulator Testing](#instant-simulator-testing)
- [Presentation Modes](#presentation-modes)
  - [1. Spin Mode (Default)](#1-spin-mode-default)
  - [2. Picker Catalog Mode](#2-picker-catalog-mode)
  - [3. Single Game Mode](#3-single-game-mode)
- [Customisation & Theming](#customisation--theming)
  - [Dark Mode & Light Mode](#dark-mode--light-mode)
  - [Custom Neo-Brutalist Theme](#custom-neo-brutalist-theme)
- [Standalone APIs & Custom Triggers](#standalone-apis--custom-triggers)
  - [Imperative Launcher (`showOfflineGames`)](#imperative-launcher-showofflinegames)
  - [Controller Control (`OfflineGamesController`)](#controller-control-offlinegamescontroller)
  - [Suppressing on Critical Screens](#suppressing-on-critical-screens)
  - [Standalone Widgets](#standalone-widgets)
- [Built-in Games](#built-in-games)
- [Shared Retro Primitives](#shared-retro-primitives)
- [AI Pair Programming (`llms.txt`)](#ai-pair-programming-llmstxt)
- [API Reference](#api-reference)
  - [`OfflineGames`](#offlinegames)
  - [`OfflineGamesTheme`](#offlinegamestheme)
  - [`OfflineGamesController`](#offlinegamescontroller)
- [Running the example](#running-the-example)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  offline_games: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Quick start

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

When internet connectivity drops, a sleek retro offer card slides in: *"You're offline. Play a quick game while you wait?"*. Tapping **Play** launches the arcade spinner! When connection is restored, a subtle top banner appears letting the player keep playing or return to the app.

## Instant Simulator Testing

Set `debugForceOffline: true` on `OfflineGames` to simulate an immediate offline episode without toggling Wi-Fi or airplane mode:

```dart
OfflineGames(
  debugForceOffline: true, // Forces the offline arcade prompt immediately
  child: child!,
)
```

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

Presents a clean 8-bit grid of all available games with high scores:

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

## Customisation & Theming

### Dark Mode & Light Mode

`OfflineGames` features a balanced neo-brutalist 8-bit aesthetic that adapts seamlessly across dark and light modes via `themeMode`:

- **Dark Mode (`ThemeMode.dark`)**: Pure black (`#000000`) screen background with high-contrast white arcade cards, solid black borders, and authentic vibrant retro vector sprites.
- **Light Mode (`ThemeMode.light`)**: Pure white (`#FFFFFF`) screen background with crisp neo-brutalist cards and solid black borders.
- **System Mode (`ThemeMode.system`)**: Automatically follows device brightness (default).

```dart
OfflineGames(
  themeMode: ThemeMode.system, // ThemeMode.dark, ThemeMode.light, or ThemeMode.system
  child: child!,
)
```

### Custom Neo-Brutalist Theme

You can customize accent colors, card corners, and backgrounds via `OfflineGamesTheme`:

```dart
OfflineGames(
  theme: OfflineGamesTheme.dark(
    primaryColor: const Color(0xFF00F0FF),
    cardColor: const Color(0xFFFFFFFF),
    backgroundColor: const Color(0xFF000000),
  ),
  child: child!,
)
```

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

OfflineGames(
  controller: controller,
  child: child!,
)

// Open or close programmatically:
controller.open();
controller.close();

// Suppress automatic prompts during checkout:
controller.suppress();
controller.allow();
```

### Suppressing on Critical Screens

Prevent games from popping up during sensitive flows like payments or camera capture:

```dart
final controller = OfflineGamesController();

// When entering checkout:
controller.suppress();

// When checkout finishes:
controller.allow();
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

## Built-in Games

| Game | ID | Genre | Description |
|---|---|---|---|
| **Breakout** | `breakout` | Action | Bounce the pixel ball to smash glowing brick walls and clear the grid. Features angle deflection physics, multi-lives, rainbow brick rows, and touch steering. |
| **Memory Match** | `memory_match` | Puzzle | Flip and match 8-bit pixel cards with the fewest possible moves. Features vibrant glyph vectors, turn scoring, and stage cleared celebration. |
| **Snake** | `snake` | Arcade | Navigate the grid, collect apples, and grow without colliding. Classic Nokia-style retro arcade snake with smooth motion, directional swipes, and tactile D-pad controls. |

## Shared Retro Primitives

The package exports its complete set of vector arcade UI primitives for you to use in your own views:

- **`PixelText`**: Pure vector 5x7 bitmask typography at any scale with word wrapping and optional phosphor glow. Zero font assets required.
- **`PixelGlyphWidget`**: 8-bit vector glyphs (`alien`, `apple`, `heart`, `star`, `sword`, `trophy`, `cloud`, `coin`, `arrowUp`, etc.).
- **`RetroPixelCard`**: Stepped hard-shadow pixel cards with solid black borders.
- **`RetroPixelButton`**: Chunky 8-bit pushable arcade buttons with tactile press mechanics.
- **`CrtScanlinesOverlay`**: CRT monitor overlay with subtle scanlines and radial perimeter vignette.

## AI Pair Programming (`llms.txt`)

This package includes a dedicated [`llms.txt`](llms.txt) at the root of the repository, structured specifically for AI coding assistants (GitHub Copilot, Cursor, Gemini, Claude, ChatGPT).

It provides agents with:
- Exact architecture contracts (`OfflineGame`, `GameSession`, `ConnectivitySource`).
- Strict 100% pixel vector rules (preventing unwanted `.ttf` or `Icons.*` imports).
- Verification test recipes for zero-regression game development.

## API Reference

### `OfflineGames`

| Property | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | **required** | The root or nested widget tree of the host app |
| `mode` | `GamesMode` | `GamesMode.spin()` | Presentation mode (`spin`, `picker`, or `single`) |
| `themeMode` | `ThemeMode` | `ThemeMode.system` | Brightness mode (`system`, `dark`, or `light`) |
| `theme` | `OfflineGamesTheme?` | `null` | Optional custom theme configuration |
| `debugForceOffline` | `bool?` | `null` | Forces immediate offline simulation for testing without turning off Wi-Fi |
| `games` | `List<OfflineGame>?` | `GameCatalog.builtIn` | List of available games |
| `trigger` | `OfflineTrigger` | `OfflineTrigger.auto` | Trigger strategy (`auto` or `manual`) |
| `offlineDelay` | `Duration` | `Duration(seconds: 1)` | Debounce delay before confirming device is offline |
| `connectivity` | `ConnectivitySource?` | `DefaultConnectivitySource` | Reachability source provider |
| `scoreStore` | `ScoreStore?` | `MemoryScoreStore` | Persistent store for high scores |
| `controller` | `OfflineGamesController?` | `null` | Controller to programmatically open, close, or suppress arcade UI |

### `OfflineGamesTheme`

| Property | Type | Default | Description |
|---|---|---|---|
| `primaryColor` | `Color?` | `#00F0FF` (dark) / `#000000` (light) | Primary accent color |
| `cardColor` | `Color?` | `#000000` (dark) / `#FFFFFF` (light) | Card background color |
| `backgroundColor` | `Color?` | `#000000` (dark) / `#FFFFFF` (light) | Arcade screen background color |
| `borderRadius` | `BorderRadius` | `BorderRadius.circular(4)` | Corner radius for retro cards and frames |
| `accentGradient` | `Gradient?` | built-in linear gradient | Optional vibrant arcade gradient |

### `OfflineGamesController`

| Method / Property | Type | Description |
|---|---|---|
| `isOpen` | `bool` | Whether the offline arcade overlay is currently open |
| `isSuppressed` | `bool` | Whether automatic offline prompts are currently suppressed |
| `open()` | `void` | Programmatically opens the offline games interface |
| `close()` | `void` | Programmatically closes the offline games interface |
| `suppress()` | `void` | Suppresses automatic offline prompts (e.g. during checkout/payment flows) |
| `allow()` | `void` | Restores automatic offline prompts after suppression |

## Running the example

```bash
cd example
flutter run
```

## Contributing

PRs and issues are welcome! Please open an issue first for significant changes. See [CONTRIBUTING_GAMES.md](doc/CONTRIBUTING_GAMES.md) for adding new mini-games in under 1 hour.

## License

Made with 💛 by [aslamambiloly](https://github.com/aslamambiloly) © 2026
