import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/app_theme.dart';
import '../../services/organisation_application_admin_service.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

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
  bool isPickingLogo = false;

  Map<String, dynamic>? application;

  @override
  void initState() {
    super.initState();
    loadApplication();
  }

  Future<void> loadApplication() async {
    setState(() {
      isLoading = true;
    });

    final result =
        await OrganisationApplicationAdminService.getApplication(
      widget.applicationId,
    );

    if (!mounted) return;

    setState(() {
      application = result;
      isLoading = false;
    });
  }

  // =========================================
  // HELPERS
  // =========================================
  bool isPdfFile(String path) {
    return path.toLowerCase().endsWith('.pdf');
  }

  void showPdfOnlyWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Only PDF files are allowed."),
        backgroundColor: Colors.red,
      ),
    );
  }

  // =========================================
  // OPEN DOCUMENT INSIDE APP
  // =========================================
  void openDocumentInApp(String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InAppDocumentViewerPage(
          title: title,
          url: url,
        ),
      ),
    );
  }

  // =========================================
  // FILE PICKER
  // =========================================
  Future<File?> pickSingleFile({
    required List<String> allowedExtensions,
    bool pdfOnly = false,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;

      if (pdfOnly && !isPdfFile(path)) {
        showPdfOnlyWarning();
        return null;
      }

      return File(path);
    }

    return null;
  }

  Future<File?> pickAndCropLogo() async {
  if (isPickingLogo) return null;

  isPickingLogo = true;

  try {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (image == null) return null;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      compressFormat: ImageCompressFormat.png,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Organisation Logo',
          toolbarColor: AppTheme.primaryColor,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.white,
          activeControlsWidgetColor: AppTheme.primaryColor,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.square,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop Organisation Logo',
          aspectRatioLockEnabled: false,
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    if (croppedFile == null) return null;

    return File(croppedFile.path);
  } catch (e) {
    if (!mounted) return null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to pick logo: $e"),
      ),
    );

    return null;
  } finally {
    isPickingLogo = false;
  }
}

  // =========================================
  // APPROVE
  // =========================================
  Future<void> approve() async {
    final success =
        await OrganisationApplicationAdminService.approve(
      widget.applicationId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Organisation approved successfully"),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to approve application"),
        ),
      );
    }
  }

  // =========================================
  // REJECT
  // =========================================
  Future<void> reject() async {
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
      widget.applicationId,
      adminRemark: reasonController.text.trim().isEmpty
          ? null
          : reasonController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Application rejected"),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to reject application"),
        ),
      );
    }
  }

  // =========================================
  // DELETE APPLICATION
  // =========================================
  Future<void> deleteApplication() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Application"),
        content: const Text(
          "Are you sure you want to delete this application? This action cannot be undone.",
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
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success =
        await OrganisationApplicationAdminService.deleteApplication(
      widget.applicationId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Application deleted successfully"),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete application"),
        ),
      );
    }
  }

  // =========================================
  // EDIT APPLICATION + FILES
  // =========================================
  Future<void> editApplication() async {
    if (application == null) return;

    final orgNameController = TextEditingController(
      text: application!['organisation_name']?.toString() ?? '',
    );
    final orgTypeController = TextEditingController(
      text: application!['organisation_type']?.toString() ?? '',
    );
    final regNoController = TextEditingController(
      text: application!['registration_number']?.toString() ?? '',
    );
    final descController = TextEditingController(
      text: application!['description']?.toString() ?? '',
    );
    final emailController = TextEditingController(
      text: application!['email']?.toString() ?? '',
    );
    final phoneController = TextEditingController(
      text: application!['phone']?.toString() ?? '',
    );
    final addressController = TextEditingController(
      text: application!['address']?.toString() ?? '',
    );
    final websiteController = TextEditingController(
      text: application!['website']?.toString() ?? '',
    );

    File? selectedLogoFile;
    File? selectedCertificateFile;
    File? selectedSupportingDocumentFile;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildFilePickerTile({
              required IconData icon,
              required Color iconColor,
              required String placeholder,
              required File? file,
              required VoidCallback onChoose,
              required VoidCallback onRemove,
            }) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: iconColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          if (file != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                file,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Icon(
                              icon,
                              color: iconColor,
                              size: 40,
                            ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              file != null
                                  ? file.path.split('/').last
                                  : placeholder,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (file != null)
                      InkWell(
                        onTap: onRemove,
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    TextButton(
                      onPressed: onChoose,
                      child: Text(file == null ? "Choose" : "Change"),
                    ),
                  ],
                ),
              );
            }

            return AlertDialog(
              title: const Text("Edit Application"),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildDialogField(
                        controller: orgNameController,
                        label: "Organisation Name",
                      ),
                      const SizedBox(height: 12),
                      buildDialogField(
                        controller: orgTypeController,
                        label: "Organisation Type",
                      ),
                      const SizedBox(height: 12),
                      buildDialogField(
                        controller: regNoController,
                        label: "Registration Number",
                      ),
                      const SizedBox(height: 12),
                      buildDialogField(
                        controller: emailController,
                        label: "Email",
                      ),
                      const SizedBox(height: 12),
                      buildDialogField(
                        controller: phoneController,
                        label: "Phone",
                      ),
                      const SizedBox(height: 12),
                      buildDialogField(
                        controller: websiteController,
                        label: "Website",
                      ),
                      const SizedBox(height: 12),
                      buildDialogField(
                        controller: addressController,
                        label: "Address",
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      buildDialogField(
                        controller: descController,
                        label: "Description",
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Update Files",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // LOGO
                      buildFilePickerTile(
                        icon: Icons.image,
                        iconColor: AppTheme.primaryColor,
                        placeholder: "Change Logo (optional)",
                        file: selectedLogoFile,
                        onChoose: () async {
                          final file = await pickAndCropLogo();

                          if (file != null) {
                            setDialogState(() {
                              selectedLogoFile = file;
                            });
                          }
                        },
                        onRemove: () {
                          setDialogState(() {
                            selectedLogoFile = null;
                          });
                        },
                      ),

                      // CERTIFICATE
                      buildFilePickerTile(
                        icon: Icons.picture_as_pdf,
                        iconColor: Colors.red,
                        placeholder: "Change Certificate (PDF only)",
                        file: selectedCertificateFile,
                        onChoose: () async {
                          final file = await pickSingleFile(
                            allowedExtensions: ['pdf'],
                            pdfOnly: true,
                          );
                          if (file != null) {
                            setDialogState(() {
                              selectedCertificateFile = file;
                            });
                          }
                        },
                        onRemove: () {
                          setDialogState(() {
                            selectedCertificateFile = null;
                          });
                        },
                      ),

                      // SUPPORTING DOCUMENT
                      buildFilePickerTile(
                        icon: Icons.description,
                        iconColor: AppTheme.primaryColor,
                        placeholder:
                            "Change Supporting Document (PDF only)",
                        file: selectedSupportingDocumentFile,
                        onChoose: () async {
                          final file = await pickSingleFile(
                            allowedExtensions: ['pdf'],
                            pdfOnly: true,
                          );
                          if (file != null) {
                            setDialogState(() {
                              selectedSupportingDocumentFile = file;
                            });
                          }
                        },
                        onRemove: () {
                          setDialogState(() {
                            selectedSupportingDocumentFile = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    final success =
        await OrganisationApplicationAdminService.updateApplication(
      id: widget.applicationId,
      organisationName: orgNameController.text.trim(),
      organisationType: orgTypeController.text.trim(),
      registrationNumber: regNoController.text.trim(),
      description: descController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      website: websiteController.text.trim(),
      logoFile: selectedLogoFile,
      certificateFile: selectedCertificateFile,
      supportingDocumentFile: selectedSupportingDocumentFile,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Application updated successfully"),
        ),
      );
      await loadApplication();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update application"),
        ),
      );
    }
  }

  // =========================================
  // UI HELPERS
  // =========================================
  Widget buildDialogField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget buildInfoTile(
    String title,
    dynamic value, {
    bool canCopy = true,
  }) {
    final displayValue =
        value?.toString().trim().isNotEmpty == true
            ? value.toString()
            : "-";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: SelectableText(
              displayValue,
              style: const TextStyle(
                height: 1.4,
              ),
            ),
          ),

          if (canCopy)
            IconButton(
              tooltip: "Copy",
              icon: const Icon(
                Icons.copy_rounded,
                size: 18,
                color: Colors.grey,
              ),
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: displayValue),
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Copied to clipboard"),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget buildDocumentTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String? url,
  }) {
    final hasUrl = url != null && url.trim().isNotEmpty;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(title),
      trailing: ElevatedButton(
        onPressed: hasUrl
            ? () => openDocumentInApp(title, url!)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        child: const Text("View"),
      ),
    );
  }

  Widget buildLogo(dynamic logoUrl) {
    if (logoUrl != null && logoUrl.toString().trim().isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.network(
            logoUrl.toString(),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                color: Colors.white,
                child: const Icon(
                  Icons.business,
                  color: AppTheme.primaryColor,
                  size: 50,
                ),
              );
            },
          ),
        ),
      );
    }

    return const CircleAvatar(
      radius: 50,
      backgroundColor: AppTheme.primaryColor,
      child: Icon(
        Icons.business,
        color: Colors.white,
        size: 50,
      ),
    );
  }

  Color getStatusBackgroundColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (application == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(
          child: Text("Application not found"),
        ),
      );
    }

    final status =
        (application!['status'] ?? 'pending').toString();
    final isPending = status.toLowerCase() == 'pending';

    final logoUrl = application!['logo_url'];
    final applicantName =
        application!['submitted_by_name'] ?? "Unknown";
    final applicantEmail =
        application!['submitted_by_email'] ?? "No email";
    final adminRemark = application!['admin_remark'];

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
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: editApplication,
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: "Edit",
          ),
          IconButton(
            onPressed: deleteApplication,
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: "Delete",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadApplication,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: buildLogo(logoUrl),
              ),
              const SizedBox(height: 18),

              Center(
                child: Text(
                  application!['organisation_name'] ?? "-",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Center(
                child: Text(
                  application!['organisation_type'] ?? "-",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusBackgroundColor(status),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getStatusTextColor(status),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              buildSectionCard(
                title: "Applicant Information",
                child: Column(
                  children: [
                    buildInfoTile(
                      "Submitted By",
                      applicantName,
                      canCopy: false,
                    ),

                    buildInfoTile(
                      "Applicant Email",
                      applicantEmail,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              buildSectionCard(
                title: "Organisation Information",
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

              const SizedBox(height: 18),

              buildSectionCard(
                title: "Organisation Description",
                child: SelectableText(
                  application!['description'] ?? "-",
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),

              const SizedBox(height: 18),

              buildSectionCard(
                title: "Uploaded Documents",
                child: Column(
                  children: [
                    buildDocumentTile(
                      icon: Icons.picture_as_pdf,
                      iconColor: Colors.red,
                      title: "Registration Certificate",
                      url: application!['certificate_url']?.toString(),
                    ),
                    if (application!['supporting_document_url'] != null)
                      buildDocumentTile(
                        icon: Icons.description,
                        iconColor: AppTheme.primaryColor,
                        title: "Supporting Document",
                        url: application!['supporting_document_url']
                            ?.toString(),
                      ),
                  ],
                ),
              ),

              if (status.toLowerCase() == 'rejected' &&
                  adminRemark != null &&
                  adminRemark.toString().trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                buildSectionCard(
                  title: "Rejection Reason",
                  child: SelectableText(
                    adminRemark.toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              if (isPending)
                Row(
                  children: [
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
                    const SizedBox(width: 15),
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
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================
// IN-APP DOCUMENT VIEWER PAGE
// =========================================
class InAppDocumentViewerPage extends StatefulWidget {
  final String title;
  final String url;

  const InAppDocumentViewerPage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<InAppDocumentViewerPage> createState() =>
      _InAppDocumentViewerPageState();
}

class _InAppDocumentViewerPageState
    extends State<InAppDocumentViewerPage> {
  late final WebViewController controller;
  bool isPageLoading = true;

  bool get isPdf {
    final lowerUrl = widget.url.toLowerCase();
    return lowerUrl.endsWith('.pdf') ||
        lowerUrl.contains('/certificate/') ||
        lowerUrl.contains('/supporting-document/');
  }

  @override
  void initState() {
    super.initState();

    final targetUrl = isPdf
        ? 'https://docs.google.com/gview?embedded=1&url=${Uri.encodeComponent(widget.url)}'
        : widget.url;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              isPageLoading = true;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              isPageLoading = false;
            });
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              isPageLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Failed to load document: ${error.description}",
                ),
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(targetUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isPageLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}