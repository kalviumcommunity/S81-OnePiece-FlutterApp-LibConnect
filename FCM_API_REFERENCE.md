# Firebase Cloud Messaging - Quick API Reference

## NotificationService Singleton

The `NotificationService` is a singleton that provides access to all FCM functionality.

### Initialize Service

```dart
import 'services/notification_service.dart';

final notificationService = NotificationService();
await notificationService.initialize();
```

---

## Core Methods

### Initialize

```dart
/// Initialize FCM service with permissions and handlers
await NotificationService().initialize();
```

**Called automatically in `main.dart`**, but can be called again if needed.

---

### Get Device Token

```dart
/// Get the current device's unique FCM token
String? token = await notificationService.getToken();

// Token example: "eRJwNjSiT0KhGQ..."
// Always store this on your backend for later use
```

**Important:**
- Token is **unique per device**
- Token can change between app launches
- Implement token refresh mechanism in your backend

---

### Check Notification Status

```dart
/// Check if notifications are enabled
bool isEnabled = await notificationService.areNotificationsEnabled();

if (isEnabled) {
  print("✓ Notifications are enabled");
} else {
  print("✗ Notifications are disabled - user must enable in Settings");
}
```

---

### Get Notification Settings

```dart
/// Get detailed notification settings
NotificationSettings settings = 
    await notificationService.getNotificationSettings();

print(status: ${settings.authorizationStatus}); // authorized, denied, etc.
print(badge: ${settings.badge});                 // true/false
print(sound: ${settings.sound});                 // true/false
print(alert: ${settings.alert});                 // true/false
```

---

## Topic Management

### Subscribe to Topic

```dart
/// Subscribe this device to a topic
/// All messages sent to this topic will be received
await notificationService.subscribeToTopic('news');
await notificationService.subscribeToTopic('sports');
```

**Use Cases:**
- App categories (news, sports, weather)
- User segments (premium, beta users)
- Broadcast announcements to multiple devices

---

### Unsubscribe from Topic

```dart
/// Unsubscribe this device from a topic
await notificationService.unsubscribeFromTopic('news');
```

---

## Token Management

### Delete/Reset Token

```dart
/// Delete the current device token
/// A new token will be generated on next app launch
await notificationService.deleteToken();
```

**Use Cases:**
- User logout (if using per-device authentication)
- Security compromise (force token refresh)
- Testing token refresh mechanism

---

## Message Callbacks

Set up handlers for different notification scenarios:

### Handle Foreground Messages

```dart
/// Called when app is open and receives a message
notificationService.onMessage = (RemoteMessage message) {
  print("📨 Foreground message received!");
  
  // Access notification data
  final title = message.notification?.title;
  final body = message.notification?.body;
  final data = message.data;
  
  // Show custom UI
  showCustomDialog(title, body);
};
```

**Characteristics:**
- App is active and visible
- User can see custom notification UI
- Perfect for in-app alerts and important updates

---

### Handle App Opened from Notification

```dart
/// Called when user taps a notification and app is backgrounded
notificationService.onMessageOpenedApp = (RemoteMessage message) {
  print("🎯 User tapped notification!");
  
  final data = message.data;
  final targetScreen = data['screen'] ?? 'home';
  
  // Navigate to specific screen
  navigateToScreen(targetScreen, data);
};
```

**Characteristics:**
- App was minimized
- User tapped the system notification
- Use `data` to determine navigation target

---

### Handle App Opened from Terminated State

```dart
/// Called when app was terminated and opened via notification
notificationService.onMessageTerminated = (RemoteMessage message) {
  print("🌟 App opened from terminated state!");
  
  // Handle the message
  final data = message.data;
  navigateToDeepLink(data);
};
```

**Characteristics:**
- App was completely closed
- User tapped system notification
- Use for deep linking and complex navigation

---

## Complete Usage Example

```dart
import 'package:flutter/material.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService().initialize();
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final notificationService = NotificationService();
  String? deviceToken;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    // Get token and store in backend
    deviceToken = await notificationService.getToken();
    await _sendTokenToBackend(deviceToken);
    
    // Set up message handlers
    notificationService.onMessage = _handleForeground;
    notificationService.onMessageOpenedApp = _handleOpened;
    notificationService.onMessageTerminated = _handleTerminated;
  }

  void _handleForeground(RemoteMessage message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.notification?.title ?? ''))
    );
  }

  void _handleOpened(RemoteMessage message) {
    Navigator.pushNamed(context, '/details', 
        arguments: message.data);
  }

  void _handleTerminated(RemoteMessage message) {
    // Deep link handling
    Navigator.pushNamed(context, message.data['target']);
  }

  Future<void> _sendTokenToBackend(String? token) async {
    // TODO: Implement backend API call
    // POST /api/notifications/register-token
    // { "deviceToken": token, "platform": "android/ios" }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
```

