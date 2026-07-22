import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

import '../../config/app_theme.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final MobileScannerController controller =
      MobileScannerController();

  bool isScanned = false;
  bool isResolving = false;

  // =========================================
  // EXTRACT URL FROM QR CONTENT
  // =========================================
  String? extractValidUrl(String rawValue) {
    final String cleaned = rawValue.trim();

    // 1. If full content itself is a valid URL
    final Uri? directUri = Uri.tryParse(cleaned);
    if (directUri != null &&
        (directUri.scheme == 'http' ||
            directUri.scheme == 'https') &&
        directUri.host.isNotEmpty) {
      return cleaned;
    }

    // 2. Try to find URL inside larger text
    final RegExp urlRegex = RegExp(
      r'(https?:\/\/[^\s]+)',
      caseSensitive: false,
    );

    final Match? match =
        urlRegex.firstMatch(cleaned);

    if (match != null) {
      final String extracted =
          match.group(0)!.trim();
      final Uri? extractedUri =
          Uri.tryParse(extracted);

      if (extractedUri != null &&
          (extractedUri.scheme == 'http' ||
              extractedUri.scheme == 'https') &&
          extractedUri.host.isNotEmpty) {
        return extracted;
      }
    }

    return null;
  }

  // =========================================
  // CHECK IF URL IS FROM QR PROVIDER / DYNAMIC QR
  // =========================================
  bool isDynamicQrProvider(String url) {
    final String lower = url.toLowerCase();

    return lower.contains("me-qr.com") ||
        lower.contains("qr-code-generator") ||
        lower.contains("qrco.de") ||
        lower.contains("bit.ly") ||
        lower.contains("tinyurl.com");
  }

  // =========================================
  // TRY TO RESOLVE FINAL DESTINATION URL
  // =========================================
  Future<String> resolveDynamicQrUrl(
      String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "User-Agent": "Mozilla/5.0",
        },
      );

      final String finalUrl =
          response.request?.url.toString() ??
              url;

      print("RESOLVED FINAL URL: $finalUrl");

      return finalUrl;
    } catch (e) {
      print("Dynamic QR resolve error: $e");
      return url;
    }
  }

  // =========================================
  // INVALID QR DIALOG
  // =========================================
  Future<void> showInvalidQrDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20),
        ),
        title: const Text(
          "Invalid QR Code",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "The scanned QR code does not contain a valid website link for donation verification.",
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                isScanned = false;
                isResolving = false;
              });

              await controller.start();
            },
            child: const Text("Scan Again"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Back"),
          ),
        ],
      ),
    );
  }

  // ============================z=============
  // HANDLE SCANNED QR
  // =========================================
  Future<void> handleScannedCode(
      String rawCode) async {
    if (isScanned) return;

    setState(() {
      isScanned = true;
      isResolving = true;
    });

    await controller.stop();

    final String scannedValue =
        rawCode.trim();
    print("SCANNED QR RAW VALUE: $scannedValue");

    final String? validUrl =
        extractValidUrl(scannedValue);

    if (validUrl == null) {
      setState(() {
        isResolving = false;
      });
      await showInvalidQrDialog();
      return;
    }

    String finalUrl = validUrl;

    // If QR looks like a dynamic QR provider link,
    // try to resolve the final destination first
    if (isDynamicQrProvider(validUrl)) {
      finalUrl =
          await resolveDynamicQrUrl(validUrl);
    }

    if (!mounted) return;

    setState(() {
      isResolving = false;
    });

    print(
      "FINAL URL RETURNED TO VERIFY PAGE: $finalUrl",
    );

    Navigator.pop(context, finalUrl);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget buildScannerFrame() {
    return Container(
      width: 270,
      height: 270,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white,
          width: 2.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // top-left
          Positioned(
            top: 0,
            left: 0,
            child: buildCorner(
              top: true,
              left: true,
            ),
          ),

          // top-right
          Positioned(
            top: 0,
            right: 0,
            child: buildCorner(
              top: true,
              left: false,
            ),
          ),

          // bottom-left
          Positioned(
            bottom: 0,
            left: 0,
            child: buildCorner(
              top: false,
              left: true,
            ),
          ),

          // bottom-right
          Positioned(
            bottom: 0,
            right: 0,
            child: buildCorner(
              top: false,
              left: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCorner({
    required bool top,
    required bool left,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 5,
                )
              : BorderSide.none,
          bottom: !top
              ? const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 5,
                )
              : BorderSide.none,
          left: left
              ? const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 5,
                )
              : BorderSide.none,
          right: !left
              ? const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 5,
                )
              : BorderSide.none,
        ),
        borderRadius:
            BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text(
          "Scan QR Code",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            AppTheme.primaryColor,
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),

      body: Stack(
        children: [
          // =========================================
          // CAMERA SCANNER
          // =========================================
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              if (isScanned) return;
              if (capture.barcodes.isEmpty) return;

              final Barcode barcode =
                  capture.barcodes.first;
              final String? code =
                  barcode.rawValue;

              if (code == null ||
                  code.trim().isEmpty) {
                return;
              }

              await handleScannedCode(code);
            },
          ),

          // =========================================
          // DARK OVERLAY
          // =========================================
          Container(
            color: Colors.black.withOpacity(0.25),
          ),

          // =========================================
          // TOP SAFE INSTRUCTION CARD
          // =========================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                0,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.58),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        Colors.white.withOpacity(0.12),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            "Scan Donation QR",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isResolving
                                ? "Resolving the QR destination link. Please wait a moment..."
                                : "Place the donation QR code inside the frame to verify its website destination.",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // =========================================
          // CENTER SCAN FRAME
          // =========================================
          Center(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                buildScannerFrame(),
                const SizedBox(height: 18),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors.black.withOpacity(0.58),
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white
                          .withOpacity(0.10),
                    ),
                  ),
                  child: Text(
                    isResolving
                        ? "Resolving QR destination..."
                        : "Align the QR code within the frame",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =========================================
          // BOTTOM STATUS PANEL
          // =========================================
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.62),
                  borderRadius:
                      BorderRadius.circular(22),
                  border: Border.all(
                    color:
                        Colors.white.withOpacity(0.10),
                  ),
                ),
                child: isResolving
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.6,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              "Resolving QR destination and preparing verification...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Scan a donation QR code containing a valid website link. SafeDonate will return the final destination URL for verification.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}