import 'package:flutter/material.dart';
import '../logic/snake_state.dart';

/// High-performance [CustomPainter] that renders the Snake arena, segments, and food.
class SnakePainter extends CustomPainter {
  /// Creates a [SnakePainter].
  const SnakePainter({
    required this.state,
    required this.primaryColor,
    required this.accentColor,
    required this.gridColor,
  });

  /// The active state of the snake game.
  final SnakeState state;

  /// Color used for the snake body and head.
  final Color primaryColor;

  /// Color used for the food item.
  final Color accentColor;

  /// Color used for the background grid matrix.
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / state.gridWidth;
    final cellHeight = size.height / state.gridHeight;

    // Draw subtle grid dots/lines
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

    // Draw food (glowing arcade apple/orb)
    final foodRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        state.food.x * cellWidth + 2,
        state.food.y * cellHeight + 2,
        cellWidth - 4,
        cellHeight - 4,
      ),
      const Radius.circular(6),
    );

    final foodPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(foodRect, foodPaint);

    // Draw snake body
    final bodyPaint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < state.body.length; i++) {
      final pos = state.body[i];
      final isHead = i == 0;

      final segmentRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          pos.x * cellWidth + (isHead ? 1 : 2),
          pos.y * cellHeight + (isHead ? 1 : 2),
          cellWidth - (isHead ? 2 : 4),
          cellHeight - (isHead ? 2 : 4),
        ),
        Radius.circular(isHead ? 6 : 4),
      );

      bodyPaint.color = isHead
          ? primaryColor
          : primaryColor.withValues(
              alpha: 0.75 - (i / state.body.length) * 0.4);

      canvas.drawRRect(segmentRect, bodyPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SnakePainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}
