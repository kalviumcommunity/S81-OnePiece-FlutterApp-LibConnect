import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── Tasks ──────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get tasks =>
      _db.collection('tasks');
  CollectionReference<Map<String, dynamic>> get users =>
      _db.collection('users');

  Future<DocumentReference<Map<String, dynamic>>> addTask({
    required String title,
    required String description,
  }) {
    final safeTitle = title.trim();
    final safeDescription = description.trim();

    if (safeTitle.isEmpty || safeDescription.isEmpty) {
      throw ArgumentError('Title and description are required.');
    }

    return tasks.add({
      'title': safeTitle,
      'description': safeDescription,
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
    if (taskId.trim().isEmpty) {
      throw ArgumentError('Task ID is required.');
    }
    return tasks.doc(taskId).set(data, SetOptions(merge: merge));
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
  }) {
    final safeTaskId = taskId.trim();
    final safeTitle = title.trim();
    final safeDescription = description.trim();

    if (safeTaskId.isEmpty || safeTitle.isEmpty || safeDescription.isEmpty) {
      throw ArgumentError('Task ID, title, and description are required.');
    }

    return tasks.doc(safeTaskId).update({
      'title': safeTitle,
      'description': safeDescription,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTasks() {
    return tasks.orderBy('createdAt', descending: true).snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTasksOnce() {
    return tasks.get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String userId) {
    return users.doc(userId).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPendingTasks() {
    return tasks.where('status', isEqualTo: 'pending').snapshots();
  }

  // ── Notes ──────────────────────────────────────────────
  Future<void> addNote(String text) async {
    await _db.collection('notes').add({
      'text': text,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotes() {
    return _db.collection('notes').snapshots();
  }

  Future<void> updateNote(String id, String text) async {
    await _db.collection('notes').doc(id).update({'text': text});
  }

  Future<void> deleteNote(String id) async {
    await _db.collection('notes').doc(id).delete();
  }
}
