import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

import '../../services/organisation_application_service.dart';

class RegisterOrganisationPage
    extends StatefulWidget {

  const RegisterOrganisationPage({
    super.key,
  });

  @override
  State<RegisterOrganisationPage>
      createState() =>
          _RegisterOrganisationPageState();
}

class _RegisterOrganisationPageState
    extends State<RegisterOrganisationPage> {

  final organisationNameController =
      TextEditingController();

  final registrationNumberController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final addressController =
      TextEditingController();

  final websiteController =
      TextEditingController();

  String organisationType = "NGO";

  bool isLoading = false;
  File? logoFile;

  File? certificateFile;

  File? supportingDocumentFile;

  Future<void> pickLogo() async {

    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {

      setState(() {

        logoFile = File(image.path);

      });

    }
  }

Future<void> pickSupportingDocument() async {

  FilePickerResult? result =
      await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
         allowMultiple: false,
      );

  if (result != null) {

    setState(() {

      supportingDocumentFile =
          File(result.files.single.path!);

    });

  }
}

Future<void> pickCertificate() async {

  FilePickerResult? result =
      await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
              );
  if (result != null) {

    setState(() {

      certificateFile =
          File(result.files.single.path!);

    });

  }
}

  Future<void> submitApplication() async {

  if (organisationNameController.text.isEmpty ||
    registrationNumberController.text.isEmpty ||
    descriptionController.text.isEmpty ||
    emailController.text.isEmpty ||
    phoneController.text.isEmpty ||
    addressController.text.isEmpty ||
    websiteController.text.isEmpty) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please fill all required fields"),
      ),
    );

    return;
  }

  if (logoFile == null || certificateFile == null) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please upload logo and registration certificate",
        ),
      ),
    );

    return;
  }

  setState(() {
    isLoading = true;
  });

  var result =
      await OrganisationApplicationService.submitApplication(

    organisationName: organisationNameController.text,

    organisationType: organisationType,

    registrationNumber: registrationNumberController.text,

    description: descriptionController.text,

    email: emailController.text,

    phone: phoneController.text,

    address: addressController.text,

    website: websiteController.text,

    logo: logoFile!,

    certificate: certificateFile!,

    supportingDocument: supportingDocumentFile,
  );

  setState(() {
    isLoading = false;
  });

  if (result != null) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Application submitted successfully",
        ),
      ),
    );

    Navigator.pop(context);

  } else {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Submission failed",
        ),
      ),
    );
  }
}

  Widget buildTextField(
    String label,
    TextEditingController controller,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(bottom: 15),

            child: TextField(

              controller: controller,

                keyboardType: label == "Website"
                    ? TextInputType.url
                    : label == "Email"
                        ? TextInputType.emailAddress
                        : TextInputType.text,

          decoration: InputDecoration(

              labelText: label,

              border: OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

      backgroundColor: AppTheme.primaryColor,

      title: const Text(

        "Register Organisation",

        style: TextStyle(
          color: Colors.white,
        ),

      ),

      centerTitle: true,

    ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            buildTextField(
              "Organisation Name",
              organisationNameController,
            ),

            DropdownButtonFormField(

              value: organisationType,

              decoration:
                  const InputDecoration(

                labelText:
                    "Organisation Type",
              ),

              items: const [

                DropdownMenuItem(
                  value: "NGO",
                  child: Text("NGO"),
                ),

                DropdownMenuItem(
                  value: "Foundation",
                  child: Text(
                    "Foundation",
                  ),
                ),

                DropdownMenuItem(
                  value: "Charity",
                  child: Text(
                    "Charity",
                  ),
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

            const SizedBox(height: 15),

            buildTextField(
              "Registration Number",
              registrationNumberController,
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Description",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            buildTextField(
              "Email",
              emailController,
            ),

            buildTextField(
              "Phone Number",
              phoneController,
            ),

            buildTextField(
              "Address",
              addressController,
            ),

            buildTextField(
              "Website",
              websiteController,
            ),

            const SizedBox(height: 20),

            // ===============================
            // Organisation Logo
            // ===============================

            SizedBox(

              width: double.infinity,

              child: OutlinedButton.icon(

                onPressed: pickLogo,

                icon: const Icon(Icons.image),

                label: Text(

                  logoFile == null
                  ? "Select Organisation Logo"
                  : logoFile!.path.split('/').last,
                ),
              ),
            ),

            if (logoFile != null)

              Padding(

                padding: const EdgeInsets.only(top: 8),

                child: Image.file(

                  logoFile!,

                  height: 120,

                ),
              ),

            const SizedBox(height: 20),

            // ===============================
            // Registration Certificate
            // ===============================

            SizedBox(

              width: double.infinity,

              child: OutlinedButton.icon(

                onPressed: pickCertificate,

                icon: const Icon(Icons.picture_as_pdf),

                label: Text(

                  certificateFile == null
                      ? "Select Registration Certificate"
                      : certificateFile!.path.split('/').last,

                ),
              ),
            ),

            const SizedBox(height: 20),

          // ===============================
          // Supporting Document (Optional)
          // ===============================

          SizedBox(

            width: double.infinity,

            child: OutlinedButton.icon(

              onPressed: pickSupportingDocument,

              icon: const Icon(Icons.description),

              label: Text(

                supportingDocumentFile == null
                    ? "Supporting Document (Optional)"
                    : supportingDocumentFile!.path.split('/').last,

              ),

            ),

          ),

          const SizedBox(height: 25),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton(

                onPressed:
                    isLoading
                        ? null
                        : submitApplication,

                child: isLoading

                    ? const CircularProgressIndicator()

                    : const Text(
                        "Submit Application",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}