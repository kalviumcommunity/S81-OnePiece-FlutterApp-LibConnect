import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LibConnectApp());
}

class LibConnectApp extends StatefulWidget {
  @override
  _LibConnectAppState createState() => _LibConnectAppState();
}

class _LibConnectAppState extends State<LibConnectApp> {
  bool isReady = false;

  void toggleReady() => setState(() => isReady = !isReady);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LibConnect Welcome',
      home: Scaffold(
        appBar: AppBar(title: Text('Welcome')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LibConnect',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Icon(Icons.local_library, size: 96, color: Colors.indigo),
                SizedBox(height: 16),
                Text(
                  isReady ? 'Ready to explore the library!' : 'Tap the button to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: isReady ? Colors.indigo : Colors.black87),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: toggleReady,
                  child: Text(isReady ? 'Reset' : 'Get Started'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
