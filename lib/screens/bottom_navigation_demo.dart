import 'package:flutter/material.dart';

class BottomNavigationDemo extends StatefulWidget {
  const BottomNavigationDemo({super.key});

  @override
  State<BottomNavigationDemo> createState() => _BottomNavigationDemoState();
}

class _BottomNavigationDemoState extends State<BottomNavigationDemo> {
  int _currentIndex = 0;
  late final PageController _pageController;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _screens = const [
      _TabHomeScreen(),
      _TabSearchScreen(),
      _TabProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bottom Navigation Demo')),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _TabHomeScreen extends StatefulWidget {
  const _TabHomeScreen();

  @override
  State<_TabHomeScreen> createState() => _TabHomeScreenState();
}

class _TabHomeScreenState extends State<_TabHomeScreen>
    with AutomaticKeepAliveClientMixin {
  int _counter = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Home Tab', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          Text('Counter: $_counter', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() => _counter++),
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}

class _TabSearchScreen extends StatefulWidget {
  const _TabSearchScreen();

  @override
  State<_TabSearchScreen> createState() => _TabSearchScreenState();
}

class _TabSearchScreenState extends State<_TabSearchScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _queryController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Search Tab', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          TextField(
            controller: _queryController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Search query',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Text('Current query: ${_queryController.text}'),
        ],
      ),
    );
  }
}

class _TabProfileScreen extends StatefulWidget {
  const _TabProfileScreen();

  @override
  State<_TabProfileScreen> createState() => _TabProfileScreenState();
}

class _TabProfileScreenState extends State<_TabProfileScreen>
    with AutomaticKeepAliveClientMixin {
  bool _notificationsEnabled = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Profile Tab', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Notifications'),
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
        ],
      ),
    );
  }
}
