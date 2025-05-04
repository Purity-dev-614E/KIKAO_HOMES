import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
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

    // Get and upload device token
    String? token;
    
    // Handle web platform differently
    if (kIsWeb) {
      try {
        // For web, we need to handle service worker registration errors
        token = await _fcm.getToken(
          vapidKey: 'BLBolON8V8vTrHBLkIZMvHE_PqzXgKxJZ9vN-djyQwJvgFjK7xp9lDjPEInNXF0cuMQAYPSiCY3wYozOLnP-9Uw',
        );
        print("Web FCM token: $token");
      } catch (e) {
        print("Error getting FCM token for web: $e");
        // Continue without FCM for web if there's an error
      }
    } else {
      // For mobile platforms
      token = await _fcm.getToken();
      print("Mobile FCM token: $token");
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
      if (!kIsWeb) {
        // Only show local notifications on mobile platforms
        _showLocalNotification(message);
      }
    });

    // Background & Terminated message tap handler
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("FCM notification opened: ${message.data}");
      // Navigate or handle logic here
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
    // Handle navigation or specific logic when the user taps on the notification
    // Example: Navigator.pushNamed(context, 'approval_screen');
  }

  static void _showLocalNotification(RemoteMessage message) {
    // Skip for web platform
    if (kIsWeb) return;
    
    final notification = message.notification;
    if (notification != null) {
      final android = AndroidNotificationDetails(
        'kikao_channel',
        'Kikao Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      final details = NotificationDetails(android: android);
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
        payload: message.data.toString(),
      );
    }
  }
}
