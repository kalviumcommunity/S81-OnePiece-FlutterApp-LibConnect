import 'package:flutter/material.dart';

class AnimationDemoScreen extends StatefulWidget {
  const AnimationDemoScreen({super.key});

  @override
  State<AnimationDemoScreen> createState() => _AnimationDemoScreenState();
}

class _AnimationDemoScreenState extends State<AnimationDemoScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isRunning = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleRotation() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> curvedTurns = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explicit Animation Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: curvedTurns,
              child: Image.asset(
                'assets/images/logo.png',
                width: 140,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _isRunning ? 1.0 : 0.4,
              child: Text(
                _isRunning ? 'Animating...' : 'Paused',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _toggleRotation,
              icon: Icon(_isRunning ? Icons.pause_circle : Icons.play_circle),
              label: Text(_isRunning ? 'Pause Rotation' : 'Play Rotation'),
            ),
          ],
        ),
      ),
    );
  }
}
