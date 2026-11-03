import 'package:flutter/material.dart';

/// A Clash of Clans-inspired retro cloud sweep transition.
///
/// Billowy cartoon pixel clouds sweep in from both sides of the screen to
/// completely envelop the view, trigger a state/view switch at peak coverage,
/// and then smoothly part away to reveal the arcade game.
class RetroCloudSweep extends StatefulWidget {
  /// Creates a [RetroCloudSweep].
  const RetroCloudSweep({
    super.key,
    required this.isSweeping,
    required this.onMidpointReached,
    this.onComplete,
    this.duration = const Duration(milliseconds: 800),
  });

  /// When true, activates the cloud sweep transition.
  final bool isSweeping;

  /// Invoked at the exact midpoint when the screen is 100% enveloped in clouds.
  final VoidCallback onMidpointReached;

  /// Invoked when the clouds have completely cleared the screen.
  final VoidCallback? onComplete;

  /// Total duration of the in-and-out sweep.
  final Duration duration;

  @override
  State<RetroCloudSweep> createState() => _RetroCloudSweepState();
}

class _RetroCloudSweepState extends State<RetroCloudSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasTriggeredMidpoint = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addListener(_checkMidpoint);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.isSweeping) {
      _startSweep();
    }
  }

  @override
  void didUpdateWidget(RetroCloudSweep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isSweeping && widget.isSweeping) {
      _startSweep();
    }
  }

  void _startSweep() {
    _hasTriggeredMidpoint = false;
    _controller.forward(from: 0.0);
  }

  void _checkMidpoint() {
    if (!_hasTriggeredMidpoint && _controller.value >= 0.5) {
      _hasTriggeredMidpoint = true;
      widget.onMidpointReached();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.value == 0.0 || _controller.value == 1.0) {
          return const SizedBox.shrink();
        }

        return Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: CustomPaint(
              painter: _ClashCloudsPainter(progress: _controller.value),
            ),
          ),
        );
      },
    );
  }
}

class _ClashCloudsPainter extends CustomPainter {
  const _ClashCloudsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Phase 1 (0.0 -> 0.5): Closing clouds (0.0 to 1.0 coverage)
    // Phase 2 (0.5 -> 1.0): Opening clouds (1.0 to 0.0 coverage)
    final double coverage;
    if (progress <= 0.5) {
      // Ease out cubic inwards
      final t = progress / 0.5;
      coverage = Curves.easeOutCubic.transform(t);
    } else {
      // Ease in cubic outwards
      final t = (progress - 0.5) / 0.5;
      coverage = 1.0 - Curves.easeInCubic.transform(t);
    }

    final halfW = size.width / 2.0;

    // Distance that each cloud bank has advanced towards center
    // coverage = 0.0 => offscreen by extra margin
    // coverage = 1.0 => overlapping in the center
    final extraMargin = size.width * 0.35;
    final leftX = -extraMargin + (halfW + extraMargin * 1.2) * coverage;
    final rightX =
        (size.width + extraMargin) - (halfW + extraMargin * 1.2) * coverage;

    // 1. Draw Left Cloud Bank
    _drawCloudBank(
      canvas: canvas,
      size: size,
      edgeX: leftX,
      isLeft: true,
    );

    // 2. Draw Right Cloud Bank
    _drawCloudBank(
      canvas: canvas,
      size: size,
      edgeX: rightX,
      isLeft: false,
    );

    // // 3. Peak Coverage Retro Banner
    // if (progress >= 0.42 && progress <= 0.58) {
    //   final bannerPaint = Paint()
    //     ..color = Colors.black.withValues(alpha: 0.85);
    //   final borderPaint = Paint()
    //     ..color = const Color(0xFF00F0FF)
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 2.0;

    //   final bannerRect = Rect.fromCenter(
    //     center: Offset(halfW, h / 2.0),
    //     width: 190,
    //     height: 48,
    //   );

    //   canvas.drawRect(bannerRect, bannerPaint);
    //   canvas.drawRect(bannerRect, borderPaint);

    //   final textPainter = TextPainter(
    //     text: const TextSpan(
    //       text: 'WARPING...',
    //       style: TextStyle(
    //         color: Color(0xFF00F0FF),
    //         fontSize: 16,
    //         fontWeight: FontWeight.bold,
    //         letterSpacing: 3,
    //         decoration: TextDecoration.none,
    //       ),
    //     ),
    //     textDirection: TextDirection.ltr,
    //   )..layout();

    //   textPainter.paint(
    //     canvas,
    //     Offset(
    //       halfW - textPainter.width / 2.0,
    //       h / 2.0 - textPainter.height / 2.0,
    //     ),
    //   );
    // }
  }

  void _drawCloudBank({
    required Canvas canvas,
    required Size size,
    required double edgeX,
    required bool isLeft,
  }) {
    final bodyPaint = Paint()..color = Colors.white;
    final shadePaint = Paint()..color = const Color(0xFFB2EBF2);
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.25);
    final outlinePaint = Paint()
      ..color = const Color(0xFF090B14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final baseRect = isLeft
        ? Rect.fromLTWH(-100, 0, edgeX + 100, size.height)
        : Rect.fromLTWH(edgeX, 0, size.width - edgeX + 100, size.height);

    // Draw main cloud backing
    canvas.drawRect(baseRect, bodyPaint);

    // Cloud puffs along vertical leading edge
    const numPuffs = 9;
    final stepY = size.height / (numPuffs - 1);

    for (int i = 0; i < numPuffs; i++) {
      final y = i * stepY;
      // Stagger radius to create billowing cartoon shape
      final radius =
          ((i % 2 == 0) ? 62.0 : 48.0) * (size.height / 600.0).clamp(0.8, 1.4);
      final puffCenter = Offset(edgeX, y);

      // Shadow
      canvas.drawCircle(
        puffCenter + const Offset(3, 4),
        radius,
        shadowPaint,
      );

      // Shaded underside
      canvas.drawCircle(
        puffCenter + const Offset(0, 3),
        radius,
        shadePaint,
      );

      // Main puff
      canvas.drawCircle(
        puffCenter,
        radius,
        bodyPaint,
      );

      // Stepped cartoon outline
      canvas.drawCircle(
        puffCenter,
        radius,
        outlinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ClashCloudsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
