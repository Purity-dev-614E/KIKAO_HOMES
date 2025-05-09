import 'package:flutter/material.dart';
import 'package:kikao_homes/core/providers/notificationProvider.dart';
import '../models/visit_sessions.dart';
import '../services/notification_service.dart';
import '../services/visit_service.dart';

class VisitProvider with ChangeNotifier {
  final VisitService _visitService = VisitService();

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
  Future<void> createVisitSession(VisitSessions session) async {
    try {
      print('VisitProvider: Creating visit session with data: ${session.toJson()}');
      final newSession = await _visitService.createVisitSession(session);
      print('VisitProvider: Visit session created successfully, response: ${newSession.toJson()}');
      _visits.add(newSession);
      notifyListeners();
      print('VisitProvider: Notified listeners after adding new session');
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


  Future<void> sendPushNotification({
    required String unitNumber,
    required String message,
  }) async {
    try {
      // Use NotificationService to send the notification
      await NotificationProvider().initializeNotifications(); //Ensure notifications are initialized
      print('Sending notification to unit $unitNumber: $message');
      // Add logic to send notification to the specific unit if needed
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  Future<void> notifySecurityApproval({
    required String message,
  }) async{
    try {
      // Use NotificationService to send the notification
      await NotificationProvider().initializeNotifications(); // Ensure notifications are initialized
      print('Sending notification to security $message');
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

 Future<void> notifySecurityRejection({
   required String message,
 }) async {
   try {
     // Use NotificationService to send the notification
     await NotificationProvider().initializeNotifications(); // Ensure notifications are initialized
     print('Sending notification: $message');
   } catch (e) {
     print('Error sending push notification: $e');
   }
 }
}
