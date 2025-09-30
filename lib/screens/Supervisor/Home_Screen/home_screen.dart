import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        print('Button tapped!');
      },
      child: CustomButton(text: "Log Out", backgroundColor: Colors.red, textColor: Colors.white, borderColor: Colors.red),
    );
  }
}
