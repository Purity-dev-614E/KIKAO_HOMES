import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  bool _isInitialized = false;
  String? _deviceToken;
  String? _error;

  bool get isInitialized => _isInitialized;
  String? get deviceToken => _deviceToken;
  String? get error => _error;

  Future<void> initializeNotifications() async {
    try {
      await NotificationService.initialize();
      _isInitialized = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isInitialized = false;
      notifyListeners();
    }
  }

  void reset() {
    _isInitialized = false;
    _deviceToken = null;
    _error = null;
    notifyListeners();
  }
}
