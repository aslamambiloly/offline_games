import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_games/src/host/offline_episode.dart';

/// A deterministic fake timer that executes callbacks on demand.
class FakeTimer implements Timer {
  FakeTimer(this.duration, this.callback);

  final Duration duration;
  final void Function() callback;
  bool _isActive = true;

  @override
  bool get isActive => _isActive;

  @override
  int get tick => 0;

  @override
  void cancel() {
    _isActive = false;
  }

  void fire() {
    if (_isActive) {
      _isActive = false;
      callback();
    }
  }
}

class FakeTimerFactory {
  final List<FakeTimer> createdTimers = <FakeTimer>[];

  Timer createTimer(Duration duration, void Function() callback) {
    final timer = FakeTimer(duration, callback);
    createdTimers.add(timer);
    return timer;
  }

  void fireLatest() {
    expect(createdTimers, isNotEmpty,
        reason: 'Expected a timer to be scheduled');
    final active = createdTimers.lastWhere((t) => t.isActive);
    active.fire();
  }

  bool get hasActiveTimer => createdTimers.any((t) => t.isActive);
}

void main() {
  group('OfflineEpisode state machine', () {
    late FakeTimerFactory timerFactory;
    late StreamController<bool> connectivityController;
    late List<OfflineEpisodeState> stateHistory;
    late OfflineEpisode episode;

    setUp(() {
      timerFactory = FakeTimerFactory();
      connectivityController = StreamController<bool>.broadcast();
      stateHistory = <OfflineEpisodeState>[];

      episode = OfflineEpisode(
        onlineStream: connectivityController.stream,
        initialOnline: true,
        offlineDelay: const Duration(seconds: 3),
        timerFactory: timerFactory.createTimer,
        onStateChanged: (state) => stateHistory.add(state),
      );
    });

    tearDown(() {
      episode.dispose();
      connectivityController.close();
    });

    Future<void> emitConnectivity(bool isOnline) async {
      connectivityController.add(isOnline);
      await pumpEventQueue();
    }

    test('starts in idle state when initially online', () {
      expect(episode.state, OfflineEpisodeState.idle);
      expect(stateHistory, isEmpty);
    });

    test('offline -> offer after offlineDelay', () async {
      // 1. Connection drops
      await emitConnectivity(false);
      expect(episode.state, OfflineEpisodeState.pendingOffline);
      expect(timerFactory.hasActiveTimer, isTrue);

      // 2. Timer fires after offlineDelay
      timerFactory.fireLatest();
      expect(episode.state, OfflineEpisodeState.offered);
      expect(stateHistory, [
        OfflineEpisodeState.pendingOffline,
        OfflineEpisodeState.offered,
      ]);
    });

    test('quick flap ignored: drops and recovers before delay returns to idle',
        () async {
      // 1. Connection drops
      await emitConnectivity(false);
      expect(episode.state, OfflineEpisodeState.pendingOffline);
      expect(timerFactory.hasActiveTimer, isTrue);

      // 2. Connection returns before timer fires
      await emitConnectivity(true);
      expect(episode.state, OfflineEpisodeState.idle);
      expect(timerFactory.hasActiveTimer, isFalse);

      expect(stateHistory, [
        OfflineEpisodeState.pendingOffline,
        OfflineEpisodeState.idle,
      ]);
    });

    test(
        'one offer per offline episode: dismissed stays dismissed until reconnect',
        () async {
      // 1. Offline & offered
      await emitConnectivity(false);
      timerFactory.fireLatest();
      expect(episode.state, OfflineEpisodeState.offered);

      // 2. User dismisses offer
      episode.userDismissedOffer();
      expect(episode.state, OfflineEpisodeState.dismissed);

      // 3. Repeated offline signal during same episode does not trigger new offer
      await emitConnectivity(false);
      expect(episode.state, OfflineEpisodeState.dismissed);
      expect(timerFactory.hasActiveTimer, isFalse);

      // 4. Connection returns -> episode ends, resets to idle
      await emitConnectivity(true);
      expect(episode.state, OfflineEpisodeState.idle);

      // 5. Next offline event is a NEW episode -> should offer again!
      await emitConnectivity(false);
      expect(episode.state, OfflineEpisodeState.pendingOffline);
      timerFactory.fireLatest();
      expect(episode.state, OfflineEpisodeState.offered);
    });

    test('suppress and allow controls', () async {
      // 1. Connection drops
      await emitConnectivity(false);
      expect(episode.state, OfflineEpisodeState.pendingOffline);

      // 2. App enters sensitive flow (e.g. payment) -> suppress
      episode.suppress();
      expect(episode.state, OfflineEpisodeState.idle);
      expect(timerFactory.hasActiveTimer, isFalse);
      expect(episode.isSuppressed, isTrue);

      // 3. While suppressed, offline does not trigger pending
      await emitConnectivity(false);
      expect(episode.state, OfflineEpisodeState.idle);

      // 4. Sensitive flow ends -> allow
      episode.allow();
      expect(episode.isSuppressed, isFalse);
    });

    test('playing flow and back-online-while-playing prompt', () async {
      // 1. Offline & offered
      await emitConnectivity(false);
      timerFactory.fireLatest();
      expect(episode.state, OfflineEpisodeState.offered);

      // 2. User accepts offer
      episode.userAcceptedOffer();
      expect(episode.state, OfflineEpisodeState.playing);

      // 3. Connection returns while playing -> prompts back-online
      await emitConnectivity(true);
      expect(episode.state, OfflineEpisodeState.playingOnline);

      // 4. User chooses keep playing -> remains in playingOnline
      episode.userChoseKeepPlaying();
      expect(episode.state, OfflineEpisodeState.playingOnline);

      // 5. User finishes and exits game -> returns to idle (because online)
      episode.userExitedGame();
      expect(episode.state, OfflineEpisodeState.idle);
    });

    test('exiting game while still offline marks episode as dismissed',
        () async {
      // 1. Offline -> Offered -> Playing
      await emitConnectivity(false);
      timerFactory.fireLatest();
      episode.userAcceptedOffer();
      expect(episode.state, OfflineEpisodeState.playing);

      // 2. User exits game while still offline
      episode.userExitedGame();
      // Must not re-prompt offer immediately in the same episode
      expect(episode.state, OfflineEpisodeState.dismissed);
    });
  });
}
