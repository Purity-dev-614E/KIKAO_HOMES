import 'package:flutter/material.dart';
import 'package:kikao_homes/core/providers/notificationProvider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/visit_sessions.dart';
import '../services/notification_service.dart';
import '../services/visit_service.dart';

class VisitProvider with ChangeNotifier {
  final VisitService _visitService = VisitService();
  final _supabase = Supabase.instance.client;

  List<VisitSessions> _visits = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VisitSessions> get visits => _visits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<List<VisitSessions>> loadMyVisits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _visits = await _visitService.getMyVisits();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return _visits;
  }

  // Approve visit
  Future<void> approveVisit(String visitId) async {
    try {
      await _visitService.approveVisit(visitId);
      await loadMyVisits();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Reject visit
  Future<void> rejectVisit(String visitId) async {
    try {
      await _visitService.rejectVisit(visitId);
      await loadMyVisits();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Create a new visit session
  Future<VisitSessions> createVisitSession(VisitSessions session) async {
    try {
      print('VisitProvider: Creating visit session with data: ${session.toJson()}');
      final newSession = await _visitService.createVisitSession(session);
      print('VisitProvider: Visit session created successfully, response: ${newSession.toJson()}');
      _visits.add(newSession);
      notifyListeners();
      print('VisitProvider: Notified listeners after adding new session');
      return newSession; // Return the created session
    } catch (e) {
      print('VisitProvider: Error creating visit session: $e');
      _errorMessage = e.toString();
      notifyListeners();
      rethrow; // Re-throw to allow proper error handling in UI
    }
  }

  // Checkout visit by national ID
  Future<void> checkoutVisit(String nationalId) async {
    try {
      await _visitService.checkoutVisit(nationalId);
      await loadMyVisits(); // Or you can remove the checked out one manually
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Assign security to a visit
  Future<void> assignSecurityToVisit({
    required String visitorId,
    required String unitNumber,
    required String authUid,
  }) async {
    try {
      await _visitService.assignSecurityToVisit(
        visitorId: visitorId,
        unitNumber: unitNumber,
        authUid: authUid,
      );
      await loadMyVisits(); // Refresh list
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Fetch all active visits (e.g. for security/admin)
  Future<List<VisitSessions>> fetchActiveVisits() async {
    try {
      return await _visitService.fetchActiveVisits();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }


  final NotificationProvider _notificationProvider = NotificationProvider();

  Future<void> sendPushNotification({
    required String unitNumber,
    required String message,
    String type = 'visitor',
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationProvider.initializeNotifications();
      
      // Format the visitor data to match the expected structure
      // This ensures consistency between direct navigation and notification-based navigation
      Map<String, dynamic> formattedData = {};
      
      if (data != null) {
        // Map the data to the expected format for visitor approval screen
        formattedData = {
          'id': data['id'] ?? '',
          'visitor_id': data['visitor_id'] ?? data['id'] ?? '',
          'visitor_name': data['visitor_name'] ?? data['name'] ?? '',
          'visitor_phone': data['visitor_phone'] ?? data['phone'] ?? '',
          'unit_number': data['unit_number'] ?? unitNumber,
          'status': data['status'] ?? 'pending',
          'check_in_at': data['check_in_at'] ?? data['time'] ?? DateTime.now().toIso8601String(),
          'check_out_at': data['check_out_at'] ?? '',
          'national_id': data['national_id'] ?? '',
          'visit_purpose': data['purpose'] ?? data['visit_purpose'] ?? 'Visit',
        };
      }
      
      print('Sending formatted notification data: $formattedData');
      
      await _notificationProvider.sendUnitNotification(
        unitNumber: unitNumber,
        message: message,
        type: type,
        data: formattedData,
      );
      print('Notification sent to unit $unitNumber: $message');
    } catch (e) {
      print('Error sending push notification: $e');
      rethrow;
    }
  }

  Future<void> notifySecurityApproval({
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationProvider.initializeNotifications();
      // Assuming security users have a specific role in the profiles table
      final securityUsers = await _supabase
          .from('profiles')
          .select('id')
          .eq('role', 'security');

      for (var user in securityUsers) {
        await _notificationProvider.sendNotification(
          userId: user['id'],
          message: message,
          type: 'security_approval',
          data: data,
        );
      }
      print('Security approval notification sent: $message');
    } catch (e) {
      print('Error sending security approval notification: $e');
      rethrow;
    }
  }

  Future<void> notifySecurityRejection({
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationProvider.initializeNotifications();
      // Assuming security users have a specific role in the profiles table
      final securityUsers = await _supabase
          .from('profiles')
          .select('id')
          .eq('role', 'security');

      for (var user in securityUsers) {
        await _notificationProvider.sendNotification(
          userId: user['id'],
          message: message,
          type: 'security_rejection',
          data: data,
        );
      }
      print('Security rejection notification sent: $message');
    } catch (e) {
      print('Error sending security rejection notification: $e');
      rethrow;
    }
  }
}
