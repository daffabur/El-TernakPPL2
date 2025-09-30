import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Bottom_Sheets.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Button.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Card_Employee.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Search_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/line_md.dart';

class AccountManagement extends StatelessWidget {
  const AccountManagement({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: [
          Expanded(
              child: CustomSearchBar()
          )
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 20.0),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: [
          Column(
            children: [
              Column(
                children: [
                  CustomCardEmployee(),
                  SizedBox(height: 16),
                  CustomCardEmployee(),
                ],
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(context: context, builder: (BuildContext context) {
            return CustomBottomSheets();
          });
        },
        backgroundColor: AppStyles.primaryColor,
        child: Iconify(LineMd.account_add, color: Colors.white),

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

    );
  }
}
