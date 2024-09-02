import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserService {
  final DatabaseReference _rootRef = FirebaseDatabase.instance
      .refFromURL("https://tcc2-notasculinarias-default-rtdb.firebaseio.com");
  late final DatabaseReference _userRef = _rootRef.child('users');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Método para salvar um novo usuário no Firebase Realtime Database e Firebase Authentication.
  Future<void> saveUser({
    required String name,
    required String email,
    required String password,
  }) async {
    // Criar um novo nó para o usuário
    final newUserRef = _userRef.push();
    final String? userId = newUserRef.key;

    try {
      // Criar usuário no Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Atualizar o perfil do usuário com o nome
      await userCredential.user?.updateDisplayName(name);

      // Definir os dados do usuário no Realtime Database
      await newUserRef.set({
        'name': name,
        'email': email,
        'firebaseUserId': userCredential.user?.uid,
      });
    } catch (e) {
      // Tratar erro de criação do usuário no Firebase Authentication
      print('Erro ao salvar o usuário: $e');
      rethrow; // Opcionalmente, você pode propagar o erro para tratá-lo na interface
    }
  }

  /// Método para realizar login do usuário usando email e senha.
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
      rethrow; // Repropagar o erro para que possa ser tratado na interface
    }
  }

  /// Método para enviar um email de redefinição de senha.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erro ao redefinir a senha: $e');
    }
  }

  /// Método para verificar se um email já está registrado.
  Future<bool> isEmailRegistered(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar email: $e');
      return false;
    }
  }

  /// Método para obter os dados do usuário atualmente autenticado.
  Future<User?> getUserData() async {
    try {
      return _auth.currentUser;
    } catch (e) {
      print('Erro ao recuperar os dados do usuário: $e');
      return null;
    }
  }

  /// Método para obter dados personalizados do usuário a partir do Realtime Database.
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

  /// Método para atualizar informações do usuário no Realtime Database e Firebase Authentication.
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

  /// Método para realizar logout do usuário.
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erro ao fazer logout: $e');
    }
  }
}
