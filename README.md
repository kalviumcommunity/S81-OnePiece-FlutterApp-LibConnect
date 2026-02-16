# S81-OnePiece-FlutterApp-LibConnect

Our team of three members is developing LibConnect, a Flutter and Firebase-based mobile application aimed at modernizing public library management. The problem we are addressing is that many public libraries still depend on manual registers to manage book availability and borrowing, making the process slow, inaccurate, and inconvenient for both readers and librarians. Our proposed solution, LibConnect, allows users to easily search, reserve, and track books in real time while providing librarians with tools to manage inventory digitally. The project’s goal is to build a fully functional MVP that demonstrates seamless Flutter-Firebase integration with an intuitive user interface and real-time data synchronization. The core features include user authentication (sign up, login, logout) using Firebase Auth, book discovery and reservation using Firestore, and a user dashboard to track borrowed or reserved books. We are using Flutter for the frontend, Firebase Firestore for database management, Firebase Auth for authentication, and GitHub Actions for CI/CD. Within our team, the UI/UX Lead is responsible for designing and developing the app’s interface and navigation flow, the Firebase & Backend Lead handles database configuration and integration, and the Testing & Deployment Lead manages app testing, builds, and deployment. The four-week sprint is structured as follows: Week 1 focuses on idea finalization, Firebase setup, and UI wireframes; Week 2 covers authentication and core functionality; Week 3 is for integration and testing of CRUD operations; and Week 4 involves UI polishing, bug fixing, and MVP deployment. The success of the sprint will be measured by delivering a stable, demo-ready APK that successfully integrates Firebase services, provides smooth user interaction, and receives positive feedback during review.

---

## Sprint 2 - Flutter and Dart Basics

### Project title and idea
LibConnect is a Flutter and Firebase-based mobile app concept to modernize public library management with real-time book discovery, reservations, and user tracking.

### Folder structure and purpose
```
lib/
  main.dart           # App entry point and initial routing
  screens/            # Individual UI screens
  widgets/            # Reusable UI components
  models/             # Data structures for the app domain
  services/           # Firebase and API logic
```

How this supports modular design:
- Screens focus on layout and navigation only, keeping UI concerns isolated.
- Widgets keep UI building blocks reusable across screens.
- Models standardize data flow between UI and services.
- Services centralize Firebase and API calls to avoid duplicated logic.

Naming conventions:
- Files: snake_case (e.g., book_detail_screen.dart, auth_service.dart)
- Classes: PascalCase (e.g., BookDetailScreen, AuthService)
- Widgets: PascalCase with Widget suffix when appropriate (e.g., PrimaryButtonWidget)

### Setup instructions
1. Install Flutter SDK and set up Android Studio or VS Code with Flutter and Dart extensions.
2. Verify install:
	- `flutter doctor`
3. Get packages and run:
	- `flutter pub get`
	- `flutter run`

### Demo
![LibConnect welcome screen](assets/demo.png)
Replace assets/demo.png with a screenshot from your emulator or device.

### Reflection
I learned how Flutter composes UI from widgets, how state changes trigger rebuilds with `setState()`, and how a clean folder structure keeps UI, data, and services separated. This organization makes it easier to scale the app with new screens and features without creating tightly coupled code.

---

## Flutter Fundamentals — Assessment 1

This section documents core Flutter architecture, the widget tree, Dart essentials, and a small reactive counter demo.

### 1) Flutter Architecture
- Framework Layer: Written in Dart. Includes Material/Cupertino widgets, rendering, animation, gesture, and routing libraries.
- Engine Layer: C++ (Skia) — handles rasterization, text layout, accessibility, and platform channels.
- Embedder Layer: Platform-specific code that integrates the engine with Android/iOS/web/desktop and the host OS.

Key idea: Flutter renders pixels itself via Skia rather than composing native UI controls, producing pixel-perfect consistent UIs across platforms.

### 2) Widget Tree
In Flutter everything is a widget — from text and icons to layout containers and screens.

- StatelessWidget: For immutable widgets that do not maintain state (e.g., static labels, icons).
- StatefulWidget: For widgets with mutable state that can change and trigger UI updates (e.g., forms, counters).

Simple example (stateless):
```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			home: Scaffold(
				appBar: AppBar(title: Text('Hello Flutter')),
				body: Center(child: Text('Welcome to Flutter!')),
			),
		);
	}
}
```

Try changing the `Text` content and use Hot Reload to see immediate updates.

