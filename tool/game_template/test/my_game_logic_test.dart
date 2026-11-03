import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import '../logic/my_game_state.dart';

void main() {
  group('MyGameState logic', () {
    test('initial state produces score 0', () {
      final state = MyGameState.initial(Random(42));
      expect(state.score, equals(0));
      expect(state.isGameOver, isFalse);
    });

    test('performAction increments score', () {
      final state = MyGameState.initial(Random(42)).performAction();
      expect(state.score, equals(10));
    });

    test('triggerGameOver sets isGameOver', () {
      final state = MyGameState.initial(Random(42)).triggerGameOver();
      expect(state.isGameOver, isTrue);
    });
  });
}
