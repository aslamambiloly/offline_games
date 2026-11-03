import 'package:flutter/foundation.dart';

/// Controller allowing host applications to inspect and manipulate the offline games UI.
class OfflineGamesController extends ChangeNotifier {
  bool _isOpen = false;
  bool _isSuppressed = false;

  /// Whether the offline games overlay/panel is currently open.
  bool get isOpen => _isOpen;

  /// Whether automatic offline prompts are currently suppressed.
  bool get isSuppressed => _isSuppressed;

  /// Programmatically opens the offline games interface.
  void open() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  /// Programmatically closes the offline games interface.
  void close() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }

  /// Suppresses automatic offline prompts (e.g. during checkout/payment flows).
  void suppress() {
    if (!_isSuppressed) {
      _isSuppressed = true;
      notifyListeners();
    }
  }

  /// Restores automatic offline prompts after suppression.
  void allow() {
    if (_isSuppressed) {
      _isSuppressed = false;
      notifyListeners();
    }
  }
}
