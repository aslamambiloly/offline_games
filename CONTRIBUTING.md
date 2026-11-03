# Contributing to offline_games

Thank you for contributing to **`offline_games`**! We welcome new mini-games, bug fixes, and improvements from human developers and AI pair programmers.

All contributions must follow our **Pixel Vector Design System** and **Architecture Contracts** to keep the package featherweight (< 120 KB) and cohesive.

## Quick Checklist

- **Zero Font Files**: No `.ttf` or `.otf` assets in `pubspec.yaml`.
- **Zero Material Icons**: No `Icons.*` imports. Use `PixelGlyphWidget` or Canvas painting.
- **Zero Raw Emojis in Viewport**: Render vector glyphs, not OS emoji characters.
- **Pure Dart Game Logic**: State in `logic/` must have 0 Flutter imports for unit testing.
- **Mandatory Attribution**: Add your name, GitHub handle, and optional sponsor link to `GameMeta`.
- **Featherweight**: No third-party game engines (Flame/Unity) or audio blobs.

## Core UI Components

Use the built-in 8-bit vector primitives:

### `PixelText`
Pure vector 5x7 bitmask typography with dynamic scaling and word wrapping.
```dart
PixelText(
  'HIGH SCORE: 4200',
  pixelSize: 2.0,
  color: Color(0xFF16A34A),
  textAlign: TextAlign.center,
)
```

### `PixelGlyphWidget`
Vector 8-bit glyph sprites (`alien`, `apple`, `heart`, `star`, `sword`, `trophy`, `cloud`, `arrowUp`, etc.):
```dart
PixelGlyphWidget(
  type: PixelGlyphType.alien,
  pixelSize: 3.0,
  color: Color(0xFF00F0FF),
)
```

### `RetroPixelCard` & `RetroPixelButton`
High-contrast cards with solid black borders and tactile arcade pushbuttons:
```dart
RetroPixelButton(
  label: 'PLAY',
  pixelSize: 1.8,
  onPressed: () => _startGame(),
)
```

### `CrtScanlinesOverlay`
Adds CRT scanlines and subtle perimeter vignette to any viewport:
```dart
CrtScanlinesOverlay(
  child: GameViewport(...),
)
```

## Architecture Contracts

Place every mini-game in `lib/src/games/<game_id>/` with strict separation of logic and presentation:

```text
lib/src/games/<your_game>/
├── <your_game>_game.dart        # OfflineGame definition & metadata
├── logic/
│   └── <your_game>_state.dart   # Pure Dart simulation (0 Flutter imports)
└── ui/
    ├── <your_game>_painter.dart # CustomPainter (if canvas-based)
    └── <your_game>_widget.dart  # Responsive Flutter Widget
```

### Key Requirements

1. **Pure Dart Logic**: Zero `package:flutter/...` imports in `logic/`. All game state and rules must be unit testable with simulated ticks.
2. **Metadata & Author Credit**:
   ```dart
   @override
   GameMeta get meta => const GameMeta(
     id: 'my_game',
     title: 'Space Cadet',
     glyph: PixelGlyphType.alien,
     authors: [
       GameAuthor(
         name: 'Jane Doe',
         github: 'janedoe',
         sponsorUrl: 'https://github.com/sponsors/janedoe',
       ),
     ],
   );
   ```
3. **Session Lifecycle**:
   - Check `session.paused` to halt physics and timers when paused.
   - Call `session.reportScore(score)` to record scores.
   - Respect back navigation via `session.exit`.
4. **Resource Discipline**: Dispose all `AnimationController`s, `Timer`s, and `Ticker`s in `dispose()`.

## AI Coding Assistants

When building a game with Cursor, Copilot, Gemini, or Claude:
- Reference [`llms.txt`](llms.txt) for architecture definitions and patterns.
- Never import Material Icons or add external packages.
- Ensure the game layout adapts cleanly from 320px mobile widths to tablets and web.

## Automated Verification

Run these 4 verification commands locally before submitting a PR:

```bash
# 1. Verify pixel vector compliance (no Material icons or raw emojis in UI)
dart run tool/check_pixel_theme.dart

# 2. Verify author metadata compliance
flutter test tool/check_authors.dart

# 3. Verify static analysis
flutter analyze --fatal-infos

# 4. Run automated test suite
flutter test
```

All checks must pass with zero errors.
