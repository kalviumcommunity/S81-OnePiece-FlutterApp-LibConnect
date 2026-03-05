# S81-OnePiece-FlutterApp-LibConnect

Our team of three members is developing LibConnect, a Flutter and Firebase-based mobile application aimed at modernizing public library management. The problem we are addressing is that many public libraries still depend on manual registers to manage book availability and borrowing, making the process slow, inaccurate, and inconvenient for both readers and librarians. Our proposed solution, LibConnect, allows users to easily search, reserve, and track books in real time while providing librarians with tools to manage inventory digitally. The project’s goal is to build a fully functional MVP that demonstrates seamless Flutter-Firebase integration with an intuitive user interface and real-time data synchronization. The core features include user authentication (sign up, login, logout) using Firebase Auth, book discovery and reservation using Firestore, and a user dashboard to track borrowed or reserved books. We are using Flutter for the frontend, Firebase Firestore for database management, Firebase Auth for authentication, and GitHub Actions for CI/CD. Within our team, the UI/UX Lead is responsible for designing and developing the app’s interface and navigation flow, the Firebase & Backend Lead handles database configuration and integration, and the Testing & Deployment Lead manages app testing, builds, and deployment. The four-week sprint is structured as follows: Week 1 focuses on idea finalization, Firebase setup, and UI wireframes; Week 2 covers authentication and core functionality; Week 3 is for integration and testing of CRUD operations; and Week 4 involves UI polishing, bug fixing, and MVP deployment. The success of the sprint will be measured by delivering a stable, demo-ready APK that successfully integrates Firebase services, provides smooth user interaction, and receives positive feedback during review.

## Google Maps Setup in Flutter

### 1) Why User Location & Markers Are Important
- Enables real-time navigation and tracking.
- Lets users see their current position on a map.
- Allows apps to highlight important places with markers (stores, destinations, checkpoints).
- Forms the base for route drawing, distance calculations, and area monitoring.

### 2) Required Dependencies

```yaml
dependencies:
  google_maps_flutter: ^latest
  geolocator: ^latest
```

Run:

```bash
flutter pub get
```

### 3) Requesting Location Permissions
Before accessing GPS, permissions must be requested.

#### Android Setup (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### iOS Setup (`Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app requires location access to show your current position.</string>
```

### 4) Getting the User’s Current Location

```dart
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
);

print("User location: ${position.latitude}, ${position.longitude}");
```

### 5) Displaying User Location on Google Map

```dart
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(position.latitude, position.longitude),
    zoom: 15,
  ),
  myLocationEnabled: true,
  myLocationButtonEnabled: true,
);
```

This centers the map on the user’s live GPS position.

### 6) Adding a Marker on the Map
Simple marker example:

```dart
Set<Marker> markers = {
  Marker(
    markerId: const MarkerId("currentLocation"),
    position: LatLng(position.latitude, position.longitude),
    infoWindow: const InfoWindow(title: "You are here"),
  ),
};
```

Using the marker in `GoogleMap`:

```dart
GoogleMap(
  initialCameraPosition: _cameraPosition,
  markers: markers,
);
```

### 7) Adding a Custom Marker (PNG Icon)
Step 1: Add PNG to `assets/` folder

```text
assets/location_pin.png
```

Update `pubspec.yaml`:

```yaml
assets:
  - assets/location_pin.png
```

Step 2: Create `BitmapDescriptor`

```dart
final customIcon = await BitmapDescriptor.fromAssetImage(
  const ImageConfiguration(size: Size(48, 48)),
  'assets/location_pin.png',
);
```

Step 3: Use it in marker

```dart
Marker(
  markerId: const MarkerId("customPin"),
  position: LatLng(position.latitude, position.longitude),
  icon: customIcon,
);
```

### 8) Updating Marker on Location Change (Live Tracking)

```dart
Geolocator.getPositionStream().listen((Position pos) {
  setState(() {
    userMarker = Marker(
      markerId: const MarkerId('live'),
      position: LatLng(pos.latitude, pos.longitude),
    );
  });
});
```

This simulates real-time movement on the map.

## Firestore CRUD with Firebase Auth

### 1) Why CRUD Matters in Mobile Apps
- Forms the foundation for apps like notes, tasks, diaries, shopping lists, chats, and dashboards.
- Allows user-specific data storage with authentication.
- Demonstrates interaction between UI components, Firestore collections, and Firebase Auth.
- Helps organize real-time syncing and dynamic UI updates.

### 2) Firebase Setup Requirements
Ensure you have:
- Email/Password Authentication enabled
- A Firestore database in production mode
- Users signed in before performing CRUD operations

### 3) Data Model Example
Each user stores data under:

```text
/users/{uid}/items/{itemId}
```

Sample item:

```json
{
  "title": "My first item",
  "description": "This is a demo entry.",
  "createdAt": 1700000000000
}
```

### 4) Create Operation (C)

```dart
final uid = FirebaseAuth.instance.currentUser!.uid;
final items = FirebaseFirestore.instance.collection('users').doc(uid).collection('items');

Future<void> createItem(String title, String desc) async {
  await items.add({
    'title': title,
    'description': desc,
    'createdAt': DateTime.now().millisecondsSinceEpoch,
  });
}
```

### 5) Read Operation (R)
Displaying items in the UI using a `StreamBuilder`:

```dart
StreamBuilder(
  stream: items.orderBy('createdAt', descending: true).snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const CircularProgressIndicator();
    final docs = snapshot.data!.docs;

    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (_, i) {
        final item = docs[i].data();
        return ListTile(
          title: Text(item['title']),
          subtitle: Text(item['description']),
        );
      },
    );
  },
);
```

This ensures the UI updates automatically when Firestore changes.

### 6) Update Operation (U)

```dart
Future<void> updateItem(String id, String newTitle) async {
  await items.doc(id).update({
    'title': newTitle,
    'updatedAt': DateTime.now().millisecondsSinceEpoch,
  });
}
```

### 7) Delete Operation (D)

```dart
Future<void> deleteItem(String id) async {
  await items.doc(id).delete();
}
```

### 8) UI Flow Example
Your CRUD UI typically includes:
- A text field to create a new item
- A list view to read items
- A tap action or dialog to update an item
- A delete icon to remove an item

Example UI layout:

```dart
Scaffold(
  appBar: AppBar(title: const Text("My Items")),
  floatingActionButton: FloatingActionButton(
    onPressed: () => openCreateDialog(),
    child: const Icon(Icons.add),
  ),
  body: ItemsListView(), // your StreamBuilder widget
);
```

### 9) Securing CRUD with Firestore Rules
Rules ensure each user can only access their own items:

```text
match /users/{uid}/items/{itemId} {
  allow read, write: if request.auth.uid == uid;
}
```

## Flutter Form Validation Guide

### 2) Basic Form Structure in Flutter
A form requires:
- A `Form` widget
- A `GlobalKey<FormState>`
- Multiple `TextFormField` widgets
- Validators to handle input checks

Example structure:

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(),
      TextFormField(),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            print("Form is valid");
          }
        },
        child: Text("Submit"),
      )
    ],
  ),
);
```

### 3) Adding Validators to Fields
Built-in basic validator:

```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return "This field is required";
  }
  return null;
}
```

### 4) Validating Common Form Inputs
Email validation:

```dart
validator: (value) {
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  if (!emailRegex.hasMatch(value ?? "")) {
    return "Enter a valid email address";
  }
  return null;
}
```

Password validation:

```dart
validator: (value) {
  if ((value ?? "").length < 8) {
    return "Password must be at least 8 characters";
  }
  return null;
}
```

Phone number validation:

```dart
validator: (value) {
  final phoneRegex = RegExp(r'^[0-9]{10}$');
  if (!phoneRegex.hasMatch(value ?? "")) {
    return "Enter a valid 10-digit phone number";
  }
  return null;
}
```

### 5) Multi-Field Cross Validation
Some validations depend on multiple fields, such as confirming a password.

```dart
String? password;
String? confirmPassword;

TextFormField(
  onChanged: (v) => password = v,
);

TextFormField(
  validator: (v) {
    if (v != password) {
      return "Passwords do not match";
    }
    return null;
  },
);
```

### 6) Showing Error Messages
Flutter automatically displays validator messages below the field.

To show messages on submit:

```dart
if (!_formKey.currentState!.validate()) {
  // Form has errors
}
```

### 7) Disabling Submit Button for Invalid Forms
Common UX enhancement:

```dart
bool isValid = _formKey.currentState?.validate() ?? false;

ElevatedButton(
  onPressed: isValid ? submitForm : null,
  child: Text("Submit"),
);
```

### 8) Complex Forms With Multiple Sections
Examples:
- Shipping address + payment details
- Multi-step onboarding
- Dynamic form fields based on user choices

Use:
- `Stepper` widget
- Separate `Form` widgets per section
- Combined validation before final submit

### 9) Best Practices
- Validate on user input for immediate feedback.
- Use input formatters for phone, card numbers, etc.
- Avoid long forms—use multiple steps or collapsible UI.
- Perform backend validation even after frontend success.
- Sanitize user input wherever possible.

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

## Assets and Icons Demo

This lesson adds local images and icons to the app and renders them in the responsive layout.

### Asset folder structure
```
assets/
  images/
    logo.png
    banner.jpg
    background.png
  icons/
    star.png
    profile.png
```

### pubspec.yaml snippet
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

### Code snippets
```dart
Image.asset(
  'assets/images/logo.png',
  width: 150,
  height: 150,
  fit: BoxFit.cover,
)
```

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.star, color: Colors.amber, size: 32),
    SizedBox(width: 10),
    Text('Starred', style: TextStyle(fontSize: 18)),
  ],
)
```

### Screenshots
- App screen showing images and icons: (add screenshot)
- Asset folders and pubspec.yaml snippet: (add screenshot)

### Reflection
- Steps needed to load assets: Create folders, add files, register in `pubspec.yaml`, then run `flutter pub get`.
- Common errors faced: Incorrect paths or YAML indentation.
- How this supports scalability: A consistent asset structure keeps UI updates predictable and team-friendly.

---

## Animations and Transitions Demo

This lesson adds implicit animations, an explicit rotation animation, and a custom page transition.

### Code snippets
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeInOut,
  width: width,
  height: height,
)
```

