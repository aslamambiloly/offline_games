import 'package:flutter/widgets.dart';
import '../../core/author.dart';
import '../../core/game_meta.dart';
import '../../core/game_session.dart';
import '../../core/offline_game.dart';
import 'ui/tic_tac_toe_widget.dart';

/// Offline implementation of the classic Tic Tac Toe mini-game.
class TicTacToeGame extends OfflineGame {
  /// Creates a [TicTacToeGame].
  const TicTacToeGame();

  @override
  GameMeta get meta => const GameMeta(
        id: 'tic_tac_toe',
        title: 'Tic Tac Toe',
        emoji: '❌',
        description:
            'Classic 3x3 grid challenge against an unbeatable minimax arcade AI.',
        version: '1.0.0',
        tags: ['puzzle', 'strategy', 'classic'],
        authors: [
          GameAuthor(
            name: 'Aslam Ambiloly',
            github: 'aslamambiloly',
          ),
        ],
      );

  @override
  Widget build(BuildContext context, GameSession session) {
    return TicTacToeWidget(session: session);
  }
}
