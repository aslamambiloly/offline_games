import 'package:flutter/material.dart';
import 'retro_pixel_glyph.dart';
import 'retro_pixel_text.dart';
import 'retro_screen.dart';

/// Modal popup shown when internet connectivity is restored during an active game session.
class BackOnlineBanner extends StatelessWidget {
  /// Creates a [BackOnlineBanner].
  const BackOnlineBanner({
    super.key,
    required this.onKeepPlaying,
    required this.onBackToApp,
  });

  /// Callback when user decides to continue playing.
  final VoidCallback onKeepPlaying;

  /// Callback when user decides to exit the arcade and return to the host app.
  final VoidCallback onBackToApp;

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFFFFFFFF);
    const cardBorder = Color(0xFF000000);
    const iconBg = Color(0xFFDCFCE7);
    const iconBorder = Color(0xFF000000);
    const glyphColor = Color(0xFF15803D);
    const titleColor = Color(0xFF000000);
    const subtitleColor = Color(0xFF4B5563);
    const keepBtnColor = Color(0xFFE5E7EB);
    const keepBtnText = Color(0xFF111827);
    const backBtnColor = Color(0xFF000000);
    const backBtnText = Color(0xFFFFFFFF);

    return Semantics(
      label: "Connection restored notification dialog. You're back online.",
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: RetroPixelCard(
          borderColor: cardBorder,
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
                    child: const PixelGlyphWidget(
                      type: PixelGlyphType.alien,
                      pixelSize: 4.5,
                      color: glyphColor,
                      glow: false,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelText(
                          "TIMELINE RESTORED!",
                          pixelSize: 2.0,
                          color: titleColor,
                          glowColor: null,
                        ),
                        SizedBox(height: 6),
                        PixelText(
                          'KEEP GAMING OR RETURN TO APP?',
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
                    label: 'Keep playing',
                    onPressed: onKeepPlaying,
                    color: keepBtnColor,
                    textColor: keepBtnText,
                    borderColor: const Color(0xFF000000),
                    pixelSize: 1.6,
                    minWidth: 110,
                  ),
                  const SizedBox(width: 10),
                  RetroPixelButton(
                    label: 'Back to app',
                    onPressed: onBackToApp,
                    color: backBtnColor,
                    textColor: backBtnText,
                    borderColor: const Color(0xFF000000),
                    pixelSize: 1.6,
                    minWidth: 110,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
