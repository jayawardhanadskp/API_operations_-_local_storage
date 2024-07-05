
import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String bText;
  final Color? color;
  const CustomButton({
    super.key, 
    required this.onTap, 
    required this.bText, 
    this.color
    });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),
        fixedSize: const Size(160, 45)
        ),
      child: Text(bText),
    );
  }
}
