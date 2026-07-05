import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import 'organisation_manage_page.dart';
import 'logs_page.dart';
import 'reports_page.dart';
import 'profile_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // =========================================
            // MANAGE ORGANISATIONS
            // =========================================

            buildMenuCard(
              context,
              "Manage Organisations",
              Icons.business,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrganisationManagePage(),
                  ),
                );
              },
            ),

            // =========================================
            // VERIFICATION LOGS
            // =========================================

            buildMenuCard(
              context,
              "Verification Logs",
              Icons.history,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminLogsPage(),
                  ),
                );
              },
            ),

            // =========================================
            // REPORTS
            // =========================================

            buildMenuCard(
              context,
              "View Reports",
              Icons.bar_chart,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportsPage(),
                  ),
                );
              },
            ),

            // =========================================
            // PROFILE
            // =========================================

            buildMenuCard(
              context,
              "Profile",
              Icons.person,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminProfilePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // REUSABLE MENU CARD
  // =========================================

  Widget buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),

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

            Icon(
              icon,
              size: 30,
              color: AppTheme.primaryColor,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}