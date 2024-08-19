import 'package:flutter/material.dart';

class FullRecipe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bolo de Chocolate'), // Título da receita
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingredientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Lista completa dos ingredientes
            Text('2 xícaras de farinha'),
            Text('1 xícara de açúcar'),
            Text('1/2 xícara de cacau em pó'),
            // ... continue com os ingredientes
            SizedBox(height: 16),
            Text(
              'Modo de Preparo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Instruções de preparo
            Text('1. Misture todos os ingredientes secos.'),
            Text('2. Adicione os líquidos e misture bem.'),
            Text('3. Asse em forno pré-aquecido por 30 minutos.'),
            // ... continue com as instruções
          ],
        ),
      ),
    );
  }
}
