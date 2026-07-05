import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../services/verification_service.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {

  bool isScanned = false;

  Future<void> verifyUrl(String url) async {

    var result =
        await VerificationService.verify(url);

    if (!mounted) return;

    showDialog(

      context: context,

      builder: (_) => AlertDialog(

        title: const Text(
          "Verification Result",
        ),

        content: Text(
          result?['message'] ??
          "Unable to verify URL",
        ),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(context);

              setState(() {
                isScanned = false;
              });
            },

            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Scan QR Code",
        ),

        centerTitle: true,
      ),

      body: MobileScanner(

        onDetect: (capture) async {

          if (isScanned) return;

          final barcode =
              capture.barcodes.first;

          final String? code =
              barcode.rawValue;

          if (code != null) {

            setState(() {
              isScanned = true;
            });

            await verifyUrl(code);
          }
        },
      ),
    );
  }
}