import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestore = FirestoreService();
    final AuthService auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Read Demo'),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.signOut();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            FutureBuilder(
              future: firestore.getUserDocument(
                FirebaseAuth.instance.currentUser?.uid ?? 'missing-user',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    title: Text('Loading profile...'),
                  );
                }

                if (snapshot.hasError) {
                  return const ListTile(
                    title: Text('Profile read failed'),
                    subtitle: Text('Check Firestore rules and user document'),
                  );
                }

                final userData = snapshot.data?.data();
                if (userData == null) {
                  return const ListTile(
                    title: Text('No profile data available'),
                    subtitle: Text('Create a document in users/{uid}'),
                  );
                }

                final name = userData['name']?.toString() ?? 'Unknown User';
                final role = userData['role']?.toString() ?? 'reader';

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Name: $name'),
                  subtitle: Text('Role: $role'),
                );
              },
            ),
            const SizedBox(height: 8),
            StreamBuilder(
              stream: firestore.getPendingTasks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pending tasks: ${snapshot.data!.docs.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder(
                stream: firestore.getTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Failed to load tasks from Firestore'),
                    );
                  }

                  final tasks = snapshot.data?.docs ?? [];
                  if (tasks.isEmpty) {
                    return const Center(child: Text('No data available'));
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final taskData = tasks[index].data();
                      final title = taskData['title']?.toString() ?? 'Untitled Task';
                      final description =
                          taskData['description']?.toString() ?? 'No description';
                      final status = taskData['status']?.toString() ?? 'unknown';

                      return Card(
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(description),
                          trailing: Text(status),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
