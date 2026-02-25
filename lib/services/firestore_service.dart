import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── Tasks ──────────────────────────────────────────────
  CollectionReference get tasks => _db.collection('tasks');

  Future<DocumentReference> addTask(String title) {
    return tasks.add({'title': title, 'createdAt': Timestamp.now()});
  }

  Stream<QuerySnapshot> getTasks() {
    return tasks.orderBy('createdAt', descending: true).snapshots();
  }

  // ── Notes ──────────────────────────────────────────────
  Future<void> addNote(String text) async {
    await _db.collection('notes').add({
      'text': text,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getNotes() {
    return _db.collection('notes').snapshots();
  }

  Future<void> updateNote(String id, String text) async {
    await _db.collection('notes').doc(id).update({'text': text});
  }

  Future<void> deleteNote(String id) async {
    await _db.collection('notes').doc(id).delete();
  }
}
