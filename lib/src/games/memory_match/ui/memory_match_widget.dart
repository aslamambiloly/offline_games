import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/game_session.dart';
import '../../../ui/retro_pixel_glyph.dart';
import '../../../ui/retro_pixel_text.dart';
import '../../../ui/retro_screen.dart';
import '../logic/memory_match_state.dart';

/// Interactive UI for the Memory Match mini-game in a Vintage Pixel Vector theme.
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
            disableAnim ? Duration.zero : const Duration(milliseconds: 700);

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

  PixelGlyphType _resolveGlyph(String symbol) {
    switch (symbol) {
      case 'alien':
        return PixelGlyphType.alien;
      case 'star':
        return PixelGlyphType.star;
      case 'sword':
        return PixelGlyphType.sword;
      case 'apple':
        return PixelGlyphType.apple;
      case 'gamepad':
        return PixelGlyphType.gamepad;
      case 'trophy':
        return PixelGlyphType.trophy;
      case 'heart':
        return PixelGlyphType.heart;
      case 'potion':
        return PixelGlyphType.potion;
      default:
        return PixelGlyphType
            .values[symbol.hashCode.abs() % PixelGlyphType.values.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    const movesColor = Color(0xFF000000);
    const pairsColor = Color(0xFF16A34A);
    const bestColor = Color(0xFFD97706);
    const victoryBg = Color(0xFFDCFCE7);
    const victoryBorder = Color(0xFF16A34A);
    const victoryTitle = Color(0xFF15803D);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Retro Scoreboard HUD Bar
              RetroPixelCard(
                shadowOffset: 3,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    PixelText(
                      'Moves: ${_state.movesCount}',
                      pixelSize: 1.8,
                      color: movesColor,
                      glowColor: null,
                    ),
                    PixelText(
                      'Pairs: ${_state.pairsMatched}/${_state.totalPairs}',
                      pixelSize: 1.8,
                      color: pairsColor,
                      glowColor: null,
                    ),
                    if (widget.session.bestScore != null)
                      PixelText(
                        'Best: ${widget.session.bestScore}',
                        pixelSize: 1.8,
                        color: bestColor,
                        glowColor: null,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 8-Bit Pixel Card Grid
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
                    final glyph = _resolveGlyph(card.emoji);

                    final cardBg = isMatched
                        ? const Color(0xFFDCFCE7)
                        : isFaceUp
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFFF3F4F6);
                    final cardBorder = isMatched
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF000000);
                    const qColor = Color(0xFF000000);

                    return Semantics(
                      label:
                          'Card $index: ${isFaceUp ? glyph.semanticsLabel : "face down"}',
                      button: true,
                      child: GestureDetector(
                        key: ValueKey('memory_card_$index'),
                        onTap: () => _handleCardTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: cardBg,
                            border: Border.all(
                              color: cardBorder,
                              width: isMatched || isFaceUp ? 2.5 : 2.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: isFaceUp
                              ? PixelGlyphWidget(
                                  type: glyph,
                                  pixelSize: 4.5,
                                  glow: false,
                                  color: isMatched
                                      ? const Color(0xFF15803D)
                                      : null,
                                )
                              : const PixelText(
                                  '?',
                                  pixelSize: 3.5,
                                  color: qColor,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Retro Victory Banner
              if (_state.isWon)
                RetroPixelCard(
                  borderColor: victoryBorder,
                  backgroundColor: victoryBg,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PixelText(
                            'STAGE CLEARED!',
                            pixelSize: 2.2,
                            color: victoryTitle,
                            glowColor: null,
                          ),
                          const SizedBox(height: 4),
                          PixelText(
                            'MOVES: ${_state.movesCount} • SCORE: ${_state.computeScore()}',
                            pixelSize: 1.6,
                            color: const Color(0xFF000000),
                          ),
                        ],
                      ),
                      RetroPixelButton(
                        label: 'REPLAY',
                        onPressed: _startNewGame,
                        minWidth: 70,
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
