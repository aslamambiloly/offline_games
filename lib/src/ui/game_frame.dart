import 'package:flutter/material.dart';
import '../core/game_session.dart';
import '../core/offline_game.dart';
import 'back_online_banner.dart';
import 'retro_pixel_glyph.dart';
import 'retro_pixel_text.dart';
import 'retro_screen.dart';
import 'theme.dart';

/// Wraps an [OfflineGame] with standard arcade controls: exit, pause toggle,
/// and author attribution chip, enhanced with a Vintage CRT screen atmosphere.
class GameFrame extends StatefulWidget {
  /// Creates a [GameFrame].
  const GameFrame({
    super.key,
    required this.game,
    required this.session,
    this.isBackOnline = false,
    this.onKeepPlaying,
    this.onBackToApp,
  });

  /// The active game being played.
  final OfflineGame game;

  /// The active session passed to the game.
  final GameSession session;

  /// Whether internet connection was restored while playing.
  final bool isBackOnline;

  /// Callback when user chooses to keep playing after reconnecting.
  final VoidCallback? onKeepPlaying;

  /// Callback when user chooses to return to app after reconnecting.
  final VoidCallback? onBackToApp;

  @override
  State<GameFrame> createState() => _GameFrameState();
}

class _GameFrameState extends State<GameFrame> {
  bool _promptDismissed = false;

  @override
  void didUpdateWidget(GameFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isBackOnline && widget.isBackOnline) {
      _promptDismissed = false;
    }
  }

  void _togglePause() {
    if (widget.session.paused is ValueNotifier<bool>) {
      final notifier = widget.session.paused as ValueNotifier<bool>;
      notifier.value = !notifier.value;
    }
  }

  void _handleKeepPlaying() {
    setState(() {
      _promptDismissed = true;
    });
    widget.onKeepPlaying?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = OfflineGamesTheme.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final topBarBg =
        isLight ? const Color(0xFFFFFFFF) : const Color(0xFF090B14);
    final topBarBorder =
        isLight ? const Color(0xFF000000) : const Color(0xFF23293D);
    final btnBg = isLight ? const Color(0xFFF3F4F6) : const Color(0xFF161A2B);
    final btnBorder =
        isLight ? const Color(0xFF000000) : const Color(0xFF3B4468);
    final arrowColor =
        isLight ? const Color(0xFF000000) : const Color(0xFF00F0FF);
    final titleColor =
        isLight ? const Color(0xFF000000) : const Color(0xFF00F0FF);
    final pauseBarsColor =
        isLight ? const Color(0xFF000000) : const Color(0xFFFFB800);
    final resumeArrowColor =
        isLight ? const Color(0xFF059669) : const Color(0xFF39FF14);

    return Material(
      color: theme.cardColor,
      child: CrtScanlinesOverlay(
        scanlineOpacity: 0.08,
        vignetteOpacity: 0.35,
        child: Stack(
          children: [
            Column(
              children: [
                // Retro CRT Top Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: topBarBg,
                    border: Border(
                      bottom: BorderSide(
                        color: topBarBorder,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        Semantics(
                          label: 'Exit game',
                          button: true,
                          child: GestureDetector(
                            onTap: widget.session.exit,
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: btnBg,
                                border: Border.all(
                                  color: btnBorder,
                                  width: 2.0,
                                ),
                              ),
                              child: PixelGlyphWidget(
                                type: PixelGlyphType.arrowLeft,
                                pixelSize: 2.2,
                                color: arrowColor,
                                glow: !isLight,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        PixelGlyphWidget(
                          type: widget.game.meta.effectiveGlyph,
                          pixelSize: 2.6,
                          glow: !isLight,
                          color: isLight ? const Color(0xFF000000) : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PixelText(
                            widget.game.meta.title,
                            pixelSize: 2.0,
                            color: titleColor,
                            glowColor: isLight ? null : titleColor,
                          ),
                        ),
                        // Pause / Resume Toggle
                        ValueListenableBuilder<bool>(
                          valueListenable: widget.session.paused,
                          builder: (context, paused, _) {
                            return Semantics(
                              label: paused ? 'Resume game' : 'Pause game',
                              button: true,
                              child: GestureDetector(
                                onTap: _togglePause,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: btnBg,
                                    border: Border.all(
                                      color: btnBorder,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: paused
                                      ? PixelGlyphWidget(
                                          type: PixelGlyphType.arrowRight,
                                          pixelSize: 2.0,
                                          color: resumeArrowColor,
                                          glow: !isLight,
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 3.5,
                                              height: 14,
                                              color: pauseBarsColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Container(
                                              width: 3.5,
                                              height: 14,
                                              color: pauseBarsColor,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Game Viewport
                Expanded(
                  child: Stack(
                    children: [
                      SafeArea(
                        top: false,
                        child: RepaintBoundary(
                          child: widget.game.build(context, widget.session),
                        ),
                      ),
                      // Retro Pause Overlay
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.session.paused,
                        builder: (context, paused, _) {
                          if (!paused) return const SizedBox.shrink();
                          return GestureDetector(
                            onTap: _togglePause,
                            child: Container(
                              color: isLight
                                  ? Colors.white.withValues(alpha: 0.88)
                                  : Colors.black.withValues(alpha: 0.82),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PixelText(
                                    'PAUSED',
                                    pixelSize: 3.6,
                                    color: isLight
                                        ? const Color(0xFF000000)
                                        : const Color(0xFFFFB800),
                                    glowColor: isLight
                                        ? null
                                        : const Color(0xFFFFB800),
                                  ),
                                  const SizedBox(height: 14),
                                  PixelText(
                                    'PRESS TO RESUME',
                                    pixelSize: 1.8,
                                    color: isLight
                                        ? const Color(0xFF4B5563)
                                        : const Color(0xFF8E9CB8),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Reconnected Modal Popup Dialog (C6 / C10)
            if (widget.isBackOnline && !_promptDismissed)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.68),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BackOnlineBanner(
                    onKeepPlaying: _handleKeepPlaying,
                    onBackToApp: () {
                      widget.onBackToApp?.call();
                      widget.session.exit();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
