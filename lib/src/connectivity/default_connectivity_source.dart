import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'connectivity_source.dart';

/// Default [ConnectivitySource] implementation using an isolated [InternetConnection] instance.
class DefaultConnectivitySource implements ConnectivitySource {
  /// Creates a [DefaultConnectivitySource].
  DefaultConnectivitySource({InternetConnection? connection})
      : _connection = connection ??
            InternetConnection.createInstance(
              checkInterval: const Duration(seconds: 2),
            ) {
    _statusSubscription = _connection.onStatusChange.listen((status) {
      _controller.add(status == InternetStatus.connected);
    });
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    try {
      final online = await _connection.hasInternetAccess;
      if (!_controller.isClosed) {
        _controller.add(online);
      }
    } catch (_) {}
  }

  final InternetConnection _connection;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<InternetStatus>? _statusSubscription;

  @override
  Stream<bool> get onlineStream => _controller.stream;

  @override
  Future<bool> isOnline() async {
    return _connection.hasInternetAccess;
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _controller.close();
  }
}
