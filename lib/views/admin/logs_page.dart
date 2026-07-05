import 'package:flutter/material.dart';

import '../../services/log_service.dart';

class AdminLogsPage extends StatefulWidget {

  const AdminLogsPage({super.key});

  @override
  State<AdminLogsPage> createState() =>
      _AdminLogsPageState();
}

class _AdminLogsPageState
    extends State<AdminLogsPage> {

  // =========================================
  // VARIABLES
  // =========================================

  List logs = [];

  bool isLoading = true;

  // =========================================
  // INIT
  // =========================================

  @override
  void initState() {
    super.initState();

    fetchLogs();
  }

  // =========================================
  // FETCH LOGS
  // =========================================

  void fetchLogs() async {

    var data =
        await LogService.getLogs();

    setState(() {

      logs = data;

      isLoading = false;
    });
  }

  // =========================================
  // UI
  // =========================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Verification Logs"),
        centerTitle: true,
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : logs.isEmpty

              ? const Center(
                  child: Text("No logs found"),
                )

              : ListView.builder(

                  padding:
                      const EdgeInsets.all(16),

                  itemCount: logs.length,

                  itemBuilder:
                      (context, index) {

                    final log = logs[index];

                    final result =
                        log['result'];

                    // =========================================
                    // STATUS SETTINGS
                    // =========================================

                    Color statusColor;

                    IconData statusIcon;

                    String statusText;

                    if (result == 'verified') {

                      statusColor =
                          Colors.green;

                      statusIcon =
                          Icons.check_circle;

                      statusText =
                          "Verified Website";

                    } else {

                      statusColor =
                          Colors.orange;

                      statusIcon =
                          Icons.warning;

                      statusText =
                          "Warning Website";
                    }

                    return Container(

                      margin:
                          const EdgeInsets.only(
                        bottom: 16,
                      ),

                      padding:
                          const EdgeInsets.all(18),

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),

                        boxShadow: const [

                          BoxShadow(
                            color:
                                Colors.black12,
                            blurRadius: 6,
                            offset:
                                Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          // STATUS ICON
                          Container(

                            padding:
                                const EdgeInsets
                                    .all(12),

                            decoration:
                                BoxDecoration(

                              color: statusColor
                                  .withOpacity(
                                0.1,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                14,
                              ),
                            ),

                            child: Icon(
                              statusIcon,
                              color:
                                  statusColor,
                              size: 30,
                            ),
                          ),

                          const SizedBox(
                            width: 16,
                          ),

                          // LOG INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                // WEBSITE
                                Text(
                                  log['website'] ??
                                      'Unknown',

                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                // STATUS
                                Row(
                                  children: [

                                    Icon(
                                      statusIcon,
                                      color:
                                          statusColor,
                                      size: 18,
                                    ),

                                    const SizedBox(
                                      width: 6,
                                    ),

                                    Text(
                                      statusText,

                                      style:
                                          TextStyle(
                                        color:
                                            statusColor,

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
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}