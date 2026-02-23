import 'package:flutter/material.dart';
import '../widgets/info_card.dart';
import '../widgets/like_button.dart';

/// Main navigation screen for accessing different demos
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Hub'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Header
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade400],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.rocket_launch,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Welcome to Flutter Demos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select a demo to explore Flutter features',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),

              const InfoCard(
                title: 'Reusable Stateless Widget',
                subtitle: 'This InfoCard is shared across multiple screens.',
                icon: Icons.widgets,
                iconColor: Colors.teal,
              ),

              const Align(
                alignment: Alignment.centerRight,
                child: LikeButton(),
              ),

              const SizedBox(height: 12),
              
              // Demo Options
              Expanded(
                child: ListView(
                  children: [
                    _buildDemoCard(
                      context,
                      title: '🔥 Hot Reload Demo',
                      description: 'Learn Hot Reload, Debug Console & DevTools',
                      color: Colors.orange,
                      icon: Icons.hot_tub,
                      onTap: () {
                        debugPrint('📍 Navigating to Hot Reload Demo');
                        Navigator.pushNamed(context, '/hot-reload');
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDemoCard(
                      context,
                      title: '🎯 Stateless vs Stateful',
                      description: 'Interactive widget demo with state management',
                      color: Colors.blue,
                      icon: Icons.widgets,
                      onTap: () {
                        debugPrint('📍 Navigating to Stateless/Stateful Demo');
                        Navigator.pushNamed(context, '/stateless-stateful');
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDemoCard(
                      context,
                      title: '🔐 Firebase Integration',
                      description: 'Explore authentication and Firestore',
                      color: Colors.deepPurple,
                      icon: Icons.cloud,
                      onTap: () {
                        debugPrint('📍 Navigating to Login Screen');
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDemoCard(
                      context,
                      title: '🧭 Simple Navigation',
                      description: 'Learn basic multi-screen navigation',
                      color: Colors.teal,
                      icon: Icons.navigation,
                      onTap: () {
                        debugPrint('📍 Navigating to Simple Navigation Demo');
                        Navigator.pushNamed(context, '/simple-home');
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildDemoCard(
                      context,
                      title: '📚 Scrollable Views',
                      description: 'ListView & GridView implementation',
                      color: Colors.indigo,
                      icon: Icons.view_quilt,
                      onTap: () {
                        debugPrint('📍 Navigating to Scrollable Views Demo');
                        Navigator.pushNamed(context, '/scrollable-views');
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildDemoCard(
                      context,
                      title: '⚡ State Management',
                      description: 'setState() for interactive UIs',
                      color: Colors.green,
                      icon: Icons.bolt,
                      onTap: () {
                        debugPrint('📍 Navigating to State Management Demo');
                        Navigator.pushNamed(context, '/state-management');
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildDemoCard(
                      context,
                      title: '📱 Responsive Design',
                      description: 'MediaQuery + LayoutBuilder for adaptive UI',
                      color: Colors.purple,
                      icon: Icons.devices,
                      onTap: () {
                        debugPrint('📍 Navigating to Responsive Design Demo');
                        Navigator.pushNamed(context, '/responsive-design');
                      },
                    ),
                  ],
                ),
              ),
              
              // Footer
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Check the Debug Console for real-time logs',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
