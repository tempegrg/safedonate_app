import 'package:flutter/material.dart';
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

  void fetchLogs() async {
    var data = await LogService.getLogs();

    setState(() {
      logs = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verification Logs"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? const Center(child: Text("No logs found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];

                    final isVerified = log['result'] == 'verified';

                    return ListTile(
                      leading: Icon(
                        isVerified
                            ? Icons.check_circle
                            : Icons.warning,
                        color: isVerified
                            ? Colors.green
                            : Colors.orange,
                      ),
                      title: Text(log['website'] ?? 'Unknown'),
                      subtitle: Text(
                        isVerified
                            ? "Verified - Safe"
                            : "Not recognized",
                      ),
                    );
                  },
                ),
    );
  }
}