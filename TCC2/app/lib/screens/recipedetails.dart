import 'package:flutter/material.dart';
import 'package:app/const.dart';

class RecipeDetails extends StatelessWidget {
  final String title;
  final List<String> items;
  final String servings;
  final List<String> prepare;

  const RecipeDetails({
    super.key,
    required this.title,
    required this.items,
    required this.servings,
    required this.prepare,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowColor,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                child: GestureDetector(
                  child: Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: darkGreyColor,
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed('/allidentifiedrecipes');
                  },
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkGreyColor),
                    ),
                    GestureDetector(
                  child: Icon(
                    Icons.bookmark_add_outlined,
                    size: 32,
                    color: darkGreyColor,
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed('/allidentifiedrecipes'); //salvar receita
                  },
                ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 48.0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: backgroundIdColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingredientes',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'PP Neue Montreal',
                                color: darkGreyColor),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return Text(
                                items[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  color: darkGreyColor,
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Divider(
                                color: lightGreyColor,
                                thickness: 1,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Rendimento',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'PP Neue Montreal',
                                color: darkGreyColor),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            servings,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Inter',
                              color: darkGreyColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Modo de preparo',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'PP Neue Montreal',
                                color: darkGreyColor),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: prepare.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '${index + 1}. ${prepare[index]}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    color: darkGreyColor,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