```dart
AnimatedOpacity(
  duration: const Duration(milliseconds: 500),
  opacity: isVisible ? 1.0 : 0.6,
  child: Image.asset('assets/images/logo.png'),
)
```

```dart
Navigator.of(context).push(
  PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 700),
    pageBuilder: (context, animation, secondaryAnimation) => const AnimationDemoScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
  ),
);
```

### Screenshots or GIFs
- Implicit animation toggle on the responsive screen: (add screenshot)
- Explicit rotation demo screen: (add screenshot or GIF)

### Reflection
- Why animations matter for UX: They guide attention and make interactions feel responsive.
- Implicit vs explicit: Implicit animations react to property changes; explicit animations are driven by controllers.
- Team usage: Apply consistent timing/curves to keep motion cohesive across screens.

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

## Sprint 2 - Handling User Input with Forms

### Project Title and Description
User Input Form for LibConnect: a simple form screen that collects a name and email, validates input, and shows submission feedback.

### Code Snippets

Text fields:
```dart
TextFormField(
  controller: _nameController,
  decoration: const InputDecoration(
    labelText: 'Name',
    border: OutlineInputBorder(),
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name.';
    }
    return null;
  },
),
```

Submit button:
```dart
ElevatedButton(
  onPressed: _handleSubmit,
  child: const Text('Submit'),
),
```

Validation and feedback:
```dart
void _handleSubmit() {
  final isValid = _formKey.currentState?.validate() ?? false;
  if (!isValid) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Form submitted successfully.')),
  );

  _formKey.currentState?.reset();
  _nameController.clear();
  _emailController.clear();
}
```

### Screenshots
- Form before input: assets/user_input_before.png
- Validation errors: assets/user_input_error.png
- Success message: assets/user_input_success.png

### Reflection
- Why is input validation important? It prevents invalid data from reaching the app logic or backend and improves user trust by providing immediate, clear feedback.
- What is the difference between TextField and TextFormField? `TextFormField` integrates with `Form` and supports validation and form state, while `TextField` is a standalone input widget.
- How does form state management simplify validation? A single `FormState` manages validation across multiple fields and provides a consistent way to validate or reset the entire form.

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
487: ❌ — Errors
488: ⚠️ — Warnings
489: 🔄 — Process started
490: ✅ — Validated/confirmed
491: 📍 — Navigation
492: 🎨 — UI changes
493: 💾 — Data operations
494: 🔐 — Auth events
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

---

## Scrollable Views Implementation

This section details the implementation of scrollable layouts using `ListView` and `GridView` widgets, which are essential for displaying large sets of data dynamically.

### Overview

The `ScrollableViews` screen ([lib/screens/scrollable_views.dart](lib/screens/scrollable_views.dart)) demonstrates:
1.  **Horizontal ListView**: A list of featured books scrolling horizontally.
2.  **Vertical GridView**: A grid of book categories scrolling vertically.

### Code Snippets

#### ListView.builder
Used for the horizontal list of featured books:
```dart
ListView.builder(
  scrollDirection: Axis.horizontal,
  itemCount: 8,
  itemBuilder: (context, index) {
    return Container(
      // ... styling (width, decorations)
      child: Column(
        children: [
          // ... book cover and details
        ],
      ),
    );
  },
)
```

#### GridView.builder
Used for the vertical grid of categories:
```dart
GridView.builder(
  physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
  shrinkWrap: true,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 1.5,
  ),
  itemCount: 6,
  itemBuilder: (context, index) {
    return Container(
      // ... styling (color, icon, text)
    );
  },
)
```

### Reflection

**How does ListView differ from GridView in design use cases?**
`ListView` is designed for linear lists of items, either vertical or horizontal. It's ideal for news feeds, chat logs, or setting menus. `GridView` arranges items in a 2D array (rows and columns), making it perfect for photo galleries, product catalogs, or dashboard icons where seeing multiple items side-by-side provides a better overview.

**Why is ListView.builder() more efficient for large lists?**
`ListView.builder()` creates items lazily. It only builds the widgets that are currently visible on the screen. As the user scrolls, new items are built and old ones are recycled/destroyed. This significantly reduces memory usage and improves performance compared to the default constructor which builds all children at once.

**What can you do to prevent lag or overflow errors in scrollable views?**
-   Use `.builder` constructors for large or infinite lists.
-   Avoid nesting scrollable widgets with the same scroll direction without proper constraints (e.g., wrap the inner one in `SizedBox` or use `shrinkWrap: true` and `NeverScrollableScrollPhysics` if scrolling should be handled by a parent).
-   Use `const` constructors for static widgets to reduce rebuilds.
-   Optimize item build methods to be lightweight.

### Screenshots & Demo

| ListView | GridView |
|----------|----------|
| ![ListView Screenshot](assets/listview_screenshot.png) | ![GridView Screenshot](assets/gridview_screenshot.png) |

**Video Demo**: [Link to Video Demo](YOUR_VIDEO_LINK_HERE)

---

## State Management with setState() — Local State Updates

This section demonstrates how to manage state in Flutter using the `setState()` method, which is fundamental for creating interactive user interfaces where data changes in real time.

### Overview

The `StateManagementDemo` screen ([lib/screens/state_management_demo.dart](lib/screens/state_management_demo.dart)) illustrates:
1. **Stateful Widget Pattern**: Creating widgets that maintain internal mutable state
2. **setState() Method**: Triggering UI updates when data changes
3. **Reactive UI**: Real-time visual feedback to user interactions
4. **Conditional Rendering**: Changing UI based on state values

### Understanding State Management Basics

#### What is State?
State is any data in your widget that can change over time. Examples:
- A counter value
- Form input text
- A boolean toggle
- A color selection

#### StatelessWidget vs StatefulWidget

| Aspect | StatelessWidget | StatefulWidget |
|--------|--|--|
| **Mutability** | Immutable — cannot change | Mutable state added via State class |
| **Purpose** | Display static content | Handle interactive features |
| **Examples** | Static labels, icons, images | Counters, forms, toggles |
| **Rebuild Trigger** | Only when parent rebuilds | When `setState()` is called |

#### How setState() Works

```dart
setState(() {
  // All code here tells Flutter the widget's data changed
  // After this block, Flutter rebuilds the widget
  _counter++; // Update local variable
  _isEven = _counter % 2 == 0; // Calculate derived state
});
```

The process:
1. User taps a button → callback function executes
2. Inside the callback, `setState({...})` is called with variable updates
3. Flutter marks the widget as "dirty" (needing rebuild)
4. Flutter calls `build()` again with new state values
5. The UI updates to reflect the new state

### Implementation Highlights

#### Counter with Even/Odd Detection

```dart
class _StateManagementDemoState extends State<StateManagementDemo> {
  int _counter = 0;
  bool _isEven = true;

  void _incrementCounter() {
    setState(() {
      _counter++;
      _isEven = _counter % 2 == 0;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
        _isEven = _counter % 2 == 0;
      }
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _isEven = true;
    });
  }
```

#### Conditional UI Updates

The background color changes when counter reaches 5:
```dart
Container(
  color: _counter >= 5 ? Colors.greenAccent.withOpacity(0.1) : Colors.white,
  child: Center(...),
)
```

The even/odd indicator displays dynamically:
```dart
Container(
  color: _isEven ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
  child: Text(
    _isEven ? 'The number is EVEN ✓' : 'The number is ODD ✗',
    style: TextStyle(
      color: _isEven ? Colors.green : Colors.orange,
    ),
  ),
)
```

#### Interactive Buttons

Three action buttons demonstrate state updates:
```dart
ElevatedButton.icon(
  onPressed: _decrementCounter,
  icon: const Icon(Icons.remove),
  label: const Text('Decrement'),
)

ElevatedButton.icon(
  onPressed: _incrementCounter,
  icon: const Icon(Icons.add),
  label: const Text('Increment'),
)

ElevatedButton.icon(
  onPressed: _resetCounter,
  icon: const Icon(Icons.refresh),
  label: const Text('Reset'),
)
```

### Real-World Applications

This pattern applies to many practical scenarios:

- **Like Counters**: Track number of likes and update heart icon
- **Theme Toggles**: Switch between light/dark mode
- **Form Validation**: Enable/disable submit button based on input
- **Shopping Cart**: Track selected items and total price
- **Search Filters**: Update results list when filters change

### Common Mistakes to Avoid

#### ❌ Updating State Without setState()
```dart
// WRONG - Won't update UI
void _incrementCounter() {
  _counter++; // Direct variable update
}

// CORRECT
void _incrementCounter() {
  setState(() {
    _counter++;
  });
}
```

#### ❌ Calling setState() Inside build()
```dart
// WRONG - Creates infinite rebuild loop
@override
Widget build(BuildContext context) {
  setState(() {
    _counter++;
  });
  return Scaffold(...);
}

// CORRECT - Call setState() in callbacks only
void _incrementCounter() {
  setState(() {
    _counter++;
  });
}
```

#### ❌ Heavy Operations Inside setState()
```dart
// WRONG - Blocks UI thread
setState(() {
  // Expensive computation here
  List<int> result = complexOperation();
  _data = result;
});

// CORRECT - Do heavy work outside setState()
void _loadData() async {
  final result = await computeAsync();
  setState(() {
    _data = result; // Just update the state
  });
}
```

### Performance Considerations

