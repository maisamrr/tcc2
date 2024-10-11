import 'dart:convert';
import 'receiptdetails.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  bool dataExtracted = false;
  String? receiptId;

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
                initialUrl = result?.code;
              },
              onPageFinished: (url) async {
                debugPrint('MyApp: ******* Início ******** Página carregada $url');
                if (_isCaptchaResolved(url) && !dataExtracted) {
                  dataExtracted = true;
                  debugPrint('MyApp: Aguardando 10 segundos para a página carregar');
                  await Future.delayed(const Duration(seconds: 10));
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
          receiptId = _generateReceiptId(); 
        });

        final url = result?.code;

        if (url != null && url.isNotEmpty) {
          controller.pauseCamera();
          setState(() {
            isCaptchaPageOpen = true; 
            isProcessing = false; 
          });
        }
      }
    });
  }

  String _generateReceiptId() {
    final now = DateTime.now().toUtc();
    final formatter = DateFormat('ddMMyyyy');
    return formatter.format(now);
  }

  bool _isCaptchaResolved(String currentUrl) {
    if (initialUrl != null && currentUrl != initialUrl) {
      debugPrint('MyApp: CAPTCHA resolvido, URL mudou de $initialUrl para $currentUrl');
      return true;
    }
    return false;
  }

  Future<void> _extractDataAndSendToBackend() async {
    setState(() {
      isProcessing = true;
    });

    try {
      String extractedData = await webViewController!.runJavascriptReturningResult(
        """
        (function() {
          var ulElement = document.querySelector('ul');
          var ulText = ulElement ? ulElement.innerText : '';
          var itemsList = ulText.split('\\n').filter(Boolean);

          // Filter items containing '(Cód: \\w+)'
          itemsList = itemsList.filter(function(item) {
            return /\\(Cód: \\w+\\)/.test(item);
          });

          // Remove ' (Cód: S\\d+)' pattern
          itemsList = itemsList.map(function(item) {
            return item.replace(/\\s\\(Cód: S\\d+\\)/, '');
          });

          // Remove quantities and units
          itemsList = itemsList.map(function(item) {
            return item.replace(/\\d+[Xx]\\d+\\w*|\\d+\\w*|\\d+/g, '').trim();
          });

          // Extract the first word and prepare the final array
          var processedItems = itemsList.map(function(item) {
            var firstWord = item.split(' ')[0];
            return {
              item_name: item,
              first_word: firstWord
            };
          });

          return JSON.stringify(processedItems);
        })();
        """
      );

      extractedData = extractedData.replaceAll('\\n', '').replaceAll('\\"', '"').trim();
      if (extractedData.startsWith('"') && extractedData.endsWith('"')) {
        extractedData = extractedData.substring(1, extractedData.length - 1);
      }
      extractedData = extractedData.replaceAll(r'\"', '"');

      var items = jsonDecode(extractedData);

      if (items.isNotEmpty) {
        debugPrint('MyApp: Extraído $items');

        await _sendDataToBackend(items);

        setState(() {
          isProcessing = false;
          isCaptchaPageOpen = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptDetails(
              title: 'Nota fiscal',
              items: items,
            ),
          ),
        );
      } else {
        debugPrint('MyApp: Falha ao extrair informações.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao extrair informações.')),
        );

        setState(() {
          isProcessing = false;
          isCaptchaPageOpen = false;
        });
      }
    } catch (e) {
      debugPrint('MyApp: Erro ao extrair informações: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao extrair informações.')),
      );

      setState(() {
        isProcessing = false;
        isCaptchaPageOpen = false;
      });
    }
  }

  Future<void> _sendDataToBackend(dynamic items) async {
    const backendUrl = 'http://192.168.0.10:5000/process_receipt';
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': items,
          'receipt_id': receiptId,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('MyApp: Sucesso: ${response.body}');
      } else {
        debugPrint('MyApp: Erro: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao processar informações no servidor.')),
        );
      }
    } catch (e) {
      debugPrint('MyApp: Falha no request para backend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao conectar ao servidor.')),
      );
    }
  }
}