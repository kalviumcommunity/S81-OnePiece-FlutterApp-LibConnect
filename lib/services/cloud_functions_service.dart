import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsService {
  static final CloudFunctionsService _instance = CloudFunctionsService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  CloudFunctionsService._internal();

  /// Factory constructor to return singleton instance
  factory CloudFunctionsService() {
    return _instance;
  }

  /// Call a callable Cloud Function
  /// 
  /// [functionName] - The name of the Cloud Function to call
  /// [data] - Parameters to pass to the function
  /// 
  /// Returns the response data from the function
  /// Throws [FirebaseFunctionsException] on function error
  Future<dynamic> callFunction(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    try {
      final callable = _functions.httpsCallable(functionName);
      final result = await callable.call(data);
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      print('Cloud Function Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error calling Cloud Function: $e');
      rethrow;
    }
  }

  /// Call the sayHello function
  /// 
  /// [name] - The name to greet
  /// 
  /// Returns a message from the function
  Future<String> sayHello(String name) async {
    try {
      final result = await callFunction('sayHello', {'name': name});
      return result['message'] ?? 'No message returned';
    } catch (e) {
      throw Exception('Failed to call sayHello: $e');
    }
  }

  /// Call a function and return typed result
  /// 
  /// Usage: 
  /// ```dart
  /// final data = await service.callFunctionTyped<MyModel>(
  ///   'functionName',
  ///   {'param': 'value'},
  ///   (json) => MyModel.fromJson(json),
  /// );
  /// ```
  Future<T> callFunctionTyped<T>(
    String functionName,
    Map<String, dynamic> data,
    T Function(dynamic) parser,
  ) async {
    try {
      final result = await callFunction(functionName, data);
      return parser(result);
    } catch (e) {
      throw Exception('Failed to parse Cloud Function result: $e');
    }
  }

  /// Example: Handle event-based function results
  /// 
  /// Event-based functions (Firestore triggers) don't return values directly,
  /// but you can listen to Firestore collection changes to see their effects
  /// 
  /// Example trigger in Cloud Functions:
  /// ```javascript
  /// exports.newUserCreated = functions.firestore
  ///   .document('users/{userId}')
  ///   .onCreate(async (snap, context) => {
  ///     const userId = context.params.userId;
  ///     // Send welcome email, create user profile, etc.
  ///     await admin.firestore()
  ///       .collection('users').doc(userId)
  ///       .update({ createdAt: admin.firestore.FieldValue.serverTimestamp() });
  ///   });
  /// ```
  
  /// Get Cloud Functions logs URL for firebase console verification
  String getLogsUrl(String projectId) {
    return 'https://console.firebase.google.com/functions/logs?project=$projectId';
  }

  /// Verify function region (default: us-central1)
  /// Change if needed: CloudFunctionsService()._functions.useFunctionsEmulator('localhost', 5002);
  void useEmulator(String host, int port) {
    _functions.useFunctionsEmulator(host, port);
  }

  /// Reset to production Cloud Functions
  void resetToProduction() {
    // This would need to be handled at app startup with proper Firebase config
    print('Using production Cloud Functions');
  }
}
