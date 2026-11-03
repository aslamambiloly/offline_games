import 'dart:math';

/// State of an individual card in the memory grid.
enum CardState {
  /// Covered face down.
  faceDown,

  /// Temporarily flipped face up.
  faceUp,

  /// Successfully paired and permanently revealed.
  matched,
}

/// Representation of a single card.
class MemoryCard {
  /// Creates a [MemoryCard].
  const MemoryCard({
    required this.id,
    required this.emoji,
    this.state = CardState.faceDown,
  });

  /// Unique card identifier.
  final int id;

  /// The emoji symbol displayed when face up.
  final String emoji;

  /// The current visibility state.
  final CardState state;

  /// Returns a copy with the updated [CardState].
  MemoryCard copyWith({CardState? state}) {
    return MemoryCard(
      id: id,
      emoji: emoji,
      state: state ?? this.state,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryCard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          emoji == other.emoji &&
          state == other.state;

  @override
  int get hashCode => Object.hash(id, emoji, state);
}

/// Default retro pixel vector glyph set for Memory Match.
const List<String> defaultMemoryEmojis = [
  'alien',
  'star',
  'sword',
  'apple',
  'gamepad',
  'trophy',
  'heart',
  'potion',
];

/// Pure-Dart immutable representation of a Memory Match game state.
class MemoryMatchState {
  /// Creates a [MemoryMatchState].
  const MemoryMatchState({
    required this.cards,
    this.movesCount = 0,
    this.pairsMatched = 0,
    this.firstFlippedIndex,
    this.secondFlippedIndex,
  });

  /// The list of cards currently in play.
  final List<MemoryCard> cards;

  /// Number of two-card flip attempts made so far.
  final int movesCount;

  /// Number of matching pairs successfully revealed.
  final int pairsMatched;

  /// Index of the first card flipped in the current turn.
  final int? firstFlippedIndex;

  /// Index of the second card flipped in the current turn.
  final int? secondFlippedIndex;

  /// Total number of pairs on the board.
  int get totalPairs => cards.length ~/ 2;

  /// Set of unique emoji symbols on the board.
  Set<String> get uniqueEmojis => cards.map((c) => c.emoji).toSet();

  /// Whether all pairs have been matched.
  bool get isWon => pairsMatched == totalPairs && totalPairs > 0;

  /// Whether two mismatched cards are currently showing face-up.
  bool get hasMismatchedPair =>
      firstFlippedIndex != null &&
      secondFlippedIndex != null &&
      cards[firstFlippedIndex!].state == CardState.faceUp &&
      cards[secondFlippedIndex!].state == CardState.faceUp;

  /// Creates a shuffled initial state using [random].
  factory MemoryMatchState.initial({
    required Random random,
    int pairCount = 6,
    List<String>? emojis,
  }) {
    final pool = List<String>.from(emojis ?? defaultMemoryEmojis)
      ..shuffle(random);
    final selectedEmojis = pool.take(pairCount).toList();

    var cardId = 0;
    final cardList = <MemoryCard>[];

    for (final emoji in selectedEmojis) {
      cardList.add(MemoryCard(id: cardId++, emoji: emoji));
      cardList.add(MemoryCard(id: cardId++, emoji: emoji));
    }

    cardList.shuffle(random);

    return MemoryMatchState(
      cards: List.unmodifiable(cardList),
      movesCount: 0,
      pairsMatched: 0,
    );
  }

  /// Flips the card at [index].
  MemoryMatchState flipCard(int index) {
    if (index < 0 || index >= cards.length) return this;
    if (cards[index].state != CardState.faceDown) return this;
    if (hasMismatchedPair) return this;

    final newCards = List<MemoryCard>.from(cards);

    if (firstFlippedIndex == null) {
      // First card of a turn
      newCards[index] = newCards[index].copyWith(state: CardState.faceUp);
      return MemoryMatchState(
        cards: List.unmodifiable(newCards),
        movesCount: movesCount,
        pairsMatched: pairsMatched,
        firstFlippedIndex: index,
        secondFlippedIndex: null,
      );
    } else {
      // Second card of a turn
      final firstIdx = firstFlippedIndex!;
      final firstCard = newCards[firstIdx];
      final secondCard = newCards[index];

      final isMatch = firstCard.emoji == secondCard.emoji;
      final newMoves = movesCount + 1;

      if (isMatch) {
        newCards[firstIdx] = firstCard.copyWith(state: CardState.matched);
        newCards[index] = secondCard.copyWith(state: CardState.matched);

        return MemoryMatchState(
          cards: List.unmodifiable(newCards),
          movesCount: newMoves,
          pairsMatched: pairsMatched + 1,
          firstFlippedIndex: null,
          secondFlippedIndex: null,
        );
      } else {
        newCards[index] = secondCard.copyWith(state: CardState.faceUp);
        return MemoryMatchState(
          cards: List.unmodifiable(newCards),
          movesCount: newMoves,
          pairsMatched: pairsMatched,
          firstFlippedIndex: firstIdx,
          secondFlippedIndex: index,
        );
      }
    }
  }

  /// Turns any mismatched cards back to [CardState.faceDown].
  MemoryMatchState resolveMismatched() {
    if (!hasMismatchedPair) return this;

    final newCards = List<MemoryCard>.from(cards);
    if (firstFlippedIndex != null &&
        newCards[firstFlippedIndex!].state == CardState.faceUp) {
      newCards[firstFlippedIndex!] =
          newCards[firstFlippedIndex!].copyWith(state: CardState.faceDown);
    }
    if (secondFlippedIndex != null &&
        newCards[secondFlippedIndex!].state == CardState.faceUp) {
      newCards[secondFlippedIndex!] =
          newCards[secondFlippedIndex!].copyWith(state: CardState.faceDown);
    }

    return MemoryMatchState(
      cards: List.unmodifiable(newCards),
      movesCount: movesCount,
      pairsMatched: pairsMatched,
      firstFlippedIndex: null,
      secondFlippedIndex: null,
    );
  }

  /// Computes a score where fewer moves and higher pair count yield higher score.
  int computeScore() {
    final baseScore = totalPairs * 150;
    final movePenalty = movesCount * 15;
    return max(50, baseScore - movePenalty);
  }
}
