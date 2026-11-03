import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/offline_games.dart';

class _MockGame extends OfflineGame {
  const _MockGame({
    required this.id,
    required this.title,
    required this.emoji,
    required this.author,
  });

  final String id;
  final String title;
  final String emoji;
  final String author;

  @override
  GameMeta get meta => GameMeta(
        id: id,
        title: title,
        emoji: emoji,
        authors: [GameAuthor(name: author)],
      );

  @override
  Widget build(BuildContext context, GameSession session) =>
      Text('Mock $title');
}

void main() {
  const gameA = _MockGame(
    id: 'game_a',
    title: 'Tic Tac Toe',
    emoji: '❌',
    author: 'Alice',
  );
  const gameB = _MockGame(
    id: 'game_b',
    title: 'Memory Match',
    emoji: '🃏',
    author: 'Bob',
  );

  group('GamePicker', () {
    testWidgets('renders all games and pixel glyph cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GamePicker(
              games: const [gameA, gameB],
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tic Tac Toe'), findsOneWidget);
      expect(find.text('Memory Match'), findsOneWidget);
      expect(find.byType(PixelGlyphWidget), findsNWidgets(2));
    });

    testWidgets('tapping a game card triggers onSelected callback',
        (tester) async {
      OfflineGame? selectedGame;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GamePicker(
              games: const [gameA, gameB],
              onSelected: (game) => selectedGame = game,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Memory Match'));
      await tester.pumpAndSettle();

      expect(selectedGame, equals(gameB));
    });

    testWidgets('displays high score badges when available', (tester) async {
      final store = MemoryScoreStore();
      await store.write('game_a', 42);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GamePicker(
              games: const [gameA, gameB],
              scoreStore: store,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HI: 42'), findsOneWidget);
    });
  });
}
