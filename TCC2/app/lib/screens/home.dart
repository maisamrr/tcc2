import 'package:flutter/material.dart';
import 'package:app/const.dart';
import 'package:app/services/user_service.dart';
import 'package:app/store/user_store.dart';
import 'package:app/widgets/profilepicwidget.dart';
import 'package:app/widgets/recipecardwidget.dart';
import 'package:app/widgets/bottomnavbar.dart';
import 'package:app/screens/recipedetails.dart';
import 'package:firebase_database/firebase_database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final userStore = UserStore();
  String? username;
  Future<List<Map<String, dynamic>>>? favoriteRecipes;

  @override
  void initState() {
    super.initState();
    getUsername(); // Carrega o nome do usuário
    favoriteRecipes = fetchFavoriteRecipes(); // Carrega as receitas favoritas
  }

  getUsername() async {
    UserService userService = UserService();
    var userData = await userService.getUserData();

    setState(() {
      username = userData?.displayName ?? 'Usuário';
    });
  }

  Future<List<Map<String, dynamic>>> fetchFavoriteRecipes() async {
    UserService userService = UserService();
    List<Map<String, dynamic>> favoritesList = await userService.getFavoriteRecipes();

    if (favoritesList.isEmpty) {
      debugPrint('****** Nenhuma receita favorita encontrada.');
      return [];
    }
    final recipesRef = FirebaseDatabase.instance.ref('recipes');
    List<Map<String, dynamic>> favoriteRecipes = [];

    for (var favorite in favoritesList) {
        favoriteRecipes.add({
          'title': favorite['title'] ?? 'Título Desconhecido',
          'ingredients': List<String>.from(favorite['ingredients'] ?? []),
          'instructions': List<String>.from(favorite['instructions'] ?? []),
          'portions': favorite['portions']?.toString() ?? 'Porções desconhecidas',
        });
    }

    return favoriteRecipes;
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              children: [
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
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: favoriteRecipes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            debugPrint('MyApp: favoriteRecipes - $favoriteRecipes');
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            debugPrint('Erro ao carregar receitas: ${snapshot.error}');
                            return const Center(
                                child: Text('Erro ao carregar receitas.'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            debugPrint("MyApp: NO DATA - $favoriteRecipes");
                            return const Center(
                              child: Text(
                                'Nenhuma receita favorita encontrada!',
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          } else {
                            final recipes = snapshot.data!;
                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height / 1.8),
                              ),
                              itemCount: recipes.length,
                              itemBuilder: (context, index) {
                                final recipe = recipes[index];

                                return RecipeCardWidget(
                                  title: recipe['title'],
                                  ingredients: recipe['ingredients'],
                                  onViewRecipe: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RecipeDetails(
                                          title: recipe['title'],
                                          items: recipe['ingredients'],
                                          servings: recipe['portions'],
                                          prepare: recipe['instructions'],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }
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