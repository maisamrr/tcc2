import 'package:app/const.dart';
import 'package:app/screens/fullrecipe.dart';
import 'package:app/widgets/profilepicwidget.dart';
import 'package:app/widgets/recipecard.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/bottomnavbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Map<String, dynamic>> recipes = [
    {
      'title': 'Bolo de Chocolate',
      'ingredients': [
        '2 xícaras de farinha',
        '1 xícara de açúcar',
        '1/2 xícara de cacau em pó'
      ],
      'onViewRecipe': () {},
    },
    {
      'title': 'Panquecas',
      'ingredients': [
        '2 xícaras de farinha',
        '1 xícara de açúcar',
        '1/2 xícara de cacau em pó',
        '2 xícaras de farinha',
        '1 xícara de açúcar',
        '2 xícaras de farinha',
        '1 xícara de açúcar',
        '2 xícaras de farinha',
        '1 xícara de açúcar',
      ],
      'onViewRecipe': () {},
    },
    {
      'title': 'Lasanha',
      'ingredients': [
        '2 xícaras de farinha',
        '1 xícara de açúcar',
        '1/2 xícara de cacau em pó',
        '2 xícaras de farinha',
        '1 xícara de açúcar',
        '2 xícaras de farinha',
        '1 xícara de açúcar'
      ],
      'onViewRecipe': () {},
    },
    {
      'title': 'Feijoada',
      'ingredients': [
        '2 xícaras de farinha',
        '1 xícara de açúcar',
        '1/2 xícara de cacau em pó',
        '2 xícaras de farinha',
        '1 xícara de açúcar',
        '2 xícaras de farinha',
        '1 xícara de açúcar',
      ],
      'onViewRecipe': () {},
    },
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundIdColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              children: [
                // Imagem de fundo
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/back04.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Conteúdo principal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Foto
                              const ProfilePicWidget(),
                              // Nome
                              Padding(
                                padding: const EdgeInsets.only(left: 24.0),
                                child: Text(
                                  "Olá, Usuária", // Mudar nome
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: darkGreyColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Configurações
                          GestureDetector(
                            child: Icon(
                              Icons.settings,
                              size: 32,
                              color: darkGreyColor,
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/configuracoes');
                            },
                          ),
                        ],
                      ),
                    ),
                    // Receitas
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Suas receitas',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: darkGreyColor),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: MediaQuery.of(context)
                                            .size
                                            .width /
                                        (MediaQuery.of(context).size.height /
                                            1.8),
                                  ),
                                  itemCount: recipes.length,
                                  itemBuilder: (context, index) {
                                    return RecipeCard(
                                      title: recipes[index]['title'],
                                      ingredients: recipes[index]
                                          ['ingredients'],
                                      onViewRecipe: recipes[index]
                                          ['onViewRecipe'],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // navbar
          const Positioned(
            bottom: 32,
            left: 32,
            right: 32,
            child: BottomNavBar(selectedIndex: 0),
          ),
        ],
      ),
    );
  }
}
