// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserStore on _UserStoreBase, Store {
  late final _$logadoAtom =
      Atom(name: '_UserStoreBase.logado', context: context);

  @override
  bool get logado {
    _$logadoAtom.reportRead();
    return super.logado;
  }

  @override
  set logado(bool value) {
    _$logadoAtom.reportWrite(value, super.logado, () {
      super.logado = value;
    });
  }

  late final _$nameAtom = Atom(name: '_UserStoreBase.name', context: context);

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  late final _$emailAtom = Atom(name: '_UserStoreBase.email', context: context);

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$passwordAtom =
      Atom(name: '_UserStoreBase.password', context: context);

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  late final _$favoriteRecipesAtom =
      Atom(name: '_UserStoreBase.favoriteRecipes', context: context);

  @override
  ObservableList<String> get favoriteRecipes {
    _$favoriteRecipesAtom.reportRead();
    return super.favoriteRecipes;
  }

  @override
  set favoriteRecipes(ObservableList<String> value) {
    _$favoriteRecipesAtom.reportWrite(value, super.favoriteRecipes, () {
      super.favoriteRecipes = value;
    });
  }

  late final _$addFavoriteRecipeAsyncAction =
      AsyncAction('_UserStoreBase.addFavoriteRecipe', context: context);

  @override
  Future<bool> addFavoriteRecipe(String recipeId) {
    return _$addFavoriteRecipeAsyncAction
        .run(() => super.addFavoriteRecipe(recipeId));
  }

  late final _$loadFavoriteRecipesAsyncAction =
      AsyncAction('_UserStoreBase.loadFavoriteRecipes', context: context);

  @override
  Future<void> loadFavoriteRecipes() {
    return _$loadFavoriteRecipesAsyncAction
        .run(() => super.loadFavoriteRecipes());
  }

  late final _$removeFavoriteRecipeAsyncAction =
      AsyncAction('_UserStoreBase.removeFavoriteRecipe', context: context);

  @override
  Future<void> removeFavoriteRecipe(String recipeId) {
    return _$removeFavoriteRecipeAsyncAction
        .run(() => super.removeFavoriteRecipe(recipeId));
  }

  late final _$toggleFavoriteRecipeAsyncAction =
      AsyncAction('_UserStoreBase.toggleFavoriteRecipe', context: context);

  @override
  Future<void> toggleFavoriteRecipe(String recipeId) {
    return _$toggleFavoriteRecipeAsyncAction
        .run(() => super.toggleFavoriteRecipe(recipeId));
  }

  late final _$getRecipeByIdAsyncAction =
      AsyncAction('_UserStoreBase.getRecipeById', context: context);

  @override
  Future<Map<String, dynamic>?> getRecipeById(String recipeId) {
    return _$getRecipeByIdAsyncAction.run(() => super.getRecipeById(recipeId));
  }

  late final _$_UserStoreBaseActionController =
      ActionController(name: '_UserStoreBase', context: context);

  @override
  void setName(String value) {
    final _$actionInfo = _$_UserStoreBaseActionController.startAction(
        name: '_UserStoreBase.setName');
    try {
      return super.setName(value);
    } finally {
      _$_UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEmail(String value) {
    final _$actionInfo = _$_UserStoreBaseActionController.startAction(
        name: '_UserStoreBase.setEmail');
    try {
      return super.setEmail(value);
    } finally {
      _$_UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPassword(String value) {
    final _$actionInfo = _$_UserStoreBaseActionController.startAction(
        name: '_UserStoreBase.setPassword');
    try {
      return super.setPassword(value);
    } finally {
      _$_UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void login(String value) {
    final _$actionInfo = _$_UserStoreBaseActionController.startAction(
        name: '_UserStoreBase.login');
    try {
      return super.login(value);
    } finally {
      _$_UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void logout() {
    final _$actionInfo = _$_UserStoreBaseActionController.startAction(
        name: '_UserStoreBase.logout');
    try {
      return super.logout();
    } finally {
      _$_UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
logado: ${logado},
name: ${name},
email: ${email},
password: ${password},
favoriteRecipes: ${favoriteRecipes}
    ''';
  }
}