**What happens on setState()?**
- Flutter doesn't rebuild the entire app
- Only the StatefulWidget that called `setState()` rebuilds
- The `build()` method is called again
- Child widgets are compared (diffing) with previous versions
- Only widgets that actually changed are rebuilt

**How to keep performance optimal:**
1. **Break widgets into smaller pieces** → Smaller rebuild scopes
2. **Use const constructors** → Widgets aren't rebuilt unnecessarily
3. **Avoid setState() for trivial updates** → Consider alternative state management (Provider, Bloc, etc.) for complex apps
4. **Keep setState() callbacks lightweight** → Do async work outside and use setState() only for state assignment

### Key Concepts Recap

| Concept | Explanation |
|---------|------------|
| **Local State** | Data stored in the State class of a StatefulWidget |
| **setState()** | Method that signals Flutter to rebuild a widget after state changes |
| **Reactive** | UI automatically updates in response to state changes |
| **Immutability** | Flutter encourages `final` and `const` for predictable widgets |
| **Rebuilds** | Smart diffing ensures only affected parts of the tree rebuild |

### Reflection Questions & Answers

**Q: What's the difference between Stateless and Stateful widgets?**
A: Stateless widgets are immutable and don't store state — they remain static unless the parent rebuilds them. Stateful widgets can maintain mutable state that changes independently, triggering their own rebuilds via `setState()`. Stateless widgets are faster for static content, while Stateful widgets enable interactivity.

**Q: Why is setState() important for Flutter's reactive model?**
A: `setState()` is the bridge between imperative code (button clicks, etc.) and Flutter's declarative UI. It tells Flutter "the data has changed, redraw me," allowing the framework to intelligently update only affected widgets. Without it, Flutter wouldn't know when to rebuild, and the UI would be static.

**Q: How can improper use of setState() affect performance?**
A: Calling `setState()` unnecessarily forces expensive rebuilds. Calling it from `build()` creates infinite loops. Heavy operations inside `setState()` block the UI thread. Large widgets rebuilding from a single `setState()` call is inefficient. The solution is to be intentional about when/why `setState()` is called and to break your widget tree into smaller, focused components.

### Screenshots & Demo

Initial State:
![Counter Demo Initial](assets/state_management_initial.png)

After Increment (Background changes at count 5):
![Counter Demo Incremented](assets/state_management_incremented.png)

Even/Odd Indicator:
![Counter Demo Even/Odd](assets/state_management_even_odd.png)

**Video Demo**: [Link to 1-2 minute demo showing setState() in action](YOUR_VIDEO_LINK_HERE)

### Running the State Management Demo

1. **Launch the app:**
   ```bash
   flutter pub get
   flutter run
   ```

2. **Access the demo:**
   - From the home screen, tap "State Management Demo"
   - Or navigate directly via route: `/state-management`

3. **Try these interactions:**
   - Click **Increment** → Counter increases, even/odd updates
   - Click **Decrement** → Counter decreases (minimum 0)
   - Reach count 5 → Background color changes to green
   - Click **Reset** → All values return to initial state

### Next Steps

For more complex state management in larger apps, explore:
- **Provider**: Simplified state management library
- **Bloc/Cubit**: Advanced pattern for scalable apps
- **GetX**: Full-featured state management and routing
- **Riverpod**: Modern reactive state management

But master `setState()` first — it's the foundation for understanding how Flutter's reactivity works!

---

## Responsive Design Demo (MediaQuery + LayoutBuilder)

This demo is implemented in [lib/screens/responsive_home.dart](lib/screens/responsive_home.dart) and is available from the Home Hub as **Responsive Design**.

### What it demonstrates
- **MediaQuery** for screen width, height, and orientation
- **LayoutBuilder** for conditional widget trees based on width constraints
- **Mobile layout** for widths under 600px (vertical `Column`)
- **Tablet layout** for widths 600px and above (horizontal `Row`)
- Proportional sizing (`screenWidth * ...`, `screenHeight * ...`) to avoid fixed-size UI issues

### How to test responsiveness
1. Run the app:
  ```bash
  flutter pub get
  flutter run
  ```
2. Open **Responsive Design** from the home screen.
3. Test on:
  - Mobile emulator (e.g., Pixel 4)
  - Tablet emulator (e.g., Nexus 9 / iPad)
4. Verify:
  - Layout switches correctly (mobile `Column` vs tablet `Row`)
  - No overflow or distortion
  - Panel sizes adapt proportionally to screen dimensions

### Screenshots for submission
- Mobile layout screenshot:
  ![Responsive Mobile](assets/responsive_mobile.png)
- Tablet layout screenshot:
  ![Responsive Tablet](assets/responsive_tablet.png)

Replace these placeholders with your captured emulator screenshots.

---

## 🔥 Setting Up Firebase Project and Connecting It to Flutter App

This section documents the complete process of creating a Firebase project, linking it to the LibConnect Flutter app, and verifying a successful integration. Firebase serves as the backend for the app — enabling authentication, real-time databases, cloud storage, and analytics.

### What is Firebase?

Firebase is a cloud platform by Google that provides tools for building, improving, and scaling mobile and web apps. Key services used in LibConnect:

| Service | Purpose |
|---------|---------|
| **Authentication** | Secure user login using email, Google, etc. |
| **Firestore Database** | Store and sync data in real-time (NoSQL) |
| **Cloud Storage** | Manage media files and documents |
| **Analytics** | Track usage and user behavior |

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Click **"Add Project"** → Enter project name (e.g., `libconnect-app`).
3. Enable **Google Analytics** (optional but recommended).
4. Wait for Firebase to initialize, then proceed to the dashboard.

### Step 2: Register the Flutter App with Firebase

#### Add the Android App
1. In the Firebase project dashboard, click **Add App → Android**.
2. Enter the Android package name (found in `android/app/build.gradle` → `applicationId`):
   ```
   com.example.s81_onepiece_flutterapp_libconnect
   ```
3. Add an optional nickname (e.g., "LibConnect Flutter App") and click **Register App**.

#### Download the Configuration File
1. Download the `google-services.json` file provided by Firebase.
2. Move it into the Flutter project:
   ```
   android/app/google-services.json
   ```

### Step 3: Add Firebase SDK Dependencies

In `pubspec.yaml`, add the Firebase packages:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

  # Firebase dependencies
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
  firebase_auth: ^5.0.0
  firebase_storage: ^11.0.0
```

Then run:
```bash
flutter pub get
```

### Step 4: Configure Android Build Files

#### Project-level `android/build.gradle`
Add the Google Services classpath:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### App-level `android/app/build.gradle`
Add the Google Services plugin at the bottom:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Step 5: Initialize Firebase in Flutter

Edit `lib/main.dart` to initialize Firebase before running the app:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  debugPrint('🚀 App launched successfully!');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Widget Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
```

Key points:
- `WidgetsFlutterBinding.ensureInitialized()` — Required before any async work in `main()`.
- `await Firebase.initializeApp()` — Connects the app to the Firebase project using the config file.
- `async` on `main()` — Necessary because Firebase initialization is asynchronous.

### Step 6: Firebase Service Classes

#### Authentication Service (`lib/services/auth_service.dart`)
```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email, password: password,
    );
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email, password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
```

