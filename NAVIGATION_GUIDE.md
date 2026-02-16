# 🧭 Flutter Multi-Screen Navigation Guide

## Complete Guide to Navigation in Flutter

---

## 📱 What is Multi-Screen Navigation?

Most Flutter apps contain **multiple screens (pages)** that users navigate between — such as:
- Login → Dashboard
- Home → Settings
- Product List → Product Details

Flutter manages navigation using a **navigation stack** (like a stack of cards) through the **Navigator** class.

---

## 🎯 Navigation Concepts

### The Navigation Stack

Think of navigation as a **stack of screens**:

```
Third Screen   ← Top of stack (current screen)
Second Screen
Home Screen    ← Bottom of stack (root)
```

**Operations:**
- **Push** → Add a new screen to the top
- **Pop** → Remove the top screen and go back

---

## 🔧 Navigation Methods

### 1. **Navigator.push()** - Direct Navigation

Directly create and push a screen onto the stack.

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SecondScreen(),
      ),
    );
  },
  child: Text('Go to Second Screen'),
)
```

**Pros:**
- Simple and straightforward
- Good for quick navigation
- Easy to pass parameters

**Cons:**
- Screen creation logic scattered throughout code
- Harder to maintain in large apps
- No central route management

---

### 2. **Navigator.pushNamed()** - Named Routes

Use predefined route names for navigation.

```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/second');
  },
  child: Text('Go to Second Screen'),
)
```

**Pros:**
- ✅ Centralized route management
- ✅ Cleaner code
- ✅ Easier to refactor
- ✅ Better for large apps

**Cons:**
- Requires route setup in main.dart
- Slightly more initial setup

---

### 3. **Navigator.pop()** - Go Back

Remove the current screen and return to the previous one.

```dart
ElevatedButton(
  onPressed: () {
    Navigator.pop(context);
  },
  child: Text('Go Back'),
)
```

**Note:** Flutter automatically adds a back button in the AppBar when you push a new screen.

---

### 4. **Navigator.popUntil()** - Advanced Back Navigation

Pop multiple screens until a condition is met.

```dart
// Go back to the first screen (home)
Navigator.popUntil(context, (route) => route.isFirst);

// Go back to a specific named route
Navigator.popUntil(context, ModalRoute.withName('/home'));
```

---

### 5. **Navigator.pushReplacement()** - Replace Current Screen

Replace the current screen with a new one (no back button).

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const Dashboard()),
);

// Or with named routes
Navigator.pushReplacementNamed(context, '/dashboard');
```

