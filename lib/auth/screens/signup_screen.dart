import 'package:chat_app/auth/providers/auth_provider.dart';
import 'package:chat_app/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSigningUp = false;
  bool isGoogleLoading = false;

  // -----------------------------
  // EMAIL + PASSWORD SIGNUP
  // -----------------------------
  Future<void> signup() async {
    setState(() => isSigningUp = true);

    final result = await ref.read(authControllerProvider).signup(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

    setState(() => isSigningUp = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully 🎉")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  // -----------------------------
  // GOOGLE SIGN-IN
  // -----------------s------------
  Future<void> signInWithGoogle() async {
    setState(() => isGoogleLoading = true);

    final result = await ref.read(authControllerProvider).googleSignIn();

    setState(() => isGoogleLoading = false);

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
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
          "Create Account",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create a new account",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF075E54),
              ),
            ),

            const SizedBox(height: 30),

            // NAME
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person, color: Color(0xFF075E54)),
                hintText: "Name",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(18),
                enabledBorder: _border(),
                focusedBorder: _focusedBorder(),
              ),
            ),

            const SizedBox(height: 25),

            // EMAIL
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email, color: Color(0xFF075E54)),
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
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF075E54)),
                hintText: "Password",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(18),
                enabledBorder: _border(),
                focusedBorder: _focusedBorder(),
              ),
            ),

            const SizedBox(height: 35),

            // SIGNUP BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSigningUp ? null : signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSigningUp
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // GOOGLE SIGN-IN BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: isGoogleLoading ? null : signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF128C7E), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isGoogleLoading
                    ? const CircularProgressIndicator(
                        color: Color(0xFF128C7E),
                      )
                    : const Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF128C7E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Log In",
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

  OutlineInputBorder _border() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
      );

  OutlineInputBorder _focusedBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF128C7E), width: 2),
      );
}
