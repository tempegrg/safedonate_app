import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'views/auth/splash_page.dart';
import 'views/auth/login_page.dart';
import 'config/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafeDonateApp());
}

class SafeDonateApp extends StatefulWidget {
  const SafeDonateApp({super.key});

  @override
  State<SafeDonateApp> createState() => _SafeDonateAppState();
}

class _SafeDonateAppState extends State<SafeDonateApp>
    with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  DateTime? pausedTime;

  static const int timeoutMinutes = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // =========================================
  // APP LIFECYCLE
  // =========================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final prefs = await SharedPreferences.getInstance();

    // App goes to background / inactive
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      pausedTime = DateTime.now();
      await prefs.setString(
        'last_inactive_time',
        pausedTime!.toIso8601String(),
      );
    }

    // App comes back to foreground
    if (state == AppLifecycleState.resumed) {
      final lastInactiveString =
          prefs.getString('last_inactive_time');

      if (lastInactiveString == null) return;

      final lastInactive =
          DateTime.tryParse(lastInactiveString);

      if (lastInactive == null) return;

      final difference =
          DateTime.now().difference(lastInactive);

      if (difference.inMinutes >= timeoutMinutes) {
        // Clear session
        await prefs.remove('token');
        await prefs.remove('role');
        await prefs.remove('name');
        await prefs.remove('email');
        await prefs.remove('user_id');
        await prefs.remove('hasLoggedInBefore');

        // Navigate to login page
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
          (route) => false,
        );

        final context = navigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Session expired due to inactivity. Please login again.",
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'SafeDonate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const SplashPage(),
    );
  }
}