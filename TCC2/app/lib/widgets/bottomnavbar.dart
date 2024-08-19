import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/const.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  const BottomNavBar({
    super.key, 
    required this.selectedIndex
  });

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  final List<Map<String, dynamic>> _items = [
    {
      'icon': 'assets/images/home.svg',
      'route': '/home',
    },
    {
      'icon': 'assets/images/camera.svg',
      'route': '/scanqrcode',
    },
    {
      'icon': 'assets/images/receipt.svg',
      'route': '/receipts',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pushNamed(context, _items[_selectedIndex]['route']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(64),
        border: Border.all(
          color: darkGreyColor,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(64),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: backgroundIdColor,
          selectedItemColor: pinkColor,
          unselectedItemColor: darkGreyColor,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: _items.map((item) {
            return BottomNavigationBarItem(
              icon: Center(
                child: SvgPicture.asset(
                  item['icon'],
                  color: _selectedIndex == _items.indexOf(item)
                      ? pinkColor
                      : darkGreyColor,
                  height: 32,
                  width: 32,
                ),
              ),
              label: '',
            );
          }).toList(),
        ),
      ),
    );
  }
}
