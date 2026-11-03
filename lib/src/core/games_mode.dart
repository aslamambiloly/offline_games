import 'offline_game.dart';

/// Presentation mode determining how offline games are chosen or launched.
sealed class GamesMode {
  /// Base const constructor.
  const GamesMode();

  /// Spin mode (default): a short, tasteful slot/wheel spin randomly selects a game.
  const factory GamesMode.spin() = SpinMode;

  /// Picker mode: players choose from an arcade grid catalog.
  const factory GamesMode.picker() = PickerMode;

  /// Single mode: always opens a specific game directly.
  const factory GamesMode.single(OfflineGame game) = SingleMode;
}

/// Random spin mode.
final class SpinMode extends GamesMode {
  /// Creates a [SpinMode].
  const SpinMode();
}

/// Catalog picker mode.
final class PickerMode extends GamesMode {
  /// Creates a [PickerMode].
  const PickerMode();
}

/// Single targeted game mode.
final class SingleMode extends GamesMode {
  /// Creates a [SingleMode] launching [game].
  const SingleMode(this.game);

  /// The game to launch.
  final OfflineGame game;
}
