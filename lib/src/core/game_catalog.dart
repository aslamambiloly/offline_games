import 'offline_game.dart';

/// Built-in registry of official games shipped with `offline_games`.
abstract final class GameCatalog {
  /// The collection of built-in games.
  /// Subclasses will be registered as built-in games are developed.
  static const List<OfflineGame> builtIn = <OfflineGame>[];
}