### 3) Dart Essentials
- Classes & objects: Everything is an object in Dart.
- Null safety: Compile-time checks to prevent null reference errors.
- Async/await: Use `Future`, `async`, and `await` for non-blocking operations.
- Type inference: `var` and `final` allow concise declarations with type safety.

Example:
```dart
class Student {
	String name;
	int age;

	Student(this.name, this.age);

	void introduce() => print('Hi, I\'m $name and I\'m $age years old.');
}

void main() {
	var s1 = Student('Aanya', 20);
	s1.introduce();
}
```

### 4) Widget Tree Demo — Profile Card
This demo app uses nested widgets to show parent-child relationships and visible state updates. The UI is a profile card with buttons that change the background highlight, toggle bio visibility, and increment likes.

Widget tree (simplified):
```
MaterialApp
 ┗ Scaffold
	 ┣ AppBar
	 ┗ Body
		 ┗ Center
			 ┗ SingleChildScrollView
				 ┗ Column
					 ┣ AnimatedContainer
					 │  ┗ Column
					 │     ┣ Row
					 │     │  ┣ CircleAvatar
					 │     │  ┣ Column
					 │     │  │  ┣ Text (name)
					 │     │  │  ┗ Text (status)
					 │     │  ┗ Icon (star)
					 │     ┣ Text (bio)
					 │     ┗ Row
					 │        ┣ ElevatedButton (Like)
					 │        ┗ OutlinedButton (Toggle Bio)
					 ┣ ElevatedButton (Highlight Card)
					 ┗ Text (helper)
```

Reactive UI behavior:
- `setState()` updates `isHighlighted`, `showBio`, or `likes`.
- Flutter rebuilds only the widgets that depend on those values.
- The animated container and button labels update without redrawing the entire UI.

Core demo (in `lib/main.dart`):
```dart
class _WidgetTreeDemoAppState extends State<WidgetTreeDemoApp> {
  bool isHighlighted = false;
  bool showBio = true;
  int likes = 0;

  void toggleHighlight() => setState(() => isHighlighted = !isHighlighted);
  void toggleBio() => setState(() => showBio = !showBio);
  void addLike() => setState(() => likes++);
}
```

Screenshots:
- Initial state: ![Widget tree demo initial state](assets/widget_tree_before.png)
- After state change: ![Widget tree demo updated state](assets/widget_tree_after.png)

### 5) Documentation Requirements (for submission)
- What is a widget tree? A hierarchical structure where each widget is a node and parents compose children to form the UI.
- How does Flutter's reactive model work? `setState()` marks widgets dirty, then Flutter rebuilds only the affected parts of the tree.
- Why does Flutter rebuild only parts of the tree? The framework diffs widgets and reuses elements/render objects for unchanged subtrees.
- Why Dart is ideal: fast AOT performance for release, JIT + Hot Reload for developer productivity, strong typing and null safety for fewer runtime errors.



Files added for this assessment:
- `lib/main.dart` — widget tree demo app source
- `pubspec.yaml` — minimal config to run the app



### 6) Figma desing link

  - https://shirt-manor-13222881.figma.site/


### 7)  High-Level Design (HLD) link

  - https://radix-badge-14040611.figma.site/

  folder structure given


---

## Stateless vs Stateful Widgets — Interactive Demo

This section demonstrates the practical differences between **StatelessWidget** and **StatefulWidget** through an interactive demo app located at [lib/screens/stateless_stateful_demo.dart](lib/screens/stateless_stateful_demo.dart).

### Understanding the Widget Types

#### 🔷 Stateless Widget
- **Definition**: A widget that does not store any mutable state
- **Characteristics**: 
  - Immutable — once built, it doesn't change
  - Rebuilds only when parent passes new data
  - Lightweight and efficient for static content
- **Use Cases**: Labels, icons, headers, static text, images

**Example in Demo**: `DemoHeader` widget
```dart
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
      // Static UI that displays the same content
      // Changes only if parent passes new title/subtitle
    );
  }
}
```

#### 🔶 Stateful Widget
- **Definition**: A widget that maintains internal state that can change
- **Characteristics**:
  - Mutable state stored in State object
  - Can update UI dynamically using `setState()`
  - Responds to user interactions, animations, or data changes
- **Use Cases**: Forms, counters, toggles, animations, interactive elements

