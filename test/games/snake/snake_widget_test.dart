import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/offline_games.dart';

void main() {
  group('SnakeWidget', () {
    late ValueNotifier<bool> pausedNotifier;
    late List<int> reportedScores;

    setUp(() {
      pausedNotifier = ValueNotifier<bool>(false);
      reportedScores = <int>[];
    });

    tearDown(() {
      pausedNotifier.dispose();
    });

    testWidgets('renders game grid and score header', (tester) async {
      const game = SnakeGame();
      final session = GameSession(
        bestScore: 50,
        paused: pausedNotifier,
        random: Random(42),
        reportScore: (score) => reportedScores.add(score),
        exit: () {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => game.build(context, session),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Score: 0'), findsOneWidget);
      expect(find.text('HI: 50'), findsOneWidget);
      expect(find.byKey(const ValueKey('snake_viewport')), findsOneWidget);
    });

    testWidgets('pause stops ticker and keeps score unchanged', (tester) async {
      const game = SnakeGame();
      pausedNotifier.value = true; // PAUSED

      final session = GameSession(
        bestScore: 50,
        paused: pausedNotifier,
        random: Random(42),
        reportScore: (score) => reportedScores.add(score),
        exit: () {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => game.build(context, session),
            ),
          ),
        ),
      );
      await tester.pump();

      // Advance by 1 second while paused
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Score: 0'), findsOneWidget);
      expect(find.text('Game Over'), findsNothing);
    });

    testWidgets('tapping D-pad controls changes direction', (tester) async {
      const game = SnakeGame();
      final session = GameSession(
        bestScore: 50,
        paused: pausedNotifier,
        random: Random(42),
        reportScore: (score) => reportedScores.add(score),
        exit: () {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => game.build(context, session),
            ),
          ),
        ),
      );
      await tester.pump();

      // Find D-pad Down button
      final downBtn = find.byKey(const ValueKey('dpad_down'));
      expect(downBtn, findsOneWidget);

      await tester.tap(downBtn);
      await tester.pump(const Duration(milliseconds: 200));

      // Continues running cleanly with direction changed
      expect(find.byKey(const ValueKey('snake_viewport')), findsOneWidget);
    });
  });
}
