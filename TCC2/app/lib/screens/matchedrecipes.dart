import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:app/const.dart';
import 'package:app/widgets/tilewidget.dart';
import 'package:app/screens/recipedetails.dart';

class MatchedRecipesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recipes;

  const MatchedRecipesScreen({super.key, required this.recipes});

  Color _getColorForSimilarity(double similarity) {
    if (similarity > 0.7) return Colors.green;
    if (similarity > 0.4) return Colors.yellow;
    return Colors.red;
  }

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
                        final similarityScore = recipe['similarity_score'] as double;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
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
                                ),
                                // Similarity Indicator Widget in the same white container, aligned to the right
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: CircularPercentIndicator(
                                      radius: 20.0,
                                      lineWidth: 4.0,
                                      percent: similarityScore,
                                      center: Text(
                                        '${(similarityScore * 100).toInt()}%',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      progressColor: _getColorForSimilarity(similarityScore),
                                      backgroundColor: Colors.grey.shade300,
                                      circularStrokeCap: CircularStrokeCap.round,
                                    ),
                                  ),
                                ),
                              ],
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