**Example in Demo**: `StatelessStatefulDemo` widget
```dart
class _StatelessStatefulDemoState extends State<StatelessStatefulDemo> {
  int _counter = 0;  // Mutable state
  bool _isDarkMode = false;
  Color _selectedColor = Colors.blue;

  void _incrementCounter() {
    setState(() {
      _counter++;  // Update state and rebuild UI
    });
  }

  @override
  Widget build(BuildContext context) {
    // UI rebuilds when setState() is called
  }
}
```

### Demo App Features

The demo app showcases **4 interactive sections** that demonstrate state management:

#### 1️⃣ **Counter Demo**
- Increment, decrement, and reset buttons
- Displays real-time count updates
- Demonstrates: State changes trigger UI updates

#### 2️⃣ **Color Changer**
- Tap button to cycle through 6 different colors
- Animated circular color preview
- Demonstrates: Visual state changes with smooth transitions

#### 3️⃣ **Favorite Toggle**
- Heart icon that fills/unfills on tap
- Animated icon transition
- Demonstrates: Boolean state and conditional rendering

#### 4️⃣ **Theme Mode Toggle**
- Switch between Light and Dark modes
- Changes background color of entire app
- Demonstrates: Global state affecting multiple UI elements

### Key Concepts Demonstrated

**setState() Method**:
```dart
void _toggleTheme() {
  setState(() {
    _isDarkMode = !_isDarkMode;  // Change state
  });
  // Flutter automatically rebuilds affected widgets
}
```

**Stateless vs Stateful Comparison**:
- **Header (Stateless)**: Never changes unless parent rebuilds it
- **Interactive sections (Stateful)**: Change dynamically based on user actions

**Reactive UI**:
- User taps button → `setState()` called → Widget marked dirty → Flutter rebuilds → UI updates
- Only affected widgets rebuild, not the entire screen

### Running the Demo

1. **Launch the app**:
   ```bash
   flutter run
   ```

2. **Interact with the features**:
   - Press +/- buttons to see counter change
   - Tap "Change Color" to cycle through colors
   - Tap heart icon to toggle favorite
   - Use switch or app bar icon to toggle theme

3. **Observe the behavior**:
   - Notice how the static header never changes
   - See how interactive elements respond immediately
   - Watch animations and state transitions

### File Structure
```
lib/
  main.dart                          # Entry point, now launches demo
  screens/
    stateless_stateful_demo.dart     # Complete interactive demo
    dashboard.dart
    login_screen.dart
    responsive_home.dart
    signup_screen.dart
```

### Learning Outcomes

After exploring this demo, you should understand:
- ✅ When to use StatelessWidget vs StatefulWidget
- ✅ How `setState()` triggers UI updates
- ✅ How to manage multiple state variables
- ✅ How state changes flow through the widget tree
- ✅ Best practices for organizing stateful logic

### Code Highlights

**Multiple State Variables**:
```dart
int _counter = 0;           // Number state
bool _isDarkMode = false;   // Boolean state
Color _selectedColor = Colors.blue;  // Object state
bool _isIconFavorite = false;
```

**Organized State Methods**:
```dart
void _incrementCounter() { setState(() => _counter++); }
void _toggleTheme() { setState(() => _isDarkMode = !_isDarkMode); }
void _changeColor() { /* Cycle through colors */ }
```

**Conditional UI Based on State**:
```dart
backgroundColor: _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
```

### Next Steps

- Experiment by adding your own interactive features
- Try combining multiple state changes in one action
- Explore Flutter's `AnimatedContainer` for smooth transitions
- Practice separating stateless presentation from stateful logic

---

## 🔥 Hot Reload & Debugging Tools Demo

This section demonstrates **Flutter's Hot Reload feature**, **Debug Console usage**, and **Flutter DevTools** — essential tools for rapid Flutter development.

### Overview

The Hot Reload Demo ([lib/screens/hot_reload_demo.dart](lib/screens/hot_reload_demo.dart)) is an interactive learning environment that helps you understand and practice:

1. **Hot Reload** — Instantly apply code changes without losing app state
2. **Debug Console** — Monitor real-time logs and app behavior
3. **Flutter DevTools** — Advanced debugging and performance profiling

### 🚀 Quick Start

```bash
# Run the app
flutter run

# Navigate to: Hot Reload Demo from the home screen
```

### 📚 Documentation

**Comprehensive guides included:**
- 📖 [HOT_RELOAD_GUIDE.md](HOT_RELOAD_GUIDE.md) — Complete tutorial on all debugging tools
- 🚦 [QUICK_REFERENCE.md](QUICK_REFERENCE.md) — Handy reference card for commands and shortcuts

### Features of the Hot Reload Demo

