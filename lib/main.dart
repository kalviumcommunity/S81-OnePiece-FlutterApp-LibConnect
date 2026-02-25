import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/hot_reload_demo.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard.dart';
import 'screens/simple_navigation_demo.dart';
import 'screens/scrollable_views.dart';
import 'screens/state_management_demo.dart';
import 'screens/responsive_home.dart';

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
        '/scrollable-views': (context) => const ScrollableViews(),
        '/state-management': (context) => StateManagementDemo(),
        '/responsive-design': (context) => const ResponsiveHome(),
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
