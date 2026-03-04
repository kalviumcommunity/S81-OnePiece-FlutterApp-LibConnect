import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsDemo extends StatefulWidget {
  const CloudFunctionsDemo({Key? key}) : super(key: key);

  @override
  State<CloudFunctionsDemo> createState() => _CloudFunctionsDemoState();
}

class _CloudFunctionsDemoState extends State<CloudFunctionsDemo> {
  final TextEditingController _nameController = TextEditingController(text: 'Flutter');
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  String? _lastResult;
  bool _isLoading = false;
  String? _errorMessage;
  String? _executionTime;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Functions Demo'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCallableFunctionSection(),
            const SizedBox(height: 24),
            _buildResultSection(),
            const SizedBox(height: 24),
            _buildFunctionTypesSection(),
            const SizedBox(height: 24),
            _buildDeploymentGuideSection(),
            const SizedBox(height: 24),
            _buildBestPracticesSection(),
          ],
        ),
      ),
    );
  }

  /// Section for testing callable functions
  Widget _buildCallableFunctionSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Callable Function Demo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test the sayHello() function:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Enter a name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'e.g., Alex, Sarah, etc.',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _callSayHello,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud),
                label: Text(_isLoading ? 'Calling Function...' : 'Call sayHello()'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            if (_executionTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Execution time: $_executionTime',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Section displaying function results
  Widget _buildResultSection() {
    return Card(
      elevation: 2,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Function Result',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Error Occurred',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else if (_lastResult != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Success',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _lastResult!,
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      Icon(Icons.inbox,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No function call yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Section explaining Cloud Function types
  Widget _buildFunctionTypesSection() {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cloud Function Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            _buildFunctionType(
              'Callable Functions',
              'Invoked directly from Flutter app. Perfect for custom logic, data processing, or third-party integrations.',
              'sayHello(name)',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildFunctionType(
              'Firestore Triggers',
              'Run automatically when documents are created, updated, or deleted. Ideal for notifications, cleanup, or analytics.',
              'onCreate, onUpdate, onDelete',
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildFunctionType(
              'HTTP Functions',
              'Web endpoints that respond to HTTP requests. Useful for webhooks or external integrations.',
              'https.onRequest()',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildFunctionType(
              'Auth Triggers',
              'Execute when users sign up, delete account, or update auth data. For welcome emails, account setup.',
              'onCreate, onDelete',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build function type item
  Widget _buildFunctionType(String type, String description, String example, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              example,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section with deployment instructions
  Widget _buildDeploymentGuideSection() {
    return Card(
      elevation: 2,
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Setup & Deployment Guide',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 16),
            _buildStep(
              '1',
              'Install Firebase Tools',
              'npm install -g firebase-tools',
            ),
            const SizedBox(height: 12),
            _buildStep(
              '2',
              'Login to Firebase',
              'firebase login',
            ),
            const SizedBox(height: 12),
            _buildStep(
              '3',
              'Initialize Functions',
              'firebase init functions',
            ),
            const SizedBox(height: 12),
            _buildStep(
              '4',
              'Create Function in functions/index.js',
              '''exports.sayHello = functions.https.onCall((data, context) => {
  return { message: `Hello, \${data.name}!` };
});''',
            ),
            const SizedBox(height: 12),
            _buildStep(
              '5',
              'Deploy Functions',
              'firebase deploy --only functions',
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build step item
  Widget _buildStep(String number, String title, String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            code,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  /// Section with best practices
  Widget _buildBestPracticesSection() {
    return Card(
      elevation: 2,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Best Practices & Use Cases',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildBestPractice(
              '✓ Server Logic',
              'Move complex calculations to Cloud Functions — keep Flutter app lightweight',
            ),
            _buildBestPractice(
              '✓ Security',
              'Validate user input and authenticate requests in functions, not on client',
            ),
            _buildBestPractice(
              '✓ Notifications',
              'Send emails/push notifications when events occur (user signup, order placed)',
            ),
            _buildBestPractice(
              '✓ Data Transformation',
              'Process and transform data before storing in Firestore (clean inputs, format)',
            ),
            _buildBestPractice(
              '✓ External APIs',
              'Call third-party APIs safely from functions (payment, weather, maps)',
            ),
            _buildBestPractice(
              '✓ Maintenance Tasks',
              'Schedule functions to run periodically (cleanup, archives, reports)',
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build best practice item
  Widget _buildBestPractice(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Call the sayHello callable function
  Future<void> _callSayHello() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a name';
        _lastResult = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _lastResult = null;
      _executionTime = null;
    });

    final startTime = DateTime.now();

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('sayHello');
      final result = await callable.call({
        'name': _nameController.text.trim(),
      });

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;

      setState(() {
        _lastResult = result.data['message'] ?? 'No response';
        _executionTime = '${duration}ms';
        _isLoading = false;
      });

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Function executed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _errorMessage = 'Function error: ${e.message}';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
