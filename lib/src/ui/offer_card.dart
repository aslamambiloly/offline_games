import 'package:flutter/material.dart';
import 'retro_pixel_glyph.dart';
import 'retro_pixel_text.dart';
import 'retro_screen.dart';
import 'theme.dart';

/// Dismissible offer card presented when the device loses internet connectivity,
/// styled with authentic retro 8-bit pixel vectors.
class OfflineOfferCard extends StatefulWidget {
  /// Creates an [OfflineOfferCard].
  const OfflineOfferCard({
    super.key,
    required this.onPlay,
    required this.onDismiss,
    this.actionLabel = 'Play',
  });

  /// Action when player taps the primary button (Play / Pick).
  final VoidCallback onPlay;

  /// Action when player dismisses the card.
  final VoidCallback onDismiss;

  /// Button label for the primary action (defaults to 'Play').
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
    final theme = OfflineGamesTheme.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = theme.backgroundColor ??
        (isLight ? const Color(0xFFFFFFFF) : const Color(0xFF000000));
    final borderColor = isLight
        ? const Color(0xFF000000)
        : (theme.primaryColor ?? const Color(0xFF00F0FF));
    final iconBg =
        isLight ? const Color(0xFFEEEEEE) : const Color(0xFF14192A);
    final titleColor = isLight
        ? const Color(0xFF0072B5)
        : (theme.primaryColor ?? const Color(0xFF00F0FF));
    final subtitleColor =
        isLight ? const Color(0xFF444444) : const Color(0xFF8E9CB8);

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
                        color: borderColor.withValues(alpha: 0.6),
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
                      type: PixelGlyphType.gamepad,
                      pixelSize: 4.5,
                      color: isLight
                          ? const Color(0xFF0072B5)
                          : const Color(0xFF00FFA3),
                      glow: !isLight,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelText(
                          "You're offline",
                          pixelSize: 2.2,
                          color: titleColor,
                          glowColor: isLight ? null : titleColor,
                        ),
                        const SizedBox(height: 6),
                        PixelText(
                          'FEELING LUCKY? PLAY A MINI-GAME!',
                          pixelSize: 1.4,
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
                    label: 'Dismiss',
                    onPressed: _handleDismiss,
                    color: isLight
                        ? const Color(0xFFE2E4EB)
                        : const Color(0xFF1E2338),
                    textColor: isLight
                        ? const Color(0xFF333333)
                        : const Color(0xFF8E9CB8),
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
