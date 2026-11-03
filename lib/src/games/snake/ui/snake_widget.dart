import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../../core/game_session.dart';
import '../logic/snake_state.dart';
import 'snake_painter.dart';

/// Interactive UI for the classic Snake arcade game.
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
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                // Top Score Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score: ${_state.score}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.session.bestScore != null)
                        Text(
                          '🏆 Best: ${widget.session.bestScore}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Arena Grid
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
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
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
                                  primaryColor: const Color(0xFF10B981),
                                  accentColor: const Color(0xFFEF4444),
                                  gridColor:
                                      Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                            ),
                            if (_state.isGameOver)
                              Container(
                                color: Colors.black87,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('💥',
                                        style: TextStyle(fontSize: 48)),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Game Over',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Score: ${_state.score}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    FilledButton.icon(
                                      onPressed: _startNewGame,
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('Play Again'),
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
                // Accessible D-Pad Controls
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: 'Move Up',
          button: true,
          child: IconButton.filledTonal(
            key: const ValueKey('dpad_up'),
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
            onPressed: () => onDirectionPressed(Direction.up),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Move Left',
              button: true,
              child: IconButton.filledTonal(
                key: const ValueKey('dpad_left'),
                constraints:
                    const BoxConstraints.tightFor(width: 48, height: 48),
                icon: const Icon(Icons.keyboard_arrow_left_rounded),
                onPressed: () => onDirectionPressed(Direction.left),
              ),
            ),
            const SizedBox(width: 48),
            Semantics(
              label: 'Move Right',
              button: true,
              child: IconButton.filledTonal(
                key: const ValueKey('dpad_right'),
                constraints:
                    const BoxConstraints.tightFor(width: 48, height: 48),
                icon: const Icon(Icons.keyboard_arrow_right_rounded),
                onPressed: () => onDirectionPressed(Direction.right),
              ),
            ),
          ],
        ),
        Semantics(
          label: 'Move Down',
          button: true,
          child: IconButton.filledTonal(
            key: const ValueKey('dpad_down'),
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            onPressed: () => onDirectionPressed(Direction.down),
          ),
        ),
      ],
    );
  }
}
