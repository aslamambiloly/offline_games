import 'dart:math';
import 'package:flutter/material.dart';
import '../connectivity/connectivity_source.dart';
import '../connectivity/default_connectivity_source.dart';
import '../core/game_catalog.dart';
import '../core/game_session.dart';
import '../core/games_mode.dart';
import '../core/offline_game.dart';
import '../storage/memory_score_store.dart';
import '../storage/score_store.dart';
import '../ui/game_frame.dart';
import '../ui/offer_card.dart';
import '../ui/picker.dart';
import '../ui/spinner.dart';
import '../ui/theme.dart';
import 'offline_episode.dart';
import 'offline_games_controller.dart';
import 'offline_trigger.dart';

/// Wraps your application to provide a plug-and-play mini-arcade when offline.
///
/// With zero configuration, it monitors reachability and presents an offer
/// card when connectivity is lost.
class OfflineGames extends StatefulWidget {
  /// Creates an [OfflineGames] host wrapper.
  const OfflineGames({
    super.key,
    required this.child,
    this.games,
    this.mode = const GamesMode.spin(),
    this.trigger = OfflineTrigger.auto,
    this.offlineDelay = const Duration(seconds: 3),
    this.connectivity,
    this.scoreStore,
    this.controller,
    this.theme,
    this.random,
  });

  /// The root or nested widget tree of the host app.
  final Widget child;

  /// The list of games available. If null, defaults to [GameCatalog.builtIn].
  final List<OfflineGame>? games;

  /// Mode determining how games are selected (spin, picker, or single).
  final GamesMode mode;

  /// Trigger strategy determining when the offline UI appears.
  final OfflineTrigger trigger;

  /// Debounce delay before confirming that the device is truly offline.
  final Duration offlineDelay;

  /// Reachability source. If null, uses an isolated [DefaultConnectivitySource].
  final ConnectivitySource? connectivity;

  /// Persistent store for high scores. If null, uses an in-memory store.
  final ScoreStore? scoreStore;

  /// Controller to programmatically open, close, or suppress the arcade UI.
  final OfflineGamesController? controller;

  /// Optional custom theme configuration.
  final OfflineGamesTheme? theme;

  /// Injected random instance for deterministic tests.
  final Random? random;

  @override
  State<OfflineGames> createState() => _OfflineGamesState();
}

