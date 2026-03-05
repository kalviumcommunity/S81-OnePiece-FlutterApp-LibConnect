# Firebase Cloud Messaging (FCM) Integration Guide

## Overview

You have successfully integrated Firebase Cloud Messaging (FCM) into your Flutter application! This guide will help you set up, configure, and test push notifications across all notification states (foreground, background, and terminated).

---

## 📁 Implementation Files Created

### 1. **NotificationService** (`lib/services/notification_service.dart`)
A comprehensive singleton service that handles all FCM operations:
- Initializes Firebase Messaging
- Requests notification permissions
- Handles messages in foreground, background, and terminated states
- Manages device tokens
- Supports topic-based messaging

### 2. **NotificationsDemoScreen** (`lib/screens/notifications_demo.dart`)
An interactive demo screen showing:
- Current notification status
- Device FCM token
- Received message history
- Test actions (subscribe/unsubscribe to topics, reset token)
- Important setup reminders

### 3. **Dependencies Added**
- `firebase_messaging: ^15.0.0` - Added to `pubspec.yaml`

### 4. **Main App Updates** (`lib/main.dart`)
- Initialized `NotificationService` in `main()` function
- Added route `/notifications` to access the demo screen

---

## 🚀 Getting Started

### Step 1: Install Dependencies

```bash
flutter pub get
```

The latest version of `firebase_messaging` will be installed, along with all its dependencies.

### Step 2: Platform-Specific Configuration

#### **Android Setup**

1. **Enable Cloud Messaging API:**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select your project
   - Go to **Project Settings** > **Cloud Messaging** tab
   - Under Server API Key section, you'll see your credentials

2. **Google Services Configuration:**
   - Already configured if you set up Firebase Authentication
   - File location: `android/app/google-services.json`

3. **Request Notification Permissions (Android 13+):**
   - The `NotificationService` automatically requests permissions via code
   - For API 33+, users will see a permission prompt when the app runs

#### **iOS Setup**

1. **APNs Configuration:**
   - In Firebase Console, go to **Project Settings** > **Cloud Messaging**
   - Upload your APNs Key (obtained from Apple Developer Account)
   - Or configure APNs certificate

2. **Firebase Info File:**
   - Ensure `ios/Runner/GoogleService-Info.plist` is present
   - This file is generated when you add your iOS app to the Firebase project

3. **Enable Push Notifications:**
   - In Xcode: Select **Runner** > **Signing & Capabilities**
   - Click **+ Capability**
   - Add **Push Notifications**

4. **Enable Background Modes:**
   - In Xcode capabilities, also add **Background Modes**
   - Enable: **Background Fetch** and **Remote Notifications**

---

## 💻 Testing Notifications

### Method 1: Firebase Console (Recommended)

1. **Navigate to Cloud Messaging:**
   - Firebase Console → Project → **Cloud Messaging** tab

2. **Send a Test Notification:**
   - Click **Send your first message**
   - Enter notification details:
     - Title: `Test Message`
     - Body: `Hello from Firebase!`
   - Click **Send test message**
   - Select your target device

3. **Alternative: Send to Topic**
   - Instead of selecting device, choose **Topic**
   - Enter topic name (app must be subscribed)
   - Send message

### Method 2: Postman/REST API

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_TOKEN_HERE",
    "notification": {
      "title": "Hello World",
      "body": "This is a test notification"
    }
  }'
```

### Method 3: Cloud Functions

Deploy a Cloud Function to trigger notifications:

```dart
// Example Firebase Cloud Function (Node.js)
const admin = require('firebase-admin');

exports.sendNotification = functions.https.onCall(async (data, context) => {
  const message = {
    notification: {
      title: data.title,
      body: data.body,
    },
    token: data.deviceToken,
  };
  
  return admin.messaging().send(message);
});
```

---

## 🔔 Notification States Explained

### 1. **Foreground State**
- App is open and active in the foreground
- Notifications arrive via `FirebaseMessaging.onMessage`
- The `NotificationService` displays a snack bar
- Messages appear in the **Received Messages** list in the demo

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Handle foreground message
  print("Message received: ${message.notification?.body}");
});
```

### 2. **Background State**
- App is minimized but still running in memory
- Handled by `_firebaseMessagingBackgroundHandler` (top-level function)
- Creates a system notification that can be tapped
- On Android 12+, notification appears in the system tray

```dart
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.notification?.title}");
}
```

### 3. **Terminated State**
- App is completely closed
- Only messages with notification payload will be displayed as system notification
- When user taps the notification, app launches
- Use `getInitialMessage()` to handle this:

```dart
RemoteMessage? initialMsg = await FirebaseMessaging.instance.getInitialMessage();
if (initialMsg != null) {
  // App was opened from terminated state
  print("Launched from notification");
}
```

---

## 🎯 Key Features & Usage

### Get Device Token

```dart
String? token = await notificationService.getToken();
print("FCM Token: $token");
```

The token is **unique per device** and **changes** when:
- App is reinstalled
- User clears app data
- User calls `deleteToken()`

### Subscribe to Topic-Based Messaging

```dart
// Subscribe to a topic
await notificationService.subscribeToTopic('news');

// Now send notification to topic 'news' instead of individual tokens
// All subscribed devices will receive it
```

**Use Cases:**
- Announcements to all users
- Category-based notifications (sports, weather, etc.)
- Broadcasting to user segments

### Check Notification Permissions

