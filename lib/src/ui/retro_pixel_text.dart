import 'package:flutter/material.dart';

/// A pure vector-based 5x7 arcade pixel font renderer with zero external dependencies.
///
/// Draws authentic 8-bit arcade text at any scale with optional CRT phosphor glow.
class PixelText extends StatelessWidget {
  /// Creates a [PixelText] widget.
  const PixelText(
    this.text, {
    super.key,
    this.pixelSize = 2.0,
    this.color = const Color(0xFF39FF14),
    this.glowColor,
    this.glowRadius = 4.0,
    this.letterSpacing = 2.0,
    this.lineSpacing = 4.0,
    this.textAlign = TextAlign.left,
  });

  /// The text string to render (supports uppercase A-Z, 0-9, and punctuation).
  final String text;

  /// The dimension of each square pixel in logical pixels.
  final double pixelSize;

  /// The primary color of the pixels.
  final Color color;

  /// Optional CRT phosphor glow color.
  final Color? glowColor;

  /// Blur radius for the CRT glow effect.
  final double glowRadius;

  /// Spacing between adjacent letters in logical pixels.
  final double letterSpacing;

  /// Spacing between consecutive lines in logical pixels.
  final double lineSpacing;

  /// Horizontal text alignment for multi-line text.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final size = _calculateSize();
    return Semantics(
      label: text,
      container: true,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Transparent text for native widget testing and layout (no underlines)
            ExcludeSemantics(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.transparent,
                  fontSize: size.height > 0 ? size.height * 0.8 : 1,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _PixelTextPainter(
                    text: text.toUpperCase(),
                    pixelSize: pixelSize,
                    color: color,
                    glowColor: glowColor,
                    glowRadius: glowRadius,
                    letterSpacing: letterSpacing,
                    lineSpacing: lineSpacing,
                    textAlign: textAlign,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Size _calculateSize() {
    final lines = text.split('\n');
    double maxWidth = 0;
    const charWidth = 5;
    const charHeight = 7;

    for (final line in lines) {
      if (line.isEmpty) continue;
      final w = line.length * (charWidth * pixelSize) +
          (line.length - 1) * letterSpacing;
      if (w > maxWidth) maxWidth = w;
    }

    final totalHeight = lines.length * (charHeight * pixelSize) +
        (lines.length - 1) * lineSpacing;

    return Size(maxWidth, totalHeight);
  }
}

class _PixelTextPainter extends CustomPainter {
  const _PixelTextPainter({
    required this.text,
    required this.pixelSize,
    required this.color,
    required this.glowColor,
    required this.glowRadius,
    required this.letterSpacing,
    required this.lineSpacing,
    required this.textAlign,
  });

  final String text;
  final double pixelSize;
  final Color color;
  final Color? glowColor;
  final double glowRadius;
  final double letterSpacing;
  final double lineSpacing;
  final TextAlign textAlign;

  static const int charWidth = 5;
  static const int charHeight = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final lines = text.split('\n');
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Paint? glowPaint;
    if (glowColor != null) {
      glowPaint = Paint()
        ..color = glowColor!
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);
    }

    double yOffset = 0;

    for (final line in lines) {
      final lineWidth = line.length * (charWidth * pixelSize) +
          (line.length - 1) * letterSpacing;

      double xOffset = 0;
      if (textAlign == TextAlign.center) {
        xOffset = (size.width - lineWidth) / 2;
      } else if (textAlign == TextAlign.right) {
        xOffset = size.width - lineWidth;
      }

      for (int i = 0; i < line.length; i++) {
        final char = line[i];
        final glyph = _pixelFont[char] ?? _pixelFont['?']!;

        for (int row = 0; row < charHeight; row++) {
          final rowBits = glyph[row];
          for (int col = 0; col < charWidth; col++) {
            // Check if bit at (4 - col) is set
            if ((rowBits & (1 << (4 - col))) != 0) {
              final rect = Rect.fromLTWH(
                xOffset + (col * pixelSize),
                yOffset + (row * pixelSize),
                pixelSize,
                pixelSize,
              );

              if (glowPaint != null) {
                canvas.drawRect(rect, glowPaint);
              }
              canvas.drawRect(rect, paint);
            }
          }
        }

        xOffset += (charWidth * pixelSize) + letterSpacing;
      }

      yOffset += (charHeight * pixelSize) + lineSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant _PixelTextPainter old) {
    return old.text != text ||
        old.pixelSize != pixelSize ||
        old.color != color ||
        old.glowColor != glowColor ||
        old.glowRadius != glowRadius ||
        old.letterSpacing != letterSpacing ||
        old.lineSpacing != lineSpacing ||
        old.textAlign != textAlign;
  }
}

/// 5x7 bitmask font map for alphanumeric arcade typography.
const Map<String, List<int>> _pixelFont = {
  ' ': [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
  'A': [0x0E, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11],
  'B': [0x1E, 0x11, 0x11, 0x1E, 0x11, 0x11, 0x1E],
  'C': [0x0E, 0x11, 0x10, 0x10, 0x10, 0x11, 0x0E],
  'D': [0x1C, 0x12, 0x11, 0x11, 0x11, 0x12, 0x1C],
  'E': [0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x1F],
  'F': [0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x10],
  'G': [0x0E, 0x11, 0x10, 0x17, 0x11, 0x11, 0x0F],
  'H': [0x11, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11],
  'I': [0x0E, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0E],
  'J': [0x07, 0x02, 0x02, 0x02, 0x02, 0x12, 0x0C],
  'K': [0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11],
  'L': [0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1F],
  'M': [0x11, 0x1B, 0x15, 0x15, 0x11, 0x11, 0x11],
  'N': [0x11, 0x11, 0x19, 0x15, 0x13, 0x11, 0x11],
  'O': [0x0E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E],
  'P': [0x1E, 0x11, 0x11, 0x1E, 0x10, 0x10, 0x10],
  'Q': [0x0E, 0x11, 0x11, 0x11, 0x15, 0x12, 0x0D],
  'R': [0x1E, 0x11, 0x11, 0x1E, 0x14, 0x12, 0x11],
  'S': [0x0F, 0x10, 0x10, 0x0E, 0x01, 0x01, 0x1E],
  'T': [0x1F, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04],
  'U': [0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E],
  'V': [0x11, 0x11, 0x11, 0x11, 0x11, 0x0A, 0x04],
  'W': [0x11, 0x11, 0x11, 0x15, 0x15, 0x15, 0x0A],
  'X': [0x11, 0x11, 0x0A, 0x04, 0x0A, 0x11, 0x11],
  'Y': [0x11, 0x11, 0x0A, 0x04, 0x04, 0x04, 0x04],
  'Z': [0x1F, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1F],
  '0': [0x0E, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0E],
  '1': [0x04, 0x0C, 0x04, 0x04, 0x04, 0x04, 0x0E],
  '2': [0x0E, 0x11, 0x01, 0x06, 0x08, 0x10, 0x1F],
  '3': [0x1F, 0x02, 0x04, 0x02, 0x01, 0x11, 0x0E],
  '4': [0x02, 0x06, 0x0A, 0x12, 0x1F, 0x02, 0x02],
  '5': [0x1F, 0x10, 0x1E, 0x01, 0x01, 0x11, 0x0E],
  '6': [0x06, 0x08, 0x10, 0x1E, 0x11, 0x11, 0x0E],
  '7': [0x1F, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08],
  '8': [0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E],
  '9': [0x0E, 0x11, 0x11, 0x0F, 0x01, 0x02, 0x0C],
  ':': [0x00, 0x0C, 0x0C, 0x00, 0x0C, 0x0C, 0x00],
  '!': [0x04, 0x04, 0x04, 0x04, 0x00, 0x04, 0x00],
  '?': [0x0E, 0x11, 0x01, 0x02, 0x04, 0x00, 0x04],
  '-': [0x00, 0x00, 0x00, 0x1F, 0x00, 0x00, 0x00],
  '+': [0x00, 0x04, 0x04, 0x1F, 0x04, 0x04, 0x00],
  '.': [0x00, 0x00, 0x00, 0x00, 0x00, 0x0C, 0x0C],
  '/': [0x01, 0x02, 0x02, 0x04, 0x08, 0x08, 0x10],
  '#': [0x0A, 0x0A, 0x1F, 0x0A, 0x1F, 0x0A, 0x0A],
  '*': [0x00, 0x15, 0x0E, 0x1F, 0x0E, 0x15, 0x00],
  '(': [0x02, 0x04, 0x08, 0x08, 0x08, 0x04, 0x02],
  ')': [0x08, 0x04, 0x02, 0x02, 0x02, 0x04, 0x08],
  '<': [0x02, 0x04, 0x08, 0x10, 0x08, 0x04, 0x02],
  '>': [0x08, 0x04, 0x02, 0x01, 0x02, 0x04, 0x08],
  "'": [0x04, 0x04, 0x08, 0x00, 0x00, 0x00, 0x00],
  ',': [0x00, 0x00, 0x00, 0x00, 0x04, 0x04, 0x08],
  '"': [0x0A, 0x0A, 0x14, 0x00, 0x00, 0x00, 0x00],
  '_': [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1F],
  '@': [0x0E, 0x11, 0x17, 0x15, 0x17, 0x10, 0x0F],
  '%': [0x19, 0x19, 0x02, 0x04, 0x08, 0x13, 0x13],
  r'$': [0x04, 0x0F, 0x14, 0x0E, 0x05, 0x1E, 0x04],
};
