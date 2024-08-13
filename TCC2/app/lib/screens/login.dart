import 'package:app/const.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundIdColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 104, 32, 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notas\nculinárias',
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: darkGreyColor),
                textAlign: TextAlign.left,
              ),
              // espacamento
              const SizedBox(height: 32),
              // email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: const TextStyle(
                      color: Color(0xFFADB5BD),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xFFDEE2E6),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xFFDEE2E6),
                        width: 1.0,
                      ),
                    )),
              ),
              // espacamento
              const SizedBox(height: 16),
              //campo senha
              TextFormField(
                controller: _senhaController,
                keyboardType: TextInputType.text,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: const TextStyle(
                    color: Color(0xFFADB5BD),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: Color(0xFFDEE2E6),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: Color(0xFFDEE2E6),
                      width: 1.0,
                    ),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                onChanged: (text) {
                  setState(() {});
                },
              ),
              // espacamento
              const SizedBox(height: 16),
              //botão login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // logica de login
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB83E8),
                    side: const BorderSide(
                      color: Color(0xFF343A40),
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF343A40),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // espacamento
              const SizedBox(height: 24),
              // esqueci senha
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/recuperarsenha');
                },
                child: Text(
                  'Esqueci minha senha',
                  style: TextStyle(
                    color: darkGreyColor,
                  ),
                ),
              ),
              // fazer cadastro
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/cadastro');
                },
                child: Text(
                  'Fazer cadastro',
                  style: TextStyle(
                    color: darkGreyColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
