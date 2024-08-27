import 'package:app/const.dart';
import 'package:app/screens/recipedetails.dart';
import 'package:app/widgets/tilewidget.dart';
import 'package:flutter/material.dart';

class AllIdentifiedRecipes extends StatefulWidget {
  const AllIdentifiedRecipes({super.key});

  @override
  State<AllIdentifiedRecipes> createState() => _AllIdentifiedRecipesState();
}

class _AllIdentifiedRecipesState extends State<AllIdentifiedRecipes> {
  final List<Map<String, dynamic>> recipes = [
    {
      'title': 'Pudim',
      'items': [
        'item 1',
        'item 2',
        'item 3',
        'item A',
        'item B',
        'item C',
        'item D',
        'item A',
      ],
    },
    {
      'title': 'Bolo fofo',
      'items': ['item A', 'item B', 'item C', 'item D'],
    },
    {
      'title': 'Bolo simples de café',
      'items': ['item X', 'item Y'],
    },
    {
      'title': 'Bolo de laranja',
      'items': ['item X', 'item Y'],
    },
    {
      'title': 'Bolo de fubá',
      'items': ['item X', 'item Y'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: Icon(
                Icons.arrow_back,
                size: 32,
                color: darkGreyColor,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Receitas identificadas',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: darkGreyColor),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TiletWidget(
                      title: recipes[index]['title'],
                      items: List<String>.from(recipes[index]['items']),
                      destination: RecipeDetails(
                          title: recipes[index]['title'],
                          items: List<String>.from(recipes[index]['items']), 
                          servings: '16 porções',
                          prepare: ['Bata todos os ingredientes no liquidificador.', 'Coloque em uma forma untada e enfarinhada.', 'Leve ao forno preaquecido e deixe assar, por cerca de 40 minutos', 'Bata todos os ingredientes no liquidificador.', 'Bata todos os ingredientes no liquidificador.','Bata todos os ingredientes no liquidificador.','Bata todos os ingredientes no liquidificador.','Bata todos os ingredientes no liquidificador.',],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