#### 1️⃣ **Interactive Counter with Debug Logging**
- Increment/decrement counter buttons
- Every action logs to Debug Console
- Example log output:
  ```
  ✨ Counter incremented to: 5
  ⬇️ Counter decremented to: 4
  📊 Current state: {counter: 4, message: "Hello, Flutter!"}
  ```

#### 2️⃣ **Dynamic Message Changing**
- Toggle between different messages
- Demonstrates Hot Reload preserving state
- Watch text change instantly on save

#### 3️⃣ **Visual Controls**
- Change background color
- Adjust font size
- Toggle animations
- Each action produces debug output

#### 4️⃣ **Lifecycle Logging**
- Tracks widget initialization: `🚀 Widget initialized`
- Monitors build calls: `🔄 Build method called`
- Logs disposal: `🔚 Widget disposed`

### 🔥 How to Use Hot Reload

#### Method 1: Auto Hot Reload (Recommended)
1. Run your app: `flutter run`
2. Make code changes in any file
3. Save the file: `Ctrl+S`
4. Changes appear **instantly** in your running app!

#### Method 2: Terminal Command
1. With app running, press `r` in terminal
2. Flutter reloads changed code immediately

#### Method 3: VS Code UI
1. Click the **Hot Reload** button (🔥) in the debug toolbar
2. Or use `Ctrl+Shift+F5`

### 🎯 Try This Exercise!

**Demonstrate Hot Reload preserving state:**

1. Run the app and navigate to Hot Reload Demo
2. Click increment button 10 times (counter = 10)
3. Change the background color to purple
4. **Important**: Don't touch the app now!
5. Go to [lib/screens/hot_reload_demo.dart](lib/screens/hot_reload_demo.dart)
6. Find this line (around line 11):
   ```dart
   String _message = 'Hello, Flutter!';
   ```
7. Change it to:
   ```dart
   String _message = 'Welcome to Hot Reload Magic!';
   ```
8. Save the file (`Ctrl+S`)
9. **Result**: The message updates instantly, but your counter stays at 10! ✨

This proves Hot Reload preserves app state while updating the UI.

### 🖥️ Using the Debug Console

**Access Debug Console:**
- VS Code: `View → Debug Console` or `Ctrl+Shift+Y`
- Terminal: Logs appear automatically when running `flutter run`

**Debug logging in the app:**
```dart
void _incrementCounter() {
  setState(() {
    _counter++;
    debugPrint('✨ Counter incremented to: $_counter');
    debugPrint('📊 Current state: {counter: $_counter, message: "$_message"}');
  });
}
```

**Why use debugPrint() instead of print():**
- ✅ Automatically wraps long messages
- ✅ Throttles output to prevent overflow
- ✅ Stripped out in release builds (better performance)
- ✅ Better formatted for Flutter logs

**Emoji-tagged logs for clarity:**
```dart
✨ — Success/completion
❌ — Errors
⚠️ — Warnings
🔄 — Process started
✅ — Validated/confirmed
📍 — Navigation
🎨 — UI changes
💾 — Data operations
🔐 — Auth events
```

### 🛠️ Flutter DevTools

**What is DevTools?**
A comprehensive suite of debugging and performance profiling tools for Flutter apps.

**How to Launch:**

**Option 1: From VS Code**
1. Run your app in debug mode (`F5`)
2. Press `Ctrl+Shift+P` → Type "Dart: Open DevTools"
3. Select "Open DevTools in Web Browser"

**Option 2: From Terminal**
```bash
# Activate DevTools (one-time setup)
flutter pub global activate devtools

# Run DevTools
flutter pub global run devtools

# Or launch with your app
flutter run --DevTools
```

**Key DevTools Features:**

#### 🔍 Widget Inspector
- Visually explore your widget tree
- Click widgets in your app to inspect properties
- See layout constraints, sizes, and positions
- Debug layout issues (overflow, alignment, etc.)
- Toggle debug paint, guidelines, baselines

**Use for:**
- Layout debugging
- Understanding widget hierarchy
- Fixing UI positioning issues

#### ⚡ Performance Tab
- Monitor frame rendering times (target: <16ms for 60 FPS)
- Identify janky frames (red bars = slow frames)
- Analyze CPU and GPU usage
- View rebuild performance

**Use for:**
- Finding performance bottlenecks
- Optimizing slow operations
- Ensuring smooth animations

#### 💾 Memory Tab
- Real-time memory usage graph
- Heap snapshot analysis
- Memory leak detection
- Object allocation tracking

