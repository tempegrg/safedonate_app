import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/report_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Map<String, dynamic>? reportData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  // =========================================
  // FETCH REPORTS
  // =========================================
  void fetchReports() async {
    var data = await ReportService.getReports();

    setState(() {
      reportData = data;
      isLoading = false;
    });
  }

  // =========================================
  // UI
  // =========================================
  @override
  Widget build(BuildContext context) {
    final totalOrganisations =
        reportData?['total_organisations']?.toString() ?? "0";
    final totalLogs =
        reportData?['total_logs']?.toString() ?? "0";
    final verifiedLogs =
        reportData?['verified_logs']?.toString() ?? "0";
    final warningLogs =
        reportData?['warning_logs']?.toString() ?? "0";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "System Reports",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                fetchReports();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================
                    // HEADER CARD
                    // =========================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.22),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.bar_chart_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Reports Overview",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "View organisation totals, verification activity and overall SafeDonate system records.",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Summary Statistics",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Track the current numbers across organisations and donation verification activity.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =========================================
                    // REPORT CARDS
                    // =========================================
                    buildReportCard(
                      title: "Total Organisations",
                      value: totalOrganisations,
                      icon: Icons.business_rounded,
                      color: Colors.indigo,
                      subtitle:
                          "Total registered and stored organisations in the system.",
                    ),

                    buildReportCard(
                      title: "Total Verification Logs",
                      value: totalLogs,
                      icon: Icons.history_rounded,
                      color: Colors.orange,
                      subtitle:
                          "All donation link verification activity records.",
                    ),

                    buildReportCard(
                      title: "Verified Websites",
                      value: verifiedLogs,
                      icon: Icons.verified_rounded,
                      color: Colors.green,
                      subtitle:
                          "Websites successfully matched with verified organisations.",
                    ),

                    buildReportCard(
                      title: "Warning Websites",
                      value: warningLogs,
                      icon: Icons.warning_amber_rounded,
                      color: Colors.red,
                      subtitle:
                          "Websites flagged as suspicious or not verified.",
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // =========================================
  // REPORT CARD
  // =========================================
  Widget buildReportCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13.2,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}