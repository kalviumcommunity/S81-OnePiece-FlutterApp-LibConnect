import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/hot_reload_demo.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard.dart';
import 'screens/simple_navigation_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  debugPrint('🚀 App launched successfully!');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ Building MyApp widget');
    return MaterialApp(
      title: 'Flutter Widget Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      
      // Define initial route
      initialRoute: '/',
      
      // Define all named routes
      routes: {
        '/': (context) => const HomeScreen(),
        '/hot-reload': (context) => const HotReloadDemo(),
        '/stateless-stateful': (context) => const StatelessStatefulDemo(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const Dashboard(),
        '/simple-home': (context) => const SimpleHomeScreen(),
        '/simple-second': (context) => const SimpleSecondScreen(),
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