#### Firestore Service (`lib/services/firestore_service.dart`)
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Tasks CRUD
  Future<DocumentReference> addTask(String title) {
    return _db.collection('tasks').add({
      'title': title,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getTasks() {
    return _db.collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Notes CRUD
  Future<void> addNote(String text) async {
    await _db.collection('notes').add({
      'text': text,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getNotes() {
    return _db.collection('notes').snapshots();
  }

  Future<void> updateNote(String id, String text) async {
    await _db.collection('notes').doc(id).update({'text': text});
  }

  Future<void> deleteNote(String id) async {
    await _db.collection('notes').doc(id).delete();
  }
}
```

### Step 7: Verify Firebase Connection

1. Run the app:
   ```bash
   flutter run
   ```
2. Open [Firebase Console](https://console.firebase.google.com/) → **Project Settings → Your Apps**.
3. If connected successfully, the Flutter app appears as an active app and terminal shows:
   ```
   🚀 App launched successfully!
   ```

### Folder Structure for Firebase Config

```
project-root/
├── android/
│   └── app/
│       ├── build.gradle          ← apply plugin line here
│       └── google-services.json  ← Firebase config file here
├── lib/
│   ├── main.dart                 ← Firebase.initializeApp() here
│   └── services/
│       ├── auth_service.dart     ← Firebase Auth wrapper
│       └── firestore_service.dart ← Firestore CRUD operations
└── pubspec.yaml                  ← Firebase dependencies here
```

### Common Issues & Fixes

| Problem | Possible Cause | Solution |
|---------|----------------|----------|
| `google-services.json` not found | File placed in wrong folder | Move to `android/app/` |
| Plugin not applied | Missing Gradle plugin line | Add `apply plugin: 'com.google.gms.google-services'` in `android/app/build.gradle` |
| Firebase not initialized | Missing `await Firebase.initializeApp()` | Add it in `main()` before `runApp()` |
| App build fails | Version mismatch | Update Gradle and Firebase dependencies |
| App crash on startup | Wrong package name | Ensure Firebase package name matches app's `applicationId` |

### Screenshots

- Firebase Console showing connected app: *(add screenshot)*
- App running with Firebase initialized: *(add screenshot)*

### Reflection

**Why is Firebase a popular choice for mobile backends?**
Firebase is popular because it provides a comprehensive suite of backend services (auth, database, storage, analytics) that are tightly integrated with each other and with Google Cloud. It eliminates the need to build and maintain a separate server, offers real-time data synchronization out of the box, and has generous free tiers. Its Flutter SDK (FlutterFire) provides native Dart packages that integrate seamlessly with the Flutter framework.

**What was the most challenging step in setup?**
The most important and error-prone step was configuring the Android build files (`build.gradle`) and placing `google-services.json` in the correct directory. A misplaced config file or missing Gradle plugin line causes the entire build to fail with unclear error messages. It's critical to follow the exact folder structure and plugin configuration.

**How does this integration prepare the app for authentication and storage features?**
With `firebase_core` initialized, the app can now use any Firebase service. The `AuthService` class wraps Firebase Auth for user sign-up, sign-in, and sign-out. The `FirestoreService` class provides CRUD operations for real-time data. Adding new Firebase features (like Cloud Storage or Cloud Messaging) only requires importing the relevant package — the core connection is already established.

---

## 🔧 Integrating Firebase SDKs Using FlutterFire CLI and Packages

This section documents the integration of Firebase SDKs into the LibConnect Flutter app using the **FlutterFire CLI** — the official tool that automates Firebase configuration across Android, iOS, and Web platforms.

### What is FlutterFire CLI?

The FlutterFire CLI is a command-line tool that simplifies connecting a Flutter project to Firebase. It:

- Registers your app on all target platforms automatically
- Generates `lib/firebase_options.dart` containing all Firebase credentials
- Eliminates manual editing of `google-services.json` or Gradle files
- Keeps Firebase SDK versions consistent across environments

### Step 1: Install Prerequisites

#### Install Firebase Tools
```bash
npm install -g firebase-tools
```

#### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### Verify Installation
```bash
flutterfire --version
```
Expected output: `FlutterFire CLI v0.2.7` (or later)

### Step 2: Login to Firebase
```bash
firebase login
```
A browser window opens — log in with the same Google account used for the Firebase project.

### Step 3: Configure the Flutter Project

Run inside the Flutter project directory:
```bash
flutterfire configure
```

The CLI will:
1. Detect all your Firebase projects
2. Ask you to select one (choose `libconnect-app`)
3. Ask which platforms to configure (Android, iOS, Web)
4. Auto-generate `lib/firebase_options.dart`

### Step 4: Add Firebase Core Dependency

In `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^3.0.0
```

Then install:
```bash
flutter pub get
```

### Step 5: Initialize Firebase with Generated Config

In `lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

**Key differences from manual setup:**
- `firebase_options.dart` replaces manual `google-services.json` configuration
- `DefaultFirebaseOptions.currentPlatform` auto-selects the correct platform config
- No need to manually edit Android Gradle files

### Step 6: Generated `firebase_options.dart` Structure

The CLI generates a file like this:
```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError('Platform not configured');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:000000000000:android:...',
    messagingSenderId: '000000000000',
    projectId: 'libconnect-app',
    storageBucket: 'libconnect-app.appspot.com',
  );

  // Similar entries for web, iOS, macOS...
}
```

### Step 7: Add Additional Firebase SDKs

With the CLI config in place, adding new services only requires a `pubspec.yaml` entry:

```yaml
dependencies:
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
  firebase_auth: ^5.0.0
  firebase_storage: ^11.0.0
  firebase_analytics: ^11.0.0
```

Then run:
```bash
flutter pub get
```

Each package automatically uses the credentials from `firebase_options.dart`.

### Step 8: Verify Integration

Run the app:
```bash
flutter run
```

Verify:
- App runs without Firebase errors
- Terminal shows: `Firebase initialized with DefaultFirebaseOptions`
- Firebase Console → **Project Settings → Your Apps** shows the registered app

### Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| `flutterfire` not recognized | CLI not in PATH | Add `~/.pub-cache/bin` to your system PATH |
| Firebase not initialized | Missing `await Firebase.initializeApp()` | Add initialization before `runApp()` |
| Build fails on Android | Missing Gradle plugin | Add `apply plugin: 'com.google.gms.google-services'` |
| Wrong Firebase project | Incorrect project selected during configure | Re-run `flutterfire configure` and select the correct project |
| Platform not configured | Missing platform in `firebase_options.dart` | Re-run `flutterfire configure` and select all target platforms |

### Folder Structure After CLI Setup

```
project-root/
├── lib/
│   ├── main.dart                 ← Firebase.initializeApp(options: ...)
│   ├── firebase_options.dart     ← Auto-generated by FlutterFire CLI
│   └── services/
│       ├── auth_service.dart     ← Firebase Auth wrapper
│       └── firestore_service.dart ← Firestore CRUD operations
└── pubspec.yaml                  ← Firebase dependencies
```

### Screenshots

- Terminal showing `flutterfire configure` output: *(add screenshot)*
- Generated `firebase_options.dart` in VS Code: *(add screenshot)*
- App running with Firebase connected: *(add screenshot)*
- Firebase Console showing registered app: *(add screenshot)*

### Reflection

**How did FlutterFire CLI simplify Firebase integration?**
FlutterFire CLI eliminated the need to manually download `google-services.json`, edit Gradle files, or configure platform-specific settings. A single `flutterfire configure` command handled everything — registering the app on all platforms, generating credentials, and creating the `firebase_options.dart` file. This reduces setup time from 30+ minutes of error-prone manual work to under 2 minutes.

**What errors did you face and how did you resolve them?**
The most common issue was the CLI not being recognized after installation. This was resolved by ensuring `~/.pub-cache/bin` was added to the system PATH. Another issue was selecting the wrong Firebase project during configuration, which was fixed by re-running `flutterfire configure`.

**Why is CLI-based setup preferred over manual configuration?**
CLI-based setup is preferred because it: (1) eliminates human error in copying API keys and editing config files, (2) supports all platforms in a single command, (3) keeps configurations version-aligned, and (4) makes it easy to reconfigure when switching Firebase projects or adding new platforms. For team projects, it ensures every developer has consistent Firebase configuration.

---

## Firestore Data Model Design (LibConnect)

### 1) How Firestore Stores Data
Firestore is a NoSQL, document-oriented database organized as:
- **Collections**: top-level containers
- **Documents**: key-value records inside collections
- **Subcollections**: nested collections under a document for scalable one-to-many data

General pattern:
```
users (collection)
 └── userId (document)
       ├── name: "Asha"
       ├── email: "asha@example.com"
       └── reservations (subcollection)
             └── reservationId (document)
```

### 2) Data Requirements List
LibConnect needs to store:
- Users (reader + librarian roles)
- User profiles
- Books (catalog + availability)
- Reservations (hold requests)
- Borrow records (issued/returned books)
- Favorites (saved books)
- App notes/tasks demo data (existing learning modules)

### 3) Firestore Schema (Core)

#### A. `users` (collection)
Document ID: `uid` (Firebase Auth UID)

Fields:
- `fullName`: string
- `email`: string
- `role`: string (`reader` | `librarian`)
- `phoneNumber`: string?
- `createdAt`: timestamp
- `updatedAt`: timestamp

Sample:
```json
{
  "fullName": "Asha Nair",
  "email": "asha@example.com",
  "role": "reader",
  "phoneNumber": "+91-9876543210",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

Subcollections under `users/{uid}`:

1) `favorites`
- Document ID: `bookId` (same as book doc for quick lookup)
- Fields:
  - `bookId`: string
  - `addedAt`: timestamp

2) `notifications` (optional but scalable)
- Document ID: auto ID
- Fields:
  - `type`: string (`reservationApproved`, `dueReminder`, etc.)
  - `message`: string
  - `isRead`: bool
  - `createdAt`: timestamp

#### B. `books` (collection)
Document ID: auto ID or ISBN-based custom ID (if guaranteed unique)

Fields:
- `title`: string
- `author`: string
- `isbn`: string
- `genre`: string
- `totalCopies`: number
- `availableCopies`: number
- `shelfLocation`: string
- `coverImageUrl`: string?
- `keywords`: array<string>
- `createdAt`: timestamp
- `updatedAt`: timestamp

Sample:
```json
{
  "title": "The Alchemist",
  "author": "Paulo Coelho",
  "isbn": "9780061122415",
  "genre": "Fiction",
  "totalCopies": 8,
  "availableCopies": 3,
  "shelfLocation": "A-12",
  "coverImageUrl": "https://...",
  "keywords": ["fiction", "inspiration"],
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

Subcollection under `books/{bookId}`:

`reviews` (if enabled later)
- Document ID: auto ID
- Fields:
  - `userId`: string
  - `rating`: number
  - `comment`: string
  - `createdAt`: timestamp

#### C. `reservations` (collection)
Document ID: auto ID

Fields:
- `userId`: string (reference key)
- `bookId`: string (reference key)
- `status`: string (`pending` | `approved` | `cancelled` | `fulfilled`)
- `reservedAt`: timestamp
- `expiresAt`: timestamp
- `updatedAt`: timestamp

Sample:
```json
{
  "userId": "uid_123",
  "bookId": "book_456",
  "status": "pending",
  "reservedAt": "serverTimestamp",
  "expiresAt": "2026-03-05T10:00:00Z",
  "updatedAt": "serverTimestamp"
}
```

#### D. `borrowRecords` (collection)
Document ID: auto ID

Fields:
- `userId`: string
- `bookId`: string
- `issuedAt`: timestamp
- `dueAt`: timestamp
- `returnedAt`: timestamp?
- `fineAmount`: number
- `status`: string (`issued` | `returned` | `overdue`)
- `createdAt`: timestamp
- `updatedAt`: timestamp

Sample:
```json
{
  "userId": "uid_123",
  "bookId": "book_456",
  "issuedAt": "2026-02-20T09:00:00Z",
  "dueAt": "2026-03-06T09:00:00Z",
  "returnedAt": null,
  "fineAmount": 0,
  "status": "issued",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

#### E. Existing demo collections in current code
From `lib/services/firestore_service.dart`:

1) `tasks`
- `title`: string
- `createdAt`: timestamp

2) `notes`
- `text`: string
- `createdAt`: timestamp

### 4) When to Use Subcollections
Use subcollections in this app when:
- Child data can grow large per parent (`users/{uid}/notifications`)
- Data naturally belongs to a parent (`users/{uid}/favorites`)
- You need focused real-time listeners without loading full parent documents

Avoid storing large, frequently updated arrays (for example a huge `favoriteBookIds` array) in a single document.

### 5) Field Design Guidelines (Applied)
- Field naming uses `lowerCamelCase`
- Types are explicit: `string`, `number`, `bool`, `array`, `timestamp`
- Keep nested maps shallow for easier queries and maintenance
- Include lifecycle timestamps in all mutable docs:
  - `createdAt: FieldValue.serverTimestamp()`
  - `updatedAt: FieldValue.serverTimestamp()`
- Document IDs:
  - Use auto IDs for transactions (`reservations`, `borrowRecords`)
  - Use meaningful IDs where useful (`users/{uid}`, `favorites/{bookId}`)

### 6) Visual Schema Diagram (Mermaid)
```mermaid
flowchart TD
  U[users]
  UDOC[(users/{uid})]
  UFAV[users/{uid}/favorites]
  UFAVDOC[(favorites/{bookId})\nbookId:string\naddedAt:timestamp]
  UNOTI[users/{uid}/notifications]
  UNOTIDOC[(notifications/{notificationId})\ntype:string\nmessage:string\nisRead:bool\ncreatedAt:timestamp]

  B[books]
  BDOC[(books/{bookId})\ntitle:string\nauthor:string\nisbn:string\ngenre:string\ntotalCopies:number\navailableCopies:number\ncreatedAt:timestamp\nupdatedAt:timestamp]
  BREV[books/{bookId}/reviews]
  BREVDOC[(reviews/{reviewId})\nuserId:string\nrating:number\ncomment:string\ncreatedAt:timestamp]

  R[reservations]
  RDOC[(reservations/{reservationId})\nuserId:string\nbookId:string\nstatus:string\nreservedAt:timestamp\nexpiresAt:timestamp\nupdatedAt:timestamp]

  BR[borrowRecords]
  BRDOC[(borrowRecords/{recordId})\nuserId:string\nbookId:string\nissuedAt:timestamp\ndueAt:timestamp\nreturnedAt:timestamp?\nfineAmount:number\nstatus:string\ncreatedAt:timestamp\nupdatedAt:timestamp]

  T[tasks]
  TDOC[(tasks/{taskId})\ntitle:string\ncreatedAt:timestamp]
  N[notes]
  NDOC[(notes/{noteId})\ntext:string\ncreatedAt:timestamp]

  U --> UDOC
  UDOC --> UFAV --> UFAVDOC
  UDOC --> UNOTI --> UNOTIDOC
  B --> BDOC
  BDOC --> BREV --> BREVDOC
  R --> RDOC
  BR --> BRDOC
  T --> TDOC
  N --> NDOC

  RDOC -. references .-> UDOC
  RDOC -. references .-> BDOC
  BRDOC -. references .-> UDOC
  BRDOC -. references .-> BDOC
```

### 7) Schema Validation Checklist
- [x] Structure matches current and planned app requirements
- [x] Scales for large user/book transaction volumes
- [x] Related data grouped logically by feature/domain
- [x] Subcollections used where high growth is expected
- [x] Field names/types are consistent and query-friendly
- [x] Schema is understandable for new team members

---

## Firestore Real-Time Listeners & StreamBuilder

This section demonstrates how to implement real-time data synchronization using Firestore snapshot listeners and Flutter's `StreamBuilder` widget. Real-time updates are critical for modern applications like chat apps, live dashboards, and inventory management systems.

### 1. Why Real-Time Sync Matters

Real-time synchronization improves user experience by:
- **Eliminating Manual Refresh**: Users see updates instantly without pulling down to refresh
- **Multi-User Collaboration**: Changes from other users appear instantly
- **Live Notifications**: Status updates, new messages, or inventory changes trigger UI updates immediately
- **Reduced Server Load**: Firestore efficiently handles multiple concurrent listeners
- **Better Engagement**: Live feeds and dashboards keep users engaged

### 2. Firestore Snapshot Listeners Overview

Firestore provides two types of snapshot listeners:

#### a) Collection Snapshots (Real-Time Collection Updates)

Listens to all documents in a collection and triggers whenever any document is added, updated, or deleted.

**Code Example:**
```dart
FirebaseFirestore.instance
  .collection('tasks')
  .snapshots();  // Returns Stream<QuerySnapshot>
```

**Triggers When:**
- A new document is added to the collection
- An existing document's field is updated
- A document is deleted from the collection
- Multiple rapid changes occur (batched updates)

**Use Cases:**
- Task management lists
- Real-time chat messages
- Live notification feeds
- Inventory updates

#### b) Document Snapshots (Real-Time Single Document Updates)

Listens to a specific document and triggers whenever any field in that document is updated.

**Code Example:**
```dart
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .snapshots();  // Returns Stream<DocumentSnapshot>
```

**Triggers When:**
- Any field in the document is modified
- Server-side values update (e.g., server timestamps)
- Nested objects within the document change

**Use Cases:**
- User profile live updates
- Live status indicators (online/offline)
- Dashboard values and analytics
- Real-time counter updates

### 3. Using StreamBuilder for Reactive UI

`StreamBuilder` is a Flutter widget that listens to a stream and rebuilds the UI whenever new data arrives. This is the primary way to display real-time Firestore data.

#### Basic StreamBuilder Structure

```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
    .collection('messages')
    .snapshots(),
  builder: (context, snapshot) {
    // Handle different connection states
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    
    // Check for errors
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    
    // Check for data
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Text('No data available');
    }
    
    // Display data
    final docs = snapshot.data!.docs;
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(docs[index]['text']),
        );
      },
    );
  },
);
```

### 4. Real-Time Collection Listener Example

This example shows a live chat-like interface where messages appear instantly:

```dart
StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  stream: FirebaseFirestore.instance
    .collection('messages')
    .orderBy('createdAt', descending: true)
    .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(child: Text('No messages yet'));
    }
    
    final messages = snapshot.data!.docs;
    
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return ListTile(
          title: Text(msg['text']),
          subtitle: Text(
            msg['createdAt'].toDate().toString(),
          ),
        );
      },
    );
  },
);
```

**How It Works:**
1. **`.snapshots()`** returns a Stream that emits a new `QuerySnapshot` whenever the collection changes
2. **`StreamBuilder`** listens to this stream
3. When new data arrives, the `builder` function is called with the latest snapshot
4. The UI rebuilds automatically with the new data
5. Each message appears in real-time without manual refresh

### 5. Real-Time Document Listener Example

This example shows how to listen to a single user's profile for live updates:

```dart
StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
  stream: FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Text('Loading...');
    }
    
    if (!snapshot.hasData || !snapshot.data!.exists) {
      return const Text('User not found');
    }
    
    final userData = snapshot.data!.data()!;
    
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(userData['avatarUrl']),
        ),
        Text('Name: ${userData['name']}'),
        Text('Status: ${userData['status']}'),
        Text('Last Updated: ${userData['lastUpdated']}'),
      ],
    );
  },
);
```

**Useful For:**
- **Live User Profiles**: Name, avatar, bio updates
- **Status Indicators**: Online/offline status that updates in real-time
- **Dashboard Values**: Live analytics, counts, balances
- **Settings Sync**: User preferences that change across devices

### 6. Handling Loading, Error, and Empty States

Proper state management ensures your app never crashes:

```dart
StreamBuilder(
  stream: _firestoreService.getTasks(),
  builder: (context, snapshot) {
    // Loading state - connection waiting
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // Error state
    if (snapshot.hasError) {
      return Center(
        child: Text(
          'Error: ${snapshot.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    
    // Empty state
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Text('No tasks available'),
      );
    }
    
    // Success state - display data
    final tasks = snapshot.data!.docs;
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(tasks[index]['title']),
        );
      },
    );
  },
);
```

### 7. Listening to Changes Manually (Advanced)

For complex scenarios requiring custom logic, use `.listen()` instead of StreamBuilder:

```dart
FirebaseFirestore.instance
  .collection('tasks')
  .snapshots()
  .listen((snapshot) {
    for (var change in snapshot.docChanges) {
      switch (change.type) {
        case DocumentChangeType.added:
          print('New task: ${change.doc['title']}');
          // Show notification, animate, etc.
          break;
        case DocumentChangeType.modified:
          print('Task updated: ${change.doc['title']}');
          break;
        case DocumentChangeType.removed:
          print('Task deleted');
          break;
      }
    }
  });
