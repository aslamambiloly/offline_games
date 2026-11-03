import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/src/core/game_session.dart';
import 'package:offline_games/src/games/breakout/breakout_game.dart';
import 'package:offline_games/src/games/breakout/ui/breakout_widget.dart';

void main() {
  group('BreakoutWidget', () {
    late ValueNotifier<bool> pausedNotifier;
    late List<int> reportedScores;

    setUp(() {
      pausedNotifier = ValueNotifier<bool>(false);
      reportedScores = <int>[];
    });

    tearDown(() {
      pausedNotifier.dispose();
    });

    testWidgets('renders game arena, scoreboard, and steering buttons',
        (tester) async {
      const game = BreakoutGame();
      final session = GameSession(
        bestScore: 450,
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

      // Scoreboard elements
      expect(find.byType(BreakoutWidget), findsOneWidget);
      expect(find.text('Score: 0'), findsOneWidget);
      expect(find.text('Best: 450'), findsOneWidget);
      expect(find.text('TAP OR DRAG TO LAUNCH'), findsOneWidget);

      // Arena & Controls
      expect(find.byKey(const ValueKey('breakout_arena')), findsOneWidget);
      expect(find.byKey(const ValueKey('breakout_steer_left')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('breakout_steer_right')), findsOneWidget);
      expect(find.byKey(const ValueKey('breakout_launch_btn')), findsOneWidget);
    });

    testWidgets('tapping steer buttons and launch button interacts with state',
        (tester) async {
      const game = BreakoutGame();
      final session = GameSession(
        bestScore: null,
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

      // Tap steer left
      await tester.tap(find.byKey(const ValueKey('breakout_steer_left')));
      await tester.pump();

      // Tap steer right
      await tester.tap(find.byKey(const ValueKey('breakout_steer_right')));
      await tester.pump();

      // Tap launch
      await tester.tap(find.byKey(const ValueKey('breakout_launch_btn')));
      await tester.pump();

      // Launch prompt should disappear after launch
      expect(find.text('TAP OR DRAG TO LAUNCH'), findsNothing);
    });

    testWidgets('pause stops physics updates and score reporting',
        (tester) async {
      const game = BreakoutGame();
      pausedNotifier.value = true; // PAUSED

      final session = GameSession(
        bestScore: 200,
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

      // Tap arena while paused
      await tester.tap(find.byKey(const ValueKey('breakout_arena')));
      await tester.pump(const Duration(milliseconds: 100));

      // Should not have launched because paused
      expect(find.text('TAP OR DRAG TO LAUNCH'), findsOneWidget);
      expect(reportedScores, isEmpty);
    });
  });
}
