import 'package:flutter/material.dart';

import 'verify_link_page.dart';
import 'organisation_page.dart';
import 'logs_page.dart';
import 'profile_page.dart';
import 'scan_qr_page.dart';
import 'register_organisation_page.dart';
import '../auth/login_page.dart';
import '../../config/app_theme.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

  return Scaffold(

    backgroundColor: const Color(0xFFF5F7FA),

    drawer: Drawer(

     child: ListView(

        padding: EdgeInsets.zero,
        children: [

            DrawerHeader(

                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                ),

                child: const Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisAlignment: MainAxisAlignment.end,

              children: [

                Icon(

                  Icons.verified_user,

                  size: 55,

                  color: Colors.white,

                ),

                SizedBox(height: 10),

                Text(

                  "SafeDonate",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 24,

                    fontWeight: FontWeight.bold,

                  ),

                ),

                SizedBox(height: 5),

                Text(

                  "Secure Donation Verification",

                  style: TextStyle(

                    color: Colors.white70,

                    fontSize: 13,

                  ),

                ),

              ],

            ),

        ),

        ListTile(

        leading: const Icon(Icons.home),

        title: const Text("Dashboard"),

        onTap: () {

          Navigator.pop(context);

        },

      ),

  const Padding(

    padding: EdgeInsets.only(

      left: 16,

      top: 10,

      bottom: 5,

    ),

  child: Text(

    "DONATION",

    style: TextStyle(

      color: Colors.grey,

      fontWeight: FontWeight.bold,

    ),

  ),

),

ListTile(

  leading: const Icon(Icons.verified),

  title: const Text("Verify Donation Link"),

  onTap: () {

    Navigator.pop(context);

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            const VerifyLinkPage(),

      ),

    );

  },

),

ListTile(

  leading: const Icon(Icons.qr_code_scanner),

  title: const Text("Scan QR Code"),

  onTap: () {

    Navigator.pop(context);

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            const ScanQrPage(),

      ),

    );

  },

),

ListTile(

  leading: const Icon(Icons.account_balance),

  title: const Text("Trusted Organisations"),

  onTap: () {

    Navigator.pop(context);

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            const OrganisationPage(),

      ),

    );

  },

),

ListTile(

  leading: const Icon(Icons.history),

  title: const Text("Verification Logs"),

  onTap: () {

    Navigator.pop(context);

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            const LogsPage(),

      ),

    );

  },

),

const Padding(

  padding: EdgeInsets.only(

    left: 16,

    top: 15,

    bottom: 5,

  ),

  child: Text(

    "ORGANISATION",

    style: TextStyle(

      color: Colors.grey,

      fontWeight: FontWeight.bold,

    ),

  ),

),

ListTile(

  leading: const Icon(

    Icons.app_registration,

  ),

  title: const Text(

    "Register Organisation",

  ),

  onTap: () {

    Navigator.pop(context);

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            const RegisterOrganisationPage(),

      ),

    );

  },

),

    ListTile(

      leading: const Icon(
        Icons.assignment,

      ),

      title: const Text(
        "My Application Status",

      ),

    onTap: () {

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Coming Soon" ),
        ),

      );

    },
),

const Padding(

  padding: EdgeInsets.only(

    left: 16,

    top: 15,

    bottom: 5,

  ),

  child: Text(

    "ACCOUNT",

    style: TextStyle(

      color: Colors.grey,

      fontWeight: FontWeight.bold,

    ),

  ),

),

ListTile(

  leading: const Icon(Icons.person),

  title: const Text("Profile"),

  onTap: () {

    Navigator.pop(context);

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            const ProfilePage(),

      ),

    );

  },

),

const Divider(),

ListTile(

  leading: const Icon(

    Icons.logout,

    color: Colors.red,

  ),

  title: const Text(

    "Logout",

    style: TextStyle(

      color: Colors.red,

    ),

  ),

  onTap: () {

    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(

        builder: (_) =>
            const LoginPage(),

      ),

      (route) => false,

    );

  },

),

      ],

    ),

  ),


appBar: AppBar(

  elevation: 0,

  backgroundColor: AppTheme.primaryColor,

  leading: Builder(

    builder: (context) => IconButton(

      icon: const Icon(

        Icons.menu,

        color: Colors.white,

      ),

      onPressed: () {

        Scaffold.of(context).openDrawer();

      },

    ),

  ),

  title: const Text(

    "SafeDonate",

    style: TextStyle(

      color: Colors.white,

      fontWeight: FontWeight.bold,

    ),

  ),

  centerTitle: true,

),

      body: SingleChildScrollView(

          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Welcome Back 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Protect your donations with secure verification.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: const [

                      Icon(
                        Icons.security,
                        color: Colors.white,
                      ),

                      SizedBox(width: 8),

                      Text(
                        "SafeDonate Protection Active",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Section Title
            const Text(
              "Features",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

         // Verify Link Card
          buildMenuCard(
            context,
            "Verify Donation Link",
            "Check if donation website is trusted",
            Icons.verified,
            Colors.green,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VerifyLinkPage(),
                ),
              );
            },
          ),

          // Scan QR Card
          buildMenuCard(
            context,
            "Scan QR Code",
            "Scan donation QR for verification",
            Icons.qr_code_scanner,
            Colors.teal,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScanQrPage(),
                ),
              );
            },
          ),

          // Trusted Organisations
          buildMenuCard(
            context,
            "Trusted Organisations",
            "View verified organisations",
            Icons.account_balance,
            Colors.orange,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrganisationPage(),
                ),
              );
            },
          ),

          // Verification Logs
          buildMenuCard(
            context,
            "Verification Logs",
            "View previous verification history",
            Icons.history,
            Colors.purple,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LogsPage(),
                ),
              );
            },
          ),

          // Register Organisation
          buildMenuCard(
            context,
            "Register Organisation",
            "Submit organisation verification request",
            Icons.business,
            Colors.indigo,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterOrganisationPage(),
                ),
              );
            },
          ),

          // Profile
          buildMenuCard(
            context,
            "Profile",
            "Manage your account settings",
            Icons.person,
            AppTheme.primaryColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),

        ],
      ),
    ),
  );
}

  // Reusable Dashboard Menu Card
  Widget buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [

            // Icon Container
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}