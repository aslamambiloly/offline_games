/// Players in Tic Tac Toe.
enum Player {
  /// Player X (Human).
  x,

  /// Player O (AI / Opponent).
  o;

  /// Returns the other player.
  Player get opponent => this == Player.x ? Player.o : Player.x;
}

/// Cell states on the 3x3 Tic Tac Toe board.
enum BoardCell {
  /// Empty cell.
  empty,

  /// Marked with X.
  x,

  /// Marked with O.
  o;

  /// Converts a [Player] to its corresponding [BoardCell].
  static BoardCell fromPlayer(Player player) =>
      player == Player.x ? BoardCell.x : BoardCell.o;
}

/// Pure-Dart immutable representation of a Tic Tac Toe game state.
class TicTacToeState {
  /// Creates a [TicTacToeState].
  const TicTacToeState({
    required this.board,
    required this.currentTurn,
  });

  /// Creates an initial empty board where [Player.x] goes first.
  factory TicTacToeState.initial() {
    return const TicTacToeState(
      board: [
        BoardCell.empty,
        BoardCell.empty,
        BoardCell.empty,
        BoardCell.empty,
        BoardCell.empty,
        BoardCell.empty,
        BoardCell.empty,
        BoardCell.empty,
        BoardCell.empty,
      ],
      currentTurn: Player.x,
    );
  }

  /// 9-element list representing row-major 3x3 grid cells.
  final List<BoardCell> board;

  /// The player whose turn it is to play.
  final Player currentTurn;

  /// Winning lines (3 rows, 3 columns, 2 diagonals).
  static const List<List<int>> lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6], // diagonals
  ];

  /// The winning line indices, or null if no player has won yet.
  List<int>? get winningLine {
    for (final line in lines) {
      final a = board[line[0]];
      final b = board[line[1]];
      final c = board[line[2]];
      if (a != BoardCell.empty && a == b && b == c) {
        return line;
      }
    }
    return null;
  }

  /// The winner of the game, or null if no winner yet.
  Player? get winner {
    final line = winningLine;
    if (line == null) return null;
    return board[line[0]] == BoardCell.x ? Player.x : Player.o;
  }

  /// Whether all cells are occupied with no winner (draw).
  bool get isDraw {
    if (winner != null) return false;
    return board.every((cell) => cell != BoardCell.empty);
  }

  /// Whether the game has concluded (either by win or draw).
  bool get isGameOver => winner != null || isDraw;

  /// Returns a new [TicTacToeState] resulting from placing the current player's
  /// mark at [index]. Throws [ArgumentError] if the cell is already occupied or
  /// game is already over.
  TicTacToeState makeMove(int index) {
    if (isGameOver) {
      throw ArgumentError('Cannot make a move when the game is over');
    }
    if (index < 0 || index >= 9) {
      throw RangeError.range(index, 0, 8, 'index');
    }
    if (board[index] != BoardCell.empty) {
      throw ArgumentError('Cell $index is already occupied');
    }

    final newBoard = List<BoardCell>.from(board);
    newBoard[index] = BoardCell.fromPlayer(currentTurn);

    return TicTacToeState(
      board: List.unmodifiable(newBoard),
      currentTurn: currentTurn.opponent,
    );
  }
}
