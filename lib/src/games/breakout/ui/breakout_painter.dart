import 'dart:math';
import 'package:flutter/material.dart';
import '../logic/breakout_state.dart';

/// Renders the Breakout arena, paddle, ball, and bricks in 8-bit CRT pixel vector style.
class BreakoutPainter extends CustomPainter {
  BreakoutPainter({
    required this.state,
    this.primaryColor = const Color(0xFF00F0FF),
    this.ballColor = const Color(0xFFFFFFFF),
    this.ballGlowColor = const Color(0xFF00F0FF),
    this.gridColor = const Color(0xFF131728),
  });

  final BreakoutState state;
  final Color primaryColor;
  final Color ballColor;
  final Color ballGlowColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Maintain aspect ratio and center virtual arena
    final scale = min(
      size.width / state.arenaWidth,
      size.height / state.arenaHeight,
    );
    final offsetX = (size.width - state.arenaWidth * scale) / 2.0;
    final offsetY = (size.height - state.arenaHeight * scale) / 2.0;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    // 1. Draw subtle CRT background grid
    _drawBackgroundGrid(canvas);

    // 2. Draw 8-Bit Bricks
    _drawBricks(canvas);

    // 3. Draw 8-Bit Stepped Paddle
    _drawPaddle(canvas);

    // 4. Draw Pixel Ball
    _drawBall(canvas);

    canvas.restore();
  }

  void _drawBackgroundGrid(Canvas canvas) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x <= state.arenaWidth; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, state.arenaHeight), gridPaint);
    }
    for (double y = 0; y <= state.arenaHeight; y += step) {
      canvas.drawLine(Offset(0, y), Offset(state.arenaWidth, y), gridPaint);
    }
  }

  void _drawBricks(Canvas canvas) {
    for (final brick in state.bricks) {
      if (brick.isDestroyed) continue;

      final color = Color(brick.colorValue);
      final rect = Rect.fromLTWH(brick.x, brick.y, brick.width, brick.height);

      // Stepped 8-bit shadow
      final shadowRect = Rect.fromLTWH(
        brick.x + 2,
        brick.y + 2,
        brick.width,
        brick.height,
      );
      canvas.drawRect(
        shadowRect,
        Paint()..color = Colors.black.withValues(alpha: 0.6),
      );

      // Brick body
      canvas.drawRect(
        rect,
        Paint()..color = color.withValues(alpha: 0.85),
      );

      // Top/Left highlight for 3D retro bevel
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(brick.x, brick.y + brick.height),
        Offset(brick.x, brick.y),
        highlightPaint,
      );
      canvas.drawLine(
        Offset(brick.x, brick.y),
        Offset(brick.x + brick.width, brick.y),
        highlightPaint,
      );

      // Bottom/Right dark bevel
      final darkBevelPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(brick.x + brick.width, brick.y),
        Offset(brick.x + brick.width, brick.y + brick.height),
        darkBevelPaint,
      );
      canvas.drawLine(
        Offset(brick.x, brick.y + brick.height),
        Offset(brick.x + brick.width, brick.y + brick.height),
        darkBevelPaint,
      );
    }
  }

  void _drawPaddle(Canvas canvas) {
    final rect = Rect.fromLTWH(
      state.paddleX,
      state.paddleY,
      BreakoutState.paddleWidth,
      BreakoutState.paddleHeight,
    );

    // Phosphor glow
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      glowPaint,
    );

    // Stepped shadow
    canvas.drawRect(
      Rect.fromLTWH(
        state.paddleX + 2,
        state.paddleY + 2,
        BreakoutState.paddleWidth,
        BreakoutState.paddleHeight,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.8),
    );

    // Paddle body
    canvas.drawRect(
      rect,
      Paint()..color = primaryColor,
    );

    // Center grip indicator
    final gripPaint = Paint()
      ..color = const Color(0xFF090B14)
      ..strokeWidth = 2.0;
    final centerX = state.paddleX + BreakoutState.paddleWidth / 2;
    canvas.drawLine(
      Offset(centerX - 8, state.paddleY + 3),
      Offset(centerX - 8, state.paddleY + BreakoutState.paddleHeight - 3),
      gripPaint,
    );
    canvas.drawLine(
      Offset(centerX, state.paddleY + 2),
      Offset(centerX, state.paddleY + BreakoutState.paddleHeight - 2),
      gripPaint,
    );
    canvas.drawLine(
      Offset(centerX + 8, state.paddleY + 3),
      Offset(centerX + 8, state.paddleY + BreakoutState.paddleHeight - 3),
      gripPaint,
    );
  }

  void _drawBall(Canvas canvas) {
    final center = Offset(state.ballX, state.ballY);
    const r = BreakoutState.ballRadius;

    // Ball glow
    final glowPaint = Paint()
      ..color = ballGlowColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center, r + 2, glowPaint);

    // Pixel ball (square-styled for 8-bit feel)
    final ballRect = Rect.fromCenter(
      center: center,
      width: r * 2,
      height: r * 2,
    );
    canvas.drawRect(ballRect, Paint()..color = ballColor);
  }

  @override
  bool shouldRepaint(covariant BreakoutPainter oldDelegate) => true;
}
