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
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? const Color(0xFFFFFFFF) : const Color(0xFF09160E);
    final cardBorder =
        isLight ? const Color(0xFF000000) : const Color(0xFF39FF14);
    final iconBg = isLight ? const Color(0xFFDCFCE7) : const Color(0xFF102619);
    final iconBorder = isLight
        ? const Color(0xFF16A34A)
        : const Color(0xFF39FF14).withValues(alpha: 0.7);
    final glyphColor =
        isLight ? const Color(0xFF15803D) : const Color(0xFF39FF14);
    final titleColor =
        isLight ? const Color(0xFF000000) : const Color(0xFF39FF14);
    final subtitleColor =
        isLight ? const Color(0xFF4B5563) : const Color(0xFF8E9CB8);
    final keepBtnColor =
        isLight ? const Color(0xFFE5E7EB) : const Color(0xFF162319);
    final keepBtnText =
        isLight ? const Color(0xFF111827) : const Color(0xFF8E9CB8);
    final backBtnColor =
        isLight ? const Color(0xFF000000) : const Color(0xFF39FF14);
    final backBtnText = isLight ? const Color(0xFFFFFFFF) : Colors.black;

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
                    child: PixelGlyphWidget(
                      type: PixelGlyphType.alien,
                      pixelSize: 4.5,
                      color: glyphColor,
                      glow: !isLight,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelText(
                          "You're back online!",
                          pixelSize: 2.0,
                          color: titleColor,
                          glowColor: isLight ? null : titleColor,
                        ),
                        const SizedBox(height: 6),
                        PixelText(
                          'KEEP PLAYING OR RETURN TO APP?',
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
                    pixelSize: 1.6,
                    minWidth: 110,
                  ),
                  const SizedBox(width: 10),
                  RetroPixelButton(
                    label: 'Back to app',
                    onPressed: onBackToApp,
                    color: backBtnColor,
                    textColor: backBtnText,
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
