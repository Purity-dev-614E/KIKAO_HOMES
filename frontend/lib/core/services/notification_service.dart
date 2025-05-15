import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kikao_homes/core/constants/appEndpoints.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  // Edge Function URL - Update with your actual Edge Function URL
  static const String _createNotificationUrl = '${AppEndpoints.BASE_URL}/createnotification';

  // Create a new notification using the Edge Function
  static Future<void> createNotification({
    required String userId,
    required String message,
    required String type,
    Map<String, dynamic>? visitorData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_createNotificationUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken ?? ''}',
        },
        body: jsonEncode({
          'user_id': userId,
          'message': message,
          'type': type,
          'visitorData': visitorData,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to create notification: ${errorData['error'] ?? 'Unknown error'}');
      }

      print('Notification created and sent successfully');
    } catch (e) {
      print('Error creating notification: $e');
      // Re-throw to allow calling code to handle the error
      rethrow;
    }
  }
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    String? token;
    
    // Check for initial message (app opened from terminated state via notification)
    await _checkInitialMessage();
    
    try {
      // Request permissions
      await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      print("Firebase Messaging permission requested");

      // Get and upload device token
      
      // Handle web platform differently
      if (kIsWeb) {
        try {
          // For web, we need to handle service worker registration errors
          token = await _fcm.getToken(
            vapidKey: 'BBjW1phLyn2aZm_EIZ6jZrYrjku-bIjbYQ2vcl1PVlc8ZTgG-YsV0JXhLtuZgoYp9Zopeo4vPhAN-ZDpwXFUhrc',
          );
          
          if (token != null) {
            print("Web FCM token successfully obtained: $token");
          } else {
            print("Web FCM token is null - notification permission may be blocked");
          }
        } catch (e) {
          print("Error getting FCM token for web: $e");
          // Continue without FCM for web if there's an error
        }
      } else {
        // For mobile platforms
        token = await _fcm.getToken();
        print("Mobile FCM token: $token");
      }
    } catch (e) {
      print("Error initializing Firebase Messaging: $e");
    }

    // Save token to Supabase if available
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null && token != null) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({'device_token': token})
            .eq('id', userId);
        print("Token saved to Supabase");
      } catch (e) {
        print("Error saving token to Supabase: $e");
      }
    }

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("FCM message received in foreground: ${message.notification?.title}");
      print("FCM message body: ${message.notification?.body}");
      print("FCM message data: ${message.data}");
      
      // Log detailed visitor data for debugging
      final visitorData = message.data;
      if (visitorData.isNotEmpty) {
        print("VISITOR DATA (foreground): $visitorData");
        print("VISITOR DATA KEYS: ${visitorData.keys.toList()}");
        visitorData.forEach((key, value) {
          print("VISITOR DATA [$key]: $value (${value.runtimeType})");
        });
      }
      
      if (kIsWeb) {
        // For web, we can use the browser's Notification API if needed
        print("Web notification data: ${message.data}");
        // Web notifications are handled by the browser and Firebase
      } else {
        // For mobile platforms, use local notifications
        _showLocalNotification(message);
      }
    });

    // Background & Terminated message tap handler
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("FCM notification opened: ${message.data}");
      
      // Extract notification data from the message
      final notificationData = message.data;
      
      // Mark notification as read in the database if it has an ID
      if (notificationData['id'] != null) {
        _markNotificationAsRead(notificationData['id']);
      }
      
      // Detailed logging for debugging
      print("NOTIFICATION DATA (onMessageOpenedApp): $notificationData");
      if (notificationData.isNotEmpty) {
        print("NOTIFICATION DATA KEYS: ${notificationData.keys.toList()}");
        notificationData.forEach((key, value) {
          print("NOTIFICATION DATA [$key]: $value (${value.runtimeType})");
        });
        
        // Check if this is a visitor notification
        final type = notificationData['type'];
        if (type == 'visitor') {
          _handleVisitorNotification(notificationData);
          return;
        }
      } else {
        print("WARNING: Empty notification data received from notification");
      }
      
      // Default navigation if not a visitor notification or if processing failed
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushReplacementNamed('/notifications');
      }
    });

    // Only initialize local notifications for mobile platforms
    if (!kIsWeb) {
      _initLocalNotifications();
    }
  }

  static void _initLocalNotifications() {
    // Skip for web platform
    if (kIsWeb) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }
  
  // Handle tap on local notifications
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final String? payload = response.payload;
    print("Local notification tapped with payload: $payload");
    
    // Parse notification data from payload
    Map<String, dynamic>? notificationData;
    if (payload != null && payload.isNotEmpty) {
      try {
        notificationData = jsonDecode(payload);
        print("Parsed notification data: $notificationData");
        
        // Detailed logging for debugging
        print("NOTIFICATION DATA (local notification): $notificationData");
        if (notificationData != null && notificationData.isNotEmpty) {
          print("NOTIFICATION DATA KEYS: ${notificationData.keys.toList()}");
          notificationData.forEach((key, value) {
            print("NOTIFICATION DATA [$key]: $value (${value.runtimeType})");
          });
          
          // Check if this is a visitor notification
          final type = notificationData['type'];
          if (type == 'visitor') {
            _handleVisitorNotification(notificationData);
            return;
          }
        } else {
          print("WARNING: Empty or null notification data parsed from payload");
        }
      } catch (e) {
        print("Error parsing notification payload: $e");
        print("PAYLOAD CONTENT: $payload");
        print("PAYLOAD TYPE: ${payload.runtimeType}");
      }
    } else {
      print("WARNING: Empty or null payload received from notification");
    }
    
    // Default navigation if not a visitor notification or if processing failed
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushReplacementNamed('/notifications');
    } else {
      print("Navigator key not available for navigation");
    }
  }
  
  // Mark notification as read in the database
  static Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'status': 'read'})
          .eq('id', notificationId);
      print('Notification marked as read: $notificationId');
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Handle visitor-specific notifications
  static Future<void> _handleVisitorNotification(Map<String, dynamic> notificationData) async {
    print("Processing visitor notification: $notificationData");
    
    // Mark notification as read in the database if it has an ID
    if (notificationData['id'] != null) {
      await _markNotificationAsRead(notificationData['id']);
    }
    
    try {
      // Check if we have complete visitor data in the notification
      bool hasCompleteVisitorData = notificationData.containsKey('visitor_id') &&
                                   notificationData.containsKey('visitor_name') &&
                                   notificationData.containsKey('visitor_phone');
      
      Map<String, dynamic> visitorData = Map.from(notificationData);
      
      // If we only have visitor_id but not complete data, fetch the rest from the database
      if (notificationData.containsKey('visitor_id') && !hasCompleteVisitorData) {
        print("Notification contains visitor_id but not complete data. Fetching from database...");
        final fetchedData = await _fetchVisitorData(notificationData['visitor_id']);
        if (fetchedData != null) {
          visitorData = {...notificationData, ...fetchedData};
          print("Enhanced visitor data with database info: $visitorData");
        }
      }
      
      // Navigate to visitor approval screen with the visitor data
      // Wrap the visitor data in the expected format with 'visitorData' key
      if (navigatorKey.currentState != null) {
        print("NAVIGATING TO VISITOR APPROVAL WITH DATA: $visitorData");
        navigatorKey.currentState!.pushReplacementNamed(
          '/visitor_approval',
          arguments: {'visitorData': visitorData},
        );
      } else {
        print("Navigator key not available for visitor navigation");
      }
    } catch (e) {
      print("Error handling visitor notification: $e");
      // Fall back to default navigation
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushReplacementNamed('/notifications');
      }
    }
  }
  
  // Fetch visitor data from Supabase if needed
  static Future<Map<String, dynamic>?> _fetchVisitorData(String visitorId) async {
    try {
      print("Fetching visitor data for ID: $visitorId");
      
      final response = await Supabase.instance.client
          .from('visit_sessions')  // Use visit_sessions table instead of visitors
          .select()
          .eq('id', visitorId)
          .single();
      
      if (response != null) {
        print("Fetched visitor data: $response");
        
        // Map the response to the expected format
        final mappedData = {
          'id': response['id']?.toString() ?? '',
          'visitor_id': response['id']?.toString() ?? '',
          'visitor_name': response['visitor_name']?.toString() ?? 'Unknown',
          'visitor_phone': response['visitor_phone']?.toString() ?? 'Unknown',
          'unit_number': response['unit_number']?.toString() ?? 'Unknown',
          'status': response['status']?.toString() ?? 'pending',
          'check_in_at': response['check_in_at']?.toString() ?? '',
          'check_out_at': response['check_out_at']?.toString() ?? '',
          'national_id': response['national_id']?.toString() ?? '',
        };
        
        print("Mapped visitor data: $mappedData");
        return mappedData;
      } else {
        print("No visitor data found for ID: $visitorId");
        return null;
      }
    } catch (e) {
      print("Error fetching visitor data: $e");
      return null;
    }
  }

  static void _showLocalNotification(RemoteMessage message) {
    // Skip for web platform
    if (kIsWeb) return;
    // We can't use Navigator directly here because we don't have a BuildContext
    // This will be handled through a global navigation key or stream
    final notification = message.notification;
    if (notification != null) {
      final android = AndroidNotificationDetails(
        'kikao_channel',
        'Kikao Notifications',
        importance: Importance.max,
        priority: Priority.high,
        channelShowBadge: true,
      );
      final details = NotificationDetails(android: android);
      
      // Convert message data to JSON string for payload
      String payload = jsonEncode(message.data);
      
      // Log payload data for debugging
      print("CREATING LOCAL NOTIFICATION WITH DATA: ${message.data}");
      print("ENCODED PAYLOAD: $payload");
      
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
        payload: payload,
      );
    }
  }
  
  // Handle initial message when app is launched from terminated state
  static Future<void> _checkInitialMessage() async {
    // Get any messages which caused the application to open from a terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    
    if (initialMessage != null) {
      print("App opened from terminated state via notification");
      print("Initial message data: ${initialMessage.data}");
      
      // Extract notification data for logging
      final notificationData = initialMessage.data;
      
      // Detailed logging for debugging
      print("NOTIFICATION DATA (initial message): $notificationData");
      if (notificationData.isNotEmpty) {
        print("NOTIFICATION DATA KEYS: ${notificationData.keys.toList()}");
        notificationData.forEach((key, value) {
          print("NOTIFICATION DATA [$key]: $value (${value.runtimeType})");
        });
        
        // Delay navigation slightly to ensure app is fully initialized
        Future.delayed(const Duration(milliseconds: 500), () {
          // Check if this is a visitor notification
          final type = notificationData['type'];
          if (type == 'visitor') {
            print("VISITOR NOTIFICATION DETECTED: $notificationData");
            _handleVisitorNotification(notificationData);
          } else {
            // Default navigation for other notification types
            if (navigatorKey.currentState != null) {
              navigatorKey.currentState!.pushReplacementNamed('/notifications');
            } else {
              print("WARNING: Navigator not ready for default navigation");
            }
          }
        });
      } else {
        print("WARNING: Empty notification data received from initial message");
      }
    } else {
      print("No initial message - app was not opened from a notification");
    }
  }
}
