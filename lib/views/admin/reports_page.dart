import 'package:flutter/material.dart';
import '../../services/report_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() =>
      _ReportsPageState();
}

class _ReportsPageState
    extends State<ReportsPage> {

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

    var data =
        await ReportService.getReports();

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

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F7FA),

      appBar: AppBar(

        title: const Text(
          "System Reports",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        backgroundColor: Colors.blue,

        centerTitle: true,
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Padding(

              padding:
                  const EdgeInsets.all(16),

              child: Column(

                children: [

                  buildReportCard(
                    "Total Organisations",
                    reportData?[
                                'total_organisations']
                            ?.toString() ??
                        "0",
                    Icons.business,
                    Colors.blue,
                  ),

                  buildReportCard(
                    "Total Verification Logs",
                    reportData?[
                                'total_logs']
                            ?.toString() ??
                        "0",
                    Icons.history,
                    Colors.orange,
                  ),

                  buildReportCard(
                    "Verified Websites",
                    reportData?[
                                'verified_logs']
                            ?.toString() ??
                        "0",
                    Icons.check_circle,
                    Colors.green,
                  ),

                  buildReportCard(
                    "Warning Websites",
                    reportData?[
                                'warning_logs']
                            ?.toString() ??
                        "0",
                    Icons.warning,
                    Colors.red,
                  ),
                ],
              ),
            ),
    );
  }

  // =========================================
  // REPORT CARD
  // =========================================

  Widget buildReportCard(

    String title,
    String value,
    IconData icon,
    Color color,

  ) {

    return Container(

      width: double.infinity,

      margin:
          const EdgeInsets.only(bottom: 16),

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

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

          Container(

            padding:
                const EdgeInsets.all(14),

            decoration: BoxDecoration(

              color:
                  color.withOpacity(0.1),

              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  title,

                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 8),

                Text(

                  value,

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
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