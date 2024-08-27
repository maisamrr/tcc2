import 'package:app/widgets/bottomnavbar.dart';
import 'package:flutter/material.dart';
import 'package:app/const.dart';

class ReceiptDetails extends StatelessWidget {
  final String title;
  final List<String> items;

  const ReceiptDetails({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greenColor,
      body: Stack(
        children: [
          Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                    child: GestureDetector(
                      child: Icon(
                        Icons.arrow_back,
                        size: 32,
                        color: darkGreyColor,
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/allreceipts');
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      'Detalhes da nota fiscal',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkGreyColor),
                    ),
                  ),

                  // Receitas
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
                              title,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'PP Neue Montreal',
                                  color: darkGreyColor),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.separated(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return Text(
                                    items[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      color: darkGreyColor,
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    color: lightGreyColor,
                                    thickness: 1, 
                                  );
                                },
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
