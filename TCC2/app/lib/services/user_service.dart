import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserService {
  final DatabaseReference _rootRef = FirebaseDatabase.instance
      .refFromURL("https://tcc2-notasculinarias-default-rtdb.firebaseio.com");
  late final DatabaseReference _userRef = _rootRef.child('users');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função auxiliar para formatar o nome da receita
  String formatRecipeTitle(String title) {
    // Remove acentos e caracteres especiais
    final accentsMap = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'õ': 'o',
      'ô': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };
    accentsMap.forEach((accent, char) {
      title = title.replaceAll(accent, char);
    });

    // Substitui espaços por underscores
    return title.replaceAll(' ', '_');
  }

  Future<void> saveUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? uid = userCredential.user?.uid;

      await userCredential.user?.updateDisplayName(name);

      final userRef = _userRef.child(uid!!);

      await userRef.set({
        'name': name,
        'email': email,
        'firebaseUserId': uid,
      });
    } catch (e) {
      print('Erro ao salvar o usuário: $e');
      rethrow;
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Erro ao fazer login: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erro ao redefinir a senha: $e');
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar email: $e');
      return false;
    }
  }

  Future<User?> getUserData() async {
    try {
      return _auth.currentUser;
    } catch (e) {
      print('Erro ao recuperar os dados do usuário: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserCustomData() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) return null;

      final String userKey = currentUser.uid;

      final DatabaseEvent snapshot = await _userRef
          .orderByChild('firebaseUserId')
          .equalTo(userKey)
          .limitToFirst(1)
          .once();

      final userData = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      return userData?.cast<String, dynamic>();
    } catch (e) {
      print('Erro ao recuperar dados personalizados do usuário: $e');
      return null;
    }
  }

  Future<void> updateUser({
    String? name,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) return;

      final String userKey = currentUser.uid;

      final DatabaseEvent snapshot = await _userRef
          .orderByChild('firebaseUserId')
          .equalTo(userKey)
          .limitToFirst(1)
          .once();

      final userMap = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (userMap != null) {
        final userId = userMap.keys.first;

        final updatedUserData = <String, dynamic>{};

        if (name != null) {
          updatedUserData['nome'] = name;
          await currentUser.updateDisplayName(name);
        }

        await _userRef.child(userId).update(updatedUserData);
      }
    } catch (e) {
      print('Erro ao atualizar o usuário: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erro ao fazer logout: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFavoriteRecipes() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) return [];

      final String userKey = currentUser.uid;

      // Recupera os IDs das receitas favoritas
      final DatabaseEvent snapshot =
          await _userRef.child(userKey).child('favorites').once();
      final Map<dynamic, dynamic>? favoriteRecipesMap =
          snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (favoriteRecipesMap == null) return [];

      List<Map<String, dynamic>> favoriteRecipes = [];

      for (String recipeTitle in favoriteRecipesMap.keys) {
        // Formata o título da receita
        String formattedTitle = formatRecipeTitle(recipeTitle);

        // Buscar dados da receita no Firebase usando o nome formatado
        final DatabaseEvent recipeSnapshot =
            await _rootRef.child('recipes').child(formattedTitle).once();

        if (recipeSnapshot.snapshot.exists) {
          final data = recipeSnapshot.snapshot.value as Map<dynamic, dynamic>;

          favoriteRecipes.add({
            'title': data['title'] ?? 'Título Desconhecido',
            'ingredients': List<String>.from(data['ingredients'] ?? []),
            'instructions': List<String>.from(data['instructions'] ?? []),
            'portions': data['portions']?.toString() ?? 'Porções desconhecidas',
          });
        } else {
          print(
              '****** Receita não encontrada no banco de dados: $formattedTitle');
        }
      }

      return favoriteRecipes;
    } catch (e) {
      print('Erro ao recuperar receitas favoritadas: $e');
      return [];
    }
  }
}
