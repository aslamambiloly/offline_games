import 'dart:math';
import 'package:flutter/material.dart';
import '../core/offline_game.dart';
import 'retro_pixel_glyph.dart';
import 'retro_pixel_text.dart';
import 'retro_screen.dart';

/// Helper to select a random game while guaranteeing that the same game
/// is never picked twice consecutively if more than one game is available.
OfflineGame pickRandomGame({
  required List<OfflineGame> games,
  OfflineGame? previous,
  required Random random,
}) {
  assert(games.isNotEmpty, 'Games list cannot be empty when spinning');
  if (games.length == 1) return games.first;

  final candidates = games.where((g) => g != previous).toList();
  return candidates[random.nextInt(candidates.length)];
}

/// Standalone animated arcade wheel / slot spinner widget in Vintage CRT theme.
class GameSpinner extends StatefulWidget {
  /// Creates a [GameSpinner].
  const GameSpinner({
    super.key,
    required this.games,
    required this.onResult,
    this.random,
    this.previousGame,
  });

  /// The pool of games to spin among.
  final List<OfflineGame> games;

  /// Callback invoked when player starts playing the chosen game.
  final void Function(OfflineGame game) onResult;

  /// Injected random instance for deterministic tests.
  final Random? random;

  /// The previously played game, if any, to avoid immediate repetition.
  final OfflineGame? previousGame;

  @override
  State<GameSpinner> createState() => _GameSpinnerState();
}

class _GameSpinnerState extends State<GameSpinner>
    with SingleTickerProviderStateMixin {
  late final Random _random;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  OfflineGame? _selectedGame;
  OfflineGame? _lastGame;
  bool _isSpinning = false;
  int _cycleIndex = 0;

  @override
  void initState() {
    super.initState();
    _random = widget.random ?? Random();
    _lastGame = widget.previousGame;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    );

    _animation.addListener(() {
      if (_isSpinning && widget.games.length > 1) {
        final totalSteps = widget.games.length * 4;
        final currentStep = (_animation.value * totalSteps).floor();
        if (currentStep != _cycleIndex) {
          setState(() {
            _cycleIndex = currentStep;
          });
        }
      }
    });

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
      }
    });

    // Pick initial game
    _selectedGame = pickRandomGame(
      games: widget.games,
      previous: _lastGame,
      random: _random,
    );
    _lastGame = _selectedGame;

    // Trigger spin on post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _spin();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;

    final picked = pickRandomGame(
      games: widget.games,
      previous: _lastGame,
      random: _random,
    );

    _selectedGame = picked;
    _lastGame = picked;

    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnim) {
      _isSpinning = false;
      setState(() {});
      return;
    }

    _isSpinning = true;
    _cycleIndex = 0;
    _controller.forward(from: 0.0);
  }

  OfflineGame _getDisplayedGame() {
    if (!_isSpinning) {
      return _selectedGame ?? widget.games.first;
    }
    final index = _cycleIndex % widget.games.length;
    return widget.games[index];
  }

  @override
  Widget build(BuildContext context) {
    final gameToShow = _getDisplayedGame();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: RetroPixelCard(
            borderColor: const Color(0xFF00F0FF),
            backgroundColor: const Color(0xFF0D101C),
            shadowOffset: 4,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Arcade Header
                const Center(
                  child: PixelText(
                    'ARCADE SPINNER',
                    pixelSize: 2.0,
                    color: Color(0xFF00F0FF),
                    glowColor: Color(0xFF00F0FF),
                  ),
                ),
                const SizedBox(height: 18),

                // CRT Slot Wheel Viewport
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF070912),
                    border: Border.all(
                      color: const Color(0xFF2C3552),
                      width: 2.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: CrtScanlinesOverlay(
                    scanlineOpacity: 0.12,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PixelGlyphWidget(
                            type: gameToShow.meta.effectiveGlyph,
                            pixelSize: 5.5,
                            glow: true,
                          ),
                          const SizedBox(height: 10),
                          PixelText(
                            gameToShow.meta.title,
                            pixelSize: 2.2,
                            color: const Color(0xFF39FF14),
                            glowColor: const Color(0xFF39FF14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (gameToShow.meta.description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  PixelText(
                    gameToShow.meta.description,
                    textAlign: TextAlign.center,
                    pixelSize: 1.3,
                    color: const Color(0xFF8E9CB8),
                  ),
                ],
                const SizedBox(height: 22),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: RetroPixelButton(
                        label: 'Spin again',
                        onPressed: _isSpinning ? null : _spin,
                        color: const Color(0xFF1E2338),
                        textColor: const Color(0xFF8E9CB8),
                        pixelSize: 1.7,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RetroPixelButton(
                        label: 'Start Game',
                        onPressed: _isSpinning
                            ? null
                            : () {
                                final game =
                                    _selectedGame ?? _getDisplayedGame();
                                widget.onResult(game);
                              },
                        color: const Color(0xFF39FF14),
                        textColor: Colors.black,
                        pixelSize: 1.7,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
