import 'package:flutter/material.dart';
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
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.logout();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          firestore.addNote("New Note");
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: firestore.getNotes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['text']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => firestore.deleteNote(doc.id),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
