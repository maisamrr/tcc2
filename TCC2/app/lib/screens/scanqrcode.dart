import 'dart:convert';
import 'package:app/screens/matchedrecipes.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/screens/recipedetails.dart';
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
                debugPrint('Página carregada: $url');
                if (_isCaptchaResolved(url) && !dataExtracted) {
                  dataExtracted = true;
                  await Future.delayed(const Duration(seconds: 10));
                  await _extractDataAndSendToBackend();
                }
              },
            ),
          if (isProcessing)
            // overlay e barra de progresso
            SizedBox.expand(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(
                            0xFFFB83E8)), // Pink color for the progress indicator
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Processando...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'PP Neue Montreal',
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
      debugPrint(
          'CAPTCHA resolvido: URL mudou de $initialUrl para $currentUrl');
      return true;
    }
    return false;
  }

  Future<void> _extractDataAndSendToBackend() async {
    setState(() {
      isProcessing = true;
    });

    try {
      String extractedData =
          await webViewController!.runJavascriptReturningResult("""
        (function() {
          var ulElement = document.querySelector('ul');
          var ulText = ulElement ? ulElement.innerText : '';
          var itemsList = ulText.split('\\n').filter(Boolean);

          itemsList = itemsList.filter(function(item) {
            return /\\(Cód: \\w+\\)/.test(item);
          });

          itemsList = itemsList.map(function(item) {
            return item.replace(/\\s\\(Cód: S\\d+\\)/, '');
          });

          itemsList = itemsList.map(function(item) {
            return item.replace(/\\d+[Xx]\\d+\\w*|\\d+\\w*|\\d+/g, '').trim();
          });

          var processedItems = itemsList.map(function(item) {
            var firstWord = item.split(' ')[0];
            return {
              item_name: item,
              first_word: firstWord
            };
          });

          return JSON.stringify(processedItems);
        })();
        """);

      extractedData =
          extractedData.replaceAll('\\n', '').replaceAll('\\"', '"').trim();
      if (extractedData.startsWith('"') && extractedData.endsWith('"')) {
        extractedData = extractedData.substring(1, extractedData.length - 1);
      }
      extractedData = extractedData.replaceAll(r'\"', '"');

      var items = jsonDecode(extractedData);

      if (items.isNotEmpty) {
        debugPrint('Extraído: $items');
        await _sendDataToBackend(items);

        setState(() {
          isProcessing = false;
          isCaptchaPageOpen = false;
        });
      } else {
        debugPrint('Falha ao extrair informações.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao extrair informações.')),
        );

        setState(() {
          isProcessing = false;
          isCaptchaPageOpen = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao extrair informações: $e');
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
    const backendUrl =
        'https://backend-notasculinarias.onrender.com/process_receipt';
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
        final responseData = jsonDecode(response.body);
        debugPrint('Sucesso: ${response.body}');

        if (responseData != null && responseData is List) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchedRecipesScreen(
                recipes: responseData.map<Map<String, dynamic>>((recipe) {
                  return {
                    'title': recipe['Receita'],
                    'items': List<String>.from(recipe['Ingredientes']),
                    'servings': recipe['Porções'].toString(),
                    'prepare': List<String>.from(recipe['Instruções']),
                    'similarity_score': recipe['similarity_score']
                  };
                }).toList(),
              ),
            ),
          );
        } else {
          debugPrint('Nenhuma receita relevante encontrada.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhuma receita encontrada.')),
          );
        }
      } else {
        debugPrint('Erro no servidor: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Falha ao processar informações no servidor.')),
        );
      }
    } catch (e) {
      debugPrint('Falha na requisição para o backend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao conectar ao servidor.')),
      );
    }
  }
}
