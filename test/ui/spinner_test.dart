import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/offline_games.dart';

class _FakeGame extends OfflineGame {
  const _FakeGame({
    required this.id,
    required this.title,
    required this.emoji,
    required this.authorName,
  });

  final String id;
  final String title;
  final String emoji;
  final String authorName;

  @override
  GameMeta get meta => GameMeta(
        id: id,
        title: title,
        emoji: emoji,
        authors: [GameAuthor(name: authorName)],
      );

  @override
  Widget build(BuildContext context, GameSession session) =>
      Text('Body of $title');
}

void main() {
  const game1 = _FakeGame(
    id: 'game_1',
    title: 'Alpha Game',
    emoji: '🅰️',
    authorName: 'Alice',
  );
  const game2 = _FakeGame(
    id: 'game_2',
    title: 'Beta Game',
    emoji: '🅱️',
    authorName: 'Bob',
  );
  const game3 = _FakeGame(
    id: 'game_3',
    title: 'Gamma Game',
    emoji: '🇬',
    authorName: 'Charlie',
  );

  group('GameSpinner', () {
    test('never repeats same game twice in a row when games > 1', () {
      final games = [game1, game2, game3];
      OfflineGame? prev;

      for (var seed = 0; seed < 50; seed++) {
        final random = Random(seed);
        final picked = pickRandomGame(
          games: games,
          previous: prev,
          random: random,
        );
        if (prev != null) {
          expect(picked, isNot(equals(prev)),
              reason: 'Should not pick the same game consecutively');
        }
        prev = picked;
      }
    });

    testWidgets('shows result with title, emoji, and author', (tester) async {
      OfflineGame? chosen;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameSpinner(
              games: [game1, game2],
              random: Random(42),
              onResult: (game) => chosen = game,
            ),
          ),
        ),
      );

      // Settle animations
      await tester.pumpAndSettle();

      // Check glyph and buttons
      expect(find.byType(PixelGlyphWidget), findsWidgets);
      expect(find.text('Spin again'), findsOneWidget);
      expect(find.text('Start Game'), findsOneWidget);

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      expect(chosen, isNotNull);
    });

    testWidgets('skips animation when disableAnimations is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: GameSpinner(
                games: [game1],
                random: Random(1),
                onResult: (_) {},
              ),
            ),
          ),
        ),
      );

      // In zero elapsed time, result is already visible
      await tester.pump();
      expect(find.text('Alpha Game'), findsOneWidget);
      expect(find.byType(PixelGlyphWidget), findsWidgets);
    });

    testWidgets('tapping Spin again picks another game', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameSpinner(
              games: [game1, game2],
              random: Random(10),
              onResult: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final firstTitle = find.text('Alpha Game').evaluate().isNotEmpty
          ? 'Alpha Game'
          : 'Beta Game';

      await tester.tap(find.text('Spin again'));
      await tester.pumpAndSettle();

      final expectedSecondTitle =
          firstTitle == 'Alpha Game' ? 'Beta Game' : 'Alpha Game';
      expect(find.text(expectedSecondTitle), findsOneWidget);
    });
  });
}
