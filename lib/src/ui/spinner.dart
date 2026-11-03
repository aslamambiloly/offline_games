import 'dart:math';
import 'package:flutter/material.dart';
import '../core/offline_game.dart';
import 'theme.dart';

/// Helper to select a random game while guaranteeing that the same game
/// is never picked twice consecutively if more than one game is available.
OfflineGame pickRandomGame({
  required List<OfflineGame> games,
  OfflineGame? previous,
  required Random random,
}) {
  assert(games.isNotEmpty, 'Games list cannot be empty when spinning');
  if (games.length == 1) return games.first;

  final candidates = games.where((g) => g != previous).toList();
  return candidates[random.nextInt(candidates.length)];
}

/// Standalone animated arcade wheel / slot spinner widget.
class GameSpinner extends StatefulWidget {
  /// Creates a [GameSpinner].
  const GameSpinner({
    super.key,
    required this.games,
    required this.onResult,
    this.random,
    this.previousGame,
  });

  /// The pool of games to spin among.
  final List<OfflineGame> games;

  /// Callback invoked when player starts playing the chosen game.
  final void Function(OfflineGame game) onResult;

  /// Injected random instance for deterministic tests.
  final Random? random;

  /// The previously played game, if any, to avoid immediate repetition.
  final OfflineGame? previousGame;

  @override
  State<GameSpinner> createState() => _GameSpinnerState();
}

class _GameSpinnerState extends State<GameSpinner>
    with SingleTickerProviderStateMixin {
  late final Random _random;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  OfflineGame? _selectedGame;
  OfflineGame? _lastGame;
  bool _isSpinning = false;
  int _cycleIndex = 0;

  @override
  void initState() {
    super.initState();
    _random = widget.random ?? Random();
    _lastGame = widget.previousGame;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.addListener(() {
      if (_isSpinning && widget.games.isNotEmpty) {
        setState(() {
          _cycleIndex = (_animation.value * 15).floor() % widget.games.length;
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
      }
    });
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _spin();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (widget.games.isEmpty) return;

    final target = pickRandomGame(
      games: widget.games,
      previous: _lastGame,
      random: _random,
    );

    _selectedGame = target;
    _lastGame = target;

    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnim) {
      _isSpinning = false;
    } else {
      _isSpinning = true;
      _controller.forward(from: 0.0);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = OfflineGamesTheme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final gameToShow = _isSpinning
        ? widget.games[_cycleIndex]
        : (_selectedGame ?? widget.games.first);

    final authorName = gameToShow.meta.authors.first.name;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: theme.borderRadius,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Arcade Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✨', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'ARCADE SPINNER',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(width: 8),
                const Text('✨', style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 20),
            // Slot Wheel Viewport
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 140,
              decoration: BoxDecoration(
                gradient: theme.accentGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    gameToShow.meta.emoji,
                    style: const TextStyle(fontSize: 54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    gameToShow.meta.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Author Attribution (C7 & 6.5)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'by $authorName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            if (gameToShow.meta.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                gameToShow.meta.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 24),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _isSpinning ? null : _spin,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('Spin again'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _isSpinning
                        ? null
                        : () {
                            if (_selectedGame != null) {
                              widget.onResult(_selectedGame!);
                            }
                          },
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text('Start Game'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
