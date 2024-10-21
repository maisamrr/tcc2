import 'package:app/const.dart';
import 'package:flutter/material.dart';

class ProfilePicWidget extends StatelessWidget {
  const ProfilePicWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, 
      height: 40, 
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: lightGreyColor,
      ),
      child: Icon(
        Icons.account_circle,
        size: 32,
        color: darkGreyColor,
      ),
    );
  }
}
