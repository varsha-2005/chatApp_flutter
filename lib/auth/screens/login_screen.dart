import 'package:chat_app/auth/providers/auth_controller.dart';
import 'package:chat_app/auth/screens/forgot_password_Screen.dart';
import 'package:chat_app/auth/screens/signup_screen.dart';
import 'package:chat_app/chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false; // ✅ added

  // -----------------------------
  // EMAIL + PASSWORD LOGIN
  // -----------------------------
  Future<void> login() async {
    setState(() => isLoading = true); // start loading

    final result = await ref
        .read(authControllerProvider)
        .login(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

    setState(() => isLoading = false); // stop loading

    if (result == null) {
      // Success
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login successful 🎉")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    } else {
      // Error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  // -----------------------------
  // GOOGLE SIGN-IN
  // -----------------------------
  Future<void> signInWithGoogle() async {
    setState(() => isLoading = true); // start loading

    final result = await ref.read(authControllerProvider).googleSignIn();

    setState(() => isLoading = false); // stop loading

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF128C7E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Log In Account",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back 👋",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF128C7E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Login to your account",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),

            // EMAIL
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.grey,
                ),
                hintText: "Email",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(18),
                enabledBorder: _border(),
                focusedBorder: _focusedBorder(),
              ),
            ),
            const SizedBox(height: 25),

            // PASSWORD
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                hintText: "Password",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(18),
                enabledBorder: _border(),
                focusedBorder: _focusedBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text("Forgot Password?"),
            ),
            const SizedBox(height: 35),

            // LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,   // disable while loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 18),

            // GOOGLE SIGN-IN BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: isLoading ? null : signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  side:
                      const BorderSide(color: Color(0xFF128C7E), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Color(0xFF128C7E),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // if you have google_logo.png in assets (you do in pubspec)
                          Image.asset(
                            'assets/google_logo.png',
                            height: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Continue with Google",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF128C7E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 18),

            // SIGN UP LINK
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Color(0xFF128C7E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // UI helper methods
  // -----------------------------
  OutlineInputBorder _border() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
      );

  OutlineInputBorder _focusedBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF128C7E), width: 2),
      );
}
