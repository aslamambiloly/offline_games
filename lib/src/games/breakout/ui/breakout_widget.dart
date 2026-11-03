import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../../core/game_session.dart';
import '../../../ui/retro_pixel_glyph.dart';
import '../../../ui/retro_pixel_text.dart';
import '../../../ui/retro_screen.dart';
import '../logic/breakout_state.dart';
import 'breakout_painter.dart';

/// Interactive UI for the classic Breakout brick-breaker arcade game.
class BreakoutWidget extends StatefulWidget {
  /// Creates a [BreakoutWidget].
  const BreakoutWidget({
    super.key,
    required this.session,
    this.random,
  });

  /// The active game session.
  final GameSession session;

  /// Optional injected random for testing.
  final Random? random;

  @override
  State<BreakoutWidget> createState() => _BreakoutWidgetState();
}

class _BreakoutWidgetState extends State<BreakoutWidget>
    with SingleTickerProviderStateMixin {
  late BreakoutState _state;
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final FocusNode _focusNode = FocusNode();
  bool _hasReportedScore = false;

  @override
  void initState() {
    super.initState();
    _state = BreakoutState(random: widget.random ?? widget.session.random);
    widget.session.paused.addListener(_onPauseChanged);

    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      if (widget.session.paused.value) {
        _lastElapsed = elapsed;
        return;
      }

      final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;

      // Cap delta time to prevent tunneling during large frame pauses
      final clampedDt = dt.clamp(0.0, 0.05);

      if (_state.isLaunched && !_state.isGameOver) {
        setState(() {
          _state.update(clampedDt);
        });

        if (_state.isGameOver && !_hasReportedScore) {
          _hasReportedScore = true;
          widget.session.reportScore(_state.score);
        }
      }
    });

    _ticker.start();
  }

  void _onPauseChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.session.paused.removeListener(_onPauseChanged);
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleDrag(DragUpdateDetails details, BoxConstraints constraints) {
    if (widget.session.paused.value || _state.isGameOver) return;

    // Convert local drag coordinate to arena coordinate space
    final arenaWidth = _state.arenaWidth;
    final arenaHeight = _state.arenaHeight;
    final scale = min(
      constraints.maxWidth / arenaWidth,
      constraints.maxHeight / arenaHeight,
    );
    final offsetX = (constraints.maxWidth - arenaWidth * scale) / 2.0;

    final localX = details.localPosition.dx - offsetX;
    final targetArenaX = localX / scale;

    setState(() {
      _state.setPaddleCenter(targetArenaX);
      if (!_state.isLaunched) {
        _state.launch();
      }
    });
  }

  void _handleTap() {
    if (widget.session.paused.value || _state.isGameOver) return;
    if (!_state.isLaunched) {
      setState(() {
        _state.launch();
      });
    }
  }

  void _restart() {
    setState(() {
      _state.restart();
      _hasReportedScore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final scoreColor =
        isLight ? const Color(0xFF000000) : const Color(0xFF00F0FF);
    final bestColor =
        isLight ? const Color(0xFFD97706) : const Color(0xFFFFB800);
    final arenaBg =
        isLight ? const Color(0xFFFFFFFF) : const Color(0xFF090B14);
    final arenaBorder =
        isLight ? const Color(0xFF000000) : const Color(0xFF2C324E);
    final paddleColor =
        isLight ? const Color(0xFF000000) : const Color(0xFF00F0FF);
    final ballColor =
        isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final gridColor =
        isLight ? const Color(0xFFE5E7EB) : const Color(0xFF131728);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;
        if (widget.session.paused.value || _state.isGameOver) return;

        if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
            event.logicalKey == LogicalKeyboardKey.keyA) {
          setState(() {
            _state.movePaddleBy(-24.0);
          });
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
            event.logicalKey == LogicalKeyboardKey.keyD) {
          setState(() {
            _state.movePaddleBy(24.0);
          });
        } else if (event.logicalKey == LogicalKeyboardKey.space) {
          _handleTap();
        }
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                // Retro Scoreboard HUD Bar
                RetroPixelCard(
                  shadowOffset: 3,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      PixelText(
                        'Score: ${_state.score}',
                        pixelSize: 1.8,
                        color: scoreColor,
                        glowColor: isLight ? null : scoreColor,
                      ),
                      // Lives display with pixel hearts
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PixelText(
                            'Lives: ',
                            pixelSize: 1.6,
                            color: Color(0xFFFF2A85),
                          ),
                          for (int i = 0; i < 3; i++) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: PixelGlyphWidget(
                                type: PixelGlyphType.heart,
                                pixelSize: 1.5,
                                color: i < _state.lives
                                    ? const Color(0xFFFF2A85)
                                    : (isLight
                                        ? const Color(0xFFE5E7EB)
                                        : const Color(0xFF3A3F55)),
                                glow: !isLight && i < _state.lives,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.session.bestScore != null)
                        PixelText(
                          'Best: ${widget.session.bestScore}',
                          pixelSize: 1.8,
                          color: bestColor,
                          glowColor: isLight ? null : bestColor,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // CRT Arena Viewport
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        key: const ValueKey('breakout_arena'),
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleTap,
                        onHorizontalDragUpdate: (details) =>
                            _handleDrag(details, constraints),
                        child: Container(
                          decoration: BoxDecoration(
                            color: arenaBg,
                            border: Border.all(
                              color: arenaBorder,
                              width: 3.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: BreakoutPainter(
                                    state: _state,
                                    primaryColor: paddleColor,
                                    ballColor: ballColor,
                                    ballGlowColor: paddleColor,
                                    gridColor: gridColor,
                                  ),
                                ),
                              ),

                              // Launch prompt indicator if not yet launched
                              if (!_state.isLaunched && !_state.isGameOver)
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLight
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : Colors.black.withValues(alpha: 0.6),
                                      border: Border.all(
                                        color: isLight
                                            ? const Color(0xFF000000)
                                            : const Color(0xFF2C324E),
                                      ),
                                    ),
                                    child: PixelText(
                                      'TAP OR DRAG TO LAUNCH',
                                      pixelSize: 1.3,
                                      color: isLight
                                          ? const Color(0xFF000000)
                                          : const Color(0xFF00FFA3),
                                    ),
                                  ),
                                ),

                              // Game Over / Victory Overlay
                              if (_state.isGameOver)
                                Container(
                                  key: const ValueKey('breakout_game_over'),
                                  color: isLight
                                      ? Colors.white.withValues(alpha: 0.92)
                                      : Colors.black.withValues(alpha: 0.88),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PixelText(
                                        _state.isWon ? 'VICTORY!' : 'GAME OVER',
                                        pixelSize: 3.0,
                                        color: _state.isWon
                                            ? (isLight
                                                ? const Color(0xFF15803D)
                                                : const Color(0xFF39FF14))
                                            : (isLight
                                                ? const Color(0xFFDC2626)
                                                : const Color(0xFFFF2A85)),
                                        glowColor: isLight
                                            ? null
                                            : (_state.isWon
                                                ? const Color(0xFF39FF14)
                                                : const Color(0xFFFF2A85)),
                                      ),
                                      const SizedBox(height: 12),
                                      PixelText(
                                        'FINAL SCORE: ${_state.score}',
                                        pixelSize: 2.0,
                                        color: isLight
                                            ? const Color(0xFF000000)
                                            : const Color(0xFFFFB800),
                                      ),
                                      const SizedBox(height: 20),
                                      RetroPixelButton(
                                        key: const ValueKey('breakout_replay'),
                                        label: 'PLAY AGAIN',
                                        color: isLight
                                            ? const Color(0xFF000000)
                                            : const Color(0xFF39FF14),
                                        textColor: isLight
                                            ? Colors.white
                                            : Colors.black,
                                        onPressed: _restart,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Left / Right Touch Steering Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSteerButton(
                      key: const ValueKey('breakout_steer_left'),
                      label: 'Move Left',
                      glyph: PixelGlyphType.arrowLeft,
                      isLight: isLight,
                      onTap: () {
                        setState(() {
                          _state.movePaddleBy(-28.0);
                        });
                      },
                    ),
                    const SizedBox(width: 24),
                    _buildSteerButton(
                      key: const ValueKey('breakout_launch_btn'),
                      label: 'Launch Ball',
                      glyph: PixelGlyphType.arrowUp,
                      isLight: isLight,
                      onTap: _handleTap,
                    ),
                    const SizedBox(width: 24),
                    _buildSteerButton(
                      key: const ValueKey('breakout_steer_right'),
                      label: 'Move Right',
                      glyph: PixelGlyphType.arrowRight,
                      isLight: isLight,
                      onTap: () {
                        setState(() {
                          _state.movePaddleBy(28.0);
                        });
                      },
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

  Widget _buildSteerButton({
    required Key key,
    required String label,
    required PixelGlyphType glyph,
    required VoidCallback onTap,
    required bool isLight,
  }) {
    final btnBg = isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1E2338);
    final btnBorder =
        isLight ? const Color(0xFF000000) : const Color(0xFF4A5578);
    final arrowColor =
        isLight ? const Color(0xFF000000) : const Color(0xFF00F0FF);

    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        key: key,
        onTap: onTap,
        child: Container(
          width: 52,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: btnBg,
            border: Border.all(
              color: btnBorder,
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: PixelGlyphWidget(
            type: glyph,
            pixelSize: 2.5,
            color: arrowColor,
            glow: !isLight,
          ),
        ),
      ),
    );
  }
}
