import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserService {
  final DatabaseReference _rootRef = FirebaseDatabase.instance
      .refFromURL("https://tcc2-notasculinarias-default-rtdb.firebaseio.com");
  late final DatabaseReference _userRef = _rootRef.child('users');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final newUserRef = _userRef.push();
    final String? userId = newUserRef.key;

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);

      await newUserRef.set({
        'name': name,
        'email': email,
        'firebaseUserId': userCredential.user?.uid,
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

      final DatabaseEvent snapshot =
          await _userRef.child(userKey).child('favorites').once();

      final Map<dynamic, dynamic>? favoriteRecipesMap =
          snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (favoriteRecipesMap == null) return [];

      // converter o mapa para uma lista de receitas
      List<Map<String, dynamic>> favoriteRecipes = [];
      favoriteRecipesMap.forEach((key, value) {
        favoriteRecipes.add({
          'title': value['title'],
          'ingredients': List<String>.from(value['ingredients']),
          'onViewRecipe': () {
            // rmplementar navegação para a receita aqui
          },
        });
      });

      return favoriteRecipes;
    } catch (e) {
      print('Erro ao recuperar receitas favoritadas: $e');
      return [];
    }
  }
}