---

## RemoteMessage Structure

Access these properties from incoming messages:

```dart
RemoteMessage message; // Received message

// Notification data (shown to user)
message.notification?.title       // String
message.notification?.body        // String
message.notification?.imageUrl    // String (iOS/Android)

// Custom app data
message.data                       // Map<String, dynamic>
message.data['userId']             // Custom field
message.data['action']             // Custom action

// Technical properties
message.messageId                  // Unique ID
message.sendTime                   // Timestamp
message.contentAvailable           // iOS specific
message.mutableContent             // iOS specific
```

---

## Error Handling

```dart
Future<void> safeGetToken() async {
  try {
    final token = await notificationService.getToken();
    if (token != null) {
      print("Token: $token");
    }
  } catch (e) {
    print("Error getting token: $e");
    // Handle error appropriately
  }
}

Future<void> safeSubscribeToTopic(String topic) async {
  try {
    await notificationService.subscribeToTopic(topic);
    print("Subscribed to $topic");
  } catch (e) {
    print("Error subscribing to $topic: $e");
  }
}
```

---

## Logging & Debugging

The `NotificationService` logs important events via `debugPrint`:

```
📱 Initializing Firebase Messaging Service...
🔐 Requesting notification permissions...
✓ Permission status: AuthorizationStatus.authorized
📨 Foreground message received!
   Title: Test Message
   Body: Hello World!
   Data: {key: value}
🎯 App opened from notification!
📧 Subscribed to topic: news
✓ FCM Token: eRJwNjSiT0KhGQf...
```

Enable debug logging:
```bash
flutter run -v  # Verbose logging
```

---

## Common Patterns

### Pattern 1: User Login - Register Token

```dart
Future<void> onUserLogin(String userId) async {
  final token = await notificationService.getToken();
  
  await _apiClient.post('/users/$userId/devices', {
    'token': token,
    'platform': Platform.isAndroid ? 'android' : 'ios',
    'appVersion': packageInfo.version,
  });
}
```

### Pattern 2: User Logout - Clear Token

```dart
Future<void> onUserLogout() async {
  final token = await notificationService.getToken();
  
  await _apiClient.delete('/users/devices/$token');
  await notificationService.deleteToken();
}
```

### Pattern 3: Topic-Based Notifications

```dart
Future<void> subscribeUserToPreferences(List<String> topics) async {
  for (final topic in topics) {
    await notificationService.subscribeToTopic(topic);
  }
  
  // Backend knows user preferences via topics
}
```

### Pattern 4: Deep Linking from Notification

```dart
void _handleDeepLink(RemoteMessage message) {
  final target = message.data['target'];
  final id = message.data['id'];
  
  if (target != null) {
    Navigator.pushNamed(context, '/$target/$id');
  }
}
```

---

## Testing Notifications

Use these Debug functions in your app:

```dart
// Add to your dev menu or test screen
Future<void> _testForeground() async {
  // Manually trigger handler
  notificationService.onMessage?.call(mockMessage);
}

Future<void> _testBackground() async {
  // Background handler is tested via Firebase Console
}

Future<void> _testTokenRefresh() async {
  await notificationService.deleteToken();
  final newToken = await notificationService.getToken();
  print("New token after refresh: $newToken");
}
```

---

## Best Practices

✅ **DO:**
- Call `initialize()` early in app lifecycle
- Store tokens in secure backend database
- Refresh token mapping on app launch
- Use topics for broadcast notifications
- Validate message sources in handlers
- Handle permission denial gracefully

❌ **DON'T:**
- Hardcode tokens in your app
- Assume token stays the same
- Ignore permission denial errors
- Store sensitive data in notification body
- Send too many notifications (causes disables)
- Forget to register background handler

---

## Related Files

- Implementation: [notification_service.dart](lib/services/notification_service.dart)
- Demo Screen: [notifications_demo.dart](lib/screens/notifications_demo.dart)
- Setup Guide: [FCM_SETUP_GUIDE.md](FCM_SETUP_GUIDE.md)
- Firebase Console: https://console.firebase.google.com
