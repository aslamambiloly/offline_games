import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/src/games/memory_match/logic/memory_match_state.dart';

void main() {
  group('MemoryMatchState logic', () {
    test('initial state produces paired cards shuffled with injected Random',
        () {
      final random = Random(42);
      final state = MemoryMatchState.initial(random: random, pairCount: 4);

      expect(state.cards, hasLength(8));
      expect(state.movesCount, equals(0));
      expect(state.pairsMatched, equals(0));
      expect(state.isWon, isFalse);

      // Verify every emoji has exactly 2 cards
      final emojiCounts = <String, int>{};
      for (final card in state.cards) {
        emojiCounts[card.emoji] = (emojiCounts[card.emoji] ?? 0) + 1;
      }
      expect(emojiCounts.values.every((c) => c == 2), isTrue);
    });

    test('flipping a single card sets it face up', () {
      final state = MemoryMatchState.initial(random: Random(1), pairCount: 2);
      final s1 = state.flipCard(0);

      expect(s1.cards[0].state, CardState.faceUp);
      expect(s1.firstFlippedIndex, equals(0));
      expect(s1.secondFlippedIndex, isNull);
    });

    test('flipping matching pair marks both as matched', () {
      final state = MemoryMatchState.initial(random: Random(1), pairCount: 2);
      final firstCard = state.cards[0];

      // Find the second card with the exact same emoji
      final secondIndex = state.cards
          .indexWhere((c) => c != firstCard && c.emoji == firstCard.emoji);
      expect(secondIndex, isNot(equals(-1)));

      final s1 = state.flipCard(0);
      final s2 = s1.flipCard(secondIndex);

      expect(s2.cards[0].state, CardState.matched);
      expect(s2.cards[secondIndex].state, CardState.matched);
      expect(s2.pairsMatched, equals(1));
      expect(s2.movesCount, equals(1));
    });

    test('flipping mismatched pair leaves both face up until resolved', () {
      final state = MemoryMatchState.initial(random: Random(1), pairCount: 2);
      final firstCard = state.cards[0];

      // Find an index with a different emoji
      final mismatchIndex = state.cards
          .indexWhere((c) => c != firstCard && c.emoji != firstCard.emoji);

      final s1 = state.flipCard(0);
      final s2 = s1.flipCard(mismatchIndex);

      expect(s2.cards[0].state, CardState.faceUp);
      expect(s2.cards[mismatchIndex].state, CardState.faceUp);
      expect(s2.pairsMatched, equals(0));
      expect(s2.movesCount, equals(1));
      expect(s2.hasMismatchedPair, isTrue);

      final s3 = s2.resolveMismatched();
      expect(s3.cards[0].state, CardState.faceDown);
      expect(s3.cards[mismatchIndex].state, CardState.faceDown);
      expect(s3.hasMismatchedPair, isFalse);
    });

    test('matching all pairs wins game and computes positive score', () {
      var state = MemoryMatchState.initial(random: Random(10), pairCount: 2);

      // Match all 2 pairs
      for (final emoji in state.uniqueEmojis) {
        final indices = [
          for (var i = 0; i < state.cards.length; i++)
            if (state.cards[i].emoji == emoji) i
        ];
        state = state.flipCard(indices[0]);
        state = state.flipCard(indices[1]);
      }

      expect(state.isWon, isTrue);
      expect(state.pairsMatched, equals(2));
      expect(state.computeScore(), greaterThan(0));
    });
  });
}
