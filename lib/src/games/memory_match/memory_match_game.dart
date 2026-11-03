import 'package:flutter/widgets.dart';
import '../../core/author.dart';
import '../../core/game_meta.dart';
import '../../core/game_session.dart';
import '../../core/offline_game.dart';
import 'ui/memory_match_widget.dart';

/// Offline implementation of the Memory Match card pairing mini-game.
class MemoryMatchGame extends OfflineGame {
  /// Creates a [MemoryMatchGame].
  const MemoryMatchGame();

  @override
  GameMeta get meta => const GameMeta(
        id: 'memory_match',
        title: 'Memory Match',
        emoji: '🃏',
        description:
            'Flip and match emoji pairs with the fewest possible moves.',
        version: '1.0.0',
        tags: ['puzzle', 'memory', 'cards'],
        authors: [
          GameAuthor(
            name: 'Aslam Ambiloly',
            github: 'aslamambiloly',
          ),
        ],
      );

  @override
  Widget build(BuildContext context, GameSession session) {
    return MemoryMatchWidget(session: session);
  }
}
