# offline_games

A pure-Flutter package that gives any app a tiny arcade when the network drops.

[![pub package](https://img.shields.io/pub/v/offline_games.svg)](https://pub.dev/packages/offline_games)
[![CI](https://github.com/aslamambiloly/offline_games/actions/workflows/ci.yaml/badge.svg)](https://github.com/aslamambiloly/offline_games/actions/workflows/ci.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Drop it in once and, with **zero configuration**, your app shows a non-intrusive, dismissible arcade card when the device goes offline. The user taps **Spin** and a random mini-game opens!

---

## Features

- 🎮 **Zero Config**: Wrap your app in `OfflineGames(child: child!)` and you're done.
- 🎰 **Spin or Picker**: Choose between a random lucky spin, a game catalog grid, or a single forced game.
- 📴 **Truly Offline**: Built-in games run locally without network, binary assets, or heavy game engines.
- 🏆 **Author Attribution**: Every game openly credits its creator inside the UI.
- 🛡️ **App-Safe**: Dismissible, non-blocking, and suppressible during critical business flows (e.g., checkout).

---

## Getting Started

Add `offline_games` to your `pubspec.yaml`:

```yaml
dependencies:
  offline_games: ^0.1.0
```

### 1. Zero Config (Default)

```dart
MaterialApp(
  builder: (context, child) => OfflineGames(child: child!),
  home: const HomePage(),
);
```

### 2. Picker Mode

```dart
OfflineGames(
  mode: const GamesMode.picker(),
  child: child!,
);
```

### 3. Standalone Widgets

```dart
GameSpinner(
  games: GameCatalog.builtIn,
  onResult: (game) => ...,
);
```

---

## Contributing Games

Want to ship a mini-game to thousands of Flutter apps? Check out [CONTRIBUTING_GAMES.md](doc/CONTRIBUTING_GAMES.md) — you can contribute a game in under an hour!

---

## License

MIT © [Aslam Ambiloly](https://github.com/aslamambiloly)
