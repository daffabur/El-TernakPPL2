import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color? backgroundColor; // null => transparan (outline only)
  final Color? textColor; // default: putih
  final Color? borderColor; // default: putih
  final VoidCallback? onTap; // <- penting: aksi saat ditekan

  const CustomButton({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? Colors.transparent;
    final Color txtColor = textColor ?? Colors.white;
    final Color brdColor = borderColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap, // <-- panggil callback dari luar (bukan print doang)
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor, // kalau transparan => jadi outline saja
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(color: brdColor, width: 2.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: txtColor,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
