import 'package:flutter/material.dart';

/// Stateless Widget - Static Header
/// This widget displays a static title that doesn't change
class DemoHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const DemoHeader({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stateful Widget - Interactive Demo Screen
/// This widget manages multiple interactive states
class StatelessStatefulDemo extends StatefulWidget {
  const StatelessStatefulDemo({Key? key}) : super(key: key);

  @override
  State<StatelessStatefulDemo> createState() => _StatelessStatefulDemoState();
}

class _StatelessStatefulDemoState extends State<StatelessStatefulDemo> {
  // State variables
  int _counter = 0;
  bool _isDarkMode = false;
  Color _selectedColor = Colors.blue;
  bool _isIconFavorite = false;

  // List of colors for the color changer
  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  /// Increment counter
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  /// Decrement counter
  void _decrementCounter() {
    setState(() {
      if (_counter > 0) _counter--;
    });
  }

  /// Reset counter
  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  /// Toggle theme mode
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  /// Change color
  void _changeColor() {
    setState(() {
      int currentIndex = _colors.indexOf(_selectedColor);
      int nextIndex = (currentIndex + 1) % _colors.length;
      _selectedColor = _colors[nextIndex];
    });
  }

  /// Toggle favorite icon
  void _toggleFavorite() {
    setState(() {
      _isIconFavorite = !_isIconFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Stateless vs Stateful Demo'),
        backgroundColor: _selectedColor,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
            tooltip: _isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stateless Widget - Static Header
            DemoHeader(
              title: 'Interactive Widget Demo',
              subtitle: 'Exploring Stateless & Stateful Widgets',
            ),
            
            const SizedBox(height: 20),

            // Counter Section
            _buildCounterSection(),

            const SizedBox(height: 20),

            // Color Changer Section
            _buildColorChangerSection(),

            const SizedBox(height: 20),

            // Favorite Icon Section
            _buildFavoriteSection(),

            const SizedBox(height: 20),

            // Theme Mode Section
            _buildThemeModeSection(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// Counter Section Widget
  Widget _buildCounterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🔢 Counter Demo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$_counter',
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: _selectedColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _decrementCounter,
                icon: const Icon(Icons.remove),
                label: const Text('Decrease'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _resetCounter,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _incrementCounter,
                icon: const Icon(Icons.add),
                label: const Text('Increase'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Color Changer Section Widget
  Widget _buildColorChangerSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🎨 Color Changer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: _selectedColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _selectedColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _changeColor,
            icon: const Icon(Icons.palette),
            label: const Text('Change Color'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  /// Favorite Icon Section Widget
  Widget _buildFavoriteSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '❤️ Favorite Toggle',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _toggleFavorite,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Icon(
                _isIconFavorite ? Icons.favorite : Icons.favorite_border,
                size: 100,
                color: _isIconFavorite ? Colors.red : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isIconFavorite ? 'Added to Favorites!' : 'Tap to Add to Favorites',
            style: TextStyle(
              fontSize: 16,
              color: _isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// Theme Mode Section Widget
  Widget _buildThemeModeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🌓 Theme Toggle',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Light Mode',
                style: TextStyle(
                  fontSize: 16,
                  color: _isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(width: 20),
              Switch(
                value: _isDarkMode,
                onChanged: (value) => _toggleTheme(),
                activeColor: _selectedColor,
              ),
              const SizedBox(width: 20),
              Text(
                'Dark Mode',
                style: TextStyle(
                  fontSize: 16,
                  color: _isDarkMode ? Colors.white : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Current: ${_isDarkMode ? "Dark" : "Light"} Mode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _selectedColor,
            ),
          ),
        ],
      ),
    );
  }
}