```

**Useful For:**
- Triggering push notifications when messages arrive
- Playing sounds for real-time events
- Auto-scrolling chat to newest messages
- Logging activity events
- Triggering animations or haptic feedback

### 8. Implementation in FirestoreRealtimeDemo Screen

The app includes a comprehensive demo at `/firestore-realtime` that showcases:

**Features:**
- ✅ **Add tasks** that appear instantly in the real-time list
- ✅ **Real-time collection listener** using `StreamBuilder` with proper state handling
- ✅ **Delete tasks** which instantly disappear from the list
- ✅ **Single document listener example** with code snippets
- ✅ **Error handling** for failed operations
- ✅ **Loading states** for better UX
- ✅ **Timestamp formatting** showing when each task was created

**To Access the Demo:**
```dart
// In main.dart, navigate using:
Navigator.pushNamed(context, '/firestore-realtime');

// Or directly:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FirestoreRealtimeDemo(),
  ),
);
```

### 9. Testing Real-Time Sync

Follow these steps to verify real-time updates work correctly:

#### Test in Firebase Console:

1. **Add a Document**
   - Open Firebase Console → Firestore Database
   - Go to `tasks` collection
   - Add a new document with: `{ title: "Test Task", description: "Testing", createdAt: timestamp }`
   - Expected: Task appears in app UI instantly without refreshing

2. **Update a Document**
   - Click an existing task document
   - Change the `title` field to something new
   - Expected: Title updates in app UI instantly

3. **Delete a Document**
   - Select a document and click Delete
   - Expected: Task disappears from app UI instantly

4. **Rapid Changes**
   - Make multiple rapid changes in console
   - Expected: App stays consistent, no missing or duplicate items

#### Test in App:

1. **Add Task via UI**
   - Enter title and description
   - Click "Add Task"
   - Expected: Task appears in list immediately with correct timestamp

2. **Delete Task via UI**
   - Click delete icon on a task
   - Expected: Task disappears instantly, no lag

3. **Multiple Instances**
   - Open app on multiple devices/emulators
   - Add/delete tasks on one device
   - Expected: All devices see updates instantly (true real-time sync)

### 10. Challenges & Solutions

**Challenge 1: Too Many Listeners**
- Problem: Creating multiple StreamBuilders for the same collection causes redundant listeners
- Solution: Use `StreamProvider` from the `provider` package or restructure listeners at a higher widget level

**Challenge 2: Slow Performance with Large Collections**
- Problem: Listening to thousands of documents causes memory and performance issues
- Solution: Use pagination or query filters like `.limit(20)` and `.orderBy()`

**Challenge 3: Handling Offline Mode**
- Problem: Listeners might fail if network is unavailable
- Solution: Check `snapshot.connectionState` and show offline indicator

**Challenge 4: Uncontrolled Rebuilds**
- Problem: StreamBuilder rebuilds on every update, even for unchanged data
- Solution: Use `const` constructors and extract complex widgets to separate classes to limit rebuilds

### 11. Code Implementation Summary

**Key Files:**
- **lib/screens/firestore_realtime_demo.dart** - Full demo with collection and document listeners
- **lib/services/firestore_service.dart** - Service methods like `getTasks()` that return Streams
- **lib/main.dart** - Route registration for `/firestore-realtime`

**Service Methods Used:**
```dart
// Collection snapshot listener
Stream<QuerySnapshot<Map<String, dynamic>>> getTasks() {
  return tasks.orderBy('createdAt', descending: true).snapshots();
}

