import 'package:chat_app/auth/screens/signup_screen.dart';
import 'package:chat_app/auth/screens/splash_screen.dart';
import 'package:chat_app/call/services/zego_service.dart';
import 'package:chat_app/chat/screens/chat_screen.dart';
import 'package:chat_app/settings/providers/settings.providers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // Global auth listener to init Zego when user logs in
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        print("User ${user.uid} logged in. Init Zego...");
        ZegoService.initZego(
          userID: user.uid,
          userName: user.displayName ?? 'User',
        );
      } else {
        print("User logged out. Cleanup Zego...");
        ZegoService.logout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      home: const SplashScreen(),
      routes: {
        '/chat': (context) => const ChatScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}

// Light Theme Configuration
ThemeData _lightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF128C7E), // WhatsApp green
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF128C7E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF128C7E),
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.grey),
    ),
    iconTheme: const IconThemeData(color: Colors.black87),
    dividerColor: Colors.grey[300],
  );
}

// Dark Theme Configuration
ThemeData _darkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color.fromARGB(255, 9, 209, 92),
    scaffoldBackgroundColor: const Color.fromARGB(
      255,
      0,
      0,
      0,
    ), // Dark background
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F2937), // Dark gray
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF128C7E),
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.grey),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    dividerColor: Colors.grey[800],
  );
}
