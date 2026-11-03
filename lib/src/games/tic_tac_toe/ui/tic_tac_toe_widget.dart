import 'package:flutter/material.dart';
import '../../../core/game_session.dart';
import '../../../ui/retro_pixel_glyph.dart';
import '../../../ui/retro_pixel_text.dart';
import '../../../ui/retro_screen.dart';
import '../logic/tic_tac_toe_ai.dart';
import '../logic/tic_tac_toe_state.dart';

/// Interactive UI for the Tic Tac Toe mini-game in Vintage Pixel Vector theme.
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
    final winningLine = _state.winningLine ?? const <int>[];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Retro Scoreboard HUD
              RetroPixelCard(
                borderColor: const Color(0xFF2C324E),
                backgroundColor: const Color(0xFF0F121E),
                shadowOffset: 3,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ScoreColumn(
                      label: 'YOU (X)',
                      score: _playerWins,
                      color: const Color(0xFF00F0FF),
                    ),
                    Container(
                      width: 2,
                      height: 28,
                      color: const Color(0xFF2C324E),
                    ),
                    _ScoreColumn(
                      label: 'DRAWS',
                      score: _draws,
                      color: const Color(0xFFFFB800),
                    ),
                    Container(
                      width: 2,
                      height: 28,
                      color: const Color(0xFF2C324E),
                    ),
                    _ScoreColumn(
                      label: 'AI (O)',
                      score: _aiWins,
                      color: const Color(0xFFFF2A85),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Neon Status Text
              PixelText(
                _getStatusText(),
                pixelSize: 2.0,
                color: _getStatusColor(),
                glowColor: _getStatusColor(),
              ),
              const SizedBox(height: 18),

              // 3x3 Retro Arcade CRT Grid
              AspectRatio(
                aspectRatio: 1.0,
                child: RetroPixelCard(
                  borderColor: const Color(0xFF2C324E),
                  backgroundColor: const Color(0xFF090C16),
                  shadowOffset: 4,
                  padding: const EdgeInsets.all(12),
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
                        child: GestureDetector(
                          key: ValueKey('tic_tac_toe_cell_$index'),
                          onTap: () => _handleCellTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isWinningCell
                                  ? const Color(0xFF0B2416)
                                  : const Color(0xFF131828),
                              border: Border.all(
                                color: isWinningCell
                                    ? const Color(0xFF39FF14)
                                    : const Color(0xFF2C3552),
                                width: isWinningCell ? 2.5 : 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isWinningCell
                                      ? const Color(0xFF39FF14)
                                          .withValues(alpha: 0.4)
                                      : Colors.black,
                                  offset: const Offset(2, 2),
                                  blurRadius: isWinningCell ? 6 : 0,
                                ),
                              ],
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

              // Retro Action Button
              if (_state.isGameOver)
                RetroPixelButton(
                  label: 'PLAY AGAIN',
                  onPressed: _resetBoard,
                  color: const Color(0xFF39FF14),
                  textColor: Colors.black,
                  pixelSize: 2.0,
                  minWidth: 160,
                )
              else
                const SizedBox(height: 44),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _renderCellContent(BoardCell cell) {
    return switch (cell) {
      BoardCell.empty => null,
      BoardCell.x => const Stack(
          alignment: Alignment.center,
          children: [
            Opacity(opacity: 0.0, child: Text('❌')),
            PixelGlyphWidget(
              type: PixelGlyphType.cross,
              pixelSize: 5.5,
              glow: true,
            ),
          ],
        ),
      BoardCell.o => const Stack(
          alignment: Alignment.center,
          children: [
            Opacity(opacity: 0.0, child: Text('⭕')),
            PixelGlyphWidget(
              type: PixelGlyphType.ring,
              pixelSize: 5.5,
              glow: true,
            ),
          ],
        ),
    };
  }

  String _getStatusText() {
    if (_state.winner == Player.x) return 'YOU WIN!';
    if (_state.winner == Player.o) return 'AI WINS!';
    if (_state.isDraw) return 'DRAW GAME!';
    return _state.currentTurn == Player.x ? 'YOUR TURN (X)' : 'AI THINKING...';
  }

  Color _getStatusColor() {
    if (_state.winner == Player.x) return const Color(0xFF39FF14);
    if (_state.winner == Player.o) return const Color(0xFFFF2A85);
    if (_state.isDraw) return const Color(0xFFFFB800);
    return const Color(0xFF00F0FF);
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
        PixelText(
          label,
          pixelSize: 1.5,
          color: color,
        ),
        const SizedBox(height: 4),
        PixelText(
          '$score',
          pixelSize: 2.2,
          color: color,
          glowColor: color,
        ),
      ],
    );
  }
}
