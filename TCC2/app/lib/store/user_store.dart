import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobx/mobx.dart';
part 'user_store.g.dart';

class UserStore = _UserStoreBase with _$UserStore;
abstract class _UserStoreBase with Store {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users');
  final DatabaseReference _recipesRef = FirebaseDatabase.instance.ref().child('recipes');

  @observable
  bool logado = false;

  @observable
  String name = "";

  @observable
  String email = "";

  @observable
  String password = "";

  @observable
  ObservableList<String> favoriteRecipes = ObservableList<String>();

  @action
  void setName(String value) => name = value;

  @action
  void setEmail(String value) => email = value;

  @action
  void setPassword(String value) => password = value;

  @action
  void login(String value) {
    logado = true;
    email = value;
  }

  @action
  void logout() {
    logado = false;
    email = "";
  }

  @action
  Future<bool> addFavoriteRecipe(String recipeId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userFavoritesRef = _userRef.child(currentUser.uid).child('favorites');
      
      // verificar ou criar o 'favorites'
      final snapshot = await userFavoritesRef.get();
      if (!snapshot.exists) {
        await userFavoritesRef.child(recipeId).set(true);
      } else {
        await userFavoritesRef.child(recipeId).set(true);
      }
      
      favoriteRecipes.add(recipeId);
      return true;
    }
    return false;
  }

  @action
  Future<void> loadFavoriteRecipes() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userFavoritesRef = _userRef.child(currentUser.uid).child('favorites');
      final snapshot = await userFavoritesRef.get();

      // verificar favorites antes de carregar
      if (snapshot.exists) {
        final favoritesMap = Map<String, dynamic>.from(snapshot.value as Map);
        favoriteRecipes.clear();
        favoriteRecipes.addAll(favoritesMap.keys);
      } else {
        favoriteRecipes.clear();
      }
    }
  }

  @action
  Future<void> removeFavoriteRecipe(String recipeId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userFavoritesRef = _userRef.child(currentUser.uid).child('favorites').child(recipeId);
      await userFavoritesRef.remove();
      favoriteRecipes.remove(recipeId);
    }
  }

  @action
  Future<void> toggleFavoriteRecipe(String recipeId) async {
    if (favoriteRecipes.contains(recipeId)) {
      await removeFavoriteRecipe(recipeId);
    } else {
      await addFavoriteRecipe(recipeId);
    }
  }

  @action
  Future<Map<String, dynamic>?> getRecipeById(String recipeId) async {
    final recipeRef = _recipesRef.child(recipeId);
    final snapshot = await recipeRef.get();

    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    } else {
      return null;
    }
  }
}