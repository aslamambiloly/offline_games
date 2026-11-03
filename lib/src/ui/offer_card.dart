import 'package:flutter/material.dart';
import 'retro_pixel_glyph.dart';
import 'retro_pixel_text.dart';
import 'retro_screen.dart';

/// Dismissible offer card presented when the device loses internet connectivity,
/// styled with authentic retro 8-bit pixel vectors.
class OfflineOfferCard extends StatefulWidget {
  /// Creates an [OfflineOfferCard].
  const OfflineOfferCard({
    super.key,
    required this.onPlay,
    required this.onDismiss,
    this.actionLabel = 'Spin',
  });

  /// Action when player taps the primary button (Spin / Play).
  final VoidCallback onPlay;

  /// Action when player dismisses the card.
  final VoidCallback onDismiss;

  /// Button label for the primary action (e.g. 'Spin' or 'Play').
  final String actionLabel;

  @override
  State<OfflineOfferCard> createState() => _OfflineOfferCardState();
}

class _OfflineOfferCardState extends State<OfflineOfferCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!disableAnim) {
      await _controller.reverse();
    }
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    Widget cardContent = Padding(
      padding: const EdgeInsets.all(16),
      child: RetroPixelCard(
        borderColor: const Color(0xFF00F0FF),
        backgroundColor: const Color(0xFF0D101C),
        shadowOffset: 4,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14192A),
                    border: Border.all(
                      color: const Color(0xFF00F0FF).withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const PixelGlyphWidget(
                    type: PixelGlyphType.gamepad,
                    pixelSize: 4.5,
                    glow: true,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PixelText(
                        "You're offline",
                        pixelSize: 2.2,
                        color: Color(0xFF00F0FF),
                        glowColor: Color(0xFF00F0FF),
                      ),
                      SizedBox(height: 6),
                      PixelText(
                        'FEELING LUCKY? PLAY A MINI-GAME!',
                        pixelSize: 1.4,
                        color: Color(0xFF8E9CB8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RetroPixelButton(
                  label: 'Dismiss',
                  onPressed: _handleDismiss,
                  color: const Color(0xFF1E2338),
                  textColor: const Color(0xFF8E9CB8),
                  pixelSize: 1.8,
                  minWidth: 84,
                ),
                const SizedBox(width: 10),
                RetroPixelButton(
                  label: widget.actionLabel,
                  onPressed: widget.onPlay,
                  color: const Color(0xFF39FF14),
                  textColor: Colors.black,
                  pixelSize: 1.8,
                  minWidth: 90,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (disableAnim) {
      return cardContent;
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: cardContent,
      ),
    );
  }
}
