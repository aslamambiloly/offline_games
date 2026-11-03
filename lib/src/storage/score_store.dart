/// Storage contract for saving and loading player game scores.
abstract class ScoreStore {
  /// Reads the highest score recorded for [gameId], or null if not played yet.
  Future<int?> read(String gameId);

  /// Saves a new score for [gameId]. Implementations should update the best
  /// score if [score] is higher than previous records.
  Future<void> write(String gameId, int score);
}
