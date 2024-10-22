import 'package:app/const.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/tilewidget.dart';
import 'package:app/screens/recipedetails.dart';

class MatchedRecipesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recipes;

  const MatchedRecipesScreen({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
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
              'Receitas encontradas',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: darkGreyColor,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: recipes.isEmpty
                  ? const Center(
                      child: Text('Nenhuma receita encontrada'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20), 
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        final recipeTitle = recipe['title'] as String;
                        final recipeItems = List<String>.from(recipe['items']);
                        final recipeServings = recipe['servings'] as String;
                        final recipePrepare = List<String>.from(recipe['prepare']);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TiletWidget(
                            title: recipeTitle,
                            items: recipeItems,
                            destination: RecipeDetails(
                              title: recipeTitle,
                              items: recipeItems,
                              servings: recipeServings,
                              prepare: recipePrepare,
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