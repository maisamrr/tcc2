import 'package:app/const.dart';
import 'package:app/screens/scanqrcode.dart';
import 'package:flutter/material.dart';

class ScanQrCodeInstructions extends StatelessWidget {
  const ScanQrCodeInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundIdColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 80),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Instruções',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkGreyColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Text(
                '1) Com a nota fiscal em mãos, posicione a câmera no QR Code e aguarde a leitura\n\n2) Valide o QR Code e aperte em Continuar consulta de NFC-e\n\n3) Aguarde o processamento da nota fiscal\n\n4) Suas receitas serão exibidas',
                style: TextStyle(
                    fontSize: 16, fontFamily: 'Inter', color: darkGreyColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ScanQrCode(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB83E8),
                    side: const BorderSide(
                      color: Color(0xFF343A40),
                      width: 1.0,
                    ),
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
      ),
    );
  }
}
