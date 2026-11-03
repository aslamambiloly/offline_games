import 'dart:math';
import 'package:flutter/material.dart';
import '../core/game_session.dart';
import '../core/offline_game.dart';
import '../storage/memory_score_store.dart';
import '../storage/score_store.dart';
import 'game_frame.dart';

/// Standalone widget to play an [OfflineGame] directly within any app view.
class GamePlayer extends StatefulWidget {
  /// Creates a [GamePlayer].
  const GamePlayer({
    super.key,
    required this.game,
    this.scoreStore,
    this.random,
    this.onExit,
  });

  /// The game to play.
  final OfflineGame game;

  /// Optional score persistence store. Defaults to in-memory.
  final ScoreStore? scoreStore;

  /// Optional injected random instance.
  final Random? random;

  /// Callback when the player taps the exit button.
  final VoidCallback? onExit;

  @override
  State<GamePlayer> createState() => _GamePlayerState();
}

class _GamePlayerState extends State<GamePlayer> {
  late final ScoreStore _scoreStore;
  late final Random _random;
  final ValueNotifier<bool> _pausedNotifier = ValueNotifier<bool>(false);
  int? _bestScore;

  @override
  void initState() {
    super.initState();
    _scoreStore = widget.scoreStore ?? MemoryScoreStore();
    _random = widget.random ?? Random();
    _loadBestScore();
  }

  @override
  void dispose() {
    _pausedNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadBestScore() async {
    final score = await _scoreStore.read(widget.game.meta.id);
    if (mounted) {
      setState(() {
        _bestScore = score;
      });
    }
  }

  void _handleReportScore(int score) {
    _scoreStore.write(widget.game.meta.id, score);
    if (_bestScore == null || score > _bestScore!) {
      setState(() {
        _bestScore = score;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = GameSession(
      bestScore: _bestScore,
      paused: _pausedNotifier,
      random: _random,
      reportScore: _handleReportScore,
      exit: widget.onExit ?? () => Navigator.of(context).maybePop(),
    );

    return GameFrame(
      game: widget.game,
      session: session,
    );
  }
}
