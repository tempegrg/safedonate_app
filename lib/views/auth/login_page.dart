import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import authentication service
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';

// Import dashboard pages
import '../admin/dashboard_page.dart';
import '../user/dashboard_page.dart';

// Import register page
import 'register_page.dart';

import '../../config/app_theme.dart';

// =========================================
// LOGIN PAGE
// =========================================

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  // =========================================
  // CONTROLLERS
  // =========================================

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  // =========================================
  // VARIABLES
  // =========================================

  bool isLoading = false;

  String selectedRole = 'user';

  bool obscurePassword = true;


  // =========================================
  // NORMAL LOGIN
  // =========================================

  void login() async {

    // Validate empty fields
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text("Please fill all fields"),
        ),
      );

      return;
    }

    // Start loading
    setState(() {
      isLoading = true;
    });

    try {

      // =========================================
      // CALL LOGIN API
      // =========================================

      var result =
          await AuthService.login(

        emailController.text.trim(),

        passwordController.text.trim(),
      );

      // Stop loading
      setState(() {
        isLoading = false;
      });

      // =========================================
      // CHECK LOGIN RESPONSE
      // =========================================

      if (result != null &&
          result['user'] != null) {

        // Get role from backend
        var role =
            result['user']['role'];

        // =========================================
        // ADMIN LOGIN
        // =========================================

        if (selectedRole == 'admin') {

          if (role == 'admin') {

            Navigator.pushReplacement(

              context,

              MaterialPageRoute(
                builder: (_) =>
                    const AdminDashboardPage(),
              ),
            );

          } else {

            ScaffoldMessenger.of(context)
                .showSnackBar(

              const SnackBar(
                content: Text(
                  "You are not registered as admin",
                ),
              ),
            );
          }
        }

        // =========================================
        // USER LOGIN
        // =========================================

        else {

          if (role == 'user') {

            Navigator.pushReplacement(

              context,

              MaterialPageRoute(
                builder: (_) =>
                    const UserDashboardPage(),
              ),
            );

          } else {

            ScaffoldMessenger.of(context)
                .showSnackBar(

              const SnackBar(
                content: Text(
                  "Admin account cannot login as user",
                ),
              ),
            );
          }
        }

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              "Invalid email or password",
            ),
          ),
        );
      }

    } catch (e) {

      // Stop loading
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text("Something went wrong"),
        ),
      );
    }
  }

// =========================================
// BIOMETRIC LOGIN
// =========================================

Future<void> biometricLogin() async {

  bool authenticated =
      await BiometricService.authenticate();

  if (!authenticated) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text(
          "Biometric authentication failed",
        ),
      ),
    );

    return;
  }

  final prefs =
      await SharedPreferences.getInstance();

  bool isLoggedIn =
      prefs.getBool('isLoggedIn') ?? false;

  String role =
      prefs.getString('role') ?? '';

  if (!isLoggedIn) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text(
          "Please login once before using fingerprint login",
        ),
      ),
    );

    return;
  }

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(
      content: Text(
        "Biometric login successful",
      ),
    ),
  );

  // ADMIN
  if (role == 'admin') {

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(
        builder: (_) =>
            const AdminDashboardPage(),
      ),
    );

  }

  // USER
  else {

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(
        builder: (_) =>
            const UserDashboardPage(),
      ),
    );
  }
}

  // =========================================
  // UI
  // =========================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F7FA),

      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(

            padding:
                const EdgeInsets.all(24),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 30),

                // =========================================
                // APP TITLE
                // =========================================

                const Text(

                  "SafeDonate",

                  style: TextStyle(
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(

                  "Secure your donations with confidence.",

                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 50),

                // =========================================
                // LOGIN TITLE
                // =========================================

                const Text(

                  "Login",

                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // =========================================
                // EMAIL FIELD
                // =========================================

                TextField(

                  controller:
                      emailController,

                  decoration: InputDecoration(

                    hintText:
                        "Email Address",

                    prefixIcon:
                        const Icon(
                      Icons.email_outlined,
                    ),

                    filled: true,

                    fillColor:
                        Colors.white,

                    border:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================================
                // PASSWORD FIELD
                // =========================================

                TextField(

                controller: passwordController,

                obscureText: obscurePassword,

                decoration: InputDecoration(

                  hintText: "Password",

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon: IconButton(

                    icon: Icon(

                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,

                    ),

                    onPressed: () {

                      setState(() {

                        obscurePassword = !obscurePassword;

                      });

                    },

                  ),

                  filled: true,

                  fillColor: Colors.white,

                  border: OutlineInputBorder(

                    borderRadius: BorderRadius.circular(14),

                    borderSide: BorderSide.none,

                  ),

                ),

              ),

                const SizedBox(height: 20),

                // =========================================
                // ROLE SELECTION
                // =========================================

                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    // USER
                    Row(
                      children: [

                        Radio(
                          
                            activeColor:
                                AppTheme.primaryColor,

                          value: 'user',

                          groupValue:
                              selectedRole,

                          onChanged: (value) {

                            setState(() {
                              selectedRole =
                                  value!;
                            });
                          },
                        ),

                        const Text("User"),
                      ],
                    ),

                    // ADMIN
                    Row(
                      children: [

                        Radio(

                          activeColor:
                          AppTheme.primaryColor,

                          value: 'admin',

                          groupValue:
                              selectedRole,

                          onChanged: (value) {

                            setState(() {
                              selectedRole =
                                  value!;
                            });
                          },
                        ),

                        const Text("Admin"),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // =========================================
                // LOGIN BUTTON
                // =========================================

                SizedBox(

                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(

                    onPressed:
                        isLoading
                            ? null
                            : login,

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          AppTheme.primaryColor,

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),

                    child: isLoading

                        ? const CircularProgressIndicator(
                            color:
                                Colors.white,
                          )

                        : const Text(

                            "Login",

                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                // =========================================
                // BIOMETRIC BUTTON
                // =========================================

                SizedBox(

                  width: double.infinity,

                  height: 55,

                  child: OutlinedButton.icon(

                    onPressed:
                        biometricLogin,

                    icon: const Icon(
                      Icons.fingerprint,
                    ),

                    label: const Text(

                      "Login with Fingerprint",

                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    style:
                        OutlinedButton.styleFrom(
                      
                      foregroundColor:
                        AppTheme.primaryColor,
                      
                      side: BorderSide(
                        color:
                            AppTheme.primaryColor,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // =========================================
                // REGISTER BUTTON
                // =========================================

                Center(

                  child: TextButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              const RegisterPage(),
                        ),
                      );
                    },

                    child: const Text(

                      "Don't have an account? Register",

                      style: TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}