**Use for:**
- Detecting memory leaks
- Monitoring memory consumption
- Ensuring proper resource disposal

#### 🌐 Network Tab
- Monitor all HTTP requests
- Inspect request/response headers and bodies
- Track API performance
- Debug authentication issues

**Use for:**
- Debugging API calls
- Monitoring Firebase operations
- Checking network performance

### 📸 Screenshots to Capture

For your assignment, take screenshots showing:

1. **✅ Hot Reload in Action**
   - Before and after code change
   - State preserved (counter value unchanged)
   - Updated UI element visible

2. **✅ Debug Console**
   - Terminal showing your `debugPrint()` messages
   - Various emoji-tagged logs
   - Lifecycle events

3. **✅ Flutter DevTools - Widget Inspector**
   - Widget tree visible on left
   - Selected widget highlighted
   - Properties panel showing details

4. **✅ Flutter DevTools - Performance Tab**
   - Timeline with frame rendering
   - Performance graph showing smooth/janky frames

5. **✅ Running App**
   - Hot Reload Demo screen
   - Interactive elements (counter, colors, buttons)

### 🎓 Development Workflow

**Efficient development cycle:**

```plaintext
1. Run app: flutter run
   ↓
2. Open DevTools (Ctrl+Shift+P → "Open DevTools")
   ↓
3. Make code changes
   ↓
4. Save file (Ctrl+S) — Hot Reload applies
   ↓
5. Check Debug Console for logs
   ↓
6. Use DevTools to inspect/profile
   ↓
7. Repeat quickly!
```

### ⚡ Quick Reference

| Command | Action |
|---------|--------|
| `flutter run` | Start app in debug mode |
| `r` | Hot Reload (in terminal) |
| `R` | Hot Restart (in terminal) |
| `Ctrl+S` | Save & Hot Reload (VS Code) |
| `Ctrl+Shift+Y` | Open Debug Console |
| `F5` | Start debugging |
| `Shift+F5` | Stop debugging |

### 🎯 What Hot Reload Can/Can't Do

**✅ Hot Reload Works For:**
- Widget UI changes (colors, text, sizes)
- Method implementations
- Adding new widgets
- Styling changes
- Layout modifications

**❌ Requires Hot Restart (R):**
- Changes to `main()` function
- Modifying `initState()`
- Global variable initializations
- Adding new imports
- Enum changes

### 💡 Pro Tips

1. **Keep DevTools Open** — Monitor performance continuously
2. **Use const Constructors** — Better performance: `const Text('Hello')`
3. **Dispose Resources** — Always dispose controllers and subscriptions
4. **Meaningful Logs** — Use emojis and context in debug messages
5. **Hot Reload Often** — Save frequently to see changes instantly
6. **Check Performance** — Use Performance tab regularly during development

### 📁 File Structure

```
lib/
  main.dart                    # Updated with debug logging
  screens/
    home_screen.dart          # Navigation hub for all demos
    hot_reload_demo.dart      # ⭐ Hot Reload demonstration
    stateless_stateful_demo.dart  # Enhanced with debug logs
    dashboard.dart
    login_screen.dart
    responsive_home.dart
    signup_screen.dart
  services/
    auth_service.dart
    firestore_service.dart

HOT_RELOAD_GUIDE.md          # 📖 Complete tutorial
QUICK_REFERENCE.md           # 🚦 Quick reference card
```

### 🚀 Getting Started

1. **Run the app:**
   ```bash
   flutter pub get
   flutter run
   ```

2. **Navigate to Hot Reload Demo** from the home screen

3. **Read the guides:**
   - [HOT_RELOAD_GUIDE.md](HOT_RELOAD_GUIDE.md) for comprehensive tutorial
   - [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for quick commands

4. **Practice:**
   - Make code changes
   - Use Hot Reload
   - Monitor Debug Console
   - Explore DevTools

### 📚 Additional Resources

- [Official Hot Reload Documentation](https://flutter.dev/docs/development/tools/hot-reload)
- [Flutter DevTools Guide](https://flutter.dev/docs/development/tools/devtools)
- [Debugging Flutter Apps](https://flutter.dev/docs/testing/debugging)

### ✨ Summary

You now have:
- ✅ Interactive Hot Reload demonstration app
- ✅ Debug logging throughout the codebase
- ✅ Comprehensive documentation and guides
- ✅ Practical exercises to demonstrate understanding
- ✅ Reference materials for ongoing development

**Master these tools to become a highly productive Flutter developer!** 🎉

  

