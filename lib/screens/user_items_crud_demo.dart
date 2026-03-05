import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class UserItemsCrudDemo extends StatefulWidget {
  const UserItemsCrudDemo({super.key});

  @override
  State<UserItemsCrudDemo> createState() => _UserItemsCrudDemoState();
}

class _UserItemsCrudDemoState extends State<UserItemsCrudDemo> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSubmitting = false;
  late Future<int> _itemCountFuture;

  @override
  void initState() {
    super.initState();
    _itemCountFuture = _loadItemCount();
  }

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User must be signed in before performing CRUD operations.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _items => FirebaseFirestore
      .instance
      .collection('users')
      .doc(_uid)
      .collection('items');

  Future<int> _loadItemCount() async {
    try {
      final snapshot = await _items.get();
      return snapshot.docs.length;
    } catch (error, stackTrace) {
      developer.log(
        'Error loading item count: $error',
        name: 'UserItemsCrudDemo',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void _retryLoadCount() {
    setState(() {
      _itemCountFuture = _loadItemCount();
    });
  }

  Future<void> _createItem() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and description.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _items.add({
        'title': title,
        'description': description,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      _titleController.clear();
      _descriptionController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item created successfully.')),
      );

      _retryLoadCount();
    } catch (error) {
      developer.log(
        'Error creating item: $error',
        name: 'UserItemsCrudDemo',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create item. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _updateItem(
    String itemId,
    String currentTitle,
    String currentDescription,
  ) async {
    final titleController = TextEditingController(text: currentTitle);
    final descriptionController = TextEditingController(text: currentDescription);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTitle = titleController.text.trim();
                final newDescription = descriptionController.text.trim();

                if (newTitle.isEmpty || newDescription.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields.')),
                  );
                  return;
                }

                try {
                  await _items.doc(itemId).update({
                    'title': newTitle,
                    'description': newDescription,
                    'updatedAt': DateTime.now().millisecondsSinceEpoch,
                  });

                  if (!mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item updated successfully.')),
                  );

                  _retryLoadCount();
                } catch (error) {
                  developer.log(
                    'Error updating item: $error',
                    name: 'UserItemsCrudDemo',
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not update item. Please retry.')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      await _items.doc(itemId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted.')),
      );

      _retryLoadCount();
    } catch (error) {
      developer.log(
        'Error deleting item: $error',
        name: 'UserItemsCrudDemo',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete item. Please retry.')),
      );
    }
  }

  Widget _buildFutureSummary() {
    return FutureBuilder<int>(
      future: _itemCountFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                const Text('Failed to load summary.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _retryLoadCount,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Card(
          child: ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('Total items (one-time load)'),
            subtitle: Text('${snapshot.data ?? 0} item(s)'),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retryLoadCount,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreamLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Loading your items...'),
        ],
      ),
    );
  }

  Widget _buildStreamErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
          const SizedBox(height: 8),
          const Text('Something went wrong while loading items.'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 44, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'No items yet.\nTap + to create your first one!',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Items')), 
      floatingActionButton: FloatingActionButton(
        onPressed: _isSubmitting ? null : _createItem,
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
      ),
      body: AbsorbPointer(
        absorbing: _isSubmitting,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              if (_isSubmitting)
                const LinearProgressIndicator(),
              if (_isSubmitting)
                const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _buildFutureSummary(),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _items.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildStreamLoadingState();
                  }

                  if (snapshot.hasError) {
                    developer.log(
                      'Stream error while loading items: ${snapshot.error}',
                      name: 'UserItemsCrudDemo',
                    );
                    return _buildStreamErrorState();
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return _buildStreamEmptyState();
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final item = doc.data();
                      final title = item['title']?.toString() ?? 'Untitled';
                      final description = item['description']?.toString() ?? '';

                      return Card(
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(description),
                          onTap: () => _updateItem(doc.id, title, description),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteItem(doc.id),
                          ),
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
      ),
    );
  }
}