```dart
bool isEnabled = await notificationService.areNotificationsEnabled();
if (!isEnabled) {
  print("Notifications are disabled!");
}
```

### Custom Callbacks

Set up custom handlers for different notification scenarios:

```dart
final service = NotificationService();

// Listen to foreground messages
service.onMessage = (RemoteMessage message) {
  print("Foreground: ${message.notification?.title}");
  // Show custom UI, play sound, etc.
};

// Listen when app is opened via notification
service.onMessageOpenedApp = (RemoteMessage message) {
  print("User tapped notification!");
  // Navigate to specific screen
  Navigator.pushNamed(context, '/detail', arguments: message.data);
};

// Handle app launched from notification
service.onMessageTerminated = (RemoteMessage message) {
  print("App opened from terminated state");
};
```

---

## 📊 Notification Payload Structure

### Full Payload Format

```json
{
  "notification": {
    "title": "New Message",
    "body": "You have a new message from John"
  },
  "data": {
    "userId": "12345",
    "chatId": "67890",
    "thumbnail": "https://example.com/image.jpg"
  },
  "android": {
    "priority": "high",
    "ttl": "86400s"
  },
  "apns": {
    "headers": {
      "apns-priority": "10"
    }
  }
}
```

### Notification vs Data Payload

| Aspect | Notification | Data |
|--------|--------------|------|
| Purpose | Display to user | Custom app data |
| Shows in system tray | Yes | No (background) |
| User action triggered | Yes | Implicit |
| Custom handling | Limited | Full control |

---

## 🐛 Common Issues & Solutions

### Issue: Notifications not appearing on Android

**Causes:**
- Notification Channel not created
- Permissions not granted
- App is killed (not just backgrounded)

**Solutions:**
```dart
// Ensure the app requests permissions
await notificationService.initialize();

// For Android 12+, manually open Settings:
// Settings > Apps > YourApp > Notifications > Allow
```

### Issue: Token keeps changing

**Cause:** Normal behavior, tokens can refresh

**Solution:** Re-fetch token when app relaunches:
```dart
String? token = await notificationService.getToken();
// Send to your backend for latest mapping
```

### Issue: Background handler not called

**Causes:**
- Handler not defined as top-level function
- Handler not registered before app exits

**Solution:** Ensure `_firebaseMessagingBackgroundHandler` is registered:
```dart
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

### Issue: iOS notifications not working

**Causes:**
- APNs not configured in Firebase
- Push Notifications capability not enabled in Xcode
- Invalid or expired APNs certificate

**Solutions:**
1. Verify APNs Key in Firebase Console
2. Check Xcode signing capabilities
3. Rebuild iOS app: `flutter clean && flutter run`

### Issue: Foreground notifications don't show alert

**Cause:** Foreground notifications only trigger callback, don't show system UI by default

**Solution:** Show custom UI in your callback:
```dart
notificationService.onMessage = (RemoteMessage message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message.notification?.title ?? ''))
  );
};
```

---

## 🔐 Security Best Practices

1. **Never hardcode tokens** - Tokens are device-specific and should be obtained at runtime

2. **Validate message sources** - Verify messages come from your backend:
```dart
notificationService.onMessage = (RemoteMessage message) {
  // Validate authorization token in message.data
  if (!_isValidMessage(message)) return;
};
```

3. **Use HTTPS for token delivery** - Always encrypt communication with your backend

4. **Implement rate limiting** - Prevent spam by limiting notifications per user per hour

5. **Respect user preferences** - Allow users to disable notifications:
```dart
if (await notificationService.areNotificationsEnabled()) {
  // Proceed with notifications
}
```

6. **Manage data carefully** - Be cautious with sensitive data in notification payloads since they might be logged

---

## 📚 Testing Checklist

- [ ] Can compile and run the app
- [ ] Notification permission prompt appears on first run
- [ ] Device token displays in NotificationsDemoScreen
- [ ] Can send notification from Firebase Console
- [ ] Notification appears when app is in foreground
- [ ] System notification appears when app is backgrounded
- [ ] Tapping notification opens app and is logged
- [ ] Can subscribe to topics
- [ ] Can receive topic-based notifications
- [ ] Notifications work after app restart (terminated state)
- [ ] Token is valid (32+ characters, alphanumeric + special chars)

---

## 📖 Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Messaging Guide](https://firebase.flutter.dev/docs/messaging/overview/)
- [Android Notification Permissions (API 33+)](https://developer.android.com/develop/ui/views/notifications/notification-permission)
- [iOS APNs Setup](https://developer.apple.com/documentation/usernotifications)
- [Flutter Background Execution](https://flutter.dev/docs/development/packages-and-plugins/background-processes)

---

## 🎓 Demo Screen Navigation

Access the notifications demo screen:

```dart
// From any screen:
Navigator.pushNamed(context, '/notifications');

// Or direct push:
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => NotificationsDemoScreen())
);
```

The demo screen shows:
- ✅ Real-time notification status
- 📱 Your unique device token
- 📨 History of received messages
- 🔧 Tools to test subscriptions and settings

---

## 🚀 Next Steps

1. **Configure your backend** to store device tokens
2. **Implement notification routing** based on user preferences
3. **Add analytics** to track notification delivery and engagement
4. **Set up Cloud Functions** for automated notifications
5. **Test thoroughly** on both Android and iOS

---

**Happy notifying! 🔔**
