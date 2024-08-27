import 'package:flutter/material.dart';
import 'package:app/const.dart';

class TiletWidget extends StatelessWidget {
  final String title;
  final List<String> items;
  final Widget destination; 

  const TiletWidget({
    super.key,
    required this.title,
    required this.items,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.25),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: darkGreyColor,
                  fontFamily: 'PP Neue Montreal',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                items.join(' • '),
                style: const TextStyle(
                  color: Color(0xFFADB5BD),
                  fontFamily: 'Inter',
                  fontSize: 12,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          destination, // Usando o novo parâmetro
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB83E8),
                  side: const BorderSide(
                    color: Color(0xFF343A40),
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Ver mais',
                  style: TextStyle(
                    color: darkGreyColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    fontSize: 10,
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
