import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:url_launcher/url_launcher.dart'; // Still useful for fallback

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

          // Ensure the URL starts with http or https and is properly encoded
          final modifiedUrl = _ensureValidUrl(url);

          await _launchURLInChrome(modifiedUrl);
          setState(() {
            isProcessing = false;
          });

          controller.resumeCamera();
        }
      }
    });
  }

  // Ensures the URL is valid and starts with "https" if missing
  String _ensureValidUrl(String url) {
    log('Original URL: $url'); // Log the original URL
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return Uri.encodeFull(url);
  }

  Future<void> _launchURLInChrome(String url) async {
    try {
      // Use Android Intent to launch Chrome
      final intent = AndroidIntent(
        action: 'action_view',
        data: url,
        package: 'com.android.chrome', // Force the URL to open in Chrome
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
      log('Launching URL in Chrome: $url');
    } catch (e) {
      // Fallback to using url_launcher if Chrome is not available
      log('Error launching Chrome, falling back to url_launcher: $e');
      await _launchURL(url);
    }
  }

  // Fallback URL launcher using url_launcher plugin
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    // Log the URL to be launched
    log('Trying to launch URL: $url');

    if (await canLaunchUrl(uri)) {
      log('Launching URL with default app: $url');
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Ensure it opens in the external browser
      );
    } else {
      log('Failed to launch URL: $url');
      _showErrorDialog('Could not launch $url');
    }
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}