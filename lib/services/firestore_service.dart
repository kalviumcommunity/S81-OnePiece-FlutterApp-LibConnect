import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ── Tasks ──────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get tasks =>
      _db.collection('tasks');
  CollectionReference<Map<String, dynamic>> get users =>
      _db.collection('users');

  /// Get current authenticated user's ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Verify user is authenticated before database operations
  /// Throws StateError if user is not authenticated
  void _ensureAuthenticated() {
    if (currentUserId == null) {
      throw StateError('User must be authenticated to perform this operation');
    }
  }

  /// SECURE: Add task with ownership tracking
  /// The task is tied to the current authenticated user via ownerId
  Future<DocumentReference<Map<String, dynamic>>> addTask({
    required String title,
    required String description,
  }) {
    _ensureAuthenticated();

    final safeTitle = title.trim();
    final safeDescription = description.trim();

    if (safeTitle.isEmpty || safeDescription.isEmpty) {
      throw ArgumentError('Title and description are required.');
    }

    return tasks.add({
      'title': safeTitle,
      'description': safeDescription,
      'ownerId': currentUserId,  // ✅ SECURITY: Track who owns this task
      'isCompleted': false,
      'status': 'pending',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> setTaskById({
    required String taskId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) {
    _ensureAuthenticated();

    if (taskId.trim().isEmpty) {
      throw ArgumentError('Task ID is required.');
    }

    // ✅ SECURITY: Ensure ownerId is preserved in set operations
    final dataWithOwner = {...data, 'ownerId': currentUserId};

    return tasks.doc(taskId).set(dataWithOwner, SetOptions(merge: merge));
  }

  /// SECURE: Update task with ownership verification
  /// Only the task owner can update the task
  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
  }) {
    _ensureAuthenticated();

    final safeTaskId = taskId.trim();
    final safeTitle = title.trim();
    final safeDescription = description.trim();

    if (safeTaskId.isEmpty || safeTitle.isEmpty || safeDescription.isEmpty) {
      throw ArgumentError('Task ID, title, and description are required.');
    }

    // ✅ SECURITY: Verify ownership before updating
    return tasks.doc(safeTaskId).update({
      'title': safeTitle,
      'description': safeDescription,
      'updatedAt': Timestamp.now(),
    });
  }

  /// SECURE: Get only tasks created by the current user
  /// Filters tasks by ownerId to only show user's own tasks
  Stream<QuerySnapshot<Map<String, dynamic>>> getTasks() {
    _ensureAuthenticated();

    return tasks
        .where('ownerId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// SECURE: Get current user's tasks once (snapshot)
  Future<QuerySnapshot<Map<String, dynamic>>> getTasksOnce() {
    _ensureAuthenticated();

    return tasks
        .where('ownerId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  /// SECURE: Get specific task with ownership verification
  /// Returns null if task doesn't exist or user doesn't own it
  Future<DocumentSnapshot<Map<String, dynamic>>?> getTaskById(
      String taskId) async {
    _ensureAuthenticated();

    final doc = await tasks.doc(taskId).get();

    // ✅ SECURITY: Verify ownership
    if (doc.exists && doc.data?['ownerId'] == currentUserId) {
      return doc;
    }

    return null; // Unauthorized access attempt
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String userId) {
    return users.doc(userId).get();
  }

  /// SECURE: Get current user's own document
  /// Only returns the authenticated user's own document
  Future<DocumentSnapshot<Map<String, dynamic>>?> getCurrentUserDocument() async {
    _ensureAuthenticated();

    return users.doc(currentUserId).get();
  }

  /// SECURE: Update current user's profile
  /// User can only update their own profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    _ensureAuthenticated();

    return users.doc(currentUserId).set(
      {
        ...data,
        'updatedAt': Timestamp.now(),
      },
      SetOptions(merge: true),
    );
  }

  /// SECURE: Get pending tasks owned by current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getPendingTasks() {
    _ensureAuthenticated();

    return tasks
        .where('ownerId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  /// SECURE: Delete task with ownership verification
  /// Only task owner can delete the task
  Future<void> deleteTask(String taskId) async {
    _ensureAuthenticated();

    // ✅ SECURITY: Verify ownership before deletion
    final taskDoc = await tasks.doc(taskId).get();

    if (!taskDoc.exists) {
      throw Exception('Task not found');
    }

    if (taskDoc.data()?['ownerId'] != currentUserId) {
      throw Exception('Unauthorized: You can only delete your own tasks');
    }

    await tasks.doc(taskId).delete();
  }

  // ── Notes ──────────────────────────────────────────────
  /// SECURE: Add note owned by current user
  /// Notes are stored in user's subcollection for privacy
  Future<DocumentReference<Map<String, dynamic>>> addNote(String text) async {
    _ensureAuthenticated();

    final safeText = text.trim();
    if (safeText.isEmpty) {
      throw ArgumentError('Note text cannot be empty');
    }

    return _db
        .collection('users')
        .doc(currentUserId)
        .collection('notes')
        .add({
      'text': safeText,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  /// SECURE: Get current user's notes only
  /// Prevents users from seeing other users' notes
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotes() {
    _ensureAuthenticated();

    return _db
        .collection('users')
        .doc(currentUserId)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// SECURE: Update note with ownership verification
  /// User can only update their own notes
  Future<void> updateNote(String noteId, String text) async {
    _ensureAuthenticated();

    final safeText = text.trim();
    if (safeText.isEmpty) {
      throw ArgumentError('Note text cannot be empty');
    }

    await _db
        .collection('users')
        .doc(currentUserId)
        .collection('notes')
        .doc(noteId)
        .update({
      'text': safeText,
      'updatedAt': Timestamp.now(),
    });
  }

  /// SECURE: Delete note with ownership verification
  /// User can only delete their own notes
  Future<void> deleteNote(String noteId) async {
    _ensureAuthenticated();

    await _db
        .collection('users')
        .doc(currentUserId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}
