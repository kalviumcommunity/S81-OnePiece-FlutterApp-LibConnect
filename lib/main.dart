import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('🚀 App launched successfully!');
  runApp(const MyApp());
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
