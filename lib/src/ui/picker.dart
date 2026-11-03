import 'package:flutter/material.dart';
import '../core/offline_game.dart';
import '../storage/score_store.dart';
import 'retro_pixel_text.dart';
import 'retro_screen.dart';

/// Standalone arcade catalog grid widget letting players choose a mini-game,
/// styled with authentic retro 8-bit pixel vector cards.
class GamePicker extends StatefulWidget {
  /// Creates a [GamePicker].
  const GamePicker({
    super.key,
    required this.games,
    required this.onSelected,
    this.scoreStore,
  });

  /// The collection of games available to select.
  final List<OfflineGame> games;

  /// Callback invoked when a game is selected.
  final void Function(OfflineGame game) onSelected;

  /// Optional storage store to load best scores for display.
  final ScoreStore? scoreStore;

  @override
  State<GamePicker> createState() => _GamePickerState();
}

class _GamePickerState extends State<GamePicker> {
  final Map<String, int> _scores = <String, int>{};

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final store = widget.scoreStore;
    if (store == null) return;

    for (final game in widget.games) {
      final score = await store.read(game.meta.id);
      if (score != null && mounted) {
        setState(() {
          _scores[game.meta.id] = score;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: PixelText(
                    'ARCADE GAMES',
                    pixelSize: 2.2,
                    color: Color(0xFF00F0FF),
                    glowColor: Color(0xFF00F0FF),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260,
                    mainAxisExtent: 180,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: widget.games.length,
                  itemBuilder: (context, index) {
                    final game = widget.games[index];
                    final authorName = game.meta.authors.first.name;
                    final score = _scores[game.meta.id];

                    return Semantics(
                      label:
                          'Play ${game.meta.title} by $authorName${score != null ? ', best score $score' : ''}',
                      button: true,
                      child: GestureDetector(
                        onTap: () => widget.onSelected(game),
                        child: RetroPixelCard(
                          borderColor: const Color(0xFF2C3552),
                          backgroundColor: const Color(0xFF0E111E),
                          shadowOffset: 3,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF161A2B),
                                      border: Border.all(
                                        color: const Color(0xFF00F0FF)
                                            .withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      game.meta.emoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (score != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A1F30),
                                        border: Border.all(
                                          color: const Color(0xFFFFB800)
                                              .withValues(alpha: 0.6),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: PixelText(
                                        '🏆 $score',
                                        pixelSize: 1.4,
                                        color: const Color(0xFFFFB800),
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              PixelText(
                                game.meta.title,
                                pixelSize: 1.8,
                                color: const Color(0xFF39FF14),
                                glowColor: const Color(0xFF39FF14),
                              ),
                              const SizedBox(height: 4),
                              PixelText(
                                'by $authorName',
                                pixelSize: 1.3,
                                color: const Color(0xFFFFB800),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const PixelText(
                                    'READY',
                                    pixelSize: 1.2,
                                    color: Color(0xFF00F0FF),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00F0FF),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
