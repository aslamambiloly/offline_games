import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/offline_games.dart';

class _DummyGame extends OfflineGame {
  const _DummyGame({required this.meta});

  @override
  final GameMeta meta;

  @override
  Widget build(BuildContext context, GameSession session) {
    return const SizedBox.shrink();
  }
}

void main() {
  group('Core Contracts', () {
    test('GameMeta requires at least one author (C7)', () {
      const emptyAuthorMeta = GameMeta(
        id: 'test_game',
        title: 'Test Game',
        emoji: '🎮',
        authors: <GameAuthor>[],
      );
      expect(() => emptyAuthorMeta.validate(), throwsAssertionError);

      const invalidIdMeta = GameMeta(
        id: 'Invalid-ID!',
        title: 'Test Game',
        emoji: '🎮',
        authors: [GameAuthor(name: 'Alice')],
      );
      expect(() => invalidIdMeta.validate(), throwsAssertionError);

      const validMeta = GameMeta(
        id: 'test_game',
        title: 'Test Game',
        emoji: '🎮',
        authors: <GameAuthor>[
          GameAuthor(name: 'Alice', github: 'alice'),
        ],
      );

      expect(() => validMeta.validate(), returnsNormally);
      expect(validMeta.authors, hasLength(1));
      expect(validMeta.authors.first.name, 'Alice');
      expect(validMeta.authors.first.github, 'alice');
    });

    test('GamesMode factory constructors construct valid instances', () {
      const spinMode = GamesMode.spin();
      expect(spinMode, isA<SpinMode>());

      const pickerMode = GamesMode.picker();
      expect(pickerMode, isA<PickerMode>());

      const game = _DummyGame(
        meta: GameMeta(
          id: 'test_game',
          title: 'Test',
          emoji: '🎮',
          authors: [GameAuthor(name: 'Alice')],
        ),
      );
      const singleMode = GamesMode.single(game);
      expect(singleMode, isA<SingleMode>());
      expect((singleMode as SingleMode).game, equals(game));
    });

    test('GameAuthor equality and toString', () {
      const author1 = GameAuthor(name: 'Alice', github: 'alice');
      const author2 = GameAuthor(name: 'Alice', github: 'alice');
      const author3 = GameAuthor(name: 'Bob', github: 'bob');

      expect(author1, equals(author2));
      expect(author1.hashCode, equals(author2.hashCode));
      expect(author1, isNot(equals(author3)));
      expect(author1.toString(), contains('Alice'));
    });
  });
}
