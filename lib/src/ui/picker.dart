import 'package:flutter/material.dart';
import '../core/offline_game.dart';
import '../storage/score_store.dart';
import 'theme.dart';

/// Standalone arcade catalog grid widget letting players choose a mini-game.
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
    final theme = OfflineGamesTheme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'ARCADE GAMES',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: colorScheme.primary,
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
                      child: InkWell(
                        onTap: () => widget.onSelected(game),
                        borderRadius: theme.borderRadius,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: theme.borderRadius,
                            border: Border.all(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    game.meta.emoji,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const Spacer(),
                                  if (score != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '🏆 $score',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                game.meta.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'by $authorName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
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
