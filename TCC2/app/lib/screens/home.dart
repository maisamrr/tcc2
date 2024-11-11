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
  Future<List<Map<String, dynamic>>>? topRecipes;

  @override
  void initState() {
    super.initState();
    topRecipes = fetchTopRecipes();
  }

  getUsername() async {
    UserService userService = UserService();
    var userData = await userService.getUserData();

    setState(() {
      username = userData!.displayName!;
    });
  }

  Future<List<Map<String, dynamic>>> fetchTopRecipes() async {
    final ref = FirebaseDatabase.instance.ref('recipes');
    print('****** Tentando acessar o Firebase Database...');
    final snapshot = await ref.limitToFirst(4).get();

    if (snapshot.exists) {
      print('****** Dados encontrados: ${snapshot.value}');

      return snapshot.children.map((child) {
        // Garantindo que o dado é um Map antes de fazer o cast
        if (child.value is! Map) {
          print('****** O valor de child não é um Map. Valor: ${child.value}');
          return <String, dynamic>{
            'title': 'Dado inválido',
            'ingredients': [],
            'instructions': [],
            'portions': 'Desconhecido'
          };
        }

        final data = child.value as Map<dynamic, dynamic>;

        // Processando os campos
        final title = data['title'] as String? ?? 'Título Desconhecido';
        
        List<String> ingredients = [];
        if (data['ingredients'] is List) {
          ingredients = (data['ingredients'] as List)
              .map((item) => item.toString().replaceAll(RegExp(r"[{}']"), '').trim())
              .toList();
        } else {
          print('****** Erro: ingredients não é uma lista');
        }

        List<String> instructions = [];
        if (data['instructions'] is List) {
          instructions = (data['instructions'] as List)
              .map((item) => item.toString().replaceAll(RegExp(r"[{}']"), '').trim())
              .toList();
        } else {
          print('****** Erro: instructions não é uma lista');
        }

        final portions = data['portions']?.toString() ?? 'Porções desconhecidas';

        return {
          'title': title,
          'ingredients': ingredients,
          'instructions': instructions,
          'portions': portions,
        };
      }).toList();
    } else {
      print('****** Nenhum dado encontrado.');
      return [];
    }
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
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: topRecipes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            print('Erro ao carregar receitas: ${snapshot.error}');
                            return const Center(
                                child: Text('Erro ao carregar receitas.'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                'Nenhuma receita encontrada!',
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          } else {
                            final recipes = snapshot.data!;
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
                              itemCount: recipes.length,
                              itemBuilder: (context, index) {
                                final recipe = recipes[index];

                                return RecipeCardWidget(
                                  title: recipe['title'],
                                  ingredients:
                                      List<String>.from(recipe['ingredients']),
                                  onViewRecipe: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RecipeDetails(
                                          title: recipe['title'],
                                          items: List<String>.from(
                                              recipe['ingredients']),
                                          servings: recipe['portions'],
                                          prepare: List<String>.from(
                                              recipe['instructions']),
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
