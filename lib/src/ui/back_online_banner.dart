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
    return Semantics(
      label: "Connection restored notification dialog. You're back online.",
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: RetroPixelCard(
          borderColor: const Color(0xFF39FF14),
          backgroundColor: const Color(0xFF09160E),
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
                      color: const Color(0xFF102619),
                      border: Border.all(
                        color: const Color(0xFF39FF14).withValues(alpha: 0.7),
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
                      color: Color(0xFF39FF14),
                      glow: true,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelText(
                          "You're back online!",
                          pixelSize: 2.0,
                          color: Color(0xFF39FF14),
                          glowColor: Color(0xFF39FF14),
                        ),
                        SizedBox(height: 6),
                        PixelText(
                          'KEEP PLAYING OR RETURN TO APP?',
                          pixelSize: 1.3,
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
                    label: 'Keep playing',
                    onPressed: onKeepPlaying,
                    color: const Color(0xFF162319),
                    textColor: const Color(0xFF8E9CB8),
                    pixelSize: 1.6,
                    minWidth: 110,
                  ),
                  const SizedBox(width: 10),
                  RetroPixelButton(
                    label: 'Back to app',
                    onPressed: onBackToApp,
                    color: const Color(0xFF39FF14),
                    textColor: Colors.black,
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
