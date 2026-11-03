import 'package:flutter/widgets.dart';
import '../../core/author.dart';
import '../../core/game_meta.dart';
import '../../core/game_session.dart';
import '../../core/offline_game.dart';
import 'ui/breakout_widget.dart';

/// Offline implementation of the retro Breakout brick-breaker arcade game.
class BreakoutGame extends OfflineGame {
  /// Creates a [BreakoutGame].
  const BreakoutGame();

  @override
  GameMeta get meta => const GameMeta(
        id: 'breakout',
        title: 'Breakout',
        emoji: '🧱',
        description:
            'Bounce the pixel ball to smash glowing brick walls and clear the grid.',
        version: '1.0.0',
        tags: ['arcade', 'retro', 'action'],
        authors: [
          GameAuthor(
            name: 'Aslam Ambiloly',
            github: 'aslamambiloly',
          ),
        ],
      );

  @override
  Widget build(BuildContext context, GameSession session) {
    return BreakoutWidget(session: session);
  }
}
