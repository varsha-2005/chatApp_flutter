import 'package:chat_app/auth/screens/signup_screen.dart';
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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),

      // Auth-based routing
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Loading while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const ChatScreen();
          } else {
            return const SignupScreen();
          }
        },
      ),
    );
  }
}
