import 'tic_tac_toe_state.dart';

/// Finds the optimal move index (0-8) for [aiPlayer] using the minimax algorithm.
int findBestMove(TicTacToeState state, {required Player aiPlayer}) {
  assert(!state.isGameOver, 'Cannot find best move for a finished game');
  assert(state.currentTurn == aiPlayer,
      "It must be the AI's turn to compute a move");

  int bestScore = -1000;
  int bestMove = -1;

  for (var i = 0; i < 9; i++) {
    if (state.board[i] == BoardCell.empty) {
      final nextState = state.makeMove(i);
      final score = _minimax(
        nextState,
        depth: 0,
        isMaximizing: false,
        aiPlayer: aiPlayer,
      );
      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }
  }

  assert(bestMove != -1, 'Minimax must locate a valid empty cell move');
  return bestMove;
}

int _minimax(
  TicTacToeState state, {
  required int depth,
  required bool isMaximizing,
  required Player aiPlayer,
}) {
  final winner = state.winner;
  if (winner == aiPlayer) {
    return 10 - depth;
  } else if (winner != null) {
    return depth - 10;
  } else if (state.isDraw) {
    return 0;
  }

  if (isMaximizing) {
    int maxEval = -1000;
    for (var i = 0; i < 9; i++) {
      if (state.board[i] == BoardCell.empty) {
        final nextState = state.makeMove(i);
        final evaluation = _minimax(
          nextState,
          depth: depth + 1,
          isMaximizing: false,
          aiPlayer: aiPlayer,
        );
        if (evaluation > maxEval) {
          maxEval = evaluation;
        }
      }
    }
    return maxEval;
  } else {
    int minEval = 1000;
    for (var i = 0; i < 9; i++) {
      if (state.board[i] == BoardCell.empty) {
        final nextState = state.makeMove(i);
        final evaluation = _minimax(
          nextState,
          depth: depth + 1,
          isMaximizing: true,
          aiPlayer: aiPlayer,
        );
        if (evaluation < minEval) {
          minEval = evaluation;
        }
      }
    }
    return minEval;
  }
}
