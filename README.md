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
  