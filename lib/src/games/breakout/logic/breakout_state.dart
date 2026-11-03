import 'dart:math';

/// A single destructible brick in the Breakout arena.
class BreakoutBrick {
  BreakoutBrick({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.points,
    required this.colorValue,
  });

  final double x;
  final double y;
  final double width;
  final double height;
  final int points;
  final int colorValue;

  bool isDestroyed = false;

  bool intersects(double bx, double by, double radius) {
    if (isDestroyed) return false;
    final closestX = bx.clamp(x, x + width);
    final closestY = by.clamp(y, y + height);
    final dx = bx - closestX;
    final dy = by - closestY;
    return (dx * dx + dy * dy) <= (radius * radius);
  }
}

/// Pure Dart state model and physics simulation for the Breakout game.
class BreakoutState {
  BreakoutState({
    this.arenaWidth = 300.0,
    this.arenaHeight = 400.0,
    Random? random,
  }) : _random = random ?? Random() {
    _initGame();
  }

  final double arenaWidth;
  final double arenaHeight;
  final Random _random;

  static const double paddleWidth = 64.0;
  static const double paddleHeight = 10.0;
  static const double ballRadius = 4.0;
  static const double baseBallSpeed = 220.0;

  late double paddleX;
  late double paddleY;

  late double ballX;
  late double ballY;
  late double ballVx;
  late double ballVy;

  late List<BreakoutBrick> bricks;

  int lives = 3;
  int score = 0;
  bool isLaunched = false;
  bool isGameOver = false;
  bool isWon = false;

  int get remainingBricks => bricks.where((b) => !b.isDestroyed).length;

  void _initGame() {
    paddleY = arenaHeight - 36.0;
    paddleX = (arenaWidth - paddleWidth) / 2.0;

    _resetBall();
    _buildBricks();
  }

  void _resetBall() {
    ballX = paddleX + paddleWidth / 2.0;
    ballY = paddleY - ballRadius - 2.0;
    final angle = (_random.nextDouble() * 0.6 - 0.3) * pi; // -54 to +54 deg
    ballVx = baseBallSpeed * sin(angle);
    ballVy = -baseBallSpeed * cos(angle).abs();
    isLaunched = false;
  }

  void _buildBricks() {
    bricks = <BreakoutBrick>[];
    const rows = 5;
    const cols = 6;
    const padding = 4.0;
    const topMargin = 40.0;
    final brickWidth = (arenaWidth - padding * (cols + 1)) / cols;
    const brickHeight = 14.0;

    const rowColors = [
      0xFFFF2A85, // Magenta
      0xFFFF5E3A, // Coral/Orange
      0xFFFFD700, // Gold
      0xFF39FF14, // Phosphor Green
      0xFF00F0FF, // Neon Cyan
    ];

    const rowPoints = [50, 40, 30, 20, 10];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = padding + c * (brickWidth + padding);
        final y = topMargin + r * (brickHeight + padding);
        bricks.add(BreakoutBrick(
          x: x,
          y: y,
          width: brickWidth,
          height: brickHeight,
          points: rowPoints[r],
          colorValue: rowColors[r],
        ));
      }
    }
  }

  /// Launches the ball if currently resting on the paddle.
  void launch() {
    if (!isLaunched && !isGameOver && !isWon) {
      isLaunched = true;
    }
  }

  /// Sets the paddle horizontal center coordinate.
  void setPaddleCenter(double targetCenterX) {
    paddleX = (targetCenterX - paddleWidth / 2.0)
        .clamp(0.0, arenaWidth - paddleWidth);
    if (!isLaunched) {
      ballX = paddleX + paddleWidth / 2.0;
    }
  }

  /// Moves the paddle horizontally by [dx].
  void movePaddleBy(double dx) {
    setPaddleCenter(paddleX + paddleWidth / 2.0 + dx);
  }

  /// Advances physics simulation by time delta [dt] seconds.
  void update(double dt) {
    if (!isLaunched || isGameOver || isWon) return;

    final prevX = ballX;
    final prevY = ballY;

    ballX += ballVx * dt;
    ballY += ballVy * dt;

    // 1. Wall Collisions
    if (ballX - ballRadius <= 0) {
      ballX = ballRadius;
      ballVx = ballVx.abs();
    } else if (ballX + ballRadius >= arenaWidth) {
      ballX = arenaWidth - ballRadius;
      ballVx = -ballVx.abs();
    }

    if (ballY - ballRadius <= 0) {
      ballY = ballRadius;
      ballVy = ballVy.abs();
    }

    // 2. Bottom Floor (Life lost)
    if (ballY + ballRadius >= arenaHeight) {
      lives--;
      if (lives <= 0) {
        isGameOver = true;
      } else {
        _resetBall();
      }
      return;
    }

    // 3. Paddle Collision
    if (ballVy > 0 &&
        ballY + ballRadius >= paddleY &&
        ballY - ballRadius <= paddleY + paddleHeight &&
        ballX + ballRadius >= paddleX &&
        ballX - ballRadius <= paddleX + paddleWidth) {
      ballY = paddleY - ballRadius;

      // Influence angle by hit position (-1.0 to 1.0)
      final hitPos =
          (ballX - (paddleX + paddleWidth / 2.0)) / (paddleWidth / 2.0);
      final clampedHit = hitPos.clamp(-1.0, 1.0);
      const maxAngle = 55.0 * (pi / 180.0);
      final bounceAngle = clampedHit * maxAngle;

      final currentSpeed = sqrt(ballVx * ballVx + ballVy * ballVy);
      final newSpeed = (currentSpeed * 1.01).clamp(baseBallSpeed, 360.0);

      ballVx = newSpeed * sin(bounceAngle);
      ballVy = -newSpeed * cos(bounceAngle).abs();
      return;
    }

    // 4. Brick Collision
    for (final brick in bricks) {
      if (brick.intersects(ballX, ballY, ballRadius)) {
        brick.isDestroyed = true;
        score += brick.points;

        // Determine bounce axis based on previous position
        final wasOutsideX = prevX + ballRadius < brick.x ||
            prevX - ballRadius > brick.x + brick.width;
        final wasOutsideY = prevY + ballRadius < brick.y ||
            prevY - ballRadius > brick.y + brick.height;

        if (wasOutsideX && !wasOutsideY) {
          ballVx = -ballVx;
        } else {
          ballVy = -ballVy;
        }

        // Slight speed boost
        final currentSpeed = sqrt(ballVx * ballVx + ballVy * ballVy);
        final newSpeed = (currentSpeed * 1.008).clamp(baseBallSpeed, 380.0);
        final speedFactor = newSpeed / currentSpeed;
        ballVx *= speedFactor;
        ballVy *= speedFactor;

        // Check Victory
        if (remainingBricks == 0) {
          isWon = true;
          isGameOver = true;
          score += 200; // Victory clear bonus
        }
        break; // Only collide with one brick per frame
      }
    }
  }

  /// Resets the game to initial state for a replay.
  void restart() {
    lives = 3;
    score = 0;
    isGameOver = false;
    isWon = false;
    paddleX = (arenaWidth - paddleWidth) / 2.0;
    _buildBricks();
    _resetBall();
  }
}
