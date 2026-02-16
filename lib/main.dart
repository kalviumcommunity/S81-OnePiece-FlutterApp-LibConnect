import 'package:flutter/material.dart';

void main() {
  runApp(const WidgetTreeDemoApp());
}

class WidgetTreeDemoApp extends StatefulWidget {
  const WidgetTreeDemoApp({super.key});

  @override
  State<WidgetTreeDemoApp> createState() => _WidgetTreeDemoAppState();
}

class _WidgetTreeDemoAppState extends State<WidgetTreeDemoApp> {
  bool isHighlighted = false;
  bool showBio = true;
  int likes = 0;

  void toggleHighlight() {
    setState(() {
      isHighlighted = !isHighlighted;
    });
  }

  void toggleBio() {
    setState(() {
      showBio = !showBio;
    });
  }

  void addLike() {
    setState(() {
      likes++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor =
        isHighlighted ? Colors.orange.shade100 : Colors.blueGrey.shade50;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Widget Tree Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Widget Tree Demo'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            child: Icon(Icons.person, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rina Patel',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                isHighlighted
                                    ? 'Featured Reader'
                                    : 'Active Reader',
                                style:
                                    TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            isHighlighted
                                ? Icons.star
                                : Icons.star_border,
                            color: isHighlighted
                                ? Colors.orange
                                : Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (showBio)
                        const Text(
                          'Loves mystery novels, weekly library visits, and book clubs.',
                          style: TextStyle(fontSize: 15),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: addLike,
                            icon: const Icon(Icons.thumb_up),
                            label: Text('Like ($likes)'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: toggleBio,
                            child:
                                Text(showBio ? 'Hide Bio' : 'Show Bio'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: toggleHighlight,
                    child: Text(isHighlighted
                        ? 'Remove Highlight'
                        : 'Highlight Card'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap buttons to trigger setState() and rebuild parts of the widget tree.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}