import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/counter_state.dart';
import 'services/notification_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/hot_reload_demo.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/dashboard.dart';
import 'screens/simple_navigation_demo.dart';
import 'screens/scrollable_views.dart';
import 'screens/state_management_demo.dart';
import 'screens/responsive_home.dart';
import 'screens/firestore_realtime_demo.dart';
import 'screens/firestore_queries_demo.dart';
import 'screens/firebase_storage_demo.dart';
import 'screens/cloud_functions_demo.dart';
import 'screens/notifications_demo.dart';
import 'screens/firestore_security_demo.dart';
import 'screens/map_screen.dart';
import 'screens/user_items_crud_demo.dart';
import 'screens/user_input_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase Cloud Messaging
  await NotificationService().initialize();
  
  debugPrint('🚀 App launched successfully!');
  runApp(
    ChangeNotifierProvider(
      create: (_) => CounterState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Flow Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const AuthScreen();
        },
      ),

      // Define all named routes
      routes: {
        '/': (context) => const AuthScreen(),
        '/hot-reload': (context) => const HotReloadDemo(),
        '/stateless-stateful': (context) => const StatelessStatefulDemo(),
        '/login': (context) => const AuthScreen(),
        '/dashboard': (context) => const Dashboard(),
        '/simple-home': (context) => const SimpleHomeScreen(),
        '/simple-second': (context) => const SimpleSecondScreen(),
        '/scrollable-views': (context) => const ScrollableViews(),
        '/state-management': (context) => StateManagementDemo(),
        '/responsive-design': (context) => const ResponsiveHome(),
        '/firestore-realtime': (context) => const FirestoreRealtimeDemo(),
        '/firestore-queries': (context) => const FirestoreQueriesDemo(),
        '/firebase-storage': (context) => const FirebaseStorageDemo(),
        '/firebase-cloud-functions': (context) => const CloudFunctionsDemo(),
        '/notifications': (context) => const NotificationsDemoScreen(),
        '/firestore-security': (context) => const FirestoreSecurityDemoScreen(),
        '/google-maps': (context) => const MapScreen(),
        '/user-items-crud': (context) => const UserItemsCrudDemo(),
        '/form-validation': (context) => const UserInputForm(),
      },
      
      // Handle unknown routes
      onUnknownRoute: (settings) {
        debugPrint('⚠️ Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
