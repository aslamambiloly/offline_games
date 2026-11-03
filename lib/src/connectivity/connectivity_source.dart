import 'dart:async';

/// Contract for checking and observing true internet reachability.
abstract class ConnectivitySource {
  /// Stream emitting real reachability updates (`true` = online, `false` = offline).
  Stream<bool> get onlineStream;

  /// Checks if the device currently has verified internet access.
  Future<bool> isOnline();

  /// Releases resources and stream subscriptions.
  void dispose();
}
