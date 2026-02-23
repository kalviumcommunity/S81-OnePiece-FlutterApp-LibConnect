import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/info_card.dart';
import '../widgets/like_button.dart';

/// Simple Home Screen - Starting point of navigation
class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('📱 SimpleHomeScreen built');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home,
                  size: 100,
                  color: Colors.blue.shade400,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Home Screen!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tap the button below to navigate to the second screen',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Navigation using Navigator.pushNamed()
                CustomButton(
                  label: 'Go to Second Screen',
                  icon: Icons.arrow_forward,
                  color: Colors.blue,
                  onPressed: () {
                    debugPrint('🚀 Navigating to Second Screen using named route');
                    Navigator.pushNamed(context, '/simple-second');
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Alternative: Direct push (not using named routes)
                OutlinedButton.icon(
                  onPressed: () {
                    debugPrint('🚀 Navigating to Second Screen using direct push');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimpleSecondScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.near_me),
                  label: const Text('Go (Direct Push)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                const InfoCard(
                  title: 'Navigation Methods',
                  subtitle: 'Named Route: Navigator.pushNamed()\nDirect Push: Navigator.push()',
                  icon: Icons.info_outline,
                  iconColor: Colors.amber,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple Second Screen - Destination screen
class SimpleSecondScreen extends StatelessWidget {
  const SimpleSecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('📱 SimpleSecondScreen built');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
        backgroundColor: Colors.green,
        // Back button is automatically provided by Flutter
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green.shade400,
                ),
                const SizedBox(height: 24),
                const Text(
                  'You Made It to the Second Screen!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Use the back button or the button below to return',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Navigation using Navigator.pop()
                CustomButton(
                  label: 'Back to Home',
                  icon: Icons.arrow_back,
                  color: Colors.green,
                  onPressed: () {
                    debugPrint('⬅️ Going back to Home Screen using Navigator.pop()');
                    Navigator.pop(context);
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Navigate to a third screen
                OutlinedButton.icon(
                  onPressed: () {
                    debugPrint('🚀 Navigating to Third Screen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimpleThirdScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.forward),
                  label: const Text('Go Deeper (Third Screen)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                const InfoCard(
                  title: 'Navigation Stack',
                  subtitle: 'Current Stack:\nHome → Second (You are here)',
                  icon: Icons.layers,
                  iconColor: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple Third Screen - Demonstrates navigation stack depth
class SimpleThirdScreen extends StatelessWidget {
  const SimpleThirdScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('📱 SimpleThirdScreen built');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Third Screen'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.stars,
                  size: 100,
                  color: Colors.purple.shade400,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Third Screen - Deep Navigation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const LikeButton(),
                const SizedBox(height: 12),
                const Text(
                  'You can go back step by step or jump to home',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Go back one step
                ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('⬅️ Going back one screen');
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Second Screen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Pop until home (go back to root)
                OutlinedButton.icon(
                  onPressed: () {
                    debugPrint('🏠 Going back to Home Screen (pop until root)');
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home (Skip Second)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.layers, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Navigation Stack',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Current Stack:\nHome → Second → Third (You are here)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
