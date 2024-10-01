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
        currentUrl != initialUrl) {
      debugPrint('MyApp: CAPTCHA resolvido, URL mudou de $initialUrl para $currentUrl');
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
      // placeholder String extractedData = '[{"item_name": "Item 1", "first_word": "Item"},{"item_name": "Item 2", "first_word": "Item"}]';

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

      // Clean up the returned string if necessary
      extractedData = extractedData.replaceAll('\\n', '').replaceAll('\\"', '"').trim();

      String pageContent = await webViewController!.runJavascriptReturningResult(
  "document.documentElement.outerHTML");
      debugPrint('MyApp: ************ HTML da página ********** $pageContent');

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
            builder: (context) => ReceiptDetails(title: 'Nota fiscal', items: [],), // teste
          ),
        );
      } else {
        debugPrint('MyApp: Falha ao extrair informações.');
        // mostrar para o usuario erro
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
      // mostrar para o usuario erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao extrair informações.')),
      );

      setState(() {
        isProcessing = false;
        isCaptchaPageOpen = false;
      });
    }
  }

  // funcao para enviar para o backend
  Future<void> _sendDataToBackend(String data) async {
    const backendUrl = 'http://172.27.2.147:5000/process_receipt';
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
          const SnackBar(content: Text('Falha ao processar informações no servidor.')),
        );
      }
    } catch (e) {
      debugPrint('MyApp: Falha no request para backend: $e');
      // mostrar para o usuario erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao conectar ao servidor.')),
      );
    }
  }
}