class _OfflineGamesState extends State<OfflineGames>
    with WidgetsBindingObserver {
  late final ConnectivitySource _connectivity;
  late final bool _ownsConnectivity;
  late final ScoreStore _scoreStore;
  late final OfflineEpisode _episode;
  late final Random _random;

  final ValueNotifier<bool> _pausedNotifier = ValueNotifier<bool>(false);
  OfflineGame? _activeGame;
  OfflineGame? _lastPlayedGame;
  int? _activeBestScore;
  bool _isManualOpen = false;

  List<OfflineGame> get _effectiveGames => widget.games ?? GameCatalog.builtIn;

  bool get _isOverlayActive =>
      _isManualOpen ||
      _episode.state == OfflineEpisodeState.playing ||
      _episode.state == OfflineEpisodeState.playingOnline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _ownsConnectivity = widget.connectivity == null;
    _connectivity = widget.connectivity ?? DefaultConnectivitySource();
    _scoreStore = widget.scoreStore ?? MemoryScoreStore();
    _random = widget.random ?? Random();

    _episode = OfflineEpisode(
      onlineStream: _connectivity.onlineStream,
      offlineDelay: widget.offlineDelay,
      onStateChanged: _onEpisodeStateChanged,
    );

    widget.controller?.addListener(_onControllerChanged);
    _syncController();
  }

  @override
  void didUpdateWidget(OfflineGames oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
      _syncController();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller?.removeListener(_onControllerChanged);
    _pausedNotifier.dispose();
    _episode.dispose();
    if (_ownsConnectivity) {
      _connectivity.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _pausedNotifier.value = true;
    }
  }

  @override
  Future<bool> didPopRoute() async {
    if (_isOverlayActive) {
      _handleExit();
      return true;
    }
    if (_episode.state == OfflineEpisodeState.offered) {
      _handleDismissOffer();
      return true;
    }
    return false;
  }

  void _onControllerChanged() {
    final controller = widget.controller;
    if (controller == null) return;

    if (controller.isSuppressed != _episode.isSuppressed) {
      if (controller.isSuppressed) {
        _episode.suppress();
      } else {
        _episode.allow();
      }
    }

    if (controller.isOpen != _isManualOpen) {
      setState(() {
        _isManualOpen = controller.isOpen;
        if (_isManualOpen && _activeGame == null && widget.mode is SingleMode) {
          _selectAndStartGame();
        }
      });
    }
  }

  void _syncController() {
    if (widget.controller?.isSuppressed == true) {
      _episode.suppress();
    }
    if (widget.controller?.isOpen == true) {
      _isManualOpen = true;
      if (widget.mode is SingleMode) {
        _selectAndStartGame();
      }
    }
  }

  void _onEpisodeStateChanged(OfflineEpisodeState state) {
    if (!mounted) return;
    setState(() {
      if (state == OfflineEpisodeState.playing &&
          _activeGame == null &&
          widget.mode is SingleMode) {
        _selectAndStartGame();
      }
    });
  }

  void _selectAndStartGame([OfflineGame? chosenGame]) {
    final game = chosenGame ?? _resolveInitialGame();
    if (game != null) {
      _activeGame = game;
      _lastPlayedGame = game;
      _loadBestScore(game.meta.id);
    }
  }

  OfflineGame? _resolveInitialGame() {
    final mode = widget.mode;
    if (mode is SingleMode) {
      return mode.game;
    }
    return null;
  }

  Future<void> _loadBestScore(String gameId) async {
    final score = await _scoreStore.read(gameId);
    if (mounted) {
      setState(() {
        _activeBestScore = score;
      });
    }
  }

  void _handleReportScore(int score) {
    final game = _activeGame;
    if (game == null) return;
    _scoreStore.write(game.meta.id, score);
    if (_activeBestScore == null || score > _activeBestScore!) {
      setState(() {
        _activeBestScore = score;
      });
    }
  }

  void _handleGameFrameExit() {
    if (widget.mode is SingleMode) {
      _handleExit();
    } else {
      setState(() {
        _activeGame = null;
        _activeBestScore = null;
      });
    }
  }

  void _handleExit() {
    setState(() {
      _isManualOpen = false;
      _activeGame = null;
      _activeBestScore = null;
    });
    widget.controller?.close();
    _episode.userExitedGame();
  }

  void _handlePlayPressed() {
    if (widget.mode is SingleMode) {
      _selectAndStartGame();
    }
    _episode.userAcceptedOffer();
  }

  void _handleDismissOffer() {
    _episode.userDismissedOffer();
  }

  String _resolveActionLabel() {
    return switch (widget.mode) {
      SingleMode() => 'Play',
      PickerMode() => 'Pick',
      SpinMode() => 'Spin',
    };
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = widget.theme ?? OfflineGamesTheme.of(context);

    final showOfferCard = widget.trigger == OfflineTrigger.auto &&
        _episode.state == OfflineEpisodeState.offered &&
        !_isOverlayActive;

    final isPlayingGame = _isOverlayActive && _activeGame != null;

    final session = isPlayingGame
        ? GameSession(
            bestScore: _activeBestScore,
            paused: _pausedNotifier,
            random: _random,
            reportScore: _handleReportScore,
            exit: _handleGameFrameExit,
          )
        : null;

    return Theme(
      data: Theme.of(context).copyWith(
        extensions: [effectiveTheme],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (showOfferCard)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: OfflineOfferCard(
                  actionLabel: _resolveActionLabel(),
                  onPlay: _handlePlayPressed,
                  onDismiss: _handleDismissOffer,
                ),
              ),
            ),
          if (_isOverlayActive)
            Positioned.fill(
              child: HeroControllerScope.none(
                child: Navigator(
                  onGenerateRoute: (settings) {
                    return PageRouteBuilder<void>(
                      pageBuilder: (context, _, __) {
                        if (isPlayingGame && session != null) {
                          return GameFrame(
                            game: _activeGame!,
                            session: session,
                            isBackOnline: _episode.state ==
                                OfflineEpisodeState.playingOnline,
                            onKeepPlaying: _episode.userChoseKeepPlaying,
                            onBackToApp: _handleExit,
                          );
                        }

                        if (widget.mode is PickerMode) {
                          return Material(
                            color: effectiveTheme.cardColor,
                            child: SafeArea(
                              child: Stack(
                                children: [
                                  GamePicker(
                                    games: _effectiveGames,
                                    scoreStore: _scoreStore,
                                    onSelected: (game) {
                                      setState(() {
                                        _selectAndStartGame(game);
                                      });
                                    },
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.close_rounded),
                                      tooltip: 'Close',
                                      onPressed: _handleExit,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Default / SpinMode
                        return Material(
                          color: effectiveTheme.cardColor,
                          child: SafeArea(
                            child: Stack(
                              children: [
                                Center(
                                  child: GameSpinner(
                                    games: _effectiveGames,
                                    random: _random,
                                    previousGame: _lastPlayedGame,
                                    onResult: (game) {
                                      setState(() {
                                        _selectAndStartGame(game);
                                      });
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    tooltip: 'Close',
                                    onPressed: _handleExit,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
