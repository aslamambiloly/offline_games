# Contributing to `offline_games` 🕹️👾

Thank you for your interest in contributing to **`offline_games`**! We welcome new mini-games, bug fixes, and performance enhancements from both human developers and their AI coding assistants.

To maintain a cohesive, stunning, and resource-efficient arcade experience, all contributions must strictly adhere to the **Retro Pixel Vector Design System** and **Architecture Contracts** outlined below.

---

## 🎨 1. The Retro Pixel Vector Design System

Every mini-game in `offline_games` lives inside an authentic 1980s vintage CRT arcade universe. We enforce **zero external font assets** and **zero runtime icon dependencies**.

### ⚠️ Strict Design Rules (Enforced by Automated CI Linting):
1. **NO External Font Files (`.ttf` / `.otf` / `.woff`)**:
   - The package footprint must remain microscopic (< 100 KB total). Never add font files to `pubspec.yaml`.
2. **NO Material Icons (`Icons.*`)**:
   - Standard Flutter Material/Cupertino icons clash with the vintage theme. Do not import or render `Icons.*`.
3. **NO Raw Emojis in Game UI**:
   - Do not display emoji glyphs (`🍎`, `🚀`, `🔥`, etc.) in game viewports or text. Emojis render inconsistently across Android and iOS versions and break the retro immersion.
4. **NO Double Underlines / Text Decorations**:
   - Wrap interactive cards with `RetroPixelCard` or `Material(type: MaterialType.transparency)` to ensure clean visual rendering.

---

## 🛠️ 2. Core UI Components to Use

The package provides a built-in suite of retro pixel vector primitives:

### `PixelText`
Draws authentic 5×7 bitmask pixel typography at any scale with dynamic word wrapping and optional CRT phosphor glow.
```dart
PixelText(
  'HIGH SCORE: 4200',
  pixelSize: 2.0,
  color: Color(0xFF39FF14),     // Neon Green
  glowColor: Color(0xFF39FF14), // Optional glow
  textAlign: TextAlign.center,
)
```

### `PixelGlyphWidget`
Draws pure vector 8-bit glyphs (controllers, alien invaders, stars, swords, potions, directional arrows, etc.) using custom canvas shaders:
```dart
PixelGlyphWidget(
  type: PixelGlyphType.alien, // or .star, .sword, .arrowLeft, .gamepad
  pixelSize: 3.0,
  color: Color(0xFF00F0FF),  // Neon Cyan
  glow: true,
)
```
> **Tip:** If your game requires a new pixel sprite, add its 8×8 or 10×10 bitmask array to `PixelGlyphType` in `lib/src/ui/retro_pixel_glyph.dart`.

### `RetroPixelCard` & `RetroPixelButton`
Stepped hard-shadow pixel cards and beveled tactile arcade pushbuttons:
```dart
RetroPixelButton(
  label: 'FIRE',
  pixelSize: 1.8,
  color: Color(0xFF39FF14),
  textColor: Colors.black,
  onPressed: () => _fireLaser(),
)
```

### `CrtScanlinesOverlay`
Adds phosphor scanlines and radial perimeter vignette to your viewport:
```dart
CrtScanlinesOverlay(
  scanlineOpacity: 0.10,
  child: GameViewport(...),
)
```

---

## 🎨 3. Color Tokens

| Token | Hex Value | Usage |
|---|---|---|
| **CRT Dark (Default)** | `#000000` or `#0D101C` | Screen backgrounds, CRT canvas |
| **Neon Cyan** | `#00F0FF` | Primary arcade frames, player ships, titles |
| **Neon Green** | `#39FF14` | High scores, confirm buttons, health |
| **Arcade Amber** | `#FFB800` | Warning, pause screens, gold coins |
| **Retro Red** | `#FF0055` | Game over, enemy invaders, hazards |
| **Muted Text** | `#8E9CB8` | Secondary labels, descriptions |

---

## 🏗️ 4. Game Architecture Contracts

Every mini-game must live in its own directory under `lib/src/games/<game_name>/` and follow strict separation of concerns:

```text
lib/src/games/<your_game>/
├── <your_game>_game.dart        # Implements OfflineGame & metadata
├── logic/
│   └── <your_game>_state.dart   # 100% Pure Dart simulation (0 Flutter imports)
└── ui/
    ├── <your_game>_painter.dart # CustomPainter rendering (if canvas-based)
    └── <your_game>_widget.dart  # Responsive Flutter Widget
```

### Key Requirements:
1. **Pure Dart Logic**: The state machine in `logic/` must have **zero Flutter UI imports** (`import 'package:flutter/...'` is forbidden in `logic/`). This allows 100% deterministic unit testing with simulated ticks.
2. **Metadata & Attribution**:
   ```dart
   @override
   GameMeta get meta => const GameMeta(
     id: 'my_game',
     title: 'Space Cadet',
     emoji: '🚀', // Fallback identifier
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
   - Read `session.paused` to pause physics and timers when the user pauses or app enters background.
   - Call `session.reportScore(score)` when completing a run or scoring.
   - Honor `session.exit` when players tap the back button.
4. **Resource Discipline**: All `AnimationController`s, `Timer`s, and `Ticker`s must be cancelled/disposed in `dispose()`.

---

## 🤖 5. Instructions for AI Coding Assistants (Copilot, Claude, Gemini, etc.)

When writing a new game for `offline_games`, always remember:
- **Do not import Material Icons.** Use `PixelGlyphWidget` or draw custom vectors on `Canvas`.
- **Do not use standard `Text()` widgets.** Use `PixelText()`.
- **Do not import external packages.** All games must run on pure Flutter without third-party dependencies.
- **Ensure responsive sizing.** Design games to scale gracefully from compact mobile screens (320px width) to tablets and web.

---

## ✅ 6. Automated Verification Before Submitting

Run these commands locally before opening a pull request:

```bash
# 1. Verify pixel vector compliance (no Material icons or emojis in UI)
dart run tool/check_pixel_theme.dart

# 2. Verify author metadata compliance
flutter test tool/check_authors.dart

# 3. Verify static analysis (zero warnings, zero lints)
flutter analyze --fatal-infos

# 4. Run the entire automated test suite
flutter test
```

All 4 checks must pass cleanly! 🚀
