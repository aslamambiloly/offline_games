import 'package:flutter/material.dart';
import '../core/game_meta.dart';
import 'retro_pixel_text.dart';
import 'retro_screen.dart';

/// Displays the author attribution and credits sheet for an [OfflineGame],
/// styled in the vintage arcade hall of fame aesthetic.
Future<void> showGameCredits(BuildContext context, GameMeta meta) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0D101C),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
      side: BorderSide(color: Color(0xFF00F0FF), width: 3.0),
    ),
    builder: (context) {
      return CrtScanlinesOverlay(
        scanlineOpacity: 0.08,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    color: const Color(0xFF00F0FF),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      meta.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PixelText(
                            meta.title,
                            pixelSize: 2.2,
                            color: const Color(0xFF00F0FF),
                            glowColor: const Color(0xFF00F0FF),
                          ),
                          const SizedBox(height: 2),
                          PixelText(
                            'VERSION ${meta.version}',
                            pixelSize: 1.2,
                            color: const Color(0xFF8E9CB8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (meta.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    meta.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E9CB8),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                const PixelText(
                  'Authors & Contributors',
                  pixelSize: 1.8,
                  color: Color(0xFFFFB800),
                ),
                const SizedBox(height: 10),
                for (final author in meta.authors)
                  RetroPixelCard(
                    borderColor: const Color(0xFF2C324E),
                    backgroundColor: const Color(0xFF141829),
                    shadowOffset: 2,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelText(
                          author.name,
                          pixelSize: 1.6,
                          color: const Color(0xFF39FF14),
                        ),
                        if (author.github != null) ...[
                          const SizedBox(height: 4),
                          SelectableText(
                            'GitHub: @${author.github}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF00F0FF),
                            ),
                          ),
                        ],
                        if (author.url != null) ...[
                          const SizedBox(height: 4),
                          SelectableText(
                            author.url!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8E9CB8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                RetroPixelButton(
                  label: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  color: const Color(0xFF39FF14),
                  textColor: Colors.black,
                  pixelSize: 1.8,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
