# Firestore Security Rules & Authentication Guide

## 🔐 Overview

This guide explains how to secure your Firebase Firestore database using authentication and fine-grained security rules. Every Firestore database starts in "test mode" with open read/write access—this guide shows you how to transition to a secure, production-ready configuration.

---

## ⚠️ Important: Test Mode is Unsafe

**Default Test Mode Rules (UNSAFE):**
```
match /{document=**} {
  allow read, write: if true;  // ❌ Anyone can read/write
}
```

You **must** replace these with secure rules before deploying to real users.

---

## 📋 Table of Contents

1. [Why Firestore Security Matters](#why-firestore-security-matters)
2. [Authentication Setup](#authentication-setup)
3. [Security Rules Explained](#security-rules-explained)
4. [Common Rule Patterns](#common-rule-patterns)
5. [Testing Rules](#testing-rules)
6. [Implementation Checklist](#implementation-checklist)
7. [Troubleshooting](#troubleshooting)

---

## Why Firestore Security Matters

### Threats Without Proper Security

- **Data Exposure**: Anyone can read all user data
- **Unauthorized Changes**: Users can modify other users' data
- **Data Deletion**: Malicious users can delete important documents
- **Spam/Abuse**: Anonymous users can spam write operations
- **Cost Overrun**: Attackers can generate massive write costs

### Benefits of Proper Security

✅ **User Privacy**: Each user can only access their own data  
✅ **Data Integrity**: Only authorized users can modify data  
✅ **Role-Based Access**: Different permission levels (admin, user, etc.)  
✅ **Compliance**: Meet privacy regulations (GDPR, CCPA)  
✅ **Performance**: Rules prevent unnecessary operations before they hit the database  

---

## Authentication Setup

### Step 1: Enable Firebase Authentication

In [Firebase Console](https://console.firebase.google.com):

1. Go to **Authentication** → **Sign-in method**
2. Enable providers you want to support:
   - ✅ Email/Password
   - ✅ Google Sign-In
   - ✅ Phone Authentication
   - ✅ Other providers

### Step 2: Initialize Firebase in Flutter

Already done in your app's `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### Step 3: Sign In a User

Example using Firebase Auth:

```dart
import 'package:firebase_auth/firebase_auth.dart';

final auth = FirebaseAuth.instance;

// Sign up
await auth.createUserWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Sign in
await auth.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Get current user
User? currentUser = auth.currentUser;
print('Logged in as: ${currentUser?.email}');
print('User ID: ${currentUser?.uid}');
```

### Step 4: Understand `request.auth` in Rules

In Firestore rules, `request.auth` contains the authenticated user's information:

```
request.auth.uid          // User's unique ID
request.auth.email        // User's email address
request.auth.token.claims // Custom claims (if using custom tokens)
```

**Important**: `request.auth` is `null` if the user is NOT authenticated.

---

## Security Rules Explained

### Rule Structure

```
service cloud.firestore {
  match /databases/{database}/documents {
    match /path/to/document {
      allow read, write: if condition;
    }
  }
}
```

### Basic Conditions

| Condition | Meaning | Example |
|-----------|---------|---------|
| `true` | Always allow | `if true;` |
| `false` | Always deny | `if false;` |
| `request.auth != null` | User is authenticated | `if request.auth != null;` |
| `request.auth.uid == userId` | User's ID matches | `if request.auth.uid == userId;` |

---

## Common Rule Patterns

### Pattern 1: Authenticated Users Only

**Requirement**: Only signed-in users can read/write

```
match /tasks/{document=**} {
  allow read, write: if request.auth != null;
}
```

**What it does:**
- ✅ Allows any signed-in user to read all tasks
- ✅ Allows any signed-in user to write any task
- ❌ Blocks anonymous users completely

---

### Pattern 2: User-Owned Documents

**Requirement**: Users can only access their own documents

```
match /users/{userId} {
  allow read, write: if request.auth != null && 
    request.auth.uid == userId;
}
```

**What it does:**
- ✅ User `abc123` can only access `/users/abc123`
- ❌ User `abc123` cannot access `/users/xyz789`
- ❌ Protects each user's personal data

**Example in code:**
```dart
// ✅ User can access their own document
await firestore
  .collection('users')
  .doc(currentUser.uid)
  .get();

// ❌ User cannot access another user's document
// Firestore will throw PERMISSION_DENIED error
await firestore
  .collection('users')
  .doc(someOtherId)
  .get();
```

---

### Pattern 3: Subcollections for Privacy

**Requirement**: Private data in user subcollections

```
match /users/{userId} {
  match /notes/{noteId} {
    allow read, write: if request.auth != null && 
      request.auth.uid == userId;
  }
}
```

**Collection Structure:**
```
users/
  userId1/
    notes/
      note1/
        text: "My private note"
  userId2/
    notes/
      note1/
        text: "Another user's note"
```

**Implementation:**
```dart
// Add note to user's subcollection
await firestore
  .collection('users')
  .doc(currentUser.uid)
  .collection('notes')
  .add({'text': 'Private note'});
```

---

### Pattern 4: Owner-Controlled Documents

**Requirement**: Only document owner can update/delete

```
match /tasks/{taskId} {
  // Anyone can read
  allow read: if request.auth != null;
  
  // Anyone can create
  allow create: if request.auth != null &&
    // But ownerId MUST be set to current user
    request.resource.data.ownerId == request.auth.uid;
  
  // Only owner can update
  allow update: if request.auth != null &&
    resource.data.ownerId == request.auth.uid;
  
  // Only owner can delete
  allow delete: if request.auth != null &&
    resource.data.ownerId == request.auth.uid;
}
```

**Key Variables:**
- `request.resource.data` = Data being written (for create/update)
- `resource.data` = Current data in Firestore (for update/delete)

**Flutter Code:**
```dart
// ✅ User creates task with their UID as owner
await firestore.collection('tasks').add({
  'title': 'My Task',
  'ownerId': currentUser.uid,  // IMPORTANT!
  'createdAt': DateTime.now(),
});

// ✅ Only owner can update
await firestore
  .collection('tasks')
  .doc(taskId)
  .update({'title': 'Updated'});  // Rules verify ownerId

// ❌ Other users get PERMISSION_DENIED
// No error in Flutter code, but operation fails silently
```

---

### Pattern 5: Admin-Only Operations

**Requirement**: Only admins can access certain data

```
match /admin/{document=**} {
  allow read, write: if request.auth != null && 
    // Check if user has admin role in users collection
    get(/databases/$(database)/documents/users/$(request.auth.uid))
      .data.role == 'admin';
}
```

**User Document Structure:**
```json
{
  "email": "admin@example.com",
  "role": "admin",
  "createdAt": "2025-01-15T00:00:00Z"
}
```

**Flutter Code:**
```dart
// Create user with role
await firestore
  .collection('users')
  .doc(currentUser.uid)
  .set({
    'email': currentUser.email,
    'role': 'user',  // or 'admin'
    'createdAt': DateTime.now(),
  });

// Admin can access admin collection
await firestore
  .collection('admin')
  .doc('systemConfig')
  .get();  // ✅ Works if role == 'admin'
```

---

### Pattern 6: Public Read, Authenticated Write

**Requirement**: Anyone can read public data, but only authenticated users can write

```
match /posts/{postId} {
  // Anyone can read (even anonymous)
  allow read: if true;
  
  // Only authenticated users can create
  allow create: if request.auth != null &&
    request.resource.data.authorId == request.auth.uid;
  
  // Only author can update/delete
  allow update, delete: if request.auth != null &&
    resource.data.authorId == request.auth.uid;
}
```

---

## Testing Rules

### Method 1: Firebase Console Rules Playground

1. Go to **Firestore** → **Rules** tab
2. Click **Rules Playground** button
3. Select **Simulate** tab
4. Choose request type:
   - **Type**: read, write, get, list, etc.
   - **Path**: /users/abc123
   - **Authentication**: 
     - Unauthenticated
     - Custom UID (e.g., `user1`, `user2`)

### Example Test Scenario

**Scenario**: Test user ownership rule

1. **Test 1: Owner reads own document**
   - Type: `get`
   - Path: `/users/user1`
   - Authentication UID: `user1`
   - **Expected**: ✅ Allow
   - **Result**: Access granted

2. **Test 2: User reads another user's document**
   - Type: `get`
   - Path: `/users/user1`
   - Authentication UID: `user2`
   - **Expected**: ❌ Deny
   - **Result**: PERMISSION_DENIED

3. **Test 3: Anonymous reads document**
   - Type: `get`
   - Path: `/users/user1`
   - Authentication: Unauthenticated
   - **Expected**: ❌ Deny
   - **Result**: PERMISSION_DENIED

### Method 2: Test in Flutter App

Create test functions in your app:

```dart
Future<void> testSecurityRule() async {
  try {
    // This should work
    final myData = await firestore
      .collection('users')
      .doc(currentUser.uid)
      .get();
    print('✅ Can read own data');
  } catch (e) {
    print('❌ Cannot read own data: $e');
  }

  try {
    // This should fail
    final otherData = await firestore
      .collection('users')
      .doc('someOtherId')
      .get();
    print('⚠️ Can read other data (security issue!)');
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      print('✅ Cannot read other data (correct)');
    }
  }
}
```

---

## Implementation Checklist

Before deploying to production:

- [ ] **Authentication Enabled**
  - [ ] At least one sign-in method enabled
  - [ ] User can successfully sign in

- [ ] **Security Rules Written**
  - [ ] Replaced default test mode rules
  - [ ] All collections have explicit rules
  - [ ] Catch-all rule denies by default: `match /{document=**} { allow read, write: if false; }`

- [ ] **Rules Tested**
  - [ ] Tested with authenticated user
  - [ ] Tested with different user (should deny)
  - [ ] Tested with anonymous user (should deny)
  - [ ] Tested all CRUD operations

- [ ] **Code Implementation**
  - [ ] All data writes include ownership field (ownerId)
  - [ ] App checks `currentUser` before database operations
  - [ ] Error handling for PERMISSION_DENIED
  - [ ] Private data stored in subcollections

- [ ] **Security Best Practices**
  - [ ] No hardcoded UIDs in app
  - [ ] Validated input before writing to Firestore
  - [ ] Error messages don't reveal security details
  - [ ] Sensitive data not logged

---

## Troubleshooting

### Issue: "PERMISSION_DENIED" when trying to access data

**Causes:**
1. User not authenticated
2. Security rules block the operation
3. User doesn't own the document

**Solutions:**
```dart
// Check if user is authenticated
if (FirebaseAuth.instance.currentUser == null) {
  print('❌ User not signed in');
  return;
}

// Add error handling
try {
  await firestore.collection('tasks').doc(id).update(data);
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    print('❌ You don\'t have permission to update this task');
  } else {
    print('❌ Error: ${e.message}');
  }
}
```

---

### Issue: Can create document but can't update it

**Cause**: `ownerId` field not being set or verified

**Solution:**
```dart
// Make sure ownerId is included when creating
await firestore.collection('tasks').add({
  'title': 'Task',
  'ownerId': currentUser.uid,  // ✅ ALWAYS include this
  'createdAt': DateTime.now(),
});

// And always include it in set operations
await firestore.collection('tasks').doc(taskId).set({
  'title': 'Updated',
  'ownerId': currentUser.uid,  // ✅ Preserve ownership
}, SetOptions(merge: true));
```

---

### Issue: Rules work locally but fail after deployment

**Causes:**
1. Different rules deployed vs. tested
2. SHA-1 key mismatch (Google Sign-In)
3. App not properly signed with release key

**Solutions:**
1. Re-test rules in Firebase Console
2. Add SHA-1/SHA-256 keys to Firebase project
3. Use `flutter run -v` to check for errors

---

## Security Files in This Project

### Files with implementations:

1. **[firestore.rules](firestore.rules)** - Production security rules
2. **[lib/services/firestore_service.dart](lib/services/firestore_service.dart)** - Secure service with ownership verification
3. **[lib/screens/firestore_security_demo.dart](lib/screens/firestore_security_demo.dart)** - Interactive demo

### How to Deploy Rules

1. In Firebase Console, go to **Firestore** → **Rules**
2. Copy content from [firestore.rules](firestore.rules)
3. Paste into the rules editor
4. Click **Publish**

Or using Firebase CLI:

```bash
firebase deploy --only firestore:rules
```

---

## Key Concepts Summary

| Concept | Explanation |
|---------|-------------|
| **Authentication** | Proving who you are (sign-in) |
| **Authorization** | What you're allowed to do (rules) |
| **request.auth** | Current user info in rules |
| **request.resource.data** | New data being written |
| **resource.data** | Existing data in Firestore |
| **ownerId** | Field storing document creator's UID |
| **Subcollections** | Nested collections for private data |

---

## Next Steps

1. ✅ Review security rules in [firestore.rules](firestore.rules)
2. ✅ Test rules using Firebase Console Rules Playground
3. ✅ Deploy rules to production
4. ✅ Test in the Flutter app at route `/firestore-security`
5. ✅ Monitor Firestore audit logs for denied requests

---

## Resources

- [Cloud Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication Documentation](https://firebase.flutter.dev/docs/auth/overview/)
- [Security Rules Simulator](https://firebase.google.com/docs/rules/simulator)
- [Common Security Rule Patterns](https://firebase.google.com/docs/firestore/security/rules-patterns)
- [Security Best Practices](https://firebase.google.com/docs/firestore/security/best-practices)

---

**Last Updated**: March 2025  
**Tested With**: Firebase SDK ^3.0.0, cloud_firestore ^5.0.0, firebase_auth ^5.0.0
