import 'package:flutter/material.dart';
import 'retro_pixel_text.dart';

/// An authentic retro CRT scanline and vignette overlay for vintage screens.
class CrtScanlinesOverlay extends StatelessWidget {
  /// Creates a [CrtScanlinesOverlay].
  const CrtScanlinesOverlay({
    super.key,
    required this.child,
    this.scanlineOpacity = 0.10,
    this.vignetteOpacity = 0.35,
    this.curvature = true,
  });

  /// The child content underneath the scanlines.
  final Widget child;

  /// Opacity of the horizontal scanlines (0.0 to 1.0).
  final double scanlineOpacity;

  /// Opacity of the edge corner vignette (0.0 to 1.0).
  final double vignetteOpacity;

  /// Whether to render subtle CRT screen corner curvature.
  final bool curvature;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CrtScanlinesPainter(
                scanlineOpacity: scanlineOpacity,
                vignetteOpacity: vignetteOpacity,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CrtScanlinesPainter extends CustomPainter {
  const _CrtScanlinesPainter({
    required this.scanlineOpacity,
    required this.vignetteOpacity,
  });

  final double scanlineOpacity;
  final double vignetteOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Draw horizontal CRT scanlines
    final scanlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: scanlineOpacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double y = 0; y < size.height; y += 4.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanlinePaint);
    }

    // 2. Draw CRT vignette (radial darkening at screen perimeter)
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: vignetteOpacity),
        ],
        stops: const [0.65, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _CrtScanlinesPainter old) {
    return old.scanlineOpacity != scanlineOpacity ||
        old.vignetteOpacity != vignetteOpacity;
  }
}

/// A vintage 8-bit arcade card with hard stepped pixel drop-shadows and solid border.
class RetroPixelCard extends StatelessWidget {
  /// Creates a [RetroPixelCard].
  const RetroPixelCard({
    super.key,
    required this.child,
    this.borderColor = const Color(0xFF3B4468),
    this.backgroundColor = const Color(0xFF0F121E),
    this.shadowColor = Colors.black,
    this.borderWidth = 3.0,
    this.shadowOffset = 4.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  /// The child inside the card.
  final Widget child;

  /// Outline border color.
  final Color borderColor;

  /// Background fill color.
  final Color backgroundColor;

  /// Color of the hard stepped pixel drop shadow.
  final Color shadowColor;

  /// Thickness of the card border.
  final double borderWidth;

  /// Pixel offset of the stepped shadow.
  final double shadowOffset;

  /// Internal padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0, // Hard stepped retro shadow
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// A chunky 8-bit pushable arcade button with authentic stepped press mechanics.
class RetroPixelButton extends StatefulWidget {
  /// Creates a [RetroPixelButton].
  const RetroPixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = const Color(0xFF00F0FF),
    this.textColor = const Color(0xFF0F121E),
    this.pixelSize = 2.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.minWidth = 100.0,
    this.minHeight = 44.0,
  });

  /// The text label to display in [PixelText].
  final String label;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Button face color.
  final Color color;

  /// Text color.
  final Color textColor;

  /// Pixel size for the label.
  final double pixelSize;

  /// Internal padding.
  final EdgeInsetsGeometry padding;

  /// Minimum tap target width.
  final double minWidth;

  /// Minimum tap target height.
  final double minHeight;

  @override
  State<RetroPixelButton> createState() => _RetroPixelButtonState();
}

class _RetroPixelButtonState extends State<RetroPixelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final effectiveColor =
        isEnabled ? widget.color : widget.color.withValues(alpha: 0.3);
    const border = 3.0;
    const shadowDepth = 4.0;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel:
            isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          transform: Matrix4.translationValues(
            _isPressed ? 2.0 : 0.0,
            _isPressed ? 2.0 : 0.0,
            0.0,
          ),
          constraints: BoxConstraints(
            minWidth: widget.minWidth,
            minHeight: widget.minHeight,
          ),
          decoration: BoxDecoration(
            color: effectiveColor,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                offset: _isPressed
                    ? const Offset(1, 1)
                    : const Offset(shadowDepth, shadowDepth),
                blurRadius: 0,
              ),
            ],
          ),
          padding: widget.padding,
          child: Center(
            child: PixelText(
              widget.label,
              pixelSize: widget.pixelSize,
              color: widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
