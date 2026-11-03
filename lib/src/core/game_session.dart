import 'dart:math';
import 'package:flutter/foundation.dart';

/// Active game session injected into each [OfflineGame] by the host.
class GameSession {
  /// Creates a [GameSession].
  const GameSession({
    required this.bestScore,
    required this.paused,
    required this.random,
    required this.reportScore,
    required this.exit,
  });

  /// The highest score recorded for this game so far, if any.
  final int? bestScore;

  /// A listenable indicating if the game is currently paused.
  /// Games must honour this to pause animations, timers, and game loops.
  final ValueListenable<bool> paused;

  /// Injectable [Random] instance. Games must use this instead of `Random()`
  /// directly to ensure deterministic behaviour in unit tests.
  final Random random;

  /// Callback used by the game to report score updates or final results.
  final void Function(int score) reportScore;

  /// Callback to exit the current game session.
  final VoidCallback exit;
}
