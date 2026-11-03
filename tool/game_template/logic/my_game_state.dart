import 'dart:math';

/// Pure-Dart logic state for the game.
/// Keep all game rules here without any Flutter/BuildContext dependencies.
class MyGameState {
  final int score;
  final bool isGameOver;

  const MyGameState({
    this.score = 0,
    this.isGameOver = false,
  });

  /// Factory for initial state using injected [Random].
  factory MyGameState.initial(Random random) {
    return const MyGameState();
  }

  /// Example action that updates game state.
  MyGameState performAction() {
    if (isGameOver) return this;
    return MyGameState(
      score: score + 10,
      isGameOver: false,
    );
  }

  /// Example end game.
  MyGameState triggerGameOver() {
    return MyGameState(
      score: score,
      isGameOver: true,
    );
  }
}
