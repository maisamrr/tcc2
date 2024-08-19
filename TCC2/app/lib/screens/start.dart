import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  int _currentIndex = 0;
  final CarouselController _controller =
      CarouselController(); // Adicionado o CarouselController

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/back01.png',
      'title': 'Notas\nculinárias',
      'subtitle':
          'Aprenda a cozinhar receitas\na partir das suas compras\nde supermercado'
    },
    {
      'image': 'assets/images/back02.png',
      'title': 'Fácil e rápido,\nno seu celular',
      'subtitle':
          'Basta escanear o QR Code da\nnota fiscal da sua compra de\nsupermercado'
    },
    {
      'image': 'assets/images/back03.png',
      'title': 'É simples\nassim',
      'subtitle':
          'O app sugere receitas com base\nnos itens que você comprou.\nAutonomia e variedade alimentar!'
    }
  ];

  List<Widget> generateImageTiles(screenWidth) {
    return _pages
        .map(
          (element) => Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(element['image']!),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 88, 32, 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        element['title']!,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 40.0,
                            color: Colors.white,
                            height: 1.0),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        element['subtitle']!,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _pages.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () => _controller.animateToPage(entry.key),
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentIndex == entry.key
                                    ? const Color.fromARGB(153, 137, 134, 134)
                                    : const Color.fromRGBO(255, 255, 255, 1.0),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_currentIndex == _pages.length - 1)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
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
                                'Iniciar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CarouselSlider(
        carouselController: _controller,
        options: CarouselOptions(
          height: screenHeight,
          enlargeCenterPage: false,
          viewportFraction: 1.0,
          autoPlay: false,
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        items: generateImageTiles(screenHeight),
      ),
    );
  }
}
