import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_theme.dart';

import '../admin/dashboard_page.dart';
import '../user/dashboard_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() =>
      _SplashPageState();
}

class _SplashPageState
    extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

 Future<void> checkLogin() async {

  await Future.delayed(
    const Duration(seconds: 4),
  );

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginPage(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F7FA),

      body: Center(

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            // App Logo
            Container(

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color:
                    AppTheme.primaryColor.withOpacity(0.15),

                shape: BoxShape.circle,
              ),

              child: const Icon(

                Icons.verified_user,

                size: 70,

                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 25),

            // App Name
            Text(

              "SafeDonate",

              style: TextStyle(

                fontSize: 32,

                fontWeight:
                    FontWeight.bold,

                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 10),

            // Tagline
            const Text(

              "Verify Before You Donate",

              style: TextStyle(

                fontSize: 16,

                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 40),

            CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}