import 'dart:convert';
import 'package:app/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'receiptdetails.dart';

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
  String? initialUrl;
  bool dataExtracted = false; // flag para nao fazer varias extracoes

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
            WebView(
              initialUrl: result?.code,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController controller) {
                webViewController = controller;
                initialUrl = result?.code; // salva url inicial
              },
              onPageFinished: (url) async {
                debugPrint('MyApp: Page loaded $url');
                if (_isCaptchaResolved(url) && !dataExtracted) {
                  dataExtracted = true; 
                  await _extractDataAndSendToBackend();
                }
              },
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
            isCaptchaPageOpen = true; // mostrar webview com pagina do captcha
            isProcessing = false; // acabou de escanear
          });
        }
      }
    });
  }

  // checar se captcha foi resolvido
  bool _isCaptchaResolved(String currentUrl) {
    if (initialUrl != null &&
        initialUrl!.startsWith('http://www') &&
        currentUrl.startsWith('https://ww1') &&
        currentUrl != initialUrl) {
      debugPrint('MyApp: CAPTCHA resolvido, URL mudou para: $currentUrl');
      return true;
    }
    return false;
  }

  // funcao para extrair infos do webview e enviar para o backend
  Future<void> _extractDataAndSendToBackend() async {
    setState(() {
      isProcessing = true;
    });

    try {
      // placeholder
      String extractedData = '[{"item_name": "Item 1", "first_word": "Item"},{"item_name": "Item 2", "first_word": "Item"}]';

      if (extractedData.isNotEmpty) {
        debugPrint('MyApp: Extraído $extractedData');
        await _sendDataToBackend(extractedData);

        setState(() {
          isProcessing = false;
          isCaptchaPageOpen = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(), // teste
          ),
        );
      } else {
        debugPrint('MyApp: Falha ao extrair informações.');
        // mostrar para o usuario erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao extrair informações.')),
        );

        setState(() {
          isProcessing = false;
          isCaptchaPageOpen = false;
        });
      }
    } catch (e) {
      debugPrint('MyApp: Erro ao extrair informações: $e');
      // mostrar para o usuario erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao extrair informações.')),
      );

      setState(() {
        isProcessing = false;
        isCaptchaPageOpen = false;
      });
    }
  }

  // funcao para enviar para o backend
  Future<void> _sendDataToBackend(String data) async {
    const backendUrl = 'http://192.168.0.10:5000/process_receipt';
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': data}),
      );

      if (response.statusCode == 200) {
        debugPrint('MyApp: Successo: ${response.body}');
      } else {
        debugPrint('MyApp: Erro: ${response.body}');
        // mostrar para o usuario erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao processar informações no servidor.')),
        );
      }
    } catch (e) {
      debugPrint('MyApp: Falha no request para backend: $e');
      // mostrar para o usuario erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao conectar ao servidor.')),
      );
    }
  }
}