import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Top-level function to handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Background message received: ${message.notification?.title}');
  debugPrint('   Body: ${message.notification?.body}');
  debugPrint('   Data: ${message.data}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Callbacks for notification events
  Function(RemoteMessage)? onMessage;
  Function(RemoteMessage)? onMessageOpenedApp;
  Function(RemoteMessage)? onMessageTerminated;

  /// Initialize FCM service
  /// This should be called early in the app lifecycle (in main or early in HomeScreen)
  Future<void> initialize() async {
    debugPrint('📱 Initializing Firebase Messaging Service...');

    // Register the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permissions
    await _requestNotificationPermission();

    // Set up foreground message handler
    _setupForegroundMessageHandler();

    // Set up message opened handler
    _setupMessageOpenedHandler();

    // Check for initial message (app opened from terminated state)
    await _checkInitialMessage();

    // Get and log the FCM token
    await _getAndLogToken();

    debugPrint('✅ Firebase Messaging Service initialized successfully!');
  }

  /// Request notification permissions from the user
  Future<NotificationSettings> _requestNotificationPermission() async {
    debugPrint('🔐 Requesting notification permissions...');

    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalSound: false,
      provisional: false,
      sound: true,
    );

    debugPrint('✓ Permission status: ${settings.authorizationStatus}');

    return settings;
  }

  /// Handle messages received when the app is in the foreground
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 Foreground message received!');
      debugPrint('   Title: ${message.notification?.title}');
      debugPrint('   Body: ${message.notification?.body}');
      debugPrint('   Data: ${message.data}');

      // Call the callback if provided
      onMessage?.call(message);
    });
  }

  /// Handle when a user taps on a notification
  void _setupMessageOpenedHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🎯 App opened from notification!');
      debugPrint('   Title: ${message.notification?.title}');
      debugPrint('   Body: ${message.notification?.body}');
      debugPrint('   Data: ${message.data}');

      // Call the callback if provided
      onMessageOpenedApp?.call(message);
    });
  }

  /// Check if the app was opened from a terminated state via notification
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('🌟 App opened from terminated state via notification!');
      debugPrint('   Title: ${initialMessage.notification?.title}');
      debugPrint('   Body: ${initialMessage.notification?.body}');
      debugPrint('   Data: ${initialMessage.data}');

      // Call the callback if provided
      onMessageTerminated?.call(initialMessage);
    }
  }

  /// Get the device FCM token
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('🔑 FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Get and log the device token (internal use)
  Future<void> _getAndLogToken() async {
    final token = await getToken();
    if (token != null) {
      debugPrint('✓ Device token obtained successfully');
    }
  }

  /// Check if notification permissions are granted
  Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Get current notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    return await _messaging.getNotificationSettings();
  }

  /// Subscribe to a topic (for topic-based messaging)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✓ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✓ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Delete the instance ID (resets the FCM token)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      debugPrint('✓ FCM token deleted. A new one will be generated on next launch.');
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }
}
