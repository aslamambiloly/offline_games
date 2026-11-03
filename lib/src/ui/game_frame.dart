import 'package:flutter/material.dart';
import '../core/game_session.dart';
import '../core/offline_game.dart';
import 'back_online_banner.dart';
import 'credits_sheet.dart';
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
    final primaryAuthor = widget.game.meta.authors.first.name;

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
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Color(0xFF00F0FF),
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.game.meta.emoji,
                          style: const TextStyle(fontSize: 22),
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
                        // Retro Author Attribution Chip (C7)
                        Semantics(
                          label: 'View credits for author $primaryAuthor',
                          button: true,
                          child: GestureDetector(
                            onTap: () =>
                                showGameCredits(context, widget.game.meta),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161A2B),
                                border: Border.all(
                                  color: const Color(0xFFFFB800)
                                      .withValues(alpha: 0.7),
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: Color(0xFFFFB800),
                                  ),
                                  const SizedBox(width: 4),
                                  PixelText(
                                    'by $primaryAuthor',
                                    pixelSize: 1.3,
                                    color: const Color(0xFFFFB800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                                  child: Icon(
                                    paused
                                        ? Icons.play_arrow_rounded
                                        : Icons.pause_rounded,
                                    color: paused
                                        ? const Color(0xFF39FF14)
                                        : const Color(0xFFFFB800),
                                    size: 22,
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

              // Reconnected Banner (C6 / C10)
              if (widget.isBackOnline && !_promptDismissed)
                Positioned(
                  top: 54,
                  left: 0,
                  right: 0,
                  child: BackOnlineBanner(
                    onKeepPlaying: _handleKeepPlaying,
                    onBackToApp: () {
                      widget.onBackToApp?.call();
                      widget.session.exit();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
