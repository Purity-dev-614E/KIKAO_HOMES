import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  bool _isInitialized = false;
  String? _deviceToken;
  String? _error;
  final _supabase = Supabase.instance.client;

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
      rethrow;
    }
  }

  Future<void> sendNotification({
    required String userId,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      await initializeNotifications();
    }

    try {
      await NotificationService.createNotification(
        userId: userId,
        message: message,
        type: type,
        visitorData: data,
      );
    } catch (e) {
      _error = 'Failed to send notification: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendUnitNotification({
    required String unitNumber,
    required String message,
    String type = 'visitor',
    Map<String, dynamic>? data,
  }) async {
    try {
      // First, get the resident's user ID for this unit
      final residentResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('unit_number', unitNumber)
          .single();

      final userId = residentResponse['id'] as String;
      if (userId.isEmpty) {
        throw Exception('No valid user ID found for unit $unitNumber');
      }
      await sendNotification(
        userId: userId,
        message: message,
        type: type,
        data: data,
      );
    } catch (e) {
      _error = 'Error sending notification to unit $unitNumber: $e';
      notifyListeners();
      rethrow;
    }
  }

  void reset() {
    _isInitialized = false;
    _deviceToken = null;
    _error = null;
    notifyListeners();
  }
}
