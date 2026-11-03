import 'dart:math';

/// Movement direction for the snake.
enum Direction {
  /// Upward movement.
  up,

  /// Downward movement.
  down,

  /// Leftward movement.
  left,

  /// Rightward movement.
  right;

  /// Returns the opposite direction (e.g. left is opposite of right).
  Direction get opposite {
    return switch (this) {
      Direction.up => Direction.down,
      Direction.down => Direction.up,
      Direction.left => Direction.right,
      Direction.right => Direction.left,
    };
  }
}

/// 2D coordinate on the integer grid.
class GridPosition {
  /// Creates a [GridPosition].
  const GridPosition(this.x, this.y);

  /// Horizontal column index (0-indexed).
  final int x;

  /// Vertical row index (0-indexed).
  final int y;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x, $y)';
}

/// Pure-Dart immutable representation of the Snake game state.
class SnakeState {
  /// Creates a [SnakeState].
  const SnakeState({
    required this.gridWidth,
    required this.gridHeight,
    required this.body,
    required this.direction,
    required this.food,
    required this.score,
    this.isGameOver = false,
  });

  /// Total columns on the grid.
  final int gridWidth;

  /// Total rows on the grid.
  final int gridHeight;

  /// Segments of the snake from head (index 0) to tail.
  final List<GridPosition> body;

  /// Current heading direction.
  final Direction direction;

  /// Current coordinate of the target food item.
  final GridPosition food;

  /// Player's accrued score.
  final int score;

  /// Whether the game has ended due to a collision.
  final bool isGameOver;

  /// Creates a centered initial snake state with food placed via [random].
  factory SnakeState.initial({
    required Random random,
    int gridWidth = 20,
    int gridHeight = 20,
  }) {
    final startX = gridWidth ~/ 2;
    final startY = gridHeight ~/ 2;

    final initialBody = [
      GridPosition(startX, startY),
      GridPosition(startX - 1, startY),
      GridPosition(startX - 2, startY),
    ];

    final food = _spawnFood(initialBody, gridWidth, gridHeight, random);

    return SnakeState(
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      body: List.unmodifiable(initialBody),
      direction: Direction.right,
      food: food,
      score: 0,
      isGameOver: false,
    );
  }

  /// Updates heading direction, preventing instant 180-degree self-collision.
  SnakeState changeDirection(Direction newDirection) {
    if (newDirection == direction.opposite || isGameOver) {
      return this;
    }

    return SnakeState(
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      body: body,
      direction: newDirection,
      food: food,
      score: score,
      isGameOver: isGameOver,
    );
  }

  /// Advances the game by one tick in [direction].
  SnakeState step({required Random random}) {
    if (isGameOver) return this;

    final head = body.first;
    final nextX = switch (direction) {
      Direction.left => head.x - 1,
      Direction.right => head.x + 1,
      _ => head.x,
    };
    final nextY = switch (direction) {
      Direction.up => head.y - 1,
      Direction.down => head.y + 1,
      _ => head.y,
    };

    final newHead = GridPosition(nextX, nextY);

    // Wall collision
    if (nextX < 0 || nextX >= gridWidth || nextY < 0 || nextY >= gridHeight) {
      return SnakeState(
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        body: body,
        direction: direction,
        food: food,
        score: score,
        isGameOver: true,
      );
    }

    // Self collision
    final hitsSelf = body.take(body.length - 1).contains(newHead);
    if (hitsSelf) {
      return SnakeState(
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        body: body,
        direction: direction,
        food: food,
        score: score,
        isGameOver: true,
      );
    }

    final newBody = <GridPosition>[newHead, ...body];

    // Food collision
    if (newHead == food) {
      final newScore = score + 10;
      final nextFood = _spawnFood(newBody, gridWidth, gridHeight, random);

      return SnakeState(
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        body: List.unmodifiable(newBody),
        direction: direction,
        food: nextFood,
        score: newScore,
        isGameOver: false,
      );
    } else {
      newBody.removeLast(); // Maintain length
      return SnakeState(
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        body: List.unmodifiable(newBody),
        direction: direction,
        food: food,
        score: score,
        isGameOver: false,
      );
    }
  }

  static GridPosition _spawnFood(
    List<GridPosition> occupied,
    int width,
    int height,
    Random random,
  ) {
    final emptySpots = <GridPosition>[];
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        final pos = GridPosition(x, y);
        if (!occupied.contains(pos)) {
          emptySpots.add(pos);
        }
      }
    }

    if (emptySpots.isEmpty) {
      return const GridPosition(0, 0);
    }

    return emptySpots[random.nextInt(emptySpots.length)];
  }
}
