import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../../core/game_session.dart';
import '../../../ui/retro_pixel_glyph.dart';
import '../../../ui/retro_pixel_text.dart';
import '../../../ui/retro_screen.dart';
import '../logic/snake_state.dart';
import 'snake_painter.dart';

/// Interactive UI for the classic Snake arcade game in Vintage Pixel Vector theme.
class SnakeWidget extends StatefulWidget {
  /// Creates a [SnakeWidget].
  const SnakeWidget({
    super.key,
    required this.session,
    this.tickInterval = const Duration(milliseconds: 160),
    this.gridWidth = 18,
    this.gridHeight = 18,
  });

  /// The active game session.
  final GameSession session;

  /// Speed interval at which the snake advances one cell.
  final Duration tickInterval;

  /// Arena grid columns.
  final int gridWidth;

  /// Arena grid rows.
  final int gridHeight;

  @override
  State<SnakeWidget> createState() => _SnakeWidgetState();
}

class _SnakeWidgetState extends State<SnakeWidget>
    with SingleTickerProviderStateMixin {
  late SnakeState _state;
  Ticker? _ticker;
  Duration _lastTickElapsed = Duration.zero;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _startNewGame();
    widget.session.paused.addListener(_handlePauseChange);

    _ticker = createTicker(_onTick);
    if (!widget.session.paused.value) {
      _ticker?.start();
    }
  }

  @override
  void dispose() {
    widget.session.paused.removeListener(_handlePauseChange);
    _ticker?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handlePauseChange() {
    if (widget.session.paused.value) {
      _ticker?.stop();
    } else if (!_state.isGameOver) {
      _ticker?.start();
    }
  }

  void _startNewGame() {
    _state = SnakeState.initial(
      random: widget.session.random,
      gridWidth: widget.gridWidth,
      gridHeight: widget.gridHeight,
    );
    _lastTickElapsed = Duration.zero;
    if (!widget.session.paused.value) {
      _ticker?.start();
    }
    setState(() {});
  }

  void _onTick(Duration elapsed) {
    if (widget.session.paused.value || _state.isGameOver) {
      return;
    }

    if (elapsed - _lastTickElapsed >= widget.tickInterval) {
      _lastTickElapsed = elapsed;
      setState(() {
        _state = _state.step(random: widget.session.random);
        if (_state.isGameOver) {
          _ticker?.stop();
          widget.session.reportScore(_state.score);
        }
      });
    }
  }

  void _changeDirection(Direction direction) {
    if (widget.session.paused.value || _state.isGameOver) return;
    setState(() {
      _state = _state.changeDirection(direction);
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW) {
      _changeDirection(Direction.up);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS) {
      _changeDirection(Direction.down);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      _changeDirection(Direction.left);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      _changeDirection(Direction.right);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.space &&
        _state.isGameOver) {
      _startNewGame();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final scoreColor =
        isLight ? const Color(0xFF000000) : const Color(0xFF39FF14);
    final hiColor =
        isLight ? const Color(0xFFD97706) : const Color(0xFFFFB800);
    final arenaBg =
        isLight ? const Color(0xFFFFFFFF) : const Color(0xFF090B14);
    final arenaBorder =
        isLight ? const Color(0xFF000000) : const Color(0xFF2C324E);
    final snakeColor =
        isLight ? const Color(0xFF000000) : const Color(0xFF39FF14);
    final foodColor =
        isLight ? const Color(0xFFDC2626) : const Color(0xFFFF2A85);
    final gridColor =
        isLight ? const Color(0xFFE5E7EB) : const Color(0xFF161A2B);

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Top Retro Scoreboard
                RetroPixelCard(
                  shadowOffset: 3,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PixelText(
                        'Score: ${_state.score}',
                        pixelSize: 2.0,
                        color: scoreColor,
                        glowColor: isLight ? null : scoreColor,
                      ),
                      if (widget.session.bestScore != null)
                        PixelText(
                          'HI: ${widget.session.bestScore}',
                          pixelSize: 1.8,
                          color: hiColor,
                          glowColor: isLight ? null : hiColor,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // CRT Arena Grid
                Expanded(
                  child: GestureDetector(
                    key: const ValueKey('snake_viewport'),
                    onVerticalDragEnd: (details) {
                      final dy = details.velocity.pixelsPerSecond.dy;
                      if (dy < -100) {
                        _changeDirection(Direction.up);
                      } else if (dy > 100) {
                        _changeDirection(Direction.down);
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      final dx = details.velocity.pixelsPerSecond.dx;
                      if (dx < -100) {
                        _changeDirection(Direction.left);
                      } else if (dx > 100) {
                        _changeDirection(Direction.right);
                      }
                    },
                    child: AspectRatio(
                      aspectRatio: 1.0,
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
                                painter: SnakePainter(
                                  state: _state,
                                  primaryColor: snakeColor,
                                  accentColor: foodColor,
                                  gridColor: gridColor,
                                ),
                              ),
                            ),
                            // Retro Game Over Screen
                            if (_state.isGameOver)
                              Container(
                                color: isLight
                                    ? Colors.white.withValues(alpha: 0.92)
                                    : Colors.black.withValues(alpha: 0.88),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PixelText(
                                      'Game Over',
                                      pixelSize: 3.2,
                                      color: isLight
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFFFF2A85),
                                      glowColor: isLight
                                          ? null
                                          : const Color(0xFFFF2A85),
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
                                      label: 'PLAY AGAIN',
                                      onPressed: _startNewGame,
                                      color: isLight
                                          ? const Color(0xFF000000)
                                          : const Color(0xFF39FF14),
                                      textColor: isLight
                                          ? Colors.white
                                          : Colors.black,
                                      pixelSize: 2.0,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Retro Arcade D-Pad Controls
                _DpadControls(
                  onDirectionPressed: _changeDirection,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DpadControls extends StatelessWidget {
  const _DpadControls({required this.onDirectionPressed});

  final void Function(Direction direction) onDirectionPressed;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final btnBg = isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1E2338);
    final btnBorder =
        isLight ? const Color(0xFF000000) : const Color(0xFF4A5578);
    final arrowColor =
        isLight ? const Color(0xFF000000) : const Color(0xFF00F0FF);
    const btnSize = 46.0;

    Widget buildDpadBtn({
      required Key key,
      required String label,
      required PixelGlyphType glyph,
      required Direction direction,
    }) {
      return Semantics(
        label: label,
        button: true,
        child: GestureDetector(
          key: key,
          onTap: () => onDirectionPressed(direction),
          child: Container(
            width: btnSize,
            height: btnSize,
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildDpadBtn(
          key: const ValueKey('dpad_up'),
          label: 'Move Up',
          glyph: PixelGlyphType.arrowUp,
          direction: Direction.up,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildDpadBtn(
              key: const ValueKey('dpad_left'),
              label: 'Move Left',
              glyph: PixelGlyphType.arrowLeft,
              direction: Direction.left,
            ),
            const SizedBox(width: btnSize),
            buildDpadBtn(
              key: const ValueKey('dpad_right'),
              label: 'Move Right',
              glyph: PixelGlyphType.arrowRight,
              direction: Direction.right,
            ),
          ],
        ),
        buildDpadBtn(
          key: const ValueKey('dpad_down'),
          label: 'Move Down',
          glyph: PixelGlyphType.arrowDown,
          direction: Direction.down,
        ),
      ],
    );
  }
}
