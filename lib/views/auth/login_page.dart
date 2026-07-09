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
      var result =
          await AuthService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() {
        isLoading = false;
      });

      if (result != null &&
          result['user'] != null) {
        var role =
            result['user']['role'];

        // ADMIN LOGIN
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

        // USER LOGIN
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
    final bool available =
        await BiometricService
            .isBiometricAvailable();

    if (!available) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Biometric authentication is not available on this device",
          ),
        ),
      );
      return;
    }

    bool authenticated =
        await BiometricService
            .authenticate();

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
        await SharedPreferences
            .getInstance();

    bool hasLoggedInBefore =
        prefs.getBool(
              'hasLoggedInBefore',
            ) ??
            false;

    String role =
        prefs.getString('role') ?? '';

    if (!hasLoggedInBefore) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please login once before using biometric login",
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

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AdminDashboardPage(),
        ),
      );
    } else {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      // =========================================
                      // LOGO
                      // =========================================
              
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/safedonate-logo.png',
                            height: 95,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.verified_user,
                                size: 95,
                                color: AppTheme.primaryColor,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 22),

                      // =========================================
                      // APP NAME
                      // =========================================
                      const Text(
                        "SafeDonate",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight:
                              FontWeight.w800,
                          letterSpacing: 0.8,
                          color:
                              AppTheme.primaryColor,
                          height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Secure your donations with confidence.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =========================================
                      // LOGIN CARD
                      // =========================================
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(
                          22,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color:
                                  Colors.black12,
                              blurRadius: 10,
                              offset:
                                  Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                color:
                                    Colors.black87,
                              ),
                            ),

                            const SizedBox(
                                height: 6),

                            const Text(
                              "Access your SafeDonate account",
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Colors.black54,
                              ),
                            ),

                            const SizedBox(
                                height: 24),

                            // =========================================
                            // EMAIL FIELD
                            // =========================================
                            TextField(
                              controller:
                                  emailController,
                              keyboardType:
                                  TextInputType
                                      .emailAddress,
                              decoration:
                                  InputDecoration(
                                hintText:
                                    "Email Address",
                                prefixIcon:
                                    const Icon(
                                  Icons
                                      .email_outlined,
                                ),
                                filled: true,
                                fillColor:
                                    const Color(
                                  0xFFF7F8FA,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal:
                                      16,
                                  vertical: 18,
                                ),
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    16,
                                  ),
                                  borderSide:
                                      BorderSide
                                          .none,
                                ),
                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    16,
                                  ),
                                  borderSide:
                                      BorderSide
                                          .none,
                                ),
                                focusedBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    16,
                                  ),
                                  borderSide:
                                      const BorderSide(
                                    color: AppTheme
                                        .primaryColor,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                                height: 16),

                            // =========================================
                            // PASSWORD FIELD
                            // =========================================
                            TextField(
                              controller:
                                  passwordController,
                              obscureText:
                                  obscurePassword,
                              decoration:
                                  InputDecoration(
                                hintText:
                                    "Password",
                                prefixIcon:
                                    const Icon(
                                  Icons
                                      .lock_outline,
                                ),
                                suffixIcon:
                                    IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons
                                            .visibility_off
                                        : Icons
                                            .visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword =
                                          !obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor:
                                    const Color(
                                  0xFFF7F8FA,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal:
                                      16,
                                  vertical: 18,
                                ),
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    16,
                                  ),
                                  borderSide:
                                      BorderSide
                                          .none,
                                ),
                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    16,
                                  ),
                                  borderSide:
                                      BorderSide
                                          .none,
                                ),
                                focusedBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    16,
                                  ),
                                  borderSide:
                                      const BorderSide(
                                    color: AppTheme
                                        .primaryColor,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                                height: 22),

                            // =========================================
                            // ROLE SELECTION
                            // =========================================
                            Container(
                              width:
                                  double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFF7F8FA,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                              ),
                              child: Wrap(
                                alignment:
                                    WrapAlignment
                                        .center,
                                crossAxisAlignment:
                                    WrapCrossAlignment
                                        .center,
                                spacing: 10,
                                runSpacing: 4,
                                children: [
                                  Row(
                                    mainAxisSize:
                                        MainAxisSize
                                            .min,
                                    children: [
                                      Radio(
                                        activeColor:
                                            AppTheme
                                                .primaryColor,
                                        value:
                                            'user',
                                        groupValue:
                                            selectedRole,
                                        onChanged:
                                            (value) {
                                          setState(
                                              () {
                                            selectedRole =
                                                value!;
                                          });
                                        },
                                      ),
                                      const Text(
                                        "User",
                                        style:
                                            TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize:
                                        MainAxisSize
                                            .min,
                                    children: [
                                      Radio(
                                        activeColor:
                                            AppTheme
                                                .primaryColor,
                                        value:
                                            'admin',
                                        groupValue:
                                            selectedRole,
                                        onChanged:
                                            (value) {
                                          setState(
                                              () {
                                            selectedRole =
                                                value!;
                                          });
                                        },
                                      ),
                                      const Text(
                                        "Admin",
                                        style:
                                            TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                                height: 24),

                            // =========================================
                            // LOGIN BUTTON
                            // =========================================
                            SizedBox(
                              width:
                                  double.infinity,
                              height: 55,
                              child:
                                  ElevatedButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : login,
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      AppTheme
                                          .primaryColor,
                                  foregroundColor:
                                      Colors.white,
                                  elevation: 0,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      16,
                                    ),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width:
                                            22,
                                        height:
                                            22,
                                        child:
                                            CircularProgressIndicator(
                                          color:
                                              Colors.white,
                                          strokeWidth:
                                              2.5,
                                        ),
                                      )
                                    : const Text(
                                        "Login",
                                        style:
                                            TextStyle(
                                          fontSize:
                                              17,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(
                                height: 14),

                            // =========================================
                            // BIOMETRIC BUTTON
                            // =========================================
                            SizedBox(
                              width:
                                  double.infinity,
                              height: 55,
                              child:
                                  OutlinedButton.icon(
                                onPressed:
                                    biometricLogin,
                                icon: const Icon(
                                  Icons
                                      .fingerprint,
                                ),
                                label: const Text(
                                  "Login with Biometric",
                                  style:
                                      TextStyle(
                                    fontSize:
                                        16,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                                style:
                                    OutlinedButton
                                        .styleFrom(
                                  foregroundColor:
                                      AppTheme
                                          .primaryColor,
                                  side:
                                      const BorderSide(
                                    color: AppTheme
                                        .primaryColor,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      16,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                                height: 18),

                            // =========================================
                            // REGISTER BUTTON
                            // =========================================
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              const RegisterPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Don't have an account? Register",
                                  textAlign:
                                      TextAlign
                                          .center,
                                  style: TextStyle(
                                    color: AppTheme
                                        .primaryColor,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}