// Single task by ID (document listener)
Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String userId) {
  return users.doc(userId).get();
}
```

### 12. Reflection: Why Real-Time Matters for LibConnect

For LibConnect's library management use case:

**Before Real-Time Sync:**
- Users manually refresh to see if a book became available
- Librarians don't know if reserved books are picked up
- Notification delays cause user frustration

**After Real-Time Sync:**
- Users see instant updates when books are reserved/available
- Librarians see immediate feedback when actions occur
- Notifications trigger instantly when relevant
- Multi-device sync means consistent data everywhere

**Key Takeaway:** Firestore's `.snapshots()` method combined with `StreamBuilder` transforms a static app into a dynamic, responsive system. By understanding when to use collection vs. document listeners, and properly handling loading/error states, we create seamless user experiences that feel instant and always up-to-date.

---

## Firestore Queries: Filtering, Sorting, and Limiting Data

This section demonstrates how to write efficient Firestore queries to fetch only relevant data. Queries are essential for scalability — instead of fetching all documents and filtering in-app, we let Firestore do the heavy lifting on the backend.

### 1. Why Firestore Queries Matter

Efficient queries reduce:
- **Network Bandwidth**: Only fetch data you need
- **App Memory**: Don't load unnecessary documents
- **Processing Time**: Server-side filtering is faster
- **Costs**: Firebase charges per read; fewer documents = lower costs

**Real-World Impact:**
- Without queries: Fetch 10,000 books → Filter in app → Slow, memory-heavy
- With queries: Fetch only books matching criteria → Fast, efficient

### 2. Basic Query Structure

A Firestore query has this pattern:

```dart
FirebaseFirestore.instance
  .collection('productName')           // Target collection
  .where('fieldName', isEqualTo: value)    // Filter
  .orderBy('fieldName')                // Sort
  .limit(10);                          // Limit results
```

**Each part is optional:**
- Queries work without filters, sorting, or limits
- Chain multiple methods for complex queries

### 3. Filters with where() Clauses

Filters narrow down documents based on field values.

#### a) Equality Filter

```dart
FirebaseFirestore.instance
  .collection('tasks')
  .where('status', isEqualTo: 'active')
  .snapshots();
```

**Use Cases:** Status, category, user ID filtering

#### b) Comparison Filters

```dart
// Greater than
.where('price', isGreaterThan: 100)
// Less than or equal
.where('age', isLessThanOrEqualTo: 18)
// Range query
.where('year', isGreaterThanOrEqualTo: 2020)
.where('year', isLessThan: 2024)
```

**Use Cases:** Price ranges, date ranges, rating thresholds

#### c) Array Contains Filter

```dart
FirebaseFirestore.instance
  .collection('products')
  .where('tags', arrayContains: 'popular')
  .snapshots();
```

**Use Cases:** Multi-tag filtering, role-based access

#### d) In Filter

```dart
FirebaseFirestore.instance
  .collection('users')
  .where('status', whereIn: ['active', 'pending'])
  .snapshots();
```

**Use Cases:** Multiple status/category selection

### 4. Sorting with orderBy()

Order results by a specific field.

```dart
// Ascending (default)
.orderBy('priority')

// Descending
.orderBy('createdAt', descending: true)

// Multiple fields
.orderBy('grade', descending: true)
.orderBy('name')
```

**Use Cases:** Sort by date, price, rating; multi-level sorting

### 5. Limiting Results with limit()

Fetch only a subset of documents:

```dart
.limit(10)  // Fetch maximum 10 documents
```

**Why limit()?**
- ❌ Bad: Fetch all 100,000 books → Filter in app
- ✅ Good: Fetch only first 20 via query

**Pagination:**
```dart
var page1 = await collection
  .orderBy('date')
  .limit(20)
  .get();

var page2 = await collection
  .orderBy('date')
  .startAfter(page1.docs.last)
  .limit(20)
  .get();
```

### 6. Chaining Queries for Power

Combine multiple operations:

```dart
FirebaseFirestore.instance
  .collection('tasks')
  .where('isCompleted', isEqualTo: false)        // Filter 1
  .where('priority', isGreaterThan: 2)           // Filter 2
  .orderBy('priority', descending: true)         // Sort
  .limit(10)                                     // Limit
  .snapshots();
```

### 7. Displaying Query Results with StreamBuilder

Real-time filtered/sorted lists:

```dart
StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  stream: FirebaseFirestore.instance
    .collection('tasks')
    .where('isCompleted', isEqualTo: false)
    .orderBy('priority', descending: true)
    .limit(20)
    .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    if (snapshot.data!.docs.isEmpty) return Text('No tasks found');

    return ListView.builder(
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        final task = snapshot.data!.docs[index];
        return ListTile(
          title: Text(task['title']),
          subtitle: Text('Priority: ${task['priority']}'),
        );
      },
    );
  },
);
```

**Key Points:**
- Query results update in real-time
- Only matching documents appear
- No post-filtering needed

### 8. Common Query Mistakes to Avoid

**❌ Mistake 1: orderBy on unindexed field combinations**
```dart
.where('status', isEqualTo: 'active')
.orderBy('createdAt')  // Requires composite index
```

**❌ Mistake 2: Too many filters**
```dart
.where('status', isEqualTo: 'active')
.where('age', isGreaterThan: 18)
.where('country', isEqualTo: 'US')
.where('verified', isEqualTo: true)  // Getting complex!
```

**❌ Mistake 3: Querying unindexed fields**
```dart
.where('description', isEqualTo: 'something')  // Slow without index
```

**❌ Mistake 4: Not using limit()**
```dart
// ❌ Fetches 100,000 docs
.collection('messages').snapshots()

// ✅ Fetch only recent 50
.orderBy('timestamp', descending: true).limit(50)
```

**❌ Mistake 5: Filtering in app code**
```dart
// ❌ Download all, filter in app
final filtered = allDocs.where((d) => d['status'] == 'active').toList();

// ✅ Filter at database level
.where('status', isEqualTo: 'active')
```

### 9. Implementation in FirestoreQueriesDemo Screen

The app includes a comprehensive query demo at `/firestore-queries` that showcases:

**Interactive Features:**
- ✅ **Filter Control**: Toggle between incomplete/completed tasks
- ✅ **Sort Control**: Switch between ascending/descending  
- ✅ **Limit Control**: Slider to adjust result limit (5-50)
- ✅ **Real-Time Results**: StreamBuilder shows filtered/sorted results instantly
- ✅ **Query Breakdown**: Visual display of current query structure

**To Access:**
```dart
Navigator.pushNamed(context, '/firestore-queries');
```

### 10. Query Performance Tips

**1. Always use indexes for where() + orderBy()**
- Create index in Firebase Console
- Then chain confidently

**2. Limit early, paginate later**
- Use `.limit(20)` not 1000
- Implement pagination for next pages

**3. Order by indexed fields**
- Good: `createdAt`, `price`, `rating`
- Avoid: `description`, `notes`

**4. Combine related filters**
- `status`, `whereIn: ['active', 'pending']` (one query)
- Not separate queries for each status

**5. Cache results locally**
- Fetch once, reuse multiple times
- Reduces Firebase reads/costs

### 11. Code Implementation Summary

**Key Files:**
- [lib/screens/firestore_queries_demo.dart](lib/screens/firestore_queries_demo.dart) - Interactive demo
- [lib/main.dart](lib/main.dart) - Route registration
- [lib/services/firestore_service.dart](lib/services/firestore_service.dart) - Service methods

**Service Integration:**
```dart
Query<Map<String, dynamic>> _buildQuery() {
  Query<Map<String, dynamic>> query = _firestoreService.tasks;
  query = query.where('isCompleted', isEqualTo: _filterCompleted);
  query = query.orderBy('createdAt', descending: _sortDescending);
  query = query.limit(_limitValue);
  return query;
}

