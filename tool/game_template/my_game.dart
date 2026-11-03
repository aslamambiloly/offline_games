import 'package:flutter/material.dart';
import 'package:offline_games/offline_games.dart';
import 'ui/my_game_widget.dart';

// TODO: 1. Rename MyGame to YourGameTitleGame (e.g. PongGame)
class MyGame extends OfflineGame {
  const MyGame();

  // TODO: 2. Add your name, emoji, and optional GitHub / Website
  @override
  GameMeta get meta => const GameMeta(
        id: 'my_game', // lower_snake_case required
        title: 'My Game',
        description: 'A brief description of your game in 1-2 sentences.',
        emoji: '🎮',
        authors: [
          GameAuthor(
            name: 'Your Name', // Required
            github: '@yourusername', // Optional
            url: 'https://yourwebsite.com', // Optional
          ),
        ],
      );

  @override
  Widget build(BuildContext context, GameSession session) {
    return MyGameWidget(session: session);
  }
}
