import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── Tasks ──────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get tasks =>
      _db.collection('tasks');
  CollectionReference<Map<String, dynamic>> get users =>
      _db.collection('users');

  Future<DocumentReference> addTask(String title) {
    return tasks.add({'title': title, 'createdAt': Timestamp.now()});
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
