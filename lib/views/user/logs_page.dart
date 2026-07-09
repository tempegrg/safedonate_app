import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/log_service.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  // =========================================
  // FETCH LOGS
  // =========================================
  void fetchLogs() async {
    var data = await LogService.getLogs();

    setState(() {
      logs = data;
      isLoading = false;
    });
  }

  // =========================================
  // BUILD STATUS CHIP
  // =========================================
  Widget buildStatusChip(bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isVerified
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified
                ? Icons.check_circle
                : Icons.warning_amber_rounded,
            size: 16,
            color: isVerified
                ? Colors.green
                : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            isVerified ? "Verified" : "Unrecognized",
            style: TextStyle(
              color: isVerified
                  ? Colors.green
                  : Colors.orange,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // BUILD LOG CARD
  // =========================================
  Widget buildLogCard(Map<String, dynamic> log) {
    final isVerified =
        (log['result'] ?? '').toString().toLowerCase() ==
            'verified';

    final String website =
        (log['website'] ?? 'Unknown Website')
            .toString();

    final String resultText = isVerified
        ? "Verified - Safe"
        : "Not recognized";

    final String checkedAt =
        (log['created_at'] ??
                log['date'] ??
                '')
            .toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =========================================
          // STATUS ICON BOX
          // =========================================
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isVerified
                  ? Colors.green.withOpacity(0.12)
                  : Colors.orange.withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Icon(
              isVerified
                  ? Icons.verified_rounded
                  : Icons.error_outline_rounded,
              color: isVerified
                  ? Colors.green
                  : Colors.orange,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          // =========================================
          // TEXT CONTENT
          // =========================================
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  website,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  resultText,
                  style: TextStyle(
                    fontSize: 14,
                    color: isVerified
                        ? Colors.green
                        : Colors.orange,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                if (checkedAt.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: Colors.black45,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          checkedAt,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                buildStatusChip(isVerified),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor:
            AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Verification History",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : logs.isEmpty
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppTheme
                                .primaryColor
                                .withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            size: 42,
                            color:
                                AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "No verification history found",
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your donation link verification records will appear here once you start checking websites or QR codes.",
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // =========================================
                    // TOP INFO HEADER
                    // =========================================
                    Container(
                      width: double.infinity,
                      margin:
                          const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        10,
                      ),
                      padding:
                          const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme
                                .primaryColor
                                .withOpacity(0.25),
                            blurRadius: 12,
                            offset:
                                const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.16),
                              borderRadius:
                                  BorderRadius
                                      .circular(16),
                            ),
                            child: const Icon(
                              Icons.history_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  "Verification History",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                    height: 6),
                                Text(
                                  "Track all donation link and QR verification results in one place. Total records: ${logs.length}",
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white70,
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

                    // =========================================
                    // LOG LIST
                    // =========================================
                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(
                          16,
                          6,
                          16,
                          16,
                        ),
                        itemCount: logs.length,
                        itemBuilder:
                            (context, index) {
                          final log =
                              Map<String, dynamic>.from(
                            logs[index],
                          );

                          return buildLogCard(log);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}