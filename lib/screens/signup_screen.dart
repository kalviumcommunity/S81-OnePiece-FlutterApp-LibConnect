import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController),
            TextField(controller: passwordController, obscureText: true),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final user = await _auth.signUp(
                  emailController.text,
                  passwordController.text,
                );

                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Dashboard()),
                  );
                }
              },
              child: const Text("Signup"),
            ),
          ],
        ),
      ),
    );
  }
}
