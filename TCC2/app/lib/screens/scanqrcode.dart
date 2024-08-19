import 'package:app/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScanQrCode extends StatefulWidget {
  const ScanQrCode({super.key});

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundIdColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Icon(
                Icons.arrow_back,
                size: 32,
                color: darkGreyColor,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        'Instruções',
                        style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: darkGreyColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Com a nota fiscal em mãos, posicione a câmera no QR Code e aguarde a leitura\nLogo a receita será exibida',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Inter',
                            color: darkGreyColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SvgPicture.asset(
                    'assets/images/camera.svg',
                    width: 0.3 * width,
                    color: darkGreyColor,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Implementação da lógica
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFB83E8),
                        side: const BorderSide(
                            color: Color(0xFF343A40), width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Escanear QR Code',
                          style: TextStyle(
                            color: Color(0xFF343A40),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
