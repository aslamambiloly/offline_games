/// Defines how the offline games prompt or overlay is triggered.
enum OfflineTrigger {
  /// Card appears automatically when the device is offline for at least `offlineDelay` (default).
  auto,

  /// Small non-intrusive banner strip with "Play?".
  banner,

  /// Never automatic; the host application triggers display programmatically via [OfflineGamesController].
  manual,
}
