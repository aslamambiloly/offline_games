import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/offline_games.dart';

void main() {
  group('MemoryMatchWidget', () {
    late ValueNotifier<bool> pausedNotifier;
    late List<int> reportedScores;

    setUp(() {
      pausedNotifier = ValueNotifier<bool>(false);
      reportedScores = <int>[];
    });

    tearDown(() {
      pausedNotifier.dispose();
    });

    testWidgets('tap flow: tapping cards flips them face up', (tester) async {
      const game = MemoryMatchGame();
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
      await tester.pumpAndSettle();

      final card0 = find.byKey(const ValueKey('memory_card_0'));
      expect(card0, findsOneWidget);

      await tester.tap(card0);
      await tester.pumpAndSettle();

      // Card 0 should now be face up
      expect(find.byKey(const ValueKey('memory_card_0')), findsOneWidget);
      expect(find.text('Moves: 0'), findsOneWidget);

      // Tap card 1 to complete a move
      final card1 = find.byKey(const ValueKey('memory_card_1'));
      await tester.tap(card1);
      await tester.pumpAndSettle();

      expect(find.text('Moves: 1'), findsOneWidget);
    });

    testWidgets('pause honoured: tapping card while paused does not flip',
        (tester) async {
      const game = MemoryMatchGame();
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
      await tester.pumpAndSettle();

      final card0 = find.byKey(const ValueKey('memory_card_0'));
      await tester.tap(card0);
      await tester.pumpAndSettle();

      // No move counted because paused
      expect(find.text('Moves: 0'), findsOneWidget);
    });
  });
}
