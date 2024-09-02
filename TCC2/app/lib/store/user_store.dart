import 'package:mobx/mobx.dart';
part 'user_store.g.dart';

class UserStore = _UserStoreBase with _$UserStore;

abstract class _UserStoreBase with Store {
  @observable
  bool logado = false;

  @observable
  String name = "";

  @observable
  String email = "";

  @observable
  String password = "";

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
}
