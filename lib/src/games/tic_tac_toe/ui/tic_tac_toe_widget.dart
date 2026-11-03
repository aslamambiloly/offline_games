import 'package:flutter/material.dart';
import '../../../core/game_session.dart';
import '../logic/tic_tac_toe_ai.dart';
import '../logic/tic_tac_toe_state.dart';

/// Interactive UI for the Tic Tac Toe mini-game.
class TicTacToeWidget extends StatefulWidget {
  /// Creates a [TicTacToeWidget].
  const TicTacToeWidget({super.key, required this.session});

  /// The active game session.
  final GameSession session;

  @override
  State<TicTacToeWidget> createState() => _TicTacToeWidgetState();
}

class _TicTacToeWidgetState extends State<TicTacToeWidget> {
  TicTacToeState _state = TicTacToeState.initial();
  int _playerWins = 0;
  int _aiWins = 0;
  int _draws = 0;

  @override
  void initState() {
    super.initState();
    _playerWins = widget.session.bestScore ?? 0;
  }

  void _handleCellTap(int index) {
    if (widget.session.paused.value) return;
    if (_state.isGameOver) return;
    if (_state.currentTurn != Player.x) return;
    if (_state.board[index] != BoardCell.empty) return;

    setState(() {
      _state = _state.makeMove(index);
    });

    _checkOutcome();

    if (!_state.isGameOver && _state.currentTurn == Player.o) {
      _makeAiMove();
    }
  }

  void _makeAiMove() {
    if (widget.session.paused.value) return;

    final aiMove = findBestMove(_state, aiPlayer: Player.o);
    setState(() {
      _state = _state.makeMove(aiMove);
    });

    _checkOutcome();
  }

  void _checkOutcome() {
    if (_state.isGameOver) {
      if (_state.winner == Player.x) {
        _playerWins++;
        widget.session.reportScore(_playerWins);
      } else if (_state.winner == Player.o) {
        _aiWins++;
      } else if (_state.isDraw) {
        _draws++;
      }
    }
  }

  void _resetBoard() {
    setState(() {
      _state = TicTacToeState.initial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final winningLine = _state.winningLine ?? const <int>[];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scoreboard Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ScoreColumn(
                      label: 'YOU (❌)',
                      score: _playerWins,
                      color: Colors.blueAccent,
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: colorScheme.outlineVariant,
                    ),
                    _ScoreColumn(
                      label: 'DRAWS',
                      score: _draws,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: colorScheme.outlineVariant,
                    ),
                    _ScoreColumn(
                      label: 'AI (⭕)',
                      score: _aiWins,
                      color: Colors.deepOrangeAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Status text
              Text(
                _getStatusText(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(colorScheme),
                    ),
              ),
              const SizedBox(height: 20),
              // 3x3 Game Grid
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final cell = _state.board[index];
                      final isWinningCell = winningLine.contains(index);

                      return Semantics(
                        label: 'Grid cell $index, ${cell.name}',
                        button: true,
                        child: InkWell(
                          key: ValueKey('tic_tac_toe_cell_$index'),
                          onTap: () => _handleCellTap(index),
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isWinningCell
                                  ? colorScheme.primary.withValues(alpha: 0.25)
                                  : colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isWinningCell
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant
                                        .withValues(alpha: 0.4),
                                width: isWinningCell ? 2.5 : 1.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: _renderCellContent(cell),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Action Button
              if (_state.isGameOver)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(160, 48),
                  ),
                  onPressed: _resetBoard,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text('Play Again'),
                )
              else
                const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _renderCellContent(BoardCell cell) {
    return switch (cell) {
      BoardCell.empty => null,
      BoardCell.x => const Text(
          '❌',
          style: TextStyle(fontSize: 36),
        ),
      BoardCell.o => const Text(
          '⭕',
          style: TextStyle(fontSize: 36),
        ),
    };
  }

  String _getStatusText() {
    if (_state.winner == Player.x) return 'You Win! 🎉';
    if (_state.winner == Player.o) return 'AI Wins! 🤖';
    if (_state.isDraw) return "It's a Draw! 🤝";
    return _state.currentTurn == Player.x ? 'Your Turn (❌)' : 'AI Turn (⭕)...';
  }

  Color _getStatusColor(ColorScheme colorScheme) {
    if (_state.winner == Player.x) return Colors.green;
    if (_state.winner == Player.o) return Colors.deepOrange;
    if (_state.isDraw) return colorScheme.primary;
    return colorScheme.onSurface;
  }
}

class _ScoreColumn extends StatelessWidget {
  const _ScoreColumn({
    required this.label,
    required this.score,
    required this.color,
  });

  final String label;
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$score',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
