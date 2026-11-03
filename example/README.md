# offline_games Example App

An interactive demonstration showcasing all features of the [`offline_games`](https://pub.dev/packages/offline_games) package.

## Features Demonstrated

1. **Connectivity Simulation**: A built-in simulated network toggle allows testing offline detection and reconnected state transitions in real time without disabling device Wi-Fi or toggling Airplane mode.
2. **Interactive Presentation Modes**:
   - **Spin Mode**: Experience the animated lucky wheel game selector with guarantee no-repeat logic.
   - **Picker Mode**: Browse the 8-bit arcade grid catalog with high scores and author credits.
   - **Single Game Mode**: Directly launch Snake, Memory Match, or Breakout.
3. **Theme Toggling**: Seamless switching between System, Dark, and Light modes to preview the balanced neo-brutalist retro visual system.
4. **Standalone Component Previews**: Direct embedded previews of `GameSpinner`, `GamePicker`, and `GamePlayer`.
5. **Imperative Trigger**: Launching the arcade over any route via `showOfflineGames(context)`.
6. **Programmatic Controller**: Controlling the arcade overlay via `OfflineGamesController`.

## Running the Example

From the root of the repository:

```bash
cd example
flutter run
```

Or run on web:

```bash
cd example
flutter run -d chrome
```

## Quick Integration

```dart
import 'package:flutter/material.dart';
import 'package:offline_games/offline_games.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Games Demo',
      // Plug-and-play arcade overlay:
      builder: (context, child) => OfflineGames(
        child: child!,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Disconnect internet to trigger arcade!'),
        ),
      ),
    );
  }
}
```
