import 'score_store.dart';

/// Default in-memory implementation of [ScoreStore].
class MemoryScoreStore implements ScoreStore {
  final Map<String, int> _scores = <String, int>{};

  @override
  Future<int?> read(String gameId) async => _scores[gameId];

  @override
  Future<void> write(String gameId, int score) async {
    final current = _scores[gameId];
    if (current == null || score > current) {
      _scores[gameId] = score;
    }
  }

  /// Clears all stored in-memory scores.
  void clear() => _scores.clear();
}
