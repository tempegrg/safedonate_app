import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_theme.dart';
import '../../services/organisation_application_service.dart';
import 'register_organisation_page.dart';

class MyApplicationStatusPage extends StatefulWidget {
  const MyApplicationStatusPage({super.key});

  @override
  State<MyApplicationStatusPage> createState() =>
      _MyApplicationStatusPageState();
}

class _MyApplicationStatusPageState
    extends State<MyApplicationStatusPage> {
  Map<String, dynamic>? application;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApplication();
  }

  // =========================================
  // FETCH USER APPLICATION
  // =========================================
  Future<void> fetchApplication() async {
    setState(() {
      isLoading = true;
    });

    final data =
        await OrganisationApplicationService.getMyApplication();

    print("MY APPLICATION DATA: $data");

    if (!mounted) return;

    setState(() {
      application = data;
      isLoading = false;
    });
  }

  // =========================================
  // OPEN DOCUMENT URL
  // =========================================
  Future<void> openDocument(String? url) async {
    if (url == null || url.trim().isEmpty) return;

    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to open document"),
        ),
      );
    }
  }

  // =========================================
  // BUILD FILE URL
  // =========================================
  String? getFullFileUrl(dynamic rawValue) {
    final String value = (rawValue ?? '').toString().trim();

    if (value.isEmpty) return null;

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    return "https://safedonate-backend-production.up.railway.app/storage/$value";
  }

  // =========================================
  // SECTION CARD
  // =========================================
  Widget buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // =========================================
  // INFO TILE
  // =========================================
  Widget buildInfoTile(
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 5,
            child: Text(
              value.isEmpty
                  ? "-"
                  : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w600,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // STATUS CHIP
  // =========================================
  Widget buildStatusChip(String status) {
    final lower = status.toLowerCase();

    Color bgColor;
    Color textColor;
    IconData icon;

    if (lower == 'approved') {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle;
    } else if (lower == 'rejected') {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
      icon = Icons.cancel;
    } else {
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontWeight:
                  FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // EMPTY STATE
  // =========================================
  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor
                    .withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 46,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              "No Application Found",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "You have not submitted any organisation application yet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const RegisterOrganisationPage(),
                    ),
                  ).then((_) {
                    fetchApplication();
                  });
                },
                icon: const Icon(
                  Icons.add_business,
                  color: Colors.white,
                ),
                label: const Text(
                  "Register Organisation",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppTheme.primaryColor,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status =
        (application?['status'] ?? 'pending')
            .toString();

    final adminRemark =
        application?['admin_remark'];

    final certificateUrl = getFullFileUrl(
      application?['certificate_url'] ??
          application?['certificate'],
    );

    final supportingUrl = getFullFileUrl(
      application?['supporting_document_url'] ??
          application?['supporting_document'],
    );

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
          "My Application Status",
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    AppTheme.primaryColor,
              ),
            )
          : application == null
              ? buildEmptyState()
              : RefreshIndicator(
                  color:
                      AppTheme.primaryColor,
                  onRefresh:
                      fetchApplication,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
                                  20),
                          decoration:
                              BoxDecoration(
                            gradient:
                                const LinearGradient(
                              colors: [
                                AppTheme
                                    .primaryColor,
                                Color(
                                    0xFF9A1F42),
                              ],
                              begin:
                                  Alignment.topLeft,
                              end: Alignment
                                  .bottomRight,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme
                                    .primaryColor
                                    .withOpacity(
                                        0.22),
                                blurRadius:
                                    14,
                                offset:
                                    const Offset(
                                        0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Text(
                                "Organisation Application",
                                style:
                                    TextStyle(
                                  color: Colors
                                      .white,
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              const SizedBox(
                                  height: 8),
                              const Text(
                                "Track the review status of your submitted organisation verification request.",
                                style:
                                    TextStyle(
                                  color: Colors
                                      .white70,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(
                                  height: 18),
                              buildStatusChip(
                                  status),
                            ],
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        buildSectionCard(
                          title:
                              "Organisation Information",
                          child: Column(
                            children: [
                              buildInfoTile(
                                "Organisation Name",
                                (application![
                                            'organisation_name'] ??
                                        '-')
                                    .toString(),
                              ),
                              buildInfoTile(
                                "Organisation Type",
                                (application![
                                            'organisation_type'] ??
                                        '-')
                                    .toString(),
                              ),
                              buildInfoTile(
                                "Registration Number",
                                (application![
                                            'registration_number'] ??
                                        '-')
                                    .toString(),
                              ),
                              buildInfoTile(
                                "Email",
                                (application![
                                            'email'] ??
                                        '-')
                                    .toString(),
                              ),
                              buildInfoTile(
                                "Phone Number",
                                (application![
                                            'phone'] ??
                                        '-')
                                    .toString(),
                              ),
                              buildInfoTile(
                                "Website",
                                (application![
                                            'website'] ??
                                        '-')
                                    .toString(),
                              ),
                              buildInfoTile(
                                "Address",
                                (application![
                                            'address'] ??
                                        '-')
                                    .toString(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                            height: 18),

                        buildSectionCard(
                          title:
                              "Organisation Description",
                          child: Text(
                            (application![
                                        'description'] ??
                                    'No description available')
                                .toString(),
                            style:
                                const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors
                                  .black87,
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 18),

                        buildSectionCard(
                          title:
                              "Uploaded Documents",
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding:
                                    EdgeInsets.zero,
                                leading:
                                    const Icon(
                                  Icons
                                      .picture_as_pdf,
                                  color: Colors.red,
                                ),
                                title: const Text(
                                  "Registration Certificate",
                                ),
                                trailing:
                                    ElevatedButton(
                                  onPressed:
                                      certificateUrl !=
                                              null
                                          ? () => openDocument(
                                              certificateUrl)
                                          : null,
                                  style: ElevatedButton
                                      .styleFrom(
                                    backgroundColor:
                                        AppTheme.primaryColor,
                                    foregroundColor:
                                        Colors
                                            .white,
                                  ),
                                  child:
                                      const Text(
                                    "Open",
                                  ),
                                ),
                              ),
                              if (supportingUrl !=
                                  null)
                                ListTile(
                                  contentPadding:
                                      EdgeInsets
                                          .zero,
                                  leading:
                                      const Icon(
                                    Icons
                                        .description,
                                    color: AppTheme
                                        .primaryColor,
                                  ),
                                  title:
                                      const Text(
                                    "Supporting Document",
                                  ),
                                  trailing:
                                      ElevatedButton(
                                    onPressed: () =>
                                        openDocument(
                                            supportingUrl),
                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          AppTheme.primaryColor,
                                      foregroundColor:
                                          Colors
                                              .white,
                                    ),
                                    child:
                                        const Text(
                                      "Open",
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        if (status
                                    .toLowerCase() ==
                                'rejected' &&
                            adminRemark != null &&
                            adminRemark
                                .toString()
                                .trim()
                                .isNotEmpty) ...[
                          const SizedBox(
                              height: 18),
                          buildSectionCard(
                            title:
                                "Rejection Reason",
                            child: Text(
                              adminRemark
                                  .toString(),
                              style:
                                  const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors
                                    .black87,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(
                            height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }
}