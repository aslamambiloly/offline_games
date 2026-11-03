import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/game_session.dart';
import '../logic/memory_match_state.dart';

/// Interactive UI for the Memory Match mini-game.
class MemoryMatchWidget extends StatefulWidget {
  /// Creates a [MemoryMatchWidget].
  const MemoryMatchWidget({
    super.key,
    required this.session,
    this.pairCount = 6,
  });

  /// The active game session.
  final GameSession session;

  /// Number of pairs to match (default 6 for a 3x4 grid).
  final int pairCount;

  @override
  State<MemoryMatchWidget> createState() => _MemoryMatchWidgetState();
}

class _MemoryMatchWidgetState extends State<MemoryMatchWidget> {
  late MemoryMatchState _state;
  Timer? _mismatchTimer;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _mismatchTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _mismatchTimer?.cancel();
    _state = MemoryMatchState.initial(
      random: widget.session.random,
      pairCount: widget.pairCount,
    );
    setState(() {});
  }

  void _handleCardTap(int index) {
    if (widget.session.paused.value) return;
    if (_state.isWon) return;

    if (_state.hasMismatchedPair) {
      _mismatchTimer?.cancel();
      setState(() {
        _state = _state.resolveMismatched();
      });
    }

    final previousMoves = _state.movesCount;
    final nextState = _state.flipCard(index);

    if (nextState != _state) {
      setState(() {
        _state = nextState;
      });

      if (_state.hasMismatchedPair) {
        final disableAnim =
            MediaQuery.maybeDisableAnimationsOf(context) ?? false;
        final delay =
            disableAnim ? Duration.zero : const Duration(milliseconds: 800);

        _mismatchTimer?.cancel();
        _mismatchTimer = Timer(delay, () {
          if (mounted) {
            setState(() {
              _state = _state.resolveMismatched();
            });
          }
        });
      }

      if (_state.isWon && previousMoves != _state.movesCount) {
        widget.session.reportScore(_state.computeScore());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Header stats bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Moves: ${_state.movesCount}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Pairs: ${_state.pairsMatched}/${_state.totalPairs}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    if (widget.session.bestScore != null)
                      Text(
                        '🏆 ${widget.session.bestScore}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Card Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _state.cards.length,
                  itemBuilder: (context, index) {
                    final card = _state.cards[index];
                    final isFaceUp = card.state != CardState.faceDown;
                    final isMatched = card.state == CardState.matched;

                    return Semantics(
                      label:
                          'Card $index: ${isFaceUp ? card.emoji : "face down"}',
                      button: true,
                      child: InkWell(
                        key: ValueKey('memory_card_$index'),
                        onTap: () => _handleCardTap(index),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? colorScheme.primaryContainer
                                : isFaceUp
                                    ? colorScheme.surface
                                    : colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isMatched
                                  ? colorScheme.primary
                                  : isFaceUp
                                      ? colorScheme.primary
                                          .withValues(alpha: 0.5)
                                      : colorScheme.outlineVariant
                                          .withValues(alpha: 0.5),
                              width: isMatched ? 2.0 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isFaceUp
                                ? Text(
                                    card.emoji,
                                    key: ValueKey('emoji_${card.id}'),
                                    style: const TextStyle(fontSize: 34),
                                  )
                                : const Text(
                                    '❓',
                                    key: ValueKey('hidden'),
                                    style: TextStyle(
                                      fontSize: 26,
                                      color: Colors.white38,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Win Banner / Play Again
              if (_state.isWon)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        'Solved in ${_state.movesCount} moves! Score: ${_state.computeScore()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.tonal(
                        onPressed: _startNewGame,
                        child: const Text('Play Again'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
