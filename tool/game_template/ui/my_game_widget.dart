import 'package:flutter/material.dart';
import 'package:offline_games/offline_games.dart';
import '../logic/my_game_state.dart';

class MyGameWidget extends StatefulWidget {
  final GameSession session;

  const MyGameWidget({
    super.key,
    required this.session,
  });

  @override
  State<MyGameWidget> createState() => _MyGameWidgetState();
}

class _MyGameWidgetState extends State<MyGameWidget> {
  late MyGameState _state;

  @override
  void initState() {
    super.initState();
    // Always use widget.session.random instead of raw Random()!
    _state = MyGameState.initial(widget.session.random);

    // Listen to session.paused if using an active game loop or timer!
    widget.session.paused.addListener(_handlePauseChange);
  }

  @override
  void dispose() {
    widget.session.paused.removeListener(_handlePauseChange);
    super.dispose();
  }

  void _handlePauseChange() {
    // Pause or resume tickers/timers when the host or episode pauses
  }

  void _onTapAction() {
    if (widget.session.paused.value || _state.isGameOver) return;

    setState(() {
      _state = _state.performAction();
    });

    // Report score to the host session
    widget.session.reportScore(_state.score);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Score: ${_state.score}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onTapAction,
            child: const Text('Tap Me!'),
          ),
        ],
      ),
    );
  }
}
