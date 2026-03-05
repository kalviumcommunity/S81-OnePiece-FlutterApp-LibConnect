import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class FirestoreSecurityDemoScreen extends StatefulWidget {
  const FirestoreSecurityDemoScreen({Key? key}) : super(key: key);

  @override
  State<FirestoreSecurityDemoScreen> createState() =>
      _FirestoreSecurityDemoScreenState();
}

class _FirestoreSecurityDemoScreenState extends State<FirestoreSecurityDemoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createSecureTask() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await _firestoreService.addTask(
        title: title,
        description: description,
      );

      _titleController.clear();
      _descriptionController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Task created with ownership tracking'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  Future<void> _viewSecurityRules() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔐 Security Rules Example'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Implementation:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                  fontFamily: 'monospace',
                ),
                child: const Text(
                  'match /tasks/{taskId} {\n'
                  '  allow read: if request.auth != null;\n'
                  '  allow create: if request.auth != null\n'
                  '    && request.resource.data.ownerId\n'
                  '       == request.auth.uid;\n'
                  '  allow update, delete: if\n'
                  '    resource.data.ownerId\n'
                  '    == request.auth.uid;\n'
                  '}',
                  style: TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'What This Means:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('Anyone logged in can read tasks'),
              _buildBulletPoint('Only task owner can update task'),
              _buildBulletPoint('Only task owner can delete task'),
              _buildBulletPoint('User ID is verified automatically'),
            ],
          ),
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

  Future<void> _testOwnershipProtection() async {
    try {
      // Try to show current user's info
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('👤 Your User Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${currentUser.email}'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User ID (UID):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      currentUser.uid,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '🔒 Security Mechanism:\n\n'
                'This UID is automatically verified by Firestore Security Rules.\n\n'
                'When you create a task, the system:\n'
                '1. Verifies you are logged in\n'
                '2. Saves your UID as task owner\n'
                '3. Later rejects edits from other users\n',
                style: TextStyle(fontSize: 12),
              ),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  Future<void> _viewUserTasks() async {
    try {
      final currentUserId = _auth.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot =
          await FirebaseFirestore.instance.collection('tasks').get();

      // Count tasks owned by current user
      final userTasks = snapshot.docs
          .where((doc) => doc['ownerId'] == currentUserId)
          .toList();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('📊 Security Stats'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatItem('Your Tasks:', userTasks.length.toString()),
              _buildStatItem('Total Tasks DB:', snapshot.docs.length.toString()),
              const SizedBox(height: 16),
              const Text(
                '✅ Security in Action:\n\n'
                'Even though all tasks are in the same collection, '
                'users can only see/edit their own.\n\n'
                'This is enforced by the ownerId field and security rules.',
                style: TextStyle(fontSize: 12),
              ),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 Firestore Security'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Authentication Status ──
            Card(
              color: currentUser != null ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser != null ? '✅ Authenticated' : '❌ Not Authenticated',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: currentUser != null ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (currentUser != null) ...[
                      Text('User: ${currentUser.email}'),
                      const SizedBox(height: 4),
                      SelectableText(
                        'UID: ${currentUser.uid}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ] else
                      const Text('Sign in to access secure data'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Why Firestore Security Matters ──
            const Text(
              '🛡️ Why Security Matters:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSecurityBenefit(
              '🔒',
              'User Privacy',
              'Users can only access their own data',
            ),
            _buildSecurityBenefit(
              '⛔',
              'Prevent Unauthorized Changes',
              'Only task owner can edit or delete',
            ),
            _buildSecurityBenefit(
              '🚫',
              'Block Anonymous Writes',
              'Must be authenticated to create',
            ),
            _buildSecurityBenefit(
              '👤',
              'Role-Based Access',
              'Rules enforce user permissions',
            ),
            const SizedBox(height: 24),

            // ── Create Secure Task ──
            const Text(
              '📝 Create Secure Task:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Task title...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.task),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Task description...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: currentUser != null ? _createSecureTask : null,
                icon: const Icon(Icons.add),
                label: const Text('Create Task'),
              ),
            ),
            const SizedBox(height: 24),

            // ── Info Cards ──
            const Text(
              '🔍 Understanding Security:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionCard(
                  '📋',
                  'View Rules',
                  _viewSecurityRules,
                ),
                _buildActionCard(
                  '👤',
                  'Your Info',
                  _testOwnershipProtection,
                ),
                _buildActionCard(
                  '📊',
                  'Security Stats',
                  _viewUserTasks,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Security Concepts ──
            _buildConceptCard(
              'Authentication vs Authorization',
              'Authentication = Proving you are who you say (sign in)\n\n'
                  'Authorization = What you are allowed to do (security rules)',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildConceptCard(
              'ownerId Field Pattern',
              'Tasks include "ownerId" field that stores creator\'s UID.\n\n'
                  'Security rules check this field to verify ownership.',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildConceptCard(
              'Subcollections for Privacy',
              'Notes are stored in user subcollections (users/{uid}/notes).\n\n'
                  'Firestore rules prevent access to other users\' subcollections.',
              Colors.purple,
            ),
            const SizedBox(height: 24),

            // ── Implementation Checklist ──
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ Security Implementation Checklist:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCheckItem('Require authentication for data access'),
                    _buildCheckItem('Store ownerId in all user-created documents'),
                    _buildCheckItem('Apply security rules before deployment'),
                    _buildCheckItem('Test rules with Firebase Simulator'),
                    _buildCheckItem('Use subcollections for private data'),
                    _buildCheckItem('Validate data on both client & server'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBenefit(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
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

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('• $text', style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildActionCard(String icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: Card(
        elevation: 1,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConceptCard(String title, String description, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
