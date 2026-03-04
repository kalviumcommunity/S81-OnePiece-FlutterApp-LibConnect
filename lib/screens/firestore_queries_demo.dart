import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

/// FirestoreQueriesDemo demonstrates Firestore query capabilities:
/// 1. Filters (where clauses) - Equality, comparison, array containment
/// 2. Sorting (orderBy) - Ascending and descending
/// 3. Limiting results - Pagination with limit()
/// 4. Real-time reactive queries with StreamBuilder
class FirestoreQueriesDemo extends StatefulWidget {
  const FirestoreQueriesDemo({Key? key}) : super(key: key);

  @override
  State<FirestoreQueriesDemo> createState() => _FirestoreQueriesDemoState();
}

class _FirestoreQueriesDemoState extends State<FirestoreQueriesDemo> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Query filters state
  bool _filterCompleted = false;
  bool _sortDescending = true;
  int _limitValue = 10;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Build a query based on current filter settings
  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query = _firestoreService.tasks;

    // Apply filter
    if (_filterCompleted) {
      query = query.where('isCompleted', isEqualTo: true);
    } else {
      query = query.where('isCompleted', isEqualTo: false);
    }

    // Apply sorting
    query = query.orderBy('createdAt', descending: _sortDescending);

    // Apply limit
    query = query.limit(_limitValue);

    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Firestore Queries Demo'),
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Input Section ───────────────────────────────────────
            _buildInputSection(),
            const SizedBox(height: 24),

            // ─── Filter & Sort Controls ──────────────────────────────
            _buildFilterSection(),
            const SizedBox(height: 24),

            // ─── Query Info Display ──────────────────────────────────
            _buildQueryInfoSection(),
            const SizedBox(height: 24),

            // ─── Filtered Results ────────────────────────────────────
            _buildFilteredResultsSection(),
            const SizedBox(height: 24),

            // ─── Query Examples ─────────────────────────────────────
            _buildQueryExamplesSection(),
          ],
        ),
      ),
    );
  }

  /// ─── Input Section ───────────────────────────────────────────────
  Widget _buildInputSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✏️ Add New Task',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addTask,
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ─── Filter & Sort Controls ──────────────────────────────────────
  Widget _buildFilterSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚙️ Query Filters & Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ─── Status Filter ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Task Status Filter',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _filterCompleted = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !_filterCompleted
                                ? Colors.indigo
                                : Colors.grey,
                          ),
                          child: const Text('Incomplete Tasks'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _filterCompleted = true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _filterCompleted
                                ? Colors.indigo
                                : Colors.grey,
                          ),
                          child: const Text('Completed Tasks'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Query: .where("isCompleted", isEqualTo: ${_filterCompleted ? "true" : "false"})',
                    style: const TextStyle(fontSize: 10, color: Colors.indigo),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ─── Sort Order ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '↕️ Sort Order (by Creation Date)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _sortDescending = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !_sortDescending
                                ? Colors.purple
                                : Colors.grey,
                          ),
                          child: const Text('Oldest First'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _sortDescending = true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _sortDescending
                                ? Colors.purple
                                : Colors.grey,
                          ),
                          child: const Text('Newest First'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Query: .orderBy("createdAt", descending: ${_sortDescending ? "true" : "false"})',
                    style: const TextStyle(fontSize: 10, color: Colors.purple),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ─── Result Limit ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📊 Result Limit',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Max: $_limitValue results',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _limitValue.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: _limitValue.toString(),
                    onChanged: (value) {
                      setState(() => _limitValue = value.toInt());
                    },
                  ),
                  Text(
                    'Current Query: .limit($_limitValue)',
                    style: const TextStyle(fontSize: 10, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ─── Display Current Query Info ──────────────────────────────────
  Widget _buildQueryInfoSection() {
    return Card(
      elevation: 2,
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📝 Current Query Breakdown',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildQueryLine(
              'Collection',
              'tasks',
              Colors.blue,
            ),
            _buildQueryLine(
              'Filter (where)',
              'isCompleted == ${_filterCompleted ? "true" : "false"}',
              Colors.orange,
            ),
            _buildQueryLine(
              'Sort (orderBy)',
              'createdAt (${_sortDescending ? "descending" : "ascending"})',
              Colors.purple,
            ),
            _buildQueryLine(
              'Limit',
              '$_limitValue documents max',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to display query line
  Widget _buildQueryLine(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 30,
            color: color,
            margin: const EdgeInsets.only(right: 8),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ─── Filtered Results Section ────────────────────────────────────
  Widget _buildFilteredResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📌 Filtered Results',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Showing ${_filterCompleted ? "completed" : "incomplete"} tasks, sorted ${_sortDescending ? "newest" : "oldest"} first, limited to $_limitValue results',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _buildQuery().snapshots(),
          builder: (context, snapshot) {
            // ─── Loading State ───────────────────────────────────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // ─── Error State ─────────────────────────────────────────
            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Query Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            }

            // ─── Empty State ────────────────────────────────────────
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No ${_filterCompleted ? "completed" : "incomplete"} tasks',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add tasks or change filters to see results',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ─── Display Filtered Results ────────────────────────────
            final tasks = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final taskData = task.data();
                final taskId = task.id;
                final title = taskData['title'] ?? 'Untitled';
                final description = taskData['description'] ?? '';
                final isCompleted = taskData['isCompleted'] ?? false;
                final createdAt = (taskData['createdAt'] as Timestamp?)
                        ?.toDate()
                        .toString()
                        .split('.')[0] ??
                    'Unknown';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isCompleted ? Colors.green.shade50 : Colors.white,
                  child: ListTile(
                    leading: Checkbox(
                      value: isCompleted,
                      onChanged: (_) => _toggleTaskCompletion(taskId, !isCompleted),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(description, maxLines: 1),
                        const SizedBox(height: 4),
                        Text(
                          '🕐 $createdAt',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(taskId),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// ─── Query Examples Section ──────────────────────────────────────
  Widget _buildQueryExamplesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📚 Query Examples & Best Practices',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildExampleCard(
          'Equality Filter',
          '.where("status", isEqualTo: "active")',
          'Fetch only documents where a field equals a specific value',
        ),
        _buildExampleCard(
          'Comparison Filters',
          '.where("price", isGreaterThan: 100)\n.where("rating", isLessThanOrEqualTo: 4.5)',
          'Compare numeric or date values using >, <, >=, <=',
        ),
        _buildExampleCard(
          'Array Filters',
          '.where("tags", arrayContains: "popular")',
          'Check if array field contains a specific value',
        ),
        _buildExampleCard(
          'Chained Queries',
          '.where("status", isEqualTo: "active")\n.orderBy("price")\n.limit(10)',
          'Combine filters, sorting, and limits for powerful queries',
        ),
        _buildExampleCard(
          'Performance Tip',
          'Always use .limit() for initial loads',
          'Reduces bandwidth, improves load time, enables pagination',
        ),
      ],
    );
  }

  /// Helper to build example cards
  Widget _buildExampleCard(String title, String code, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 10,
                  color: Color(0xFF40FF40),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Add a new task
  Future<void> _addTask() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await _firestoreService.addTask(
        title: _titleController.text,
        description: _descriptionController.text,
      );

      _titleController.clear();
      _descriptionController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Task added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Toggle task completion status
  Future<void> _toggleTaskCompletion(String taskId, bool newStatus) async {
    try {
      await _firestoreService.setTaskById(
        taskId: taskId,
        data: {'isCompleted': newStatus},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    }
  }

  /// Delete a task
  Future<void> _deleteTask(String taskId) async {
    try {
      await _firestoreService.tasks.doc(taskId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Task deleted'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: $e')),
        );
      }
    }
  }
}
