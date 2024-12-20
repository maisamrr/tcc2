import 'package:flutter/material.dart';
import 'package:app/const.dart';
import 'package:app/services/user_service.dart';
import 'package:app/store/user_store.dart';
import 'package:app/widgets/profilepicwidget.dart';
import 'package:app/widgets/recipecardwidget.dart';
import 'package:app/widgets/bottomnavbar.dart';
import 'package:app/screens/recipedetails.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final userStore = UserStore();
  String? username;

  @override
  void initState() {
    super.initState();
    getUsername();
    userStore.loadFavoriteRecipes().then((_) {
      setState(() {});
    });
  }

  getUsername() async {
    UserService userService = UserService();
    var userData = await userService.getUserData();

    setState(() {
      username = userData!.displayName!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundIdColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/back05.png',
                    fit: BoxFit.cover,
                  ),
                ),
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
                              const ProfilePicWidget(),
                              Padding(
                                padding: const EdgeInsets.only(left: 24.0),
                                child: Text(
                                  "Olá, $username",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: darkGreyColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.settings,
                              size: 32,
                              color: darkGreyColor,
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/profile');
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Observer(
                        builder: (context) {
                          if (userStore.favoriteRecipes.isEmpty) {
                            return Center(
                              child: Text(
                                'Suas receitas favoritas aparecerão aqui!',
                                style: TextStyle(
                                  color: darkGreyColor,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: MediaQuery.of(context)
                                      .size
                                      .width /
                                  (MediaQuery.of(context).size.height / 1.8),
                            ),
                            itemCount: userStore.favoriteRecipes.length,
                            itemBuilder: (context, index) {
                              final recipeId = userStore.favoriteRecipes[index];

                              return FutureBuilder<Map<String, dynamic>?>(
                                future: userStore.getRecipeById(recipeId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError || !snapshot.hasData) {
                                    return const Text(
                                        'Erro ao carregar a receita.');
                                  }

                                  final recipe = snapshot.data!;

                                  return RecipeCardWidget(
                                    title: recipe['title'],
                                    ingredients: List<String>.from(
                                        recipe['ingredients']),
                                    onViewRecipe: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RecipeDetails(
                                            title: recipe['title'],
                                            items: List<String>.from(
                                                recipe['ingredients']),
                                            servings: recipe['servings'],
                                            prepare: List<String>.from(
                                                recipe['prepare']),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
