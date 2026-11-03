import 'package:flutter/material.dart';
import '../core/game_session.dart';
import '../core/offline_game.dart';
import 'back_online_banner.dart';
import 'credits_sheet.dart';
import 'theme.dart';

/// Wraps an [OfflineGame] with standard arcade controls: exit, pause toggle,
/// best score badge, and author attribution chip.
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
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Arcade Navigation Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Semantics(
                        label: 'Exit game',
                        button: true,
                        child: IconButton(
                          iconSize: 24,
                          constraints: const BoxConstraints.tightFor(
                            width: 44,
                            height: 44,
                          ),
                          tooltip: 'Exit game',
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: widget.session.exit,
                        ),
                      ),
                      Text(
                        widget.game.meta.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.game.meta.title,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      // Author Attribution Chip (C7)
                      Semantics(
                        label: 'View credits for author $primaryAuthor',
                        button: true,
                        child: ActionChip(
                          avatar: const Icon(Icons.person_outline, size: 16),
                          label: Text(
                            'by $primaryAuthor',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () =>
                              showGameCredits(context, widget.game.meta),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Pause / Resume Toggle
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.session.paused,
                        builder: (context, paused, _) {
                          return Semantics(
                            label: paused ? 'Resume game' : 'Pause game',
                            button: true,
                            child: IconButton(
                              iconSize: 24,
                              constraints: const BoxConstraints.tightFor(
                                width: 44,
                                height: 44,
                              ),
                              tooltip: paused ? 'Resume game' : 'Pause game',
                              icon: Icon(
                                paused
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                              ),
                              onPressed: _togglePause,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Game Viewport
                Expanded(
                  child: Stack(
                    children: [
                      RepaintBoundary(
                        child: widget.game.build(context, widget.session),
                      ),
                      // Pause Overlay
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.session.paused,
                        builder: (context, paused, _) {
                          if (!paused) return const SizedBox.shrink();
                          return GestureDetector(
                            onTap: _togglePause,
                            child: Container(
                              color: Colors.black54,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.pause_circle_filled_rounded,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Paused',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap anywhere to resume',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.white70,
                                        ),
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
            // Floating Reconnect Banner
            if (widget.isBackOnline && !_promptDismissed)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: BackOnlineBanner(
                  onKeepPlaying: _handleKeepPlaying,
                  onBackToApp: widget.onBackToApp ?? widget.session.exit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
