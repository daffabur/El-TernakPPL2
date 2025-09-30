import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const CustomButton({super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Colors.transparent;
    final textColor = widget.textColor ?? Colors.white;
    final borderColor = widget.borderColor ?? Colors.white;
    return GestureDetector(
      onTap: (){
        print('${widget.text} button tapped!');
      },
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
              border:BoxBorder.all(
                color: borderColor,
                width: 2.0
              ) ,
        ),
        child:
        Text(widget.text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
