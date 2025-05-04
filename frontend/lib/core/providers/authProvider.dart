import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dart:developer';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createUser({
    required String email,
    required String fullName,
    required String role,
    String? unitNumber,
  }) async {
    _startLoading();
    try {
      final message = await _authService.createUser(
        email: email,
        fullName: fullName,
        role: role,
        unitNumber: unitNumber,
      );
      _successMessage = message;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _stopLoading();
  }

  Future<void> updatePassword({
    required String email,
    required String password,
  }) async {
    _startLoading();
    try {
      final message = await _authService.updatePassword(
        email: email,
        password: password,
      );
      _successMessage = message;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _stopLoading();
  }

  Future<void> sendSetPasswordEmail(String email) async {
    _startLoading();
    try {
      final message = await _authService.sendSetPasswordEmail(email: email);
      _successMessage = message;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _stopLoading();
  }

  Future<Map<String, dynamic>?> fetchUser() async {
    _startLoading();
    try {
      final data = await _authService.fetchUserById();
      _user = data;
      _errorMessage = null;
      return _user;
    } catch (e) {
      _errorMessage = e.toString();
      _user = null;
      return null;
    } finally {
      _stopLoading();
    }
  }

  Future<void> login(String email, String password) async {
    _startLoading();
    try {
      final message = await _authService.login(email: email, password: password);
      _successMessage = message;

    } catch (e) {
      log('provider error $e');
      _errorMessage = e.toString();
    }

    _stopLoading();
  }

  Future<void> adminSignup(String email, String password) async {
    _startLoading();
    try {
      final message = await _authService.adminSignup(email: email, password: password);
      _successMessage = message;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _stopLoading();
  }



  Future<void> securityLogin(String email, String password) async {
    _startLoading();
    try {
      final message = await _authService.securityLogin(email: email, password: password);
      _successMessage = message;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _stopLoading();
  }

  Future<void> securityLogout() async {
    _startLoading();
    try {
      final message = await _authService.securityLogout();
      _successMessage = message;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _stopLoading();
  }

  // Optional: reset messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