**Use Case:** After login, replace the login screen with the dashboard (user shouldn't go back to login).

---

### 6. **Navigator.pushNamedAndRemoveUntil()** - Clear Stack

Push a new screen and remove all previous screens.

```dart
// Go to home and clear entire navigation history
Navigator.pushNamedAndRemoveUntil(
  context,
  '/home',
  (route) => false, // Remove all routes
);
```

**Use Case:** After logout, go to login screen and clear all history.

---

## 🛠️ Setting Up Named Routes

### Step 1: Define Routes in main.dart

```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/second_screen.dart';
import 'screens/third_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      // Define the initial route
      initialRoute: '/',
      
      // Define all routes
      routes: {
        '/': (context) => HomeScreen(),
        '/second': (context) => SecondScreen(),
        '/third': (context) => ThirdScreen(),
        '/settings': (context) => SettingsScreen(),
      },
      
      // Handle unknown routes (404 page)
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => NotFoundScreen(),
        );
      },
    );
  }
}
```

### Step 2: Navigate Using Route Names

```dart
// In any screen
Navigator.pushNamed(context, '/second');
Navigator.pushNamed(context, '/settings');
```

---

## 📦 Passing Data Between Screens

### Method 1: Constructor Parameters (Direct Push)

```dart
// Define screen with parameters
class ProductDetailScreen extends StatelessWidget {
  final String productName;
  final double price;
  
  const ProductDetailScreen({
    Key? key,
    required this.productName,
    required this.price,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(productName)),
      body: Center(
        child: Text('Price: \$$price'),
      ),
    );
  }
}

// Navigate and pass data
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailScreen(
      productName: 'Flutter Book',
      price: 29.99,
    ),
  ),
);
```

### Method 2: Route Arguments (Named Routes)

```dart
// Navigate with arguments
Navigator.pushNamed(
  context,
  '/product-details',
  arguments: {
    'name': 'Flutter Book',
    'price': 29.99,
  },
);

// Receive arguments in destination screen
class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Extract arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String name = args['name'];
    final double price = args['price'];
    
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(child: Text('Price: \$$price')),
    );
  }
}
```

### Method 3: Return Data from Screen

```dart
// Push and wait for result
ElevatedButton(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectionScreen()),
    );
    
    if (result != null) {
      print('Selected: $result');
    }
  },
  child: Text('Make Selection'),
)

// In SelectionScreen, return data
ElevatedButton(
  onPressed: () {
    Navigator.pop(context, 'User selected Option A');
  },
  child: Text('Select Option A'),
)
```

---

## 🎓 Practical Examples - Your Project

### Your Current Navigation Structure

```
HomeScreen (/)
├── HotReloadDemo (/hot-reload)
├── StatelessStatefulDemo (/stateless-stateful)
├── LoginScreen (/login)
│   └── Dashboard (/dashboard)
└── SimpleHomeScreen (/simple-home)
    └── SimpleSecondScreen (/simple-second)
        └── SimpleThirdScreen
```

### Example 1: Basic Navigation

```dart
// In HomeScreen
Navigator.pushNamed(context, '/hot-reload');

// In HotReloadDemo, go back
Navigator.pop(context);
```

### Example 2: Login Flow

```dart
// After successful login in LoginScreen
Navigator.pushReplacementNamed(context, '/dashboard');
// User can't go back to login

// After logout in Dashboard
Navigator.pushNamedAndRemoveUntil(
  context,
  '/',
  (route) => false,
);
// Clear all history and go to home
```

### Example 3: Deep Navigation

```dart
// SimpleHomeScreen → SimpleSecondScreen → SimpleThirdScreen

// In SimpleThirdScreen, go back to home directly
Navigator.popUntil(context, (route) => route.isFirst);
```

---

## 🎯 Navigation Patterns

### Pattern 1: Bottom Navigation Bar

```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    DashboardScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

### Pattern 2: Drawer Navigation

```dart
Scaffold(
  appBar: AppBar(title: Text('Home')),
  drawer: Drawer(
    child: ListView(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () {
            Navigator.pop(context); // Close drawer
            Navigator.pushNamed(context, '/');
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    ),
  ),
  body: Center(child: Text('Home Screen')),
)
```

### Pattern 3: Tab Navigation

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      title: Text('Tabs'),
      bottom: TabBar(
        tabs: [
          Tab(icon: Icon(Icons.book), text: 'Books'),
          Tab(icon: Icon(Icons.person), text: 'Authors'),
          Tab(icon: Icon(Icons.category), text: 'Categories'),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        BooksTab(),
        AuthorsTab(),
        CategoriesTab(),
      ],
    ),
  ),
)
```

---

## 🔍 Testing Your Navigation

### Try the Simple Navigation Demo

1. Run your app:
   ```bash
   flutter run
   ```

2. Navigate to **🧭 Simple Navigation** from the home screen

3. Observe the navigation stack:
   - **Home** → **Second** → **Third**
   - Try different back navigation methods
   - Check Debug Console for navigation logs

### Debug Navigation

```dart
Navigator.pushNamed(context, '/second').then((_) {
  debugPrint('✅ Returned from second screen');
});

// Log current route
debugPrint('Current route: ${ModalRoute.of(context)?.settings.name}');
```

---

## 💡 Best Practices

### ✅ DO

1. **Use named routes** for large apps
2. **Group related routes** logically
3. **Handle back button** behavior appropriately
4. **Clear navigation stack** after logout
5. **Log navigation events** during development
6. **Handle unknown routes** gracefully

### ❌ DON'T

1. **Don't create circular navigation** (A → B → A → B)
2. **Don't forget to dispose** resources when popping
3. **Don't push same route** repeatedly
4. **Don't ignore** Android back button behavior
5. **Don't hardcode** screen paths everywhere

---

## 🚀 Quick Reference

| Method | Description | Use Case |
|--------|-------------|----------|
| `push()` | Add screen to stack | Navigate forward |
| `pushNamed()` | Navigate using route name | Navigate with clean code |
| `pop()` | Remove current screen | Go back one screen |
| `popUntil()` | Pop multiple screens | Go back to specific screen |
| `pushReplacement()` | Replace current screen | Login → Dashboard |
| `pushNamedAndRemoveUntil()` | Clear stack and navigate | Logout → Login |

---

## 📊 Navigation Flow Diagram

```
[Home Screen]
    ├── Press button → push('/second')
    │                     ↓
    │                [Second Screen]
    │                     ├── Press back → pop()
    │                     │                 ↓
    │                     │           [Home Screen]
    │                     └── Press forward → push(ThirdScreen)
    │                                   ↓
    │                              [Third Screen]
    │                                   ├── pop() → [Second]
    │                                   └── popUntil(isFirst) → [Home]
```

---

## 🎯 Try This Exercise!

### Exercise 1: Create Your Own Navigation

1. Create a new screen: `profile_screen.dart`
2. Add it to routes in `main.dart`
3. Add navigation button in `HomeScreen`
4. Navigate to it and back

### Exercise 2: Pass Data

1. Create a screen that accepts a name parameter
2. Navigate to it with your name
3. Display the name on the screen
4. Return a message when going back

### Exercise 3: Login Flow

1. Create login → dashboard flow
2. Use `pushReplacement` after login
3. Use `pushNamedAndRemoveUntil` after logout
4. Test that users can't go back to login after authenticated

---

## 📚 Additional Resources

- [Official Navigator Documentation](https://api.flutter.dev/flutter/widgets/Navigator-class.html)
- [Navigation and Routing](https://docs.flutter.dev/development/ui/navigation)
- [Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)

---

## ✨ Summary

You now understand:
- ✅ Navigation stack concept
- ✅ Different navigation methods (push, pop, pushNamed)
- ✅ Setting up named routes
- ✅ Passing data between screens
- ✅ Common navigation patterns
- ✅ Best practices for multi-screen apps

**Practice these concepts using the Simple Navigation Demo in your app!** 🚀

---

*Happy Navigating!* 🧭
