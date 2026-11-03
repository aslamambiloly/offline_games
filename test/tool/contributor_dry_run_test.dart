import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/offline_games.dart';
import '../../tool/game_template/my_game.dart';
import '../../tool/game_template/logic/my_game_state.dart';

void main() {
  group('Contributor Dry-Run Verification', () {
    test('game_template compiles, instantiates, and adheres to contract', () {
      const templateGame = MyGame();
      expect(templateGame.meta.id, equals('my_game'));
      expect(templateGame.meta.title, equals('My Game'));
      expect(templateGame.meta.authors.isNotEmpty, isTrue);
      expect(templateGame.meta.authors.first.name, equals('Your Name'));
      expect(() => templateGame.meta.validate(), returnsNormally);
    });

    test('template logic state performs actions cleanly', () {
      final initial = MyGameState.initial(Random(123));
      expect(initial.score, equals(0));
      expect(initial.isGameOver, isFalse);

      final updated = initial.performAction();
      expect(updated.score, equals(10));
      expect(updated.isGameOver, isFalse);

      final over = updated.triggerGameOver();
      expect(over.score, equals(10));
      expect(over.isGameOver, isTrue);
    });

    testWidgets('template UI renders and reports score on tap', (tester) async {
      const templateGame = MyGame();
      final scores = <int>[];
      final paused = ValueNotifier<bool>(false);

      final session = GameSession(
        bestScore: 0,
        paused: paused,
        random: Random(123),
        reportScore: (s) => scores.add(s),
        exit: () {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => templateGame.build(ctx, session),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Score: 0'), findsOneWidget);
      expect(find.text('Tap Me!'), findsOneWidget);

      await tester.tap(find.text('Tap Me!'));
      await tester.pump();

      expect(scores, contains(10));
      expect(find.text('Score: 10'), findsOneWidget);

      paused.dispose();
    });
  });
}
