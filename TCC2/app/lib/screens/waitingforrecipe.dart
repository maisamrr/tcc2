import 'package:app/const.dart';
import 'package:flutter/material.dart';

class WaitingForRecipe extends StatelessWidget {
  const WaitingForRecipe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 80),
        child: Center( 
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              Text(
                'Estamos preparando sua receita...',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkGreyColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(darkGreyColor),
                  strokeWidth: 5.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
