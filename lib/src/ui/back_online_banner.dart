import 'package:flutter/material.dart';
import 'retro_pixel_text.dart';
import 'retro_screen.dart';

/// Floating banner shown when internet connectivity is restored during an active game.
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
      label: "Connection restored notification banner. You're back online.",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: RetroPixelCard(
          borderColor: const Color(0xFF39FF14),
          backgroundColor: const Color(0xFF09160E),
          shadowOffset: 3,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF39FF14),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF39FF14),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: PixelText(
                      "You're back online!",
                      pixelSize: 1.8,
                      color: Color(0xFF39FF14),
                      glowColor: Color(0xFF39FF14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RetroPixelButton(
                    label: 'Keep playing',
                    onPressed: onKeepPlaying,
                    color: const Color(0xFF162319),
                    textColor: const Color(0xFF8E9CB8),
                    pixelSize: 1.5,
                    minWidth: 80,
                  ),
                  const SizedBox(width: 8),
                  RetroPixelButton(
                    label: 'Back to app',
                    onPressed: onBackToApp,
                    color: const Color(0xFF39FF14),
                    textColor: Colors.black,
                    pixelSize: 1.5,
                    minWidth: 80,
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
