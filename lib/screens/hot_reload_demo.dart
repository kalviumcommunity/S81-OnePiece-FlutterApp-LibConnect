import 'package:flutter/material.dart';

/// Hot Reload Demo Screen
/// This screen demonstrates Flutter's Hot Reload feature and debugging capabilities
class HotReloadDemo extends StatefulWidget {
  const HotReloadDemo({Key? key}) : super(key: key);

  @override
  State<HotReloadDemo> createState() => _HotReloadDemoState();
}

class _HotReloadDemoState extends State<HotReloadDemo> {
  int _counter = 0;
  String _message = 'Hello, Flutter!';
  Color _backgroundColor = Colors.blue;
  double _fontSize = 24.0;
  bool _isAnimated = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 HotReloadDemo: initState() called - Widget initialized');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      debugPrint('✨ Counter incremented to: $_counter');
      debugPrint('📊 Current state: {counter: $_counter, message: "$_message"}');
    });
  }

  void _changeMessage() {
    setState(() {
      _message = _message == 'Hello, Flutter!'
          ? 'Welcome to Hot Reload!'
          : 'Hello, Flutter!';
      debugPrint('💬 Message changed to: "$_message"');
    });
  }

  void _changeBackgroundColor() {
    setState(() {
      final colors = [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.teal];
      final currentIndex = colors.indexOf(_backgroundColor);
      _backgroundColor = colors[(currentIndex + 1) % colors.length];
      debugPrint('🎨 Background color changed to: ${_backgroundColor.toString()}');
    });
  }

  void _changeFontSize() {
    setState(() {
      _fontSize = _fontSize == 24.0 ? 32.0 : 24.0;
      debugPrint('📏 Font size changed to: $_fontSize');
    });
  }

  void _toggleAnimation() {
    setState(() {
      _isAnimated = !_isAnimated;
      debugPrint('🎬 Animation ${_isAnimated ? "enabled" : "disabled"}');
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 HotReloadDemo: build() method called');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hot Reload Demo'),
        backgroundColor: _backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              debugPrint('ℹ️ Info button pressed');
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _backgroundColor.withOpacity(0.3),
              _backgroundColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Section
                _buildHeaderCard(),
                
                const SizedBox(height: 30),
                
                // Counter Section
                _buildCounterCard(),
                
                const SizedBox(height: 20),
                
                // Message Section
                _buildMessageCard(),
                
                const SizedBox(height: 20),
                
                // Control Buttons Section
                _buildControlButtons(),
                
                const SizedBox(height: 30),
                
                // Hot Reload Instructions
                _buildInstructions(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _incrementCounter();
          debugPrint('🔘 FloatingActionButton pressed');
        },
        backgroundColor: _backgroundColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_backgroundColor.withOpacity(0.7), _backgroundColor],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              Icons.hot_tub,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            const Text(
              'Hot Reload Demo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing values and press Ctrl+S',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Counter Value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedScale(
              scale: _isAnimated && _counter % 2 == 1 ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                '$_counter',
                style: TextStyle(
                  fontSize: _fontSize * 2,
                  fontWeight: FontWeight.bold,
                  color: _backgroundColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_counter > 0) _counter--;
                      debugPrint('⬇️ Counter decremented to: $_counter');
                    });
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrease'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _incrementCounter,
                  icon: const Icon(Icons.add),
                  label: const Text('Increase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Dynamic Message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedDefaultTextStyle(
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.bold,
                color: _backgroundColor,
              ),
              duration: const Duration(milliseconds: 300),
              child: Text(
                _message,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _changeMessage,
              icon: const Icon(Icons.refresh),
              label: const Text('Change Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _backgroundColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Try These Controls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _changeBackgroundColor,
                  icon: const Icon(Icons.palette),
                  label: const Text('Change Color'),
                ),
                ElevatedButton.icon(
                  onPressed: _changeFontSize,
                  icon: const Icon(Icons.text_fields),
                  label: const Text('Font Size'),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleAnimation,
                  icon: Icon(_isAnimated ? Icons.animation : Icons.stop),
                  label: Text(_isAnimated ? 'Disable Anim' : 'Enable Anim'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      color: Colors.amber.shade50,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  'Hot Reload Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionItem('1. Press buttons to change state'),
            _buildInstructionItem('2. Modify widget properties in code'),
            _buildInstructionItem('3. Save file (Ctrl+S) to hot reload'),
            _buildInstructionItem('4. Check Debug Console for logs'),
            _buildInstructionItem('5. State is preserved after reload!'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    debugPrint('📱 Showing info dialog');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hot Reload Info'),
        content: const Text(
          'Hot Reload allows you to:\n\n'
          '✅ Update UI instantly\n'
          '✅ Preserve app state\n'
          '✅ Speed up development\n'
          '✅ Test changes quickly\n\n'
          'Try changing colors, text, or sizes in the code and save to see instant updates!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              debugPrint('✅ Dialog dismissed');
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('🔚 HotReloadDemo: dispose() called - Widget disposed');
    super.dispose();
  }
}
