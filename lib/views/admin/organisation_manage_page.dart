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

class _OrganisationManagePageState extends State<OrganisationManagePage> {
  List organisations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrganisations();
  }

  Future<void> fetchOrganisations() async {
    setState(() {
      isLoading = true;
    });

    final data =
        await OrganisationApplicationAdminService.getApplications();

    if (!mounted) return;

    setState(() {
      organisations = data;
      isLoading = false;
    });
  }

  Future<void> approveApplication(int id) async {
    final success =
        await OrganisationApplicationAdminService.approve(id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Application approved successfully"),
        ),
      );
      fetchOrganisations();
    }
  }

  Future<void> rejectApplication(int id) async {
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reject Application"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add rejection reason for the applicant (optional).",
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter rejection reason",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Reject"),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final success =
        await OrganisationApplicationAdminService.reject(
      id,
      adminRemark: reasonController.text.trim().isEmpty
          ? null
          : reasonController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Application rejected successfully"),
        ),
      );
      fetchOrganisations();
    }
  }

  Color getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade100;
      case 'approved':
      case 'verified':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget buildLogo(dynamic organisation) {
    final logoUrl = organisation['logo_url'];

    if (logoUrl != null && logoUrl.toString().trim().isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.network(
            logoUrl.toString(),
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 56,
                height: 56,
                color: AppTheme.primaryColor.withOpacity(0.10),
                child: const Icon(
                  Icons.business,
                  color: AppTheme.primaryColor,
                  size: 26,
                ),
              );
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.10),
      child: const Icon(
        Icons.business,
        color: AppTheme.primaryColor,
        size: 26,
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13.5,
                color: Colors.black87,
                height: 1.45,
              ),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                TextSpan(
                  text: value.isEmpty ? "-" : value,
                  style: TextStyle(
                    color: valueColor ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyle buildButtonStyle({
    required Color backgroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 46),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
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
              child: CircularProgressIndicator(),
            )
          : organisations.isEmpty
              ? const Center(
                  child: Text(
                    "No organisation applications found.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchOrganisations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: organisations.length,
                    itemBuilder: (context, index) {
                      final organisation = organisations[index];

                      final status =
                          (organisation['status'] ?? 'pending')
                              .toString();

                      final organisationName =
                          (organisation['organisation_name'] ?? "-")
                              .toString();

                      final organisationType =
                          (organisation['organisation_type'] ?? "-")
                              .toString();

                      final submittedByName =
                          (organisation['submitted_by_name'] ?? "")
                              .toString();

                      final submittedByEmail =
                          (organisation['submitted_by_email'] ??
                                  "Unknown applicant")
                              .toString();

                      final website =
                          (organisation['website'] ?? "-").toString();

                      final email =
                          (organisation['email'] ?? "-").toString();

                      final phone =
                          (organisation['phone'] ?? "-").toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // =========================
                              // HEADER
                              // =========================
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  buildLogo(organisation),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          organisationName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                                FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          organisationType,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            color: Colors.grey,
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getStatusBg(status),
                                      borderRadius:
                                          BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            getStatusTextColor(status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // =========================
                              // APPLICANT BOX
                              // =========================
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F2F4),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.person_outline,
                                          size: 16,
                                          color:
                                              AppTheme.primaryColor,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Applicant Information",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w700,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    buildInfoRow(
                                      icon: Icons.badge_outlined,
                                      label: "Name",
                                      value: submittedByName.isEmpty
                                          ? "Unknown applicant"
                                          : submittedByName,
                                    ),
                                    const SizedBox(height: 8),
                                    buildInfoRow(
                                      icon: Icons.email_outlined,
                                      label: "Email",
                                      value: submittedByEmail,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 16),

                              // =========================
                              // ORGANISATION INFO
                              // =========================
                              buildInfoRow(
                                icon: Icons.language,
                                label: "Website",
                                value: website,
                                valueColor: Colors.blue,
                              ),
                              const SizedBox(height: 12),
                              buildInfoRow(
                                icon: Icons.mail_outline,
                                label: "Organisation Email",
                                value: email,
                              ),
                              const SizedBox(height: 12),
                              buildInfoRow(
                                icon: Icons.phone_outlined,
                                label: "Phone",
                                value: phone,
                              ),

                              const SizedBox(height: 20),

                              // =========================
                              // ACTION BUTTONS
                              // =========================
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: status.toLowerCase() ==
                                              'pending'
                                          ? () => approveApplication(
                                                organisation['id'],
                                              )
                                          : null,
                                      style: buildButtonStyle(
                                        backgroundColor:
                                            Colors.green,
                                      ),
                                      child: const Text(
                                        "Approve",
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: status.toLowerCase() ==
                                              'pending'
                                          ? () => rejectApplication(
                                                organisation['id'],
                                              )
                                          : null,
                                      style: buildButtonStyle(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text(
                                        "Reject",
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final refresh =
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
                                    Icons.visibility_outlined,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    "View Details",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: buildButtonStyle(
                                    backgroundColor:
                                        AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}