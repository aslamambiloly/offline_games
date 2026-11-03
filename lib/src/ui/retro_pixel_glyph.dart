import 'package:flutter/material.dart';

/// Available 8-bit retro pixel vector glyphs for arcade games and cards.
enum PixelGlyphType {
  alien('Alien Invader', Color(0xFF00F0FF), [
    0x24,
    0x18,
    0x7E,
    0xDB,
    0xFF,
    0xBD,
    0xA5,
    0x18,
  ]),
  heart('Heart', Color(0xFFFF2A85), [
    0x66,
    0xFF,
    0xFF,
    0xFF,
    0x7E,
    0x3C,
    0x18,
    0x00,
  ]),
  sword('Sword', Color(0xFF4D96FF), [
    0x03,
    0x06,
    0x0C,
    0x18,
    0x30,
    0x78,
    0x30,
    0x40,
  ]),
  coin('Gold Coin', Color(0xFFFFD700), [
    0x3C,
    0x7E,
    0xDB,
    0xDB,
    0xDB,
    0xDB,
    0x7E,
    0x3C,
  ]),
  potion('Magic Potion', Color(0xFFA29BFE), [
    0x18,
    0x18,
    0x3C,
    0x66,
    0x7E,
    0x7E,
    0x3C,
    0x00,
  ]),
  skull('Skull', Color(0xFFF1F2F6), [
    0x3C,
    0x7E,
    0xDB,
    0xFF,
    0x7E,
    0x3C,
    0x2A,
    0x00,
  ]),
  star('Star', Color(0xFFFFEA79), [
    0x18,
    0x18,
    0xFF,
    0x7E,
    0x3C,
    0x66,
    0xC3,
    0x00,
  ]),
  gamepad('Joystick', Color(0xFF00FFA3), [
    0x7E,
    0xFF,
    0xA5,
    0xFF,
    0xFF,
    0xC3,
    0x81,
    0x00,
  ]),
  apple('Apple', Color(0xFFFF3838), [
    0x0C,
    0x18,
    0x7E,
    0xFF,
    0xFF,
    0xFF,
    0x7E,
    0x3C,
  ]),
  trophy('Trophy', Color(0xFFFFB800), [
    0xFF,
    0xFF,
    0x7E,
    0x3C,
    0x18,
    0x18,
    0x3C,
    0x7E,
  ]),
  cross('Cross', Color(0xFF00F0FF), [
    0xC3,
    0xE7,
    0x7E,
    0x3C,
    0x3C,
    0x7E,
    0xE7,
    0xC3,
  ]),
  ring('Ring', Color(0xFFFF2A85), [
    0x3C,
    0x7E,
    0xE7,
    0xC3,
    0xC3,
    0xE7,
    0x7E,
    0x3C,
  ]);

  const PixelGlyphType(this.semanticsLabel, this.defaultColor, this.bitmap);

  final String semanticsLabel;
  final Color defaultColor;
  final List<int> bitmap;
}

/// A standalone widget that renders an 8x8 retro vector pixel glyph.
class PixelGlyphWidget extends StatelessWidget {
  /// Creates a [PixelGlyphWidget].
  const PixelGlyphWidget({
    super.key,
    required this.type,
    this.pixelSize = 4.0,
    this.color,
    this.glow = true,
  });

  /// The glyph type to draw.
  final PixelGlyphType type;

  /// Size of each pixel cell.
  final double pixelSize;

  /// Optional override color; defaults to [PixelGlyphType.defaultColor].
  final Color? color;

  /// Whether to render a CRT phosphor glow.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? type.defaultColor;

    return Semantics(
      label: type.semanticsLabel,
      child: CustomPaint(
        size: Size(8 * pixelSize, 8 * pixelSize),
        painter: _PixelGlyphPainter(
          bitmap: type.bitmap,
          color: effectiveColor,
          pixelSize: pixelSize,
          glow: glow,
        ),
      ),
    );
  }
}

class _PixelGlyphPainter extends CustomPainter {
  const _PixelGlyphPainter({
    required this.bitmap,
    required this.color,
    required this.pixelSize,
    required this.glow,
  });

  final List<int> bitmap;
  final Color color;
  final double pixelSize;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Paint? glowPaint;
    if (glow) {
      glowPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    }

    for (int row = 0; row < 8; row++) {
      final bits = bitmap[row];
      for (int col = 0; col < 8; col++) {
        if ((bits & (1 << (7 - col))) != 0) {
          final rect = Rect.fromLTWH(
            col * pixelSize,
            row * pixelSize,
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
  }

  @override
  bool shouldRepaint(covariant _PixelGlyphPainter old) {
    return old.bitmap != bitmap ||
        old.color != color ||
        old.pixelSize != pixelSize ||
        old.glow != glow;
  }
}
