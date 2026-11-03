import '../games/breakout/breakout_game.dart';
import '../games/memory_match/memory_match_game.dart';
import '../games/snake/snake_game.dart';
import 'offline_game.dart';

/// Built-in registry of official games shipped with `offline_games`.
abstract final class GameCatalog {
  /// The collection of built-in games.
  static const List<OfflineGame> builtIn = <OfflineGame>[
    BreakoutGame(),
    MemoryMatchGame(),
    SnakeGame(),
  ];
}
