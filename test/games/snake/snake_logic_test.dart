import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/src/games/snake/logic/snake_state.dart';

void main() {
  group('SnakeState logic', () {
    test('initial state produces valid snake and food on empty position', () {
      final random = Random(42);
      final state = SnakeState.initial(
        random: random,
        gridWidth: 10,
        gridHeight: 10,
      );

      expect(state.body, isNotEmpty);
      expect(state.direction, equals(Direction.right));
      expect(state.score, equals(0));
      expect(state.isGameOver, isFalse);
      // Food cannot spawn on snake's body
      expect(state.body.contains(state.food), isFalse);
    });

    test('step moves head forward and tail follows', () {
      final random = Random(1);
      const state = SnakeState(
        gridWidth: 10,
        gridHeight: 10,
        body: [
          GridPosition(5, 5),
          GridPosition(4, 5),
          GridPosition(3, 5),
        ],
        direction: Direction.right,
        food: GridPosition(8, 8),
        score: 0,
      );

      final nextState = state.step(random: random);
      expect(nextState.body.first, equals(const GridPosition(6, 5)));
      expect(nextState.body[1], equals(const GridPosition(5, 5)));
      expect(nextState.body[2], equals(const GridPosition(4, 5)));
      expect(nextState.body.length, equals(3));
      expect(nextState.isGameOver, isFalse);
    });

    test('cannot reverse directly into opposite direction', () {
      const state = SnakeState(
        gridWidth: 10,
        gridHeight: 10,
        body: [GridPosition(5, 5), GridPosition(4, 5)],
        direction: Direction.right,
        food: GridPosition(8, 8),
        score: 0,
      );

      // Attempt reverse to left
      final reversed = state.changeDirection(Direction.left);
      expect(reversed.direction, equals(Direction.right)); // ignored!

      // Turning up is valid
      final turnedUp = state.changeDirection(Direction.up);
      expect(turnedUp.direction, equals(Direction.up));
    });

    test('eating food increments score and grows body', () {
      final random = Random(2);
      const state = SnakeState(
        gridWidth: 10,
        gridHeight: 10,
        body: [
          GridPosition(5, 5),
          GridPosition(4, 5),
        ],
        direction: Direction.right,
        food: GridPosition(6, 5), // Food directly ahead
        score: 0,
      );

      final nextState = state.step(random: random);
      expect(nextState.body.first, equals(const GridPosition(6, 5)));
      expect(nextState.body.length, equals(3)); // Grew by 1
      expect(nextState.score, equals(10));
      expect(nextState.food, isNot(equals(const GridPosition(6, 5))));
    });

    test('colliding with wall triggers game over', () {
      final random = Random(3);
      const state = SnakeState(
        gridWidth: 10,
        gridHeight: 10,
        body: [GridPosition(9, 5), GridPosition(8, 5)],
        direction: Direction.right, // Will hit right wall (x=10)
        food: GridPosition(0, 0),
        score: 0,
      );

      final nextState = state.step(random: random);
      expect(nextState.isGameOver, isTrue);
    });

    test('colliding with self triggers game over', () {
      final random = Random(4);
      // Snake shaped in a loop:
      // (2,2) -> (2,3) -> (1,3) -> (1,2) -> (1,1)
      // Moving left from (2,2) enters (1,2) which is in the active body!
      const state = SnakeState(
        gridWidth: 10,
        gridHeight: 10,
        body: [
          GridPosition(2, 2),
          GridPosition(2, 3),
          GridPosition(1, 3),
          GridPosition(1, 2),
          GridPosition(1, 1),
        ],
        direction: Direction.left,
        food: GridPosition(9, 9),
        score: 0,
      );

      final nextState = state.step(random: random);
      expect(nextState.isGameOver, isTrue);
    });
  });
}
