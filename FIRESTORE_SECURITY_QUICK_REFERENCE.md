# Firestore Security - Quick Reference

## 🚀 TL;DR - Secure Your Firestore in 3 Steps

### 1. Deploy Rules
Copy [firestore.rules](firestore.rules) content → Firebase Console → Firestore → Rules → Publish

### 2. Add Authentication
User signs in → `FirebaseAuth.instance.currentUser` is available

### 3. Track Ownership
Every document includes `ownerId: currentUser.uid` → Rules verify before allowing access

---

## Common Rule Template

```
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User-owned documents
    match /tasks/{taskId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        request.resource.data.ownerId == request.auth.uid;
      allow update, delete: if request.auth != null &&
        resource.data.ownerId == request.auth.uid;
    }
    
    // Deny everything else
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## Firebase Service with Security

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  // ✅ Always check authentication
  void _ensureAuthenticated() {
    if (_auth.currentUser == null) {
      throw StateError('User must be authenticated');
    }
  }
  
  // ✅ Include ownership when creating
  Future<void> addTask(String title) async {
    _ensureAuthenticated();
    
    await _db.collection('tasks').add({
      'title': title,
      'ownerId': _auth.currentUser!.uid,  // IMPORTANT
      'createdAt': Timestamp.now(),
    });
  }
  
  // ✅ Filter by ownership when reading
  Stream<QuerySnapshot> getTasks() {
    _ensureAuthenticated();
    
    return _db.collection('tasks')
      .where('ownerId', isEqualTo: _auth.currentUser!.uid)
      .snapshots();
  }
  
  // ✅ Verify ownership before updating
  Future<void> updateTask(String taskId, String title) async {
    _ensureAuthenticated();
    
    final doc = await _db.collection('tasks').doc(taskId).get();
    
    if (doc.data()?['ownerId'] != _auth.currentUser!.uid) {
      throw Exception('Unauthorized: You can only update your own tasks');
    }
    
    await doc.reference.update({'title': title});
  }
}
```

---

## Rule Conditions Cheat Sheet

| Need | Rule |
|------|------|
| Only authenticated users | `if request.auth != null` |
| Only on sign-in | `if request.auth != null && request.auth.uid == userId` |
| Only document owner | `if resource.data.ownerId == request.auth.uid` |
| When creating with owner | `if request.resource.data.ownerId == request.auth.uid` |
| Admin only | `if getUser().role == 'admin'` |
| Deny all | `if false` |

---

## Error Handling

```dart
try {
  await firestore.collection('tasks').doc(id).delete();
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ You don\'t have permission'))
    );
  } else {
    print('Error: ${e.message}');
  }
}
```

---

## Three Security Levels

### Level 1: ❌ UNSAFE - Test Mode (Default)
```
match /{document=**} {
  allow read, write: if true;  // NEVER DEPLOY
}
```

### Level 2: ✅ BASIC - Authenticated Users Only
```
match /{document=**} {
  allow read, write: if request.auth != null;
}
```

### Level 3: ✅✅ SECURE - Ownership-Based
```
match /tasks/{taskId} {
  allow read, write: if request.auth != null &&
    resource.data.ownerId == request.auth.uid;
}
```

---

## Firestore Structure with Security

```
Database: Firestore
├── collections/
│   ├── users/
│   │   └── {uid}/
│   │       ├── name: "John"
│   │       ├── email: "john@example.com"
│   │       └── notes/ (subcollection)
│   │           └── {noteId}/
│   │               ├── text: "Private note"
│   │               └── createdAt: timestamp
│   │
│   └── tasks/
│       ├── {taskId}/
│       │   ├── title: "Buy milk"
│       │   ├── ownerId: "abc123"
│       │   └── createdAt: timestamp
│       │
│       └── {taskId2}/
│           ├── title: "Walk dog"
│           ├── ownerId: "xyz789"
│           └── createdAt: timestamp
```

**Why this structure is secure:**
- User's subcollections are private by path
- Tasks track ownership via `ownerId` field
- Rules verify both path and data

---

## Testing Checklist

- [ ] User can create task (ownerId is theirs)
- [ ] User can read their own task
- [ ] User can update their own task
- [ ] User can delete their own task
- [ ] User CANNOT read other user's task
- [ ] User CANNOT update other user's task
- [ ] User CANNOT delete other user's task
- [ ] Anonymous user cannot do anything

---

## Common Patterns

### Pattern: Task Management

```
Task rules:
- Read: authenticated users
- Create: must set ownerId = currentUser
- Update/Delete: only owner
```

```dart
// Creating
await _db.collection('tasks').add({
  'title': title,
  'ownerId': _auth.currentUser!.uid,  // ✅ REQUIRED
});

// Querying (only your tasks)
_db.collection('tasks')
  .where('ownerId', isEqualTo: _auth.currentUser!.uid)
  .snapshots();
```

### Pattern: User Profile

```
User rules:
- Read: only own profile
- Write: only own profile
```

```dart
// Rules
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// Code
await _db.collection('users')
  .doc(_auth.currentUser!.uid)
  .set(profileData);
```

### Pattern: Private Notes

```
Notes rules:
- Store in subcollection under user
- Rules automatically protect by path
```

```dart
// Structure: users/{uid}/notes/{noteId}
await _db.collection('users')
  .doc(_auth.currentUser!.uid)
  .collection('notes')
  .add({'text': note});
```

---

## Production Checklist

Before deploying your app:

```
Security Rules
□ Replaced test mode rules
□ Every collection has explicit rules
□ Catch-all denies by default
□ Tested with Rules Playground

Code Implementation
□ Added ownerId to all user documents
□ App checks authentication before DB calls
□ Error handling for PERMISSION_DENIED
□ No sensitive data exposed in errors

Testing
□ Authenticated user can access own data
□ Authenticated user cannot access others' data
□ Anonymous users completely blocked
□ All CRUD operations tested

Firebase Console
□ Rules deployed and published
□ Authentication enabled
□ At least one sign-in method active
□ No test mode rules active
```

---

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Always get `permission-denied` | User not authenticated | Call `signIn()` first |
| Can create but not update | Missing `ownerId` | Add to create and update |
| Others can see my data | No rule restriction | Check rule logic |
| Rule won't compile | Syntax error | Validate in Firebase Console |

---

## Related Files

- Full Rules: [firestore.rules](firestore.rules)
- Service Class: [lib/services/firestore_service.dart](lib/services/firestore_service.dart)
- Demo Screen: [lib/screens/firestore_security_demo.dart](lib/screens/firestore_security_demo.dart)
- Full Guide: [FIRESTORE_SECURITY_GUIDE.md](FIRESTORE_SECURITY_GUIDE.md)

---

## Demo

Access the interactive security demo in your app:

```
Navigation → /firestore-security
```

The demo shows:
- ✅ Current authentication status
- ✅ How ownership works
- ✅ Security rule examples
- ✅ Test operations
