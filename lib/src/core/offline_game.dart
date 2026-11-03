import 'package:flutter/widgets.dart';
import 'game_meta.dart';
import 'game_session.dart';

/// Contract that every standalone offline mini-game must implement.
abstract class OfflineGame {
  /// Constant constructor for subclasses.
  const OfflineGame();

  /// Metadata describing this game (id, title, author, etc.).
  GameMeta get meta;

  /// Builds the game interface using the given [GameSession].
  Widget build(BuildContext context, GameSession session);
}
