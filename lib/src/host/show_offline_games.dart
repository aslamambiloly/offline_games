import 'package:flutter/material.dart';
import '../connectivity/connectivity_source.dart';
import '../core/game_catalog.dart';
import '../core/games_mode.dart';
import '../core/offline_game.dart';
import '../storage/memory_score_store.dart';
import '../storage/score_store.dart';
import '../ui/theme.dart';
import 'offline_games_controller.dart';
import 'offline_games_widget.dart';
import 'offline_trigger.dart';

/// Manually displays the offline arcade UI inside a full-screen modal page route.
///
/// Useful for dedicated "Offline Arcade" or "Mini Games" buttons in app menus,
/// loading screens, or 404 error views.
Future<void> showOfflineGames(
  BuildContext context, {
  List<OfflineGame>? games,
  GamesMode mode = const GamesMode.spin(),
  ScoreStore? scoreStore,
  ConnectivitySource? connectivity,
  OfflineGamesTheme? theme,
}) {
  final effectiveGames = games ?? GameCatalog.builtIn;
  final effectiveScoreStore = scoreStore ?? MemoryScoreStore();
  final controller = OfflineGamesController()..open();

  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: OfflineGames(
            connectivity: connectivity,
            controller: controller,
            games: effectiveGames,
            mode: mode,
            scoreStore: effectiveScoreStore,
            theme: theme,
            trigger: OfflineTrigger.manual,
            child: const SizedBox.expand(),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}
