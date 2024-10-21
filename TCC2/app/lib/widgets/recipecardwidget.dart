import 'package:app/const.dart';
import 'package:flutter/material.dart';

class RecipeCardWidget extends StatelessWidget {
  final String title;
  final List<String> ingredients;
  final VoidCallback onViewRecipe;

  const RecipeCardWidget({
    super.key,
    required this.title,
    required this.ingredients,
    required this.onViewRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Calcula o espaço disponível para o texto
        double maxTextHeight = constraints.maxHeight - 100; // 100 é um valor estimado para o título, espaçamento, e botão.

        return SizedBox(
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.25),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: darkGreyColor,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Text(
                          ingredients.join(' • '),
                          style: const TextStyle(
                            color: Color(0xFFADB5BD),
                            fontFamily: 'Inter',
                            fontSize: 10,
                          ),
                          maxLines: (maxTextHeight / 12).floor(), // Estima o número máximo de linhas baseado na altura disponível.
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onViewRecipe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFB83E8),
                      side: const BorderSide(
                        color: Color(0xFF343A40),
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Ver mais',
                      style: TextStyle(
                        color: darkGreyColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