stream: _buildQuery().snapshots()
```

### 12. Query Examples by Use Case

**Email Search:**
```dart
.where('email', isEqualTo: userEmail).get()
```

**Recent Posts (Last 10):**
```dart
.orderBy('timestamp', descending: true).limit(10).snapshots()
```

**Price Range:**
```dart
.where('price', isGreaterThanOrEqualTo: minPrice)
.where('price', isLessThanOrEqualTo: maxPrice)
.orderBy('price')
```

**Tagged Items:**
```dart
.where('tags', arrayContains: selectedTag)
.orderBy('rating', descending: true)
.limit(20)
```

### 13. Reflection: Queries in LibConnect

**Without Queries (Inefficient):**
- Download all 10,000 books
- Filter in app code
- Slow, memory-heavy

**With Queries (Efficient):**
```dart
FirebaseFirestore.instance
  .collection('books')
  .where('availableCopies', isGreaterThan: 0)
  .orderBy('rating', descending: true)
  .limit(20)
  .snapshots();
```

**Benefits:**
- Load time: 5 sec → 500ms
- Bandwidth: 10,000 books → 20 books
- Cost: 10,000 reads → 20 reads
- UX: Instant, snappy

**Key Takeaway:** Firestore queries distribute filtering to the backend, reduce app complexity, and enable lightning-fast user experiences. Always filter at the database level!

---

## Firebase Storage: Uploading, Managing, and Displaying Files

This section demonstrates how to implement file uploads, downloads, and management using Firebase Cloud Storage.

### 1. Why Firebase Storage Matters

Firebase Storage provides:
- **Scalable Media Hosting**: Unlimited files with automatic scaling
- **Fast CDN Distribution**: Files served globally
- **Security Rules**: Control upload/download access
- **Progress Tracking**: Monitor upload status
- **Cost-Effective**: Pay-as-you-go pricing

### 2. Uploading Files

```dart
Future<String> uploadImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (pickedFile == null) return '';

  try {
    final File file = File(pickedFile.path);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    
    final Reference ref = FirebaseStorage.instance
        .ref("uploads/user_images/$fileName.jpg");
    
    await ref.putFile(file);
    return await ref.getDownloadURL();
  } catch (e) {
    print('Upload failed: $e');
    return '';
  }
}
```

### 3. Getting Download URLs

```dart
String downloadURL = await FirebaseStorage.instance
    .ref("uploads/user_images/photo_123.jpg")
    .getDownloadURL();
```

### 4. Displaying Images with Error Handling

```dart
Image.network(
  downloadURL,
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.broken_image);
  },
)
```

### 5. Deleting Files

```dart
Future<void> deleteFile(String storagePath) async {
  try {
    await FirebaseStorage.instance.ref(storagePath).delete();
  } catch (e) {
    print('Delete failed: $e');
  }
}
```

### 6. Upload Progress Tracking

```dart
final UploadTask uploadTask = ref.putFile(file);

uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
  double progress = snapshot.bytesTransferred / snapshot.totalBytes;
  print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
});
```

### 7. Firebase Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Require authentication for uploads
    match /uploads/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Validate file types
    match /uploads/{allPaths=**} {
      allow write: if request.resource.contentType.matches('image/.*');
    }
    
    // Limit file size (1 MB)
    match /uploads/{allPaths=**} {
      allow write: if request.resource.size < 1 * 1024 * 1024;
    }
  }
}
```

### 8. StorageService Implementation

The app includes a complete service at [lib/services/storage_service.dart](lib/services/storage_service.dart) with methods:

- `uploadFile()` - Upload file to Firebase
- `uploadFileWithMetadata()` - Upload with metadata
- `getDownloadUrl()` - Get public URL
- `deleteFile()` - Remove files
- `getFileMetadata()` - Get file info
- `listFiles()` - List files in folder
- `generateUniqueFileName()` - Create unique names
- `isFileSizeValid()` - Validate before upload

### 9. Firebase Storage Demo

Access the demo at `/firebase-storage`:

**Features:**
- Image picker (gallery/camera)
- File upload to Firebase
- Display uploaded images
- Delete files with confirmation
- Upload progress tracking
- Error handling

### 10. Common Mistakes to Avoid

**❌ No Size Validation**
```dart
// BAD
await ref.putFile(file);

// GOOD
if (!storageService.isFileSizeValid(filePath, 10)) {
  throw Exception('File too large');
}
```

**❌ No Error Handling**
```dart
// BAD
final url = await ref.putFile(file).then(...);

// GOOD
try {
  final url = await ref.putFile(file).then(...);
} catch (e) {
  showErrorMessage('Upload failed: $e');
}
```

**❌ Storing Paths Instead of URLs**
```dart
// BAD - Path may change
await db.update({'photo': 'uploads/photo.jpg'});

// GOOD - Store download URL
final url = await ref.getDownloadURL();
await db.update({'photo': url});
```

### 11. Complete Workflow

```dart
// 1. Pick file
final XFile? file = await picker.pickImage(source: ImageSource.gallery);

// 2. Upload
final url = await storageService.uploadFile(
  folderPath: 'uploads/user_images/',
  fileName: 'profile.jpg',
  filePath: file!.path,
);

// 3. Store URL in Firestore
await firestore.collection('users').doc(uid).update({'avatar': url});

// 4. Display
Image.network(url)
```

### 12. File Organization

Structure storage logically:

```
gs://bucket-name/
├── user_profiles/{userId}/profile.jpg
├── book_covers/{bookId}/cover.jpg
├── documents/{userId}/backup.pdf
└── temp/{sessionId}/upload.jpg
```

### 13. Key Takeaway

Firebase Storage handles file management complexity — scaling, security, CDN distribution. Always:
- Validate file size before upload
- Use security rules to prevent unauthorized access
- Store download URLs in Firestore, not file paths
- Handle errors gracefully with Loading/Error states

---

## Cloud Functions: Callable and Event-Based Serverless Logic

This section demonstrates how to implement serverless backend logic using Firebase Cloud Functions, including callable functions (invoked from Flutter) and event-triggered functions (Firestore/Auth triggers).

### 1. Why Cloud Functions Matter

Cloud Functions provide:
- **Serverless Compute**: No servers to manage
- **Auto-Scaling**: Handle any load automatically
- **Security**: Server-side validation and logic
- **Cost-Effective**: Pay only for execution
- **Integration**: Call third-party APIs safely
- **Reliability**: Automatic retries and error handling

### 2. Understanding Function Types

**Callable Functions** — Invoked directly from Flutter app:
```dart
final callable = FirebaseFunctions.instance.httpsCallable('sayHello');
final result = await callable.call({'name': 'Alex'});
```

**Firestore Triggers** — Run automatically when data changes:
```javascript
exports.newUserCreated = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    // Send welcome email, create profile, etc.
  });
```

**Auth Triggers** — Run when user accounts change:
```javascript
exports.welcomeNewUser = functions.auth
  .user()
  .onCreate(async (user) => {
    // Send welcome email to user
  });
```

**HTTP Functions** — Web endpoints for webhooks:
```javascript
exports.webhook = functions.https.onRequest((req, res) => {
  return res.json({ message: 'Received!' });
});
```

### 3. Prerequisites: Install Firebase Tools

```bash
# Install Node.js (if not already installed)
# Download from https://nodejs.org/

# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Navigate to your project directory
cd your_flutter_project
```

### 4. Initialize Cloud Functions

```bash
# From your Flutter project root
firebase init functions

# Choose:
# - Language: JavaScript or TypeScript
# - ESLint: Yes (for code quality)
# - npm install: Yes
```

This creates a `functions/` directory with:

```
functions/
├── index.js       (Main function code)
├── package.json   (Dependencies)
└── .eslintrc.json (Linting rules)
```

### 5. Creating a Simple Callable Function

**Backend (functions/index.js):**

```javascript
const functions = require('firebase-functions');

exports.sayHello = functions.https.onCall((data, context) => {
  const name = data.name || 'Guest';
  return {
    message: `Hello, ${name}! Welcome to LibConnect.`,
    timestamp: new Date().toISOString(),
  };
});
```

**Flutter Code:**

```dart
Future<void> callSayHello() async {
  try {
    final callable = FirebaseFunctions.instance.httpsCallable('sayHello');
    final result = await callable.call({'name': 'Alex'});
    
    print('Result: ${result.data['message']}');
    // Output: Hello, Alex! Welcome to LibConnect.
  } on FirebaseFunctionsException catch (e) {
    print('Error: ${e.message}');
  }
}
```

### 6. Returning Complex Data from Functions

**Backend (functions/index.js):**

```javascript
exports.getUserData = functions.https.onCall(async (data, context) => {
  const userId = data.userId;
  
  // Get user from Firestore
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();
  
  return {
    success: true,
    user: userDoc.data(),
    totalBooks: userDoc.data()?.books?.length || 0,
  };
});
```

**Flutter Code:**

```dart
final result = await callable.call({'userId': user.uid});
final userData = result.data['user'];
final bookCount = result.data['totalBooks'];
```

### 7. Error Handling in Cloud Functions

**Backend (functions/index.js):**

```javascript
exports.validateEmail = functions.https.onCall((data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be logged in to validate email'
    );
  }
  
  const email = data.email;
  if (!email.includes('@')) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Email must contain @ symbol'
    );
  }
  
  return { valid: true };
});
```

**Flutter Code:**

```dart
try {
  await callable.call({'email': 'user@example.com'});
} on FirebaseFunctionsException catch (e) {
  if (e.code == 'unauthenticated') {
    print('Please log in first');
  } else if (e.code == 'invalid-argument') {
    print('Invalid email format');
  }
}
```

### 8. Firestore Trigger Functions

**Backend (functions/index.js) — Event-Triggered:**

