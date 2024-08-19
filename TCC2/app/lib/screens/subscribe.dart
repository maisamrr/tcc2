import 'package:app/const.dart';
import 'package:flutter/material.dart';

class Subscribe extends StatefulWidget {
  const Subscribe({super.key});

  @override
  State<Subscribe> createState() => _SubscribeState();
}

class _SubscribeState extends State<Subscribe> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool agree = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundIdColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                child: Icon(
                  Icons.arrow_back,
                  size: 32,
                  color: darkGreyColor,
                ),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
              // espacamento
              const SizedBox(height: 40),
              // titulo
              Text(
                'Notas\nculinárias',
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: darkGreyColor),
                textAlign: TextAlign.left,
              ),
              // espacamento
              const SizedBox(height: 16),
              // titulo
              Text(
                'Complete seu cadastro',
                style: TextStyle(fontSize: 18, color: darkGreyColor),
                textAlign: TextAlign.left,
              ),
              // espacamento
              const SizedBox(height: 24),
              // nome
              TextFormField(
                controller: _nomeController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: 'Nome',
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
              // senha
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
              // login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                    // falta a logica
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
                      'Cadastrar',
                      style: TextStyle(
                        color: Color(0xFF343A40),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
