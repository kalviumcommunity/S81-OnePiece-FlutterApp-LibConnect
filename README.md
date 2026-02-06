# S81-OnePiece-FlutterApp-LibConnect
# S81-OnePiece-FlutterApp-LibConnect

Our team of three members is developing LibConnect, a Flutter and Firebase-based mobile application aimed at modernizing public library management. The problem we are addressing is that many public libraries still depend on manual registers to manage book availability and borrowing, making the process slow, inaccurate, and inconvenient for both readers and librarians. Our proposed solution, LibConnect, allows users to easily search, reserve, and track books in real time while providing librarians with tools to manage inventory digitally. The project’s goal is to build a fully functional MVP that demonstrates seamless Flutter-Firebase integration with an intuitive user interface and real-time data synchronization. The core features include user authentication (sign up, login, logout) using Firebase Auth, book discovery and reservation using Firestore, and a user dashboard to track borrowed or reserved books. We are using Flutter for the frontend, Firebase Firestore for database management, Firebase Auth for authentication, and GitHub Actions for CI/CD. Within our team, the UI/UX Lead is responsible for designing and developing the app’s interface and navigation flow, the Firebase & Backend Lead handles database configuration and integration, and the Testing & Deployment Lead manages app testing, builds, and deployment. The four-week sprint is structured as follows: Week 1 focuses on idea finalization, Firebase setup, and UI wireframes; Week 2 covers authentication and core functionality; Week 3 is for integration and testing of CRUD operations; and Week 4 involves UI polishing, bug fixing, and MVP deployment. The success of the sprint will be measured by delivering a stable, demo-ready APK that successfully integrates Firebase services, provides smooth user interaction, and receives positive feedback during review.

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

### 4) Reactive UI — Counter App
The demo app uses a `StatefulWidget` to hold a `count` integer. Calling `setState()` updates the state and signals Flutter to re-run `build()` for affected widgets — Flutter then efficiently repaints only the necessary parts of the widget tree.

Counter core (in `lib/main.dart`):
```dart
import 'package:flutter/material.dart';

void main() => runApp(CounterApp());

class CounterApp extends StatefulWidget {
	@override
	_CounterAppState createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
	int count = 0;

	void increment() => setState(() => count++);

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Flutter Assessment Counter',
			home: Scaffold(
				appBar: AppBar(title: Text('Stateful Widget Demo')),
				body: Center(child: Text('Count: $count', style: TextStyle(fontSize: 28))),
				floatingActionButton: FloatingActionButton(
					onPressed: increment,
					child: Icon(Icons.add),
				),
			),
		);
	}
}
```

What happens when you press the button:
- `increment()` updates `count`.
- `setState()` marks the widget dirty and schedules a rebuild.
- Flutter re-renders just the widgets that depend on the changed state.

### 5) Documentation Requirements (for submission)
- Difference between `StatelessWidget` and `StatefulWidget`: see section 2 above.
- How Flutter uses the widget tree to build reactive UIs: state changes trigger rebuilds; Flutter uses element/widget/render object trees to update efficiently.
- Why Dart is ideal: fast AOT performance for release, JIT + Hot Reload for developer productivity, strong typing and null safety for fewer runtime errors.



Files added for this assessment:
- `lib/main.dart` — counter app source
- `pubspec.yaml` — minimal config to run the app


