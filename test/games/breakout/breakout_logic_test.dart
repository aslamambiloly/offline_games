import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/src/games/breakout/logic/breakout_state.dart';

void main() {
  group('BreakoutState logic', () {
    test('initial state produces full brick grid and paddle with 3 lives', () {
      final state = BreakoutState(random: Random(42));

      expect(state.lives, 3);
      expect(state.score, 0);
      expect(state.isLaunched, isFalse);
      expect(state.isGameOver, isFalse);
      expect(state.isWon, isFalse);
      expect(state.bricks.length, 30);
      expect(state.remainingBricks, 30);

      // Ball sits directly on top of paddle center
      expect(state.ballX, state.paddleX + BreakoutState.paddleWidth / 2);
      expect(state.ballY, state.paddleY - BreakoutState.ballRadius - 2.0);
    });

    test('paddle movement updates paddleX and tracks ball when not launched',
        () {
      final state = BreakoutState(random: Random(42));

      state.setPaddleCenter(60.0);
      expect(state.paddleX, 60.0 - BreakoutState.paddleWidth / 2);
      expect(state.ballX, state.paddleX + BreakoutState.paddleWidth / 2);

      // Clamp to left bound
      state.setPaddleCenter(-50.0);
      expect(state.paddleX, 0.0);

      // Clamp to right bound
      state.setPaddleCenter(500.0);
      expect(state.paddleX, state.arenaWidth - BreakoutState.paddleWidth);
    });

    test('launching ball allows physics update to move ball', () {
      final state = BreakoutState(random: Random(42));
      state.launch();
      expect(state.isLaunched, isTrue);

      final initialY = state.ballY;
      state.update(0.05); // 50ms step
      expect(state.ballY, isNot(equals(initialY)));
    });

    test('ball bounces off left and right arena walls', () {
      final state = BreakoutState(random: Random(42));
      state.isLaunched = true;
      state.ballX = 2.0;
      state.ballVx = -100.0;
      state.ballVy = 0.0;

      state.update(0.05);
      expect(state.ballVx, isPositive);
    });

    test('ball bounces off top arena ceiling', () {
      final state = BreakoutState(random: Random(42));
      state.isLaunched = true;
      state.ballY = 2.0;
      state.ballVx = 0.0;
      state.ballVy = -100.0;

      state.update(0.05);
      expect(state.ballVy, isPositive);
    });

    test('ball hitting bottom floor loses life and resets ball to paddle', () {
      final state = BreakoutState(random: Random(42));
      state.isLaunched = true;
      state.ballY = state.arenaHeight - 1.0;
      state.ballVy = 100.0;

      state.update(0.05);
      expect(state.lives, 2);
      expect(state.isLaunched, isFalse);
      expect(state.isGameOver, isFalse);
      expect(state.ballX, state.paddleX + BreakoutState.paddleWidth / 2);

      // Lose 2nd life
      state.isLaunched = true;
      state.ballY = state.arenaHeight - 1.0;
      state.ballVy = 100.0;
      state.update(0.05);
      expect(state.lives, 1);
      expect(state.isGameOver, isFalse);

      // Lose 3rd life -> Game Over
      state.isLaunched = true;
      state.ballY = state.arenaHeight - 1.0;
      state.ballVy = 100.0;
      state.update(0.05);
      expect(state.lives, 0);
      expect(state.isGameOver, isTrue);
    });

    test('ball bounces upward when hitting paddle', () {
      final state = BreakoutState(random: Random(42));
      state.isLaunched = true;
      state.ballX = state.paddleX + BreakoutState.paddleWidth / 2;
      state.ballY = state.paddleY - BreakoutState.ballRadius + 1.0;
      state.ballVy = 150.0; // Moving down

      state.update(0.01);
      expect(state.ballVy, isNegative); // Bounced up
    });

    test('brick collision destroys brick and awards score', () {
      final state = BreakoutState(random: Random(42));
      final brick = state.bricks.first;

      state.isLaunched = true;
      state.ballX = brick.x + brick.width / 2;
      state.ballY = brick.y + brick.height + BreakoutState.ballRadius - 1.0;
      state.ballVy = -150.0; // Moving up into brick

      state.update(0.01);
      expect(brick.isDestroyed, isTrue);
      expect(state.score, brick.points);
      expect(state.remainingBricks, 29);
      expect(state.ballVy, isPositive); // Bounced down
    });

    test('destroying all bricks triggers victory and bonus score', () {
      final state = BreakoutState(random: Random(42));
      // Destroy all but one brick
      for (int i = 1; i < state.bricks.length; i++) {
        state.bricks[i].isDestroyed = true;
      }
      expect(state.remainingBricks, 1);

      final lastBrick = state.bricks.first;
      state.isLaunched = true;
      state.ballX = lastBrick.x + lastBrick.width / 2;
      state.ballY =
          lastBrick.y + lastBrick.height + BreakoutState.ballRadius - 1.0;
      state.ballVy = -150.0;

      state.update(0.01);
      expect(state.remainingBricks, 0);
      expect(state.isWon, isTrue);
      expect(state.isGameOver, isTrue);
      expect(state.score, lastBrick.points + 200);
    });

    test('restart restores full lives, 30 bricks, and zero score', () {
      final state = BreakoutState(random: Random(42));
      state.lives = 1;
      state.score = 300;
      state.bricks.first.isDestroyed = true;
      state.isGameOver = true;

      state.restart();
      expect(state.lives, 3);
      expect(state.score, 0);
      expect(state.isGameOver, isFalse);
      expect(state.isWon, isFalse);
      expect(state.remainingBricks, 30);
    });
  });
}
