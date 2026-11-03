import 'dart:async';

/// States of an offline episode within the host application.
enum OfflineEpisodeState {
  /// App is connected or at rest.
  idle,

  /// Network drop detected; debouncing over `offlineDelay` to ignore quick flaps.
  pendingOffline,

  /// Offline status confirmed; offer card or banner is presented to the user.
  offered,

  /// User dismissed the offer for this offline episode.
  dismissed,

  /// User accepted the offer or manually opened a game while offline.
  playing,

  /// Game is actively being played, but internet connectivity was restored.
  playingOnline,
}

/// A timer creation factory callback used for dependency injection in unit tests.
typedef TimerFactory = Timer Function(
    Duration duration, void Function() callback);

/// Pure-Dart state machine managing offline episodes, flapping debounce,
/// single-offer-per-episode enforcement, and reconnection flows.
class OfflineEpisode {
  /// Creates an [OfflineEpisode] state machine.
  OfflineEpisode({
    Stream<bool>? onlineStream,
    bool initialOnline = true,
    this.offlineDelay = const Duration(seconds: 3),
    TimerFactory? timerFactory,
    void Function(OfflineEpisodeState state)? onStateChanged,
  })  : _isOnline = initialOnline,
        _timerFactory = timerFactory ?? Timer.new,
        _onStateChanged = onStateChanged {
    if (onlineStream != null) {
      _subscription = onlineStream.listen(onConnectivityChanged);
    }
  }

  /// Debounce delay before confirming that the device is truly offline.
  final Duration offlineDelay;

  final TimerFactory _timerFactory;
  final void Function(OfflineEpisodeState state)? _onStateChanged;
  StreamSubscription<bool>? _subscription;

  OfflineEpisodeState _state = OfflineEpisodeState.idle;
  bool _isOnline;
  bool _isSuppressed = false;
  Timer? _pendingTimer;

  /// Current state of the offline episode.
  OfflineEpisodeState get state => _state;

  /// Whether internet access is currently online.
  bool get isOnline => _isOnline;

  /// Whether automatic offline offers are currently suppressed.
  bool get isSuppressed => _isSuppressed;

  void _setState(OfflineEpisodeState newState) {
    if (_state != newState) {
      _state = newState;
      _onStateChanged?.call(newState);
    }
  }

  /// Handles an updated connectivity status (`true` = online, `false` = offline).
  void onConnectivityChanged(bool isOnline) {
    _isOnline = isOnline;

    if (isOnline) {
      _handleOnline();
    } else {
      _handleOffline();
    }
  }

  void _handleOnline() {
    switch (_state) {
      case OfflineEpisodeState.pendingOffline:
        _pendingTimer?.cancel();
        _pendingTimer = null;
        _setState(OfflineEpisodeState.idle);
      case OfflineEpisodeState.offered:
        _setState(OfflineEpisodeState.idle);
      case OfflineEpisodeState.dismissed:
        // Episode ended; reset to idle for the next episode.
        _setState(OfflineEpisodeState.idle);
      case OfflineEpisodeState.playing:
        // Connection returned while playing -> prompt user
        _setState(OfflineEpisodeState.playingOnline);
      case OfflineEpisodeState.playingOnline:
      case OfflineEpisodeState.idle:
        break;
    }
  }

  void _handleOffline() {
    if (_isSuppressed) return;

    switch (_state) {
      case OfflineEpisodeState.idle:
        _setState(OfflineEpisodeState.pendingOffline);
        _pendingTimer?.cancel();
        _pendingTimer = _timerFactory(offlineDelay, () {
          _pendingTimer = null;
          if (!_isOnline &&
              !_isSuppressed &&
              _state == OfflineEpisodeState.pendingOffline) {
            _setState(OfflineEpisodeState.offered);
          }
        });
      case OfflineEpisodeState.playingOnline:
        _setState(OfflineEpisodeState.playing);
      case OfflineEpisodeState.pendingOffline:
      case OfflineEpisodeState.offered:
      case OfflineEpisodeState.dismissed:
      case OfflineEpisodeState.playing:
        break;
    }
  }

  /// Called when the user taps Spin or Play from the offer card.
  void userAcceptedOffer() {
    if (_state == OfflineEpisodeState.offered) {
      _setState(OfflineEpisodeState.playing);
    }
  }

  /// Called when the user dismisses the offer card.
  void userDismissedOffer() {
    if (_state == OfflineEpisodeState.offered) {
      _setState(OfflineEpisodeState.dismissed);
    }
  }

  /// Called when the user chooses to keep playing despite the connection returning.
  void userChoseKeepPlaying() {
    if (_state == OfflineEpisodeState.playingOnline) {
      // Retain playingOnline state but game continues uninterrupted.
    }
  }

  /// Called when the player finishes or closes the game.
  void userExitedGame() {
    if (_isOnline) {
      _setState(OfflineEpisodeState.idle);
    } else {
      // Still offline; mark dismissed so they are not immediately re-offered
      // in the same episode.
      _setState(OfflineEpisodeState.dismissed);
    }
  }

  /// Suppresses automatic offline prompts.
  void suppress() {
    if (!_isSuppressed) {
      _isSuppressed = true;
      if (_state == OfflineEpisodeState.pendingOffline) {
        _pendingTimer?.cancel();
        _pendingTimer = null;
        _setState(OfflineEpisodeState.idle);
      } else if (_state == OfflineEpisodeState.offered) {
        _setState(OfflineEpisodeState.idle);
      }
    }
  }

  /// Restores automatic offline prompts after suppression.
  void allow() {
    if (_isSuppressed) {
      _isSuppressed = false;
      if (!_isOnline && _state == OfflineEpisodeState.idle) {
        _handleOffline();
      }
    }
  }

  /// Immediately forces an offline episode state for debugging or demo purposes.
  void debugForceOfflineState() {
    _pendingTimer?.cancel();
    _pendingTimer = null;
    _isOnline = false;
    _setState(OfflineEpisodeState.offered);
  }

  /// Immediately forces an online idle state for debugging or demo purposes.
  void debugForceOnlineState() {
    _pendingTimer?.cancel();
    _pendingTimer = null;
    _isOnline = true;
    _setState(OfflineEpisodeState.idle);
  }

  /// Releases resources, active timers, and connectivity subscriptions.
  void dispose() {
    _pendingTimer?.cancel();
    _pendingTimer = null;
    _subscription?.cancel();
    _subscription = null;
  }
}
