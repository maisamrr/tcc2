import 'package:app/widgets/bottomnavbar.dart';
import 'package:flutter/material.dart';
import 'package:app/const.dart';

class ReceiptDetails extends StatelessWidget {
  final String title;
  final List<dynamic> items;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                child: GestureDetector(
                  child: Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: darkGreyColor,
                  ),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/allreceipts');
                  },
                ),
              ),
              const SizedBox(height: 40),
              // Title
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  'Detalhes da nota fiscal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkGreyColor,
                  ),
                ),
              ),
              // Receipt Items
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
                        // Receipt Title
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'PP Neue Montreal',
                            color: darkGreyColor,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 16),
                        // List of Items
                        Expanded(
                          child: ListView.separated(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              var item = items[index];
                              return ListTile(
                                title: Text(
                                  item['item_name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    color: darkGreyColor,
                                  ),
                                ),
                                subtitle: Text(
                                  'Primeira Palavra: ${item['first_word'] ?? ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    color: darkGreyColor,
                                  ),
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
          // Bottom Navigation Bar
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