import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

class NotificationsDemoScreen extends StatefulWidget {
  const NotificationsDemoScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsDemoScreen> createState() => _NotificationsDemoScreenState();
}

class _NotificationsDemoScreenState extends State<NotificationsDemoScreen> {
  final NotificationService _notificationService = NotificationService();
  String? _deviceToken;
  String _notificationStatus = 'Initializing...';
  List<String> _receivedMessages = [];
  bool _isNotificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Initialize the notification service
      await _notificationService.initialize();

      // Set up callbacks
      _notificationService.onMessage = _handleForegroundMessage;
      _notificationService.onMessageOpenedApp = _handleMessageOpenedApp;
      _notificationService.onMessageTerminated = _handleTerminatedMessage;

      // Get device token
      final token = await _notificationService.getToken();
      final isEnabled = await _notificationService.areNotificationsEnabled();

      setState(() {
        _deviceToken = token;
        _isNotificationEnabled = isEnabled;
        _notificationStatus = isEnabled
            ? '✅ Notifications Enabled'
            : '⚠️ Notifications Disabled';
      });
    } catch (e) {
      setState(() {
        _notificationStatus = '❌ Initialization Error: $e';
      });
      debugPrint('Error initializing notifications: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final messageText =
        '${message.notification?.title ?? 'No Title'}: ${message.notification?.body ?? 'No Body'}';

    setState(() {
      _receivedMessages.insert(0, '[FOREGROUND] $messageText');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📨 Message Received: ${message.notification?.title}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final messageText =
        '${message.notification?.title ?? 'No Title'}: ${message.notification?.body ?? 'No Body'}';

    setState(() {
      _receivedMessages.insert(0, '[OPENED] $messageText');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎯 Opened from Notification: ${message.notification?.title}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleTerminatedMessage(RemoteMessage message) {
    final messageText =
        '${message.notification?.title ?? 'No Title'}: ${message.notification?.body ?? 'No Body'}';

    setState(() {
      _receivedMessages.insert(0, '[TERMINATED] $messageText');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🌟 App Opened from Terminated: ${message.notification?.title}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _subscribeToTopic() async {
    await _notificationService.subscribeToTopic('demo_topic');
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Subscribed to demo_topic'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _unsubscribeFromTopic() async {
    await _notificationService.unsubscribeFromTopic('demo_topic');
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Unsubscribed from demo_topic'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteToken() async {
    await _notificationService.deleteToken();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Token reset. A new one will be generated.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openNotificationSettings() async {
    final settings = await _notificationService.getNotificationSettings();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${settings.authorizationStatus}'),
            const SizedBox(height: 8),
            Text('Alert: ${settings.alert}'),
            Text('Badge: ${settings.badge}'),
            Text('Sound: ${settings.sound}'),
            Text('Critical Sound: ${settings.criticalSound}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearMessages() {
    setState(() {
      _receivedMessages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 Push Notifications (FCM)'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              elevation: 2,
              color: _isNotificationEnabled ? Colors.green.shade50 : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _notificationStatus,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isNotificationEnabled ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Device Token:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          _deviceToken ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            const Text(
              'How FCM Works:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInstructionItem(
              '1',
              'Foreground',
              'Your app receives notifications while open',
              Colors.blue,
            ),
            _buildInstructionItem(
              '2',
              'Background',
              'App receives notifications when minimized',
              Colors.purple,
            ),
            _buildInstructionItem(
              '3',
              'Terminated',
              'App can handle messages from terminated state',
              Colors.red,
            ),
            const SizedBox(height: 24),

            // Actions
            const Text(
              'Test Actions:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  '📧 Subscribe Topic',
                  _subscribeToTopic,
                  Colors.blue,
                ),
                _buildActionButton(
                  '🚫 Unsubscribe Topic',
                  _unsubscribeFromTopic,
                  Colors.orange,
                ),
                _buildActionButton(
                  '⚙️ Settings',
                  _openNotificationSettings,
                  Colors.teal,
                ),
                _buildActionButton(
                  '🔄 Reset Token',
                  _deleteToken,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Received Messages
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Received Messages:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_receivedMessages.isNotEmpty)
                  TextButton(
                    onPressed: _clearMessages,
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_receivedMessages.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.mail_outline, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No messages received yet.\nSend a notification from Firebase Console.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              )
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _receivedMessages.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _receivedMessages[index],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Important Notes
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ Important Setup Steps:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildNote('1. Enable FCM in Firebase Console'),
                    _buildNote('2. Download google-services.json (Android)'),
                    _buildNote('3. Download GoogleService-Info.plist (iOS)'),
                    _buildNote('4. Grant notification permissions when prompted'),
                    _buildNote('5. Copy your device token to Firebase Console'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
      ),
      child: Text(label),
    );
  }

  Widget _buildNote(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
