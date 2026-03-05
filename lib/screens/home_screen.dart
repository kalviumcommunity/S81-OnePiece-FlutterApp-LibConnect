import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../providers/theme_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeState = context.watch<ThemeState>();
    final isDarkMode = themeState.mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.email ?? 'User'}'),
        actions: [
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              context.read<ThemeState>().toggleTheme(value);
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Theme mode',
            onSelected: (value) {
              if (value == 'system') {
                context.read<ThemeState>().setSystemTheme();
              } else if (value == 'light') {
                context.read<ThemeState>().toggleTheme(false);
              } else {
                context.read<ThemeState>().toggleTheme(true);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'system', child: Text('System theme')),
              PopupMenuItem(value: 'light', child: Text('Light theme')),
              PopupMenuItem(value: 'dark', child: Text('Dark theme')),
            ],
            icon: const Icon(Icons.palette_outlined),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You are logged in!',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/google-maps'),
              icon: const Icon(Icons.map),
              label: const Text('Google Maps Demo'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/user-items-crud'),
              icon: const Icon(Icons.edit_note),
              label: const Text('User CRUD Demo'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/form-validation'),
              icon: const Icon(Icons.fact_check),
              label: const Text('Form Validation Demo'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/bottom-navigation'),
              icon: const Icon(Icons.view_day),
              label: const Text('Bottom Navigation Demo'),
            ),
          ],
        ),
      ),
    );
  }
}
