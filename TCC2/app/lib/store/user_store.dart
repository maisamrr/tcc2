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
  Future<void> loadFavoriteRecipes() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userFavoritesRef = _userRef.child(currentUser.uid).child('favorites');
      final snapshot = await userFavoritesRef.get();

      if (snapshot.exists) {
        final favoritesMap = Map<String, dynamic>.from(snapshot.value as Map);
        favoriteRecipes.clear();
        favoriteRecipes.addAll(favoritesMap.keys);
      }
    }
  }

  @action
  Future<void> addFavoriteRecipe(String recipeId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userFavoritesRef = _userRef.child(currentUser.uid).child('favorites').child(recipeId);
      await userFavoritesRef.set(true);
      favoriteRecipes.add(recipeId);
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