import 'package:flutter/material.dart';
import 'package:notes_app/core/app_colors.dart';

class CustomIconBotton extends StatelessWidget {
  final void Function() onPressed;
  final IconData icon;
  final Color? color ;
  final Color? iconColor ;
  const CustomIconBotton({super.key, required this.onPressed, required this.icon,  this.color, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      color: iconColor??Colors.white,
      style: IconButton.styleFrom(
        backgroundColor: color??AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon,),);
  }
}
