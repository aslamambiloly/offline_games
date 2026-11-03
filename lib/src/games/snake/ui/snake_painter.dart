import 'package:flutter/material.dart';
import '../logic/snake_state.dart';

/// High-performance [CustomPainter] that renders the Snake arena, pixel segments, and 8-bit food.
class SnakePainter extends CustomPainter {
  /// Creates a [SnakePainter].
  const SnakePainter({
    required this.state,
    this.primaryColor = const Color(0xFF39FF14),
    this.accentColor = const Color(0xFFFF2A85),
    this.gridColor = const Color(0xFF1B2238),
  });

  /// The active state of the snake game.
  final SnakeState state;

  /// Phosphor green / neon color for the snake.
  final Color primaryColor;

  /// Neon color for the food.
  final Color accentColor;

  /// Color used for the CRT grid lines.
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / state.gridWidth;
    final cellHeight = size.height / state.gridHeight;

    // 1. Draw retro CRT radar / grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var x = 0; x <= state.gridWidth; x++) {
      canvas.drawLine(
        Offset(x * cellWidth, 0),
        Offset(x * cellWidth, size.height),
        gridPaint,
      );
    }
    for (var y = 0; y <= state.gridHeight; y++) {
      canvas.drawLine(
        Offset(0, y * cellHeight),
        Offset(size.width, y * cellHeight),
        gridPaint,
      );
    }

    // 2. Draw 8-Bit Vector Pixel Food (Apple with green stem pixel)
    _drawPixelApple(canvas, state.food.x * cellWidth, state.food.y * cellHeight,
        cellWidth, cellHeight);

    // 3. Draw Snake Body (Chunky retro pixel blocks with highlights)
    final bodyPaint = Paint()..style = PaintingStyle.fill;
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    for (var i = state.body.length - 1; i >= 0; i--) {
      final pos = state.body[i];
      final isHead = i == 0;

      final cellX = pos.x * cellWidth;
      final cellY = pos.y * cellHeight;

      if (isHead) {
        // Glowing neon head block
        bodyPaint.color = primaryColor;
        final headRect = Rect.fromLTWH(
          cellX + 1,
          cellY + 1,
          cellWidth - 2,
          cellHeight - 2,
        );
        canvas.drawRect(headRect, bodyPaint);

        // Head highlight pixel
        canvas.drawRect(
          Rect.fromLTWH(cellX + 2, cellY + 2, 2, 2),
          highlightPaint,
        );

        // 2-pixel retro eyes oriented according to direction
        _drawSnakeEyes(
            canvas, cellX, cellY, cellWidth, cellHeight, state.direction);
      } else {
        // Segmented body blocks with slight retro alpha gradient
        final alpha = 0.90 - (i / state.body.length) * 0.35;
        bodyPaint.color = primaryColor.withValues(alpha: alpha);

        final segmentRect = Rect.fromLTWH(
          cellX + 1.5,
          cellY + 1.5,
          cellWidth - 3,
          cellHeight - 3,
        );
        canvas.drawRect(segmentRect, bodyPaint);
      }
    }
  }

  void _drawPixelApple(Canvas canvas, double x, double y, double w, double h) {
    final foodPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final stemPaint = Paint()
      ..color = const Color(0xFF39FF14)
      ..style = PaintingStyle.fill;

    // Stem pixel
    canvas.drawRect(
      Rect.fromLTWH(x + w * 0.5 - 1, y + 1, 2, h * 0.25),
      stemPaint,
    );

    // Apple body
    final appleRect = Rect.fromLTWH(
      x + 2,
      y + h * 0.25,
      w - 4,
      h * 0.75 - 2,
    );
    canvas.drawRect(appleRect, glowPaint);
    canvas.drawRect(appleRect, foodPaint);

    // Pixel shine
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(x + 3.5, y + h * 0.35, 2, 2),
      shinePaint,
    );
  }

  void _drawSnakeEyes(
      Canvas canvas, double x, double y, double w, double h, Direction dir) {
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    double e1x, e1y, e2x, e2y;

    switch (dir) {
      case Direction.up:
        e1x = x + 3;
        e1y = y + 3;
        e2x = x + w - 5;
        e2y = y + 3;
      case Direction.down:
        e1x = x + 3;
        e1y = y + h - 5;
        e2x = x + w - 5;
        e2y = y + h - 5;
      case Direction.left:
        e1x = x + 3;
        e1y = y + 3;
        e2x = x + 3;
        e2y = y + h - 5;
      case Direction.right:
        e1x = x + w - 5;
        e1y = y + 3;
        e2x = x + w - 5;
        e2y = y + h - 5;
    }

    canvas.drawRect(Rect.fromLTWH(e1x, e1y, 2, 2), eyePaint);
    canvas.drawRect(Rect.fromLTWH(e2x, e2y, 2, 2), eyePaint);
  }

  @override
  bool shouldRepaint(covariant SnakePainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.gridColor != gridColor;
  }
}
