import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../services/organisation_application_admin_service.dart';
import 'organisation_application_detail_page.dart';

class OrganisationManagePage extends StatefulWidget {
  const OrganisationManagePage({super.key});

  @override
  State<OrganisationManagePage> createState() =>
      _OrganisationManagePageState();
}

class _OrganisationManagePageState
    extends State<OrganisationManagePage> {

  // =========================================
  // VARIABLES
  // =========================================

  List organisations = [];

  bool isLoading = true;

  // =========================================
  // INIT
  // =========================================

  @override
  void initState() {
    super.initState();

    fetchOrganisations();
  }

  // =========================================
  // FETCH APPLICATIONS
  // =========================================

  Future<void> fetchOrganisations() async {

    setState(() {

      isLoading = true;

    });

    var data =
        await OrganisationApplicationAdminService
            .getApplications();

    setState(() {

      organisations = data;

      isLoading = false;

    });

  }

  // =========================================
  // APPROVE
  // =========================================

  Future<void> approveApplication(
      int id) async {

    bool success =
        await OrganisationApplicationAdminService
            .approve(id);

    if (success) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Application approved successfully",
          ),

        ),

      );

      fetchOrganisations();

    }

  }

  // =========================================
  // REJECT
  // =========================================

  Future<void> rejectApplication(
      int id) async {

    bool success =
        await OrganisationApplicationAdminService
            .reject(id);

    if (success) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Application rejected",
          ),

        ),

      );

      fetchOrganisations();

    }

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

        title: const Text(

          "Organisation Applications",

          style: TextStyle(

            color: Colors.white,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

      body: isLoading

          ? const Center(

              child:
                  CircularProgressIndicator(),

            )

          : organisations.isEmpty

              ? const Center(

                  child: Text(

                    "No organisation applications found.",

                    style: TextStyle(
                      fontSize: 16,
                    ),

                  ),

                )

              : ListView.builder(

                  padding:
                      const EdgeInsets.all(16),

                  itemCount:
                      organisations.length,

                  itemBuilder:
                      (context, index) {

                    final organisation =
                        organisations[index];

                    return Card(

                      elevation: 5,

                      color: Colors.white,

                      margin:
                          const EdgeInsets.only(
                        bottom: 18,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),

                      ),

                      child: Padding(

                        padding:
                            const EdgeInsets.all(
                          16,
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                          
                                                      // =========================================
                            // HEADER
                            // =========================================

                            Row(

                              children: [

                                const CircleAvatar(

                                  radius: 28,

                                  backgroundColor:
                                      AppTheme.primaryColor,

                                  child: Icon(

                                    Icons.business,

                                    color: Colors.white,

                                    size: 28,

                                  ),

                                ),

                                const SizedBox(width: 16),

                                Expanded(

                                  child: Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [

                                      Text(

                                        organisation[
                                            'organisation_name'],

                                        style:
                                            const TextStyle(

                                          fontSize: 18,

                                          fontWeight:
                                              FontWeight.bold,

                                        ),

                                      ),

                                      const SizedBox(height: 4),

                                      Text(

                                        organisation[
                                            'organisation_type'],

                                        style:
                                            const TextStyle(

                                          color: Colors.grey,

                                          fontSize: 14,

                                        ),

                                      ),

                                    ],

                                  ),

                                ),

                                Container(

                                  padding:
                                      const EdgeInsets.symmetric(

                                    horizontal: 12,

                                    vertical: 6,

                                  ),

                                  decoration: BoxDecoration(

                                    color:

                                        organisation['status'] == 'pending'

                                            ? Colors.orange.shade100

                                            : organisation['status'] == 'verified'

                                                ? Colors.green.shade100

                                                : Colors.red.shade100,

                                    borderRadius:
                                        BorderRadius.circular(30),

                                  ),

                                  child: Text(

                                    organisation['status']
                                        .toString()
                                        .toUpperCase(),

                                    style: TextStyle(

                                      fontWeight:
                                          FontWeight.bold,

                                      color:

                                          organisation['status'] == 'pending'

                                              ? Colors.orange

                                              : organisation['status'] == 'verified'

                                                  ? Colors.green

                                                  : Colors.red,

                                    ),

                                  ),

                                ),

                              ],

                            ),

                            const SizedBox(height: 20),

                            const Divider(),

                            const SizedBox(height: 10),

                            Row(

                              children: [

                                const Icon(

                                  Icons.language,

                                  color: AppTheme.primaryColor,

                                ),

                                const SizedBox(width: 10),

                                Expanded(

                                  child: Text(

                                    organisation['website'],

                                    style: const TextStyle(

                                      color: Colors.blue,

                                      fontSize: 15,

                                    ),

                                  ),

                                ),

                              ],

                            ),

                            const SizedBox(height: 8),

                            Row(

                              children: [

                                const Icon(

                                  Icons.email_outlined,

                                  color: AppTheme.primaryColor,

                                ),

                                const SizedBox(width: 10),

                                Expanded(

                                  child: Text(

                                    organisation['email'],

                                  ),

                                ),

                              ],

                            ),

                            const SizedBox(height: 8),

                            Row(

                              children: [

                                const Icon(

                                  Icons.phone,

                                  color: AppTheme.primaryColor,

                                ),

                                const SizedBox(width: 10),

                                Expanded(

                                  child: Text(

                                    organisation['phone'],

                                  ),

                                ),

                              ],

                            ),

                            const SizedBox(height: 20),

                            Row(

                              children: [

                                                                Expanded(

                                  child: ElevatedButton.icon(

                                    onPressed: () async {

                                      bool? refresh =
                                          await Navigator.push(

                                        context,

                                        MaterialPageRoute(

                                          builder: (_) =>
                                              OrganisationApplicationDetailPage(

                                            applicationId:
                                                organisation['id'],

                                          ),

                                        ),

                                      );

                                      if (refresh == true) {

                                        fetchOrganisations();

                                      }

                                    },

                                    icon: const Icon(
                                      Icons.visibility,
                                    ),

                                    label: const Text(
                                      "View",
                                    ),

                                    style:
                                        ElevatedButton.styleFrom(

                                      backgroundColor:
                                          AppTheme.primaryColor,

                                      foregroundColor:
                                          Colors.white,

                                      shape:
                                          RoundedRectangleBorder(

                                        borderRadius:
                                            BorderRadius.circular(
                                          10,
                                        ),

                                      ),

                                    ),

                                  ),

                                ),

                                const SizedBox(width: 10),

                                Expanded(

                                  child: ElevatedButton(

                                    onPressed:
                                        organisation['status'] == 'pending'

                                            ? () {

                                                approveApplication(

                                                  organisation['id'],

                                                );

                                              }

                                            : null,

                                    style:
                                        ElevatedButton.styleFrom(

                                      backgroundColor:
                                          Colors.green,

                                      foregroundColor:
                                          Colors.white,

                                      shape:
                                          RoundedRectangleBorder(

                                        borderRadius:
                                            BorderRadius.circular(
                                          10,
                                        ),

                                      ),

                                    ),

                                    child: const Text(
                                      "Approve",
                                    ),

                                  ),

                                ),

                                const SizedBox(width: 10),

                                Expanded(

                                  child: ElevatedButton(

                                    onPressed:
                                        organisation['status'] == 'pending'

                                            ? () {

                                                rejectApplication(

                                                  organisation['id'],

                                                );

                                              }

                                            : null,

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
                                          10,
                                        ),

                                      ),

                                    ),

                                    child: const Text(
                                      "Reject",
                                    ),

                                  ),

                                ),

                              ],

                            ),

                          ],

                        ),

                      ),

                    );

                  },

                ),

    );

  }

}
                            