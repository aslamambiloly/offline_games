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

    return Material(
      color: theme.cardColor,
      child: CrtScanlinesOverlay(
        scanlineOpacity: 0.08,
        vignetteOpacity: 0.35,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Retro CRT Top Bar
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF090B14),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF23293D),
                          width: 2.0,
                        ),
                      ),
                    ),
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
                                color: const Color(0xFF161A2B),
                                border: Border.all(
                                  color: const Color(0xFF3B4468),
                                  width: 2.0,
                                ),
                              ),
                              child: const PixelGlyphWidget(
                                type: PixelGlyphType.arrowLeft,
                                pixelSize: 2.2,
                                color: Color(0xFF00F0FF),
                                glow: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        PixelGlyphWidget(
                          type: widget.game.meta.effectiveGlyph,
                          pixelSize: 2.6,
                          glow: true,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PixelText(
                            widget.game.meta.title,
                            pixelSize: 2.0,
                            color: const Color(0xFF00F0FF),
                            glowColor: const Color(0xFF00F0FF),
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
                                    color: const Color(0xFF161A2B),
                                    border: Border.all(
                                      color: const Color(0xFF3B4468),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: paused
                                      ? const PixelGlyphWidget(
                                          type: PixelGlyphType.arrowRight,
                                          pixelSize: 2.0,
                                          color: Color(0xFF39FF14),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 3.5,
                                              height: 14,
                                              color: const Color(0xFFFFB800),
                                            ),
                                            const SizedBox(width: 4),
                                            Container(
                                              width: 3.5,
                                              height: 14,
                                              color: const Color(0xFFFFB800),
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

                  // Game Viewport
                  Expanded(
                    child: Stack(
                      children: [
                        RepaintBoundary(
                          child: widget.game.build(context, widget.session),
                        ),
                        // Retro Pause Overlay
                        ValueListenableBuilder<bool>(
                          valueListenable: widget.session.paused,
                          builder: (context, paused, _) {
                            if (!paused) return const SizedBox.shrink();
                            return GestureDetector(
                              onTap: _togglePause,
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.82),
                                alignment: Alignment.center,
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PixelText(
                                      'PAUSED',
                                      pixelSize: 3.6,
                                      color: Color(0xFFFFB800),
                                      glowColor: Color(0xFFFFB800),
                                    ),
                                    SizedBox(height: 14),
                                    PixelText(
                                      'PRESS TO RESUME',
                                      pixelSize: 1.8,
                                      color: Color(0xFF8E9CB8),
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
      ),
    );
  }
}
