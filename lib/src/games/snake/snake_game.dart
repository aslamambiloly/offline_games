import 'package:flutter/widgets.dart';
import '../../core/author.dart';
import '../../core/game_meta.dart';
import '../../core/game_session.dart';
import '../../core/offline_game.dart';
import 'ui/snake_widget.dart';

/// Offline implementation of the retro Snake arcade game.
class SnakeGame extends OfflineGame {
  /// Creates a [SnakeGame].
  const SnakeGame();

  @override
  GameMeta get meta => const GameMeta(
        id: 'snake',
        title: 'Snake',
        emoji: '🐍',
        description:
            'Navigate the grid, collect apples, and grow without colliding.',
        version: '1.0.0',
        tags: ['arcade', 'retro', 'classic'],
        authors: [
          GameAuthor(
            name: 'Aslam Ambiloly',
            github: 'aslamambiloly',
          ),
        ],
      );

  @override
  Widget build(BuildContext context, GameSession session) {
    return SnakeWidget(session: session);
  }
}
