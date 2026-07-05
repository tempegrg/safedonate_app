import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {

  String name = "";
  String email = "";
  String role = "";

  @override
  void initState() {
    super.initState();

    loadUserData();
  }

  // =========================================
  // LOAD USER DATA
  // =========================================

  Future<void> loadUserData() async {

    final prefs =
        await SharedPreferences.getInstance();

    setState(() {

      name =
          prefs.getString('name') ??
          'Unknown User';

      email =
          prefs.getString('email') ??
          'No Email';

      role =
          prefs.getString('role') ??
          'User';
    });
  }

  // =========================================
  // LOGOUT
  // =========================================

  Future<void> logout() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();

    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(
        builder: (_) =>
            const LoginPage(),
      ),

      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F7FA),

      appBar: AppBar(

        backgroundColor: Colors.blue,

        title: const Text(

          "Profile",

          style: TextStyle(
            color: Colors.white,
          ),
        ),

        centerTitle: true,
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 20),

            // =========================================
            // PROFILE IMAGE
            // =========================================

            const CircleAvatar(

              radius: 50,

              backgroundColor:
                  Colors.blue,

              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // =========================================
            // USER NAME
            // =========================================

            Text(

              name,

              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // =========================================
            // EMAIL
            // =========================================

            Text(

              email,

              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 12),

            // =========================================
            // ROLE
            // =========================================

            Container(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              decoration: BoxDecoration(

                color:
                    Colors.blue.shade50,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Text(

                role.toUpperCase(),

                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // =========================================
            // LOGOUT BUTTON
            // =========================================

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton.icon(

                onPressed: logout,

                icon: const Icon(
                  Icons.logout,
                ),

                label: const Text(

                  "Logout",

                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.red,

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}