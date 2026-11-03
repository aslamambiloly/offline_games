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
    this.actionLabel = 'Play',
    this.title = 'SIGNAL LOST IN TIME',
    this.subtitle =
        'LET ME TAKE YOU TO A WORLD WHERE NO SMARTPHONE OR INTERNET EXISTED.',
    this.isBackOnline = false,
  });

  /// Action when player taps the primary button (Play / Pick).
  final VoidCallback onPlay;

  /// Action when player dismisses the card.
  final VoidCallback onDismiss;

  /// Button label for the primary action (defaults to 'Play').
  final String actionLabel;

  /// Header title for the offer card.
  final String title;

  /// Descriptive subtitle for the offer card.
  final String subtitle;

  /// Whether internet connection returned while the card was showing.
  final bool isBackOnline;

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
      duration: const Duration(milliseconds: 320),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
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
    final isBackOnline = widget.isBackOnline;

    // Both Dark and Light modes use the clean, high-contrast light mode card styling
    const cardBg = Color(0xFFFFFFFF);
    const borderColor = Color(0xFF000000);
    final iconBg =
        isBackOnline ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6);
    const iconBorder = Color(0xFF000000);
    final glyphColor =
        isBackOnline ? const Color(0xFF15803D) : const Color(0xFF000000);
    const titleColor = Color(0xFF000000);
    const subtitleColor = Color(0xFF4B5563);

    final displayTitle = isBackOnline ? 'TIMELINE RESTORED!' : widget.title;
    final displaySubtitle = isBackOnline
        ? 'THE MODERN WORLD IS CALLING. KEEP GAMING OR RETURN TO APP?'
        : widget.subtitle;
    final primaryLabel = isBackOnline ? 'Play anyway' : widget.actionLabel;
    final dismissLabel = isBackOnline ? 'Back to app' : 'Dismiss';

    Widget cardContent = Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: RetroPixelCard(
          borderColor: borderColor,
          backgroundColor: cardBg,
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
                      color: iconBg,
                      border: Border.all(
                        color: iconBorder,
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
                    child: PixelGlyphWidget(
                      type: isBackOnline
                          ? PixelGlyphType.alien
                          : PixelGlyphType.gamepad,
                      pixelSize: 4.5,
                      color: glyphColor,
                      glow: false,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelText(
                          displayTitle,
                          pixelSize: 2.0,
                          color: titleColor,
                          glowColor: null,
                        ),
                        const SizedBox(height: 6),
                        PixelText(
                          displaySubtitle,
                          pixelSize: 1.3,
                          color: subtitleColor,
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
                    label: dismissLabel,
                    onPressed: _handleDismiss,
                    color: const Color(0xFFE5E7EB),
                    textColor: const Color(0xFF111827),
                    borderColor: const Color(0xFF000000),
                    pixelSize: 1.6,
                    minWidth: 84,
                  ),
                  const SizedBox(width: 10),
                  RetroPixelButton(
                    label: primaryLabel,
                    onPressed: widget.onPlay,
                    color: const Color(0xFF000000),
                    textColor: const Color(0xFFFFFFFF),
                    borderColor: const Color(0xFF000000),
                    pixelSize: 1.6,
                    minWidth: 90,
                  ),
                ],
              ),
            ],
          ),
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
