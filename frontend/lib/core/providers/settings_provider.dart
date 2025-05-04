import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  // General Settings
  bool _visitorNotificationsEnabled = true;
  String _autoCheckOutTime = '18:00';
  String _securityCheckInTime = '07:00';

  // Security Settings
  bool _securityBadgeRequired = true;
  String _securityPatrolFrequency = '2 hours';

  // Resident Settings
  int _maxVisitorsPerResident = 3;
  String _visitorDurationLimit = '4 hours';

  // Getters
  bool get visitorNotificationsEnabled => _visitorNotificationsEnabled;
  String get autoCheckOutTime => _autoCheckOutTime;
  String get securityCheckInTime => _securityCheckInTime;
  bool get securityBadgeRequired => _securityBadgeRequired;
  String get securityPatrolFrequency => _securityPatrolFrequency;
  int get maxVisitorsPerResident => _maxVisitorsPerResident;
  String get visitorDurationLimit => _visitorDurationLimit;

  // Setters
  void setVisitorNotificationsEnabled(bool value) {
    _visitorNotificationsEnabled = value;
    notifyListeners();
  }

  void setAutoCheckOutTime(String time) {
    _autoCheckOutTime = time;
    notifyListeners();
  }

  void setSecurityCheckInTime(String time) {
    _securityCheckInTime = time;
    notifyListeners();
  }

  void setSecurityBadgeRequired(bool value) {
    _securityBadgeRequired = value;
    notifyListeners();
  }

  void setSecurityPatrolFrequency(String frequency) {
    _securityPatrolFrequency = frequency;
    notifyListeners();
  }

  void setMaxVisitorsPerResident(int count) {
    _maxVisitorsPerResident = count;
    notifyListeners();
  }

  void setVisitorDurationLimit(String duration) {
    _visitorDurationLimit = duration;
    notifyListeners();
  }

  // Save settings
  Future<void> saveSettings() async {
    // TODO: Implement saving settings to persistent storage
    print('Saving settings...');
  }
}
