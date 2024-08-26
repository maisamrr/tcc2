import 'package:app/const.dart';
import 'package:app/widgets/receiptwidget.dart';
import 'package:flutter/material.dart';

class AllReceipts extends StatefulWidget {
  const AllReceipts({super.key});

  @override
  State<AllReceipts> createState() => _AllReceiptsState();
}

class _AllReceiptsState extends State<AllReceipts> {
  final List<Map<String, dynamic>> receipts = [
    {
      'title': 'Nota fiscal de 16/08/2024',
      'items': ['item 1', 'item 2', 'item 3', 'item A', 'item B', 'item C', 'item D', 'item A', 'item B', 'item C', 'item D', 'item A', 'item B', 'item C', 'item D', 'item 1', 'item 2', 'item 3', 'item A', 'item B', 'item 1', 'item 2', 'item 3', 'item A', 'item B'],
    },
    {
      'title': 'Nota fiscal de 15/08/2024',
      'items': ['item A', 'item B', 'item C', 'item D'],
    },
    {
      'title': 'Nota fiscal de 14/08/2024',
      'items': ['item X', 'item Y'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greenColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: Icon(
                Icons.arrow_back,
                size: 32,
                color: darkGreyColor,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Últimas notas fiscais',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: darkGreyColor),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: receipts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ReceiptWidget(
                      title: receipts[index]['title'],
                      items: List<String>.from(receipts[index]['items']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
