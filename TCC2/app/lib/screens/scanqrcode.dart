import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class ScanQrCode extends StatefulWidget {
  const ScanQrCode({super.key});

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isProcessing = false;
  bool isCaptchaPageOpen = false;
  WebViewController? webViewController;
  String? initialUrl; // Store the initial URL here
  bool captchaSolved = false; // Track if CAPTCHA has been solved

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          if (!isCaptchaPageOpen)
            Column(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: Colors.red,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 250,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: (result != null)
                        ? Text('QR Code: ${result!.code}')
                        : const Text('Escaneie um QR Code'),
                  ),
                ),
              ],
            ),
          if (isCaptchaPageOpen)
            Column(
              children: [
                Expanded(
                  flex: 5,
                  child: WebView(
                    initialUrl: result?.code, // Open the scanned URL in WebView
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController controller) {
                      webViewController = controller;
                      initialUrl = result?.code; // Save the initial URL
                    },
                    onPageFinished: (url) {
                      // No longer auto-trigger backend call; let the user click a button
                      log('Page loaded: $url');
                    },
                  ),
                ),
                // Add a button for the user to click when the CAPTCHA is solved
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // When the user presses the button, process the URL
                      String? currentUrl = await webViewController?.currentUrl();
                      if (currentUrl != null && _isCaptchaResolved(currentUrl)) {
                        await _sendUrlToBackend(currentUrl);
                      } else {
                        log('CAPTCHA not resolved yet.');
                      }
                    },
                    child: const Text('CAPTCHA Solved'),
                  ),
                ),
              ],
            ),
          if (isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      if (!isProcessing) {
        setState(() {
          isProcessing = true;
          result = scanData;
        });

        final url = result?.code;

        if (url != null && url.isNotEmpty) {
          controller.pauseCamera();
          setState(() {
            isCaptchaPageOpen = true; // Show the WebView with the CAPTCHA page
            isProcessing = false; // QR scanning is done, set isProcessing to false here
          });
        }
      }
    });
  }

  // Check if CAPTCHA is resolved by comparing the URL structure
  bool _isCaptchaResolved(String currentUrl) {
    // Check if the URL has changed to the format "https://ww1..."
    if (initialUrl != null &&
        currentUrl.startsWith('https://ww1') &&
        currentUrl != initialUrl) {
      log('CAPTCHA solved, URL changed to: $currentUrl');
      return true; // CAPTCHA resolved
    }
    return false;
  }

  // Function to send the URL to the backend after CAPTCHA is resolved
  Future<void> _sendUrlToBackend(String url) async {
    setState(() {
      isProcessing = true; // Start processing the backend request
    });

    const backendUrl = 'http://localhost:5000/process_receipt'; // Your Flask backend URL
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode == 200) {
        log("Success: ${response.body}");
      } else {
        log("Error: ${response.body}");
      }
    } catch (e) {
      log("Backend request failed: $e");
    } finally {
      setState(() {
        isProcessing = false;
        isCaptchaPageOpen = false; // Close WebView and return to the QR scanner
        captchaSolved = false; // Reset captcha state
      });

      // Optionally, resume the camera to allow scanning another QR code
      controller?.resumeCamera();
    }
  }
}
