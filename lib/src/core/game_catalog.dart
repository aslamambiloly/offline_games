import '../games/tic_tac_toe/tic_tac_toe_game.dart';
import 'offline_game.dart';

/// Built-in registry of official games shipped with `offline_games`.
abstract final class GameCatalog {
  /// The collection of built-in games.
  static const List<OfflineGame> builtIn = <OfflineGame>[
    TicTacToeGame(),
  ];
}
