import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_theme.dart';
import '../../services/organisation_application_admin_service.dart';

class OrganisationApplicationDetailPage extends StatefulWidget {
  final int applicationId;

  const OrganisationApplicationDetailPage({
    super.key,
    required this.applicationId,
  });

  @override
  State<OrganisationApplicationDetailPage> createState() =>
      _OrganisationApplicationDetailPageState();
}

class _OrganisationApplicationDetailPageState
    extends State<OrganisationApplicationDetailPage> {

  bool isLoading = true;

  Map<String, dynamic>? application;

  @override
  void initState() {
    super.initState();
    loadApplication();
  }

  // ===========================================
  // LOAD APPLICATION
  // ===========================================
  Future<void> loadApplication() async {

    var result =
        await OrganisationApplicationAdminService
            .getApplication(widget.applicationId);

    // ===========================================
    // DEBUG
    // ===========================================

    print("=======================================");
    print("APPLICATION DATA");
    print(result);
    print("=======================================");

    if (result != null) {

      // Android Emulator cannot access localhost.
      // Replace localhost/127.0.0.1 with 10.0.2.2

      if (result["logo_url"] != null) {

        result["logo_url"] = result["logo_url"]
            .toString()
            .replaceAll("localhost", "10.0.2.2")
            .replaceAll("127.0.0.1", "10.0.2.2");
      }

      if (result["certificate_url"] != null) {

        result["certificate_url"] = result["certificate_url"]
            .toString()
            .replaceAll("localhost", "10.0.2.2")
            .replaceAll("127.0.0.1", "10.0.2.2");
      }

      if (result["supporting_document_url"] != null) {

        result["supporting_document_url"] =
            result["supporting_document_url"]
                .toString()
                .replaceAll("localhost", "10.0.2.2")
                .replaceAll("127.0.0.1", "10.0.2.2");
      }

    }

    setState(() {

      application = result;

      isLoading = false;

    });

  }

  // ===========================================
  // OPEN DOCUMENT
  // ===========================================

    Future<void> openDocument(String url) async {

    print("================================");
    print("Opening Document:");
    print(url);
    print("================================");

    final uri = Uri.parse(url);

    try {

      bool launched = await launchUrl(

        uri,

        mode: LaunchMode.externalApplication,

      );

      if (!launched) {

        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(

              content: Text(
                "Unable to open document.",
              ),

            ),

          );

        }

      }

    } catch (e) {

      print(e);

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text(
              "Error: $e",
            ),

          ),

        );

      }

    }

  }

  // ===========================================
  // APPROVE
  // ===========================================

  Future<void> approve() async {

    bool success =
        await OrganisationApplicationAdminService
            .approve(widget.applicationId);

    if (success && mounted) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Organisation approved successfully",
          ),

        ),

      );

      Navigator.pop(context, true);

    }

  }

  // ===========================================
  // REJECT
  // ===========================================

  Future<void> reject() async {

    bool success =
        await OrganisationApplicationAdminService
            .reject(widget.applicationId);

    if (success && mounted) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Application rejected",
          ),

        ),

      );

      Navigator.pop(context, true);

    }

  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );

    }

    if (application == null) {

      return const Scaffold(

        body: Center(

          child: Text(
            "Application not found",
          ),

        ),

      );

    }

    return Scaffold(

      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(

        backgroundColor: AppTheme.primaryColor,

        centerTitle: true,

        title: const Text(

          "Application Details",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),

        ),

      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

                    // ===========================================
            // ORGANISATION HEADER
            // ===========================================

            Center(

              child: CircleAvatar(

                radius: 50,

                backgroundColor: AppTheme.primaryColor,

                child: const Icon(

                  Icons.business,

                  color: Colors.white,

                  size: 50,

                ),

              ),

            ),

            const SizedBox(height: 20),

            Center(

              child: Text(

                application!['organisation_name'] ?? "-",

                style: const TextStyle(

                  fontSize: 24,

                  fontWeight: FontWeight.bold,

                ),

                textAlign: TextAlign.center,

              ),

            ),

            const SizedBox(height: 5),

            Center(

              child: Text(

                application!['organisation_type'] ?? "-",

                style: const TextStyle(

                  color: Colors.grey,

                  fontSize: 16,

                ),

              ),

            ),

            const SizedBox(height: 25),

            // ===========================================
            // INFORMATION CARD
            // ===========================================

            Card(

              elevation: 4,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(18),

              ),

              child: Padding(

                padding: const EdgeInsets.all(18),

                child: Column(

                  children: [

                    buildInfoTile(

                      "Registration No",

                      application!['registration_number'],

                    ),

                    buildInfoTile(

                      "Email",

                      application!['email'],

                    ),

                    buildInfoTile(

                      "Phone",

                      application!['phone'],

                    ),

                    buildInfoTile(

                      "Website",

                      application!['website'],

                    ),

                    buildInfoTile(

                      "Address",

                      application!['address'],

                    ),

                  ],

                ),

              ),

            ),

            const SizedBox(height: 20),

            // ===========================================
            // DESCRIPTION
            // ===========================================

            Card(

              elevation: 4,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(18),

              ),

              child: Padding(

                padding: const EdgeInsets.all(18),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(

                      "Organisation Description",

                      style: TextStyle(

                        fontSize: 18,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                    const SizedBox(height: 12),

                    Text(

                      application!['description'] ?? "-",

                      style: const TextStyle(

                        fontSize: 15,

                      ),

                    ),

                  ],

                ),

              ),

            ),

            const SizedBox(height: 20),

                        // ===========================================
            // DOCUMENTS
            // ===========================================

            Card(

              elevation: 4,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(18),

              ),

              child: Padding(

                padding: const EdgeInsets.all(18),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(

                      "Uploaded Documents",

                      style: TextStyle(

                        fontSize: 18,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                    const SizedBox(height: 15),

                    ListTile(

                      leading: const Icon(

                        Icons.picture_as_pdf,

                        color: Colors.red,

                      ),

                      title: const Text(
                        "Registration Certificate",
                      ),

                      trailing: ElevatedButton(

                        onPressed: () {

                          openDocument(
                            application!['certificate_url'],
                          );

                        },

                        style: ElevatedButton.styleFrom(

                          backgroundColor:
                              AppTheme.primaryColor,

                          foregroundColor:
                              Colors.white,

                        ),

                        child: const Text("Open"),

                      ),

                    ),

                    if (application![
                            'supporting_document_url'] !=
                        null)

                      ListTile(

                        leading: const Icon(

                          Icons.description,

                          color: AppTheme.primaryColor,

                        ),

                        title: const Text(
                          "Supporting Document",
                        ),

                        trailing: ElevatedButton(

                          onPressed: () {

                            openDocument(

                              application![
                                  'supporting_document_url'],

                            );

                          },

                          style: ElevatedButton.styleFrom(

                            backgroundColor:
                                AppTheme.primaryColor,

                            foregroundColor:
                                Colors.white,

                          ),

                          child: const Text("Open"),

                        ),

                      ),

                  ],

                ),

              ),

            ),

            const SizedBox(height: 30),

            // ===========================================
            // ACTION BUTTONS
            // ===========================================

            Row(

              children: [

                Expanded(

                  child: ElevatedButton(

                    onPressed: approve,

                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.green,

                      foregroundColor: Colors.white,

                      minimumSize: const Size(0, 55),

                    ),

                    child: const Text(

                      "Approve",

                      style: TextStyle(

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                  ),

                ),

                const SizedBox(width: 15),

                Expanded(

                  child: ElevatedButton(

                    onPressed: reject,

                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.red,

                      foregroundColor: Colors.white,

                      minimumSize: const Size(0, 55),

                    ),

                    child: const Text(

                      "Reject",

                      style: TextStyle(

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                  ),

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }

  // ===========================================
  // REUSABLE INFO TILE
  // ===========================================

  Widget buildInfoTile(

    String title,

    dynamic value,

  ) {

    return Padding(

      padding: const EdgeInsets.symmetric(

        vertical: 8,

      ),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          SizedBox(

            width: 140,

            child: Text(

              title,

              style: const TextStyle(

                fontWeight: FontWeight.bold,

              ),

            ),

          ),

          Expanded(

            child: Text(

              value?.toString() ?? "-",

            ),

          ),

        ],

      ),

    );

  }

}
