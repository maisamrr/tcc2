import 'package:app/const.dart';
import 'package:app/widgets/profilepicwidget.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/bottomnavbar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blueIdColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(32, 40, 32, 0),
                      child: Row(
                        children: [
                          // Foto
                          ProfilePicWidget(),
                          // Nome
                          Padding(
                            padding: EdgeInsets.only(left: 24.0),
                            child: Text(
                              "Olá, Usuária", // Mudar nome
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 48.0),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: backgroundIdColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seu perfil',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: darkGreyColor),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 32),
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: lightGreyColor,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nome',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Inter',
                                        color: lightGreyColor,
                                      ),
                                    ),
                                    Text(
                                      'Usuária da Silva', //mudar
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Inter',
                                        color: darkGreyColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: lightGreyColor,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Data de nascimento',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Inter',
                                        color: lightGreyColor,
                                      ),
                                    ),
                                    Text(
                                      '01/01/1990', //mudar
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Inter',
                                        color: darkGreyColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: lightGreyColor,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'E-mail',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Inter',
                                        color: lightGreyColor,
                                      ),
                                    ),
                                    Text(
                                      'user_user@gmail.com', //mudar
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Inter',
                                        color: darkGreyColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFADB5BD),
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
                                      'Logout',
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
                    ),
                  ],
                ),
              ],
            ),
          ),
          // navbar
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