```javascript
// When a new user document is created
exports.newUserCreated = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    const userData = snap.data();
    
    // Send welcome email
    const nodemailer = require('nodemailer');
    const transporter = nodemailer.createTransport({
      // Configure email provider
    });
    
    await transporter.sendMail({
      to: userData.email,
      subject: 'Welcome to LibConnect!',
      html: `<h1>Welcome ${userData.name}!</h1>`,
    });
    
    // Create user profile document
    await snap.ref.parent.doc(userId).update({
      displayName: userData.name,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isNewUser: true,
    });
  });

// When a user document is updated
exports.userUpdated = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    
    console.log('User updated:', {
      before: beforeData,
      after: afterData,
    });
  });

// When a user document is deleted
exports.userDeleted = functions.firestore
  .document('users/{userId}')
  .onDelete(async (snap, context) => {
    const userId = context.params.userId;
    console.log('User deleted:', userId);
  });
```

**Flutter Code — Listening to Changes:**

```dart
// Listen to Firestore to see effects of trigger functions
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .snapshots()
  .listen((snapshot) {
    if (snapshot.exists) {
      final createdAt = snapshot['createdAt'];
      print('User created at: $createdAt'); // Set by trigger function
    }
  });
```

### 9. Publishing and Deploying Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:sayHello

# Deploy with different regions
firebase deploy --only functions --region us-central1,europe-west1
```

### 10. Viewing Function Logs

**Option 1: Firebase Console**

```
https://console.firebase.google.com/functions/logs?project=your-project-id
```

**Option 2: Terminal**

```bash
firebase functions:log
```

**Option 3: Using SDK in Code**

```dart
String logsUrl = 'https://console.firebase.google.com/functions/logs?project=$projectId';
```

### 11. Local Testing with Emulator

**Backend (functions/index.js):**

```javascript
exports.testWithData = functions.https.onCall((data, context) => {
  return { 
    received: data,
    executedLocally: true 
  };
});
```

**Terminal:**

```bash
firebase emulators:start --only functions
```

**Flutter Code:**

```dart
// Connect to emulator
FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

final result = await callable.call({'test': 'data'});
```

### 12. Common Use Cases

**E-Commerce Order Processing:**

```javascript
exports.processOrder = functions.https.onCall(async (data, context) => {
  const orderId = data.orderId;
  const paymentIntent = await stripe.paymentIntents.create({
    amount: data.amount,
    currency: 'usd',
  });
  
  await admin.firestore()
    .collection('orders')
    .doc(orderId)
    .update({ paymentIntentId: paymentIntent.id });
  
  return { success: true };
});
```

**PDF Generation:**

```javascript
exports.generateInvoice = functions.https.onCall(async (data, context) => {
  const PDFDocument = require('pdfkit');
  const pdf = new PDFDocument();
  
  // Create invoice PDF
  pdf.fontSize(25).text('Invoice');
  
  const buffer = await new Promise((resolve) => {
    pdf.on('finish', () => resolve(pdf.getBuffer()));
    pdf.end();
  });
  
  // Upload to Storage
  await admin.storage()
    .bucket()
    .file(`invoices/${data.invoiceId}.pdf`)
    .save(buffer);
  
  return { success: true };
});
```

**Data Synchronization:**

```javascript
exports.syncBookRatings = functions.https.onCall(async (data, context) => {
  // Get all book reviews
  const reviews = await admin.firestore()
    .collection('reviews')
    .get();
  
  // Calculate average rating
  const bookRatings = {};
  reviews.docs.forEach(doc => {
    const bookId = doc.data().bookId;
    const rating = doc.data().rating;
    
    if (!bookRatings[bookId]) {
      bookRatings[bookId] = { sum: 0, count: 0 };
    }
    bookRatings[bookId].sum += rating;
    bookRatings[bookId].count += 1;
  });
  
  // Update book documents
  for (const [bookId, data] of Object.entries(bookRatings)) {
    await admin.firestore()
      .collection('books')
      .doc(bookId)
      .update({
        averageRating: data.sum / data.count,
        totalReviews: data.count,
      });
  }
  
  return { success: true, processed: Object.keys(bookRatings).length };
});
```

### 13. Best Practices

**✓ Always Validate Input**

```javascript
// BAD
exports.updateProfile = functions.https.onCall((data) => {
  return admin.firestore()
    .collection('users')
    .doc(data.userId)
    .update(data); // Any data!
});

// GOOD
exports.updateProfile = functions.https.onCall((data) => {
  if (!data.userId || !data.name) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'userId and name are required'
    );
  }
  
  return admin.firestore()
    .collection('users')
    .doc(data.userId)
    .update({ name: data.name }); // Only name
});
```

**✓ Authenticate Sensitive Operations**

```javascript
exports.deleteUserData = functions.https.onCall((data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be logged in'
    );
  }
  
  // Verify user is deleting their own data
  if (context.auth.uid !== data.userId) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Cannot delete other user data'
    );
  }
  
  return admin.firestore()
    .collection('users')
    .doc(data.userId)
    .delete();
});
```

**✓ Use Environment Variables**

```javascript
// In functions/.env.local
SENDGRID_API_KEY=your_key_here
STRIPE_SECRET_KEY=your_key_here

// In functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Load environment variables
const config = functions.config();
const sendgridKey = process.env.SENDGRID_API_KEY;
```

**✓ Handle Long-Running Operations**

```javascript
// Don't let function timeout
exports.processLargeDataset = functions.https.onCall(async (data) => {
  // Return confirmation immediately
  return { messageId: 'task_123', status: 'processing' };
});

// Use Cloud Tasks or background functions for heavy work
exports.processLargeDatasetBackground = functions
  .runWith({
    timeoutSeconds: 540, // 9 minutes max
    memory: '2GB',
  })
  .https.onCall(async (data, context) => {
    // Do heavy processing
  });
```

### 14. Common Mistakes to Avoid

**❌ Missing Authentication Check**

```javascript
// BAD - Anyone can delete data
exports.deleteData = functions.https.onCall(async (data) => {
  await admin.firestore()
    .collection('important')
    .doc(data.id)
    .delete();
});

// GOOD - Only logged-in users
exports.deleteData = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be logged in'
    );
  }
  const userId = context.auth.uid;
  // Verify ownership before deleting
});
```

**❌ Not Handling Network Errors**

```dart
// BAD - App crashes on error
final result = await callable.call(data);
print(result.data['message']);

// GOOD - Graceful error handling
try {
  final result = await callable.call(data);
  print(result.data['message']);
} on FirebaseFunctionsException catch (e) {
  print('Function error: ${e.code} - ${e.message}');
  showErrorDialog('Something went wrong. Please try again.');
} catch (e) {
  print('Network error: $e');
  showErrorDialog('Network connection failed.');
}
```

**❌ Exposing Sensitive information**

```javascript
// BAD - API keys visible in code
const stripe = require('stripe')('sk_live_12345');

// GOOD - Use environment variables
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
```

### 15. Integration with LibConnect

**Scenario 1: New User Signup**

```javascript
// Cloud Function - Listen to auth user creation
exports.setupNewUserProfile = functions.auth
  .user()
  .onCreate(async (user) => {
    // Create Firestore user document
    await admin.firestore()
      .collection('users')
      .doc(user.uid)
      .set({
        email: user.email,
        displayName: user.displayName || 'Anonymous',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        role: 'member',
        booksRead: 0,
        favoriteBooks: [],
      });
    
    // Send welcome email (via nodemailer or SendGrid)
    console.log(`Welcome email queued for ${user.email}`);
  });
```

**Scenario 2: Chat Message Notifications**

```javascript
// Cloud Function - Called when user sends message
exports.notifyNewMessage = functions.https.onCall(async (data, context) => {
  const userId = context.auth.uid;
  const recipientId = data.recipientId;
  const message = data.message;
  
  // Store message in Firestore
  await admin.firestore()
    .collection('messages')
    .add({
      senderId: userId,
      recipientId: recipientId,
      message: message,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  
  // Send push notification to recipient
  const recipientToken = (await admin.firestore()
    .collection('users')
    .doc(recipientId)
    .get()).data().fcmToken;
  
  if (recipientToken) {
    await admin.messaging().send({
      token: recipientToken,
      notification: {
        title: 'New Message',
        body: message.substring(0, 50),
      },
    });
  }
  
  return { success: true };
});
```

**Scenario 3: Book Rating Update**

```javascript
// Cloud Function - Triggered when rating is added
exports.updateBookRating = functions.firestore
  .document('books/{bookId}/ratings/{ratingId}')
  .onCreate(async (snap, context) => {
    const bookId = context.params.bookId;
    const ratingData = snap.data();
    
    // Get all ratings for this book
    const ratings = await admin.firestore()
      .collection('books')
      .doc(bookId)
      .collection('ratings')
      .get();
    
    // Calculate average
    const ratings = ratings.docs.map(d => d.data().score);
    const average = ratings.reduce((a, b) => a + b, 0) / ratings.length;
    
    // Update main book document
    await admin.firestore()
      .collection('books')
      .doc(bookId)
      .update({
        averageRating: average,
        totalRatings: ratings.length,
      });
  });
```

### 16. Monitoring and Debugging

**Check Function Performance:**

```bash
# View logs in terminal
firebase functions:log -n 50

# View specific function logs
firebase functions:log --only sayHello
```

**Monitor Costs:**

Cloud Functions pricing:
- First 2M invocations/month: FREE
- Each invocation: $0.40 per 1M calls
- Compute time: $0.0000166667 per GB-second

**Example:** 1 million function calls per month = $0

### 17. Key Takeaway

Cloud Functions move backend logic to the cloud:
- **Callable Functions** handle on-demand operations (form submissions, API calls)
- **Trigger Functions** automate workflows (welcome emails, data cleanup)
- **Secure Validation** happens server-side, not on client
- **Always Deploy** functions through Firebase CLI before testing
