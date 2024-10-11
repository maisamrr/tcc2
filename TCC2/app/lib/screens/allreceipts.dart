import 'package:app/const.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/tilewidget.dart';
import 'package:app/screens/receiptdetails.dart';
import 'package:firebase_database/firebase_database.dart';

class AllReceipts extends StatefulWidget {
  const AllReceipts({super.key});

  @override
  State<AllReceipts> createState() => _AllReceiptsState();
}

class _AllReceiptsState extends State<AllReceipts> {
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('processed_notes');
  List<Map<String, dynamic>> receipts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReceiptsFromFirebase();
  }

  Future<void> _fetchReceiptsFromFirebase() async {
    try {
      final DataSnapshot snapshot = await dbRef.get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> fetchedReceipts = [];
        Map<dynamic, dynamic> receiptsMap =
            snapshot.value as Map<dynamic, dynamic>;

        receiptsMap.forEach((receiptId, receiptData) {
          fetchedReceipts.add({
            'receipt_id': receiptId,
            'items': receiptData,
          });
        });

        setState(() {
          receipts = fetchedReceipts;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      debugPrint('Error fetching receipts from Firebase: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatReceiptIdToDate(String receiptId) {
    try {
      final formatter = DateFormat('yyyyMMdd');
      final dateTime = formatter.parseUtc(receiptId);
      final displayFormatter = DateFormat('dd/MM/yyyy');
      return displayFormatter.format(dateTime.toLocal());
    } catch (e) {
      return receiptId;
    }
  }

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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : receipts.isEmpty
                      ? const Center(
                          child: Text('Nenhuma nota fiscal encontrada'))
                      : ListView.builder(
                          itemCount: receipts.length,
                          itemBuilder: (context, index) {
                            final receipt = receipts[index];
                            final receiptId = receipt['receipt_id'];
                            final itemsData = receipt['items'];

                            debugPrint('MyApp: Receipt ID - $receiptId');
                            debugPrint('MyApp: itemsData - $itemsData');
                            debugPrint(
                                'MyApp: itemsData type - ${itemsData.runtimeType}');

                            List<Map<String, dynamic>> itemsList = [];

                            if (itemsData is Map) {
                              itemsData.forEach((key, value) {
                                if (value is Map &&
                                    value.containsKey('item_name') &&
                                    value.containsKey('first_word')) {
                                  itemsList.add({
                                    'item_name':
                                        value['item_name'] as String? ?? '',
                                    'first_word':
                                        value['first_word'] as String? ?? '',
                                  });
                                } else {
                                  debugPrint(
                                      'Formato de valor inesperado para item: $value');
                                }
                              });
                            } else if (itemsData is List) {
                              for (var value in itemsData) {
                                if (value is Map &&
                                    value.containsKey('item_name') &&
                                    value.containsKey('first_word')) {
                                  itemsList.add({
                                    'item_name':
                                        value['item_name'] as String? ?? '',
                                    'first_word':
                                        value['first_word'] as String? ?? '',
                                  });
                                } else {
                                  debugPrint(
                                      'Formato de valor inesperado para item: $value');
                                }
                              }
                            } else {
                              debugPrint(
                                  'Tipo de itemsData não esperado: ${itemsData.runtimeType}');
                            }

                            final receiptDate =
                                _formatReceiptIdToDate(receiptId);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: TiletWidget(
                                title: receiptDate,
                                items: itemsList
                                    .map<String>(
                                        (item) => item['item_name'] as String)
                                    .toList(),
                                destination: ReceiptDetails(
                                  title: receiptDate,
                                  items: itemsList,
                                ),
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
