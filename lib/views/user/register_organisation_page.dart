import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../services/organisation_application_service.dart';

class RegisterOrganisationPage extends StatefulWidget {
  const RegisterOrganisationPage({
    super.key,
  });

  @override
  State<RegisterOrganisationPage> createState() =>
      _RegisterOrganisationPageState();
}

class _RegisterOrganisationPageState
    extends State<RegisterOrganisationPage> {
  final organisationNameController = TextEditingController();
  final registrationNumberController = TextEditingController();
  final descriptionController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final websiteController = TextEditingController();

  String organisationType = "NGO";

  bool isLoading = false;
  bool isPickingLogo = false;

  File? logoFile;
  File? certificateFile;
  File? supportingDocumentFile;

  // =========================================
  // HELPERS
  // =========================================
  bool isPdfFile(String path) {
    return path.toLowerCase().endsWith('.pdf');
  }

  void showPdfOnlyWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Only PDF files are allowed for documents."),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // =========================================
  // PICK + CROP LOGO
  // =========================================
  Future<void> pickLogo() async {
    if (isPickingLogo) return;

    isPickingLogo = true;

    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null) return;

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
            presentStyle: WebPresentStyle.page,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          logoFile = File(croppedFile.path);
        });
      }
    } catch (e) {
      showMessage("Failed to pick logo: $e");
    } finally {
      isPickingLogo = false;
    }
  }

  // =========================================
  // PICK CERTIFICATE (PDF ONLY)
  // =========================================
  Future<void> pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;

      if (!isPdfFile(path)) {
        showPdfOnlyWarning();
        return;
      }

      setState(() {
        certificateFile = File(path);
      });
    }
  }

  // =========================================
  // PICK SUPPORTING DOCUMENT (PDF ONLY)
  // =========================================
  Future<void> pickSupportingDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;

      if (!isPdfFile(path)) {
        showPdfOnlyWarning();
        return;
      }

      setState(() {
        supportingDocumentFile = File(path);
      });
    }
  }

  // =========================================
  // SUBMIT APPLICATION
  // =========================================
  Future<void> submitApplication() async {
    if (organisationNameController.text.trim().isEmpty ||
        registrationNumberController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        websiteController.text.trim().isEmpty) {
      showMessage("Please fill all required fields.");
      return;
    }

    if (logoFile == null || certificateFile == null) {
      showMessage(
        "Please upload the organisation logo and registration certificate.",
      );
      return;
    }

    if (certificateFile != null &&
        !isPdfFile(certificateFile!.path)) {
      showPdfOnlyWarning();
      return;
    }

    if (supportingDocumentFile != null &&
        !isPdfFile(supportingDocumentFile!.path)) {
      showPdfOnlyWarning();
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result =
        await OrganisationApplicationService.submitApplication(
      organisationName: organisationNameController.text.trim(),
      organisationType: organisationType,
      registrationNumber:
          registrationNumberController.text.trim(),
      description: descriptionController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      website: websiteController.text.trim(),
      logo: logoFile!,
      certificate: certificateFile!,
      supportingDocument: supportingDocumentFile,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result != null) {
      if (result["error"] == true) {
        showMessage(result["message"] ?? "Submission failed.");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Application submitted successfully"),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      showMessage("Submission failed.");
    }
  }

  // =========================================
  // LABEL WITH MANDATORY STAR
  // =========================================
  Widget buildFieldLabel(
    String label, {
    bool required = false,
  }) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        children: required
            ? const [
                TextSpan(
                  text: " *",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            : [],
      ),
    );
  }

  // =========================================
  // SECTION CARD
  // =========================================
  Widget buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  // =========================================
  // TEXT FIELD
  // =========================================
  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          buildFieldLabel(
            label,
            required: required,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: "Enter $label",
              filled: true,
              fillColor: const Color(0xFFF9FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // SELECTED FILE TILE
  // =========================================
  Widget buildSelectedFileTile({
    required File file,
    required VoidCallback onRemove,
    required IconData icon,
    Color iconColor = AppTheme.primaryColor,
  }) {
    final fileName = file.path.split('/').last;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(20),
            child: Container(
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
        ],
      ),
    );
  }

  // =========================================
  // UPLOAD CARD
  // =========================================
  Widget buildUploadCard({
    required String title,
    required bool required,
    required String emptyText,
    required IconData icon,
    required VoidCallback onTap,
    required File? file,
    required VoidCallback onRemove,
    bool showPreview = false,
    String? helperText,
    Color iconColor = AppTheme.primaryColor,
  }) {
    final String buttonText =
        file == null ? emptyText : "Choose another file";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          buildFieldLabel(title, required: required),
          const SizedBox(height: 12),

          if (showPreview)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: file != null
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(18),
                              child: Image.file(
                                file,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: onRemove,
                              child: Container(
                                padding:
                                    const EdgeInsets.all(5),
                                decoration:
                                    const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 36,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Logo Preview",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

          if (showPreview) const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(
                icon,
                color: AppTheme.primaryColor,
              ),
              label: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                side: const BorderSide(
                  color: AppTheme.primaryColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          if (file != null && !showPreview)
            buildSelectedFileTile(
              file: file,
              onRemove: onRemove,
              icon: icon,
              iconColor: iconColor,
            ),

          if (helperText != null) ...[
            const SizedBox(height: 10),
            Text(
              helperText,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],

          if (showPreview)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                "Tip: After selecting the logo, you can crop and adjust it to fit inside the frame.(Max. Size: 2048 KB)",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    organisationNameController.dispose();
    registrationNumberController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
        title: const Text(
          "Register Organisation",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    screenWidth > 700 ? 700 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          Color(0xFF9A1F42),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor
                              .withOpacity(0.22),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.apartment_rounded,
                            color: AppTheme.primaryColor,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Organisation Application",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Submit your organisation verification request by completing the form and uploading the required documents.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor
                                .withOpacity(0.10),
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Fields marked with * are required. Registration Certificate and Supporting Document must be uploaded as PDF files only.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  buildSectionCard(
                    title: "Organisation Details",
                    subtitle:
                        "Provide the basic information about your organisation.",
                    icon: Icons.business_rounded,
                    child: Column(
                      children: [
                        buildTextField(
                          "Organisation Name",
                          organisationNameController,
                          required: true,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              buildFieldLabel(
                                "Organisation Type",
                                required: true,
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField(
                                value: organisationType,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      const Color(0xFFF9FAFC),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color:
                                          Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color:
                                          AppTheme.primaryColor,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: "NGO",
                                    child: Text("NGO"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Foundation",
                                    child: Text("Foundation"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Charity",
                                    child: Text("Charity"),
                                  ),
                                  DropdownMenuItem(
                                    value: "CLBG",
                                    child: Text("CLBG"),
                                  ),
                                  DropdownMenuItem(
                                    value:
                                        "Religious Organization",
                                    child: Text(
                                      "Religious Organization",
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    organisationType =
                                        value.toString();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        buildTextField(
                          "Registration Number",
                          registrationNumberController,
                          required: true,
                        ),
                        buildTextField(
                          "Description",
                          descriptionController,
                          required: true,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),

                  buildSectionCard(
                    title: "Contact Information",
                    subtitle:
                        "Add the official contact details for your organisation.",
                    icon: Icons.contact_phone_rounded,
                    child: Column(
                      children: [
                        buildTextField(
                          "Email",
                          emailController,
                          required: true,
                          keyboardType:
                              TextInputType.emailAddress,
                        ),
                        buildTextField(
                          "Phone Number",
                          phoneController,
                          required: true,
                          keyboardType: TextInputType.phone,
                        ),
                        buildTextField(
                          "Address",
                          addressController,
                          required: true,
                          maxLines: 3,
                        ),
                        buildTextField(
                          "Website",
                          websiteController,
                          required: true,
                          keyboardType: TextInputType.url,
                        ),
                      ],
                    ),
                  ),

                  buildSectionCard(
                    title: "Documents & Logo",
                    subtitle:
                        "Upload your organisation logo and supporting documents for verification.",
                    icon: Icons.folder_open_rounded,
                    child: Column(
                      children: [
                        buildUploadCard(
                          title: "Organisation Logo",
                          required: true,
                          emptyText: "Select Organisation Logo",
                          icon: Icons.image_outlined,
                          onTap: pickLogo,
                          file: logoFile,
                          onRemove: () {
                            setState(() {
                              logoFile = null;
                            });
                          },
                          showPreview: true,
                        ),
                        buildUploadCard(
                          title: "Registration Certificate",
                          required: true,
                          emptyText:
                              "Select Registration Certificate (PDF)",
                          icon: Icons.picture_as_pdf,
                          onTap: pickCertificate,
                          file: certificateFile,
                          onRemove: () {
                            setState(() {
                              certificateFile = null;
                            });
                          },
                          helperText:
                              "Accepted format: PDF only. (Max. Size: 4096 KB)",
                          iconColor: Colors.red,
                        ),
                        buildUploadCard(
                          title: "Supporting Document",
                          required: false,
                          emptyText:
                              "Select Supporting Document (PDF)",
                          icon: Icons.description_outlined,
                          onTap: pickSupportingDocument,
                          file: supportingDocumentFile,
                          onRemove: () {
                            setState(() {
                              supportingDocumentFile = null;
                            });
                          },
                          helperText:
                              "Accepted format: PDF only.(Max.Size: 4096 KB)",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : submitApplication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.6,
                              ),
                            )
                          : const Text(
                              "Submit Application",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}