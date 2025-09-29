
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Search_bar.dart';
import 'package:flutter/material.dart';


class AccountManagement extends StatelessWidget {
  const AccountManagement({super.key});

  @override
  Widget build(BuildContext context) {


    return ListView(
        children: [
          Padding(padding: EdgeInsets.all(20.0),
          child:
          Row(
            children: [
              const Expanded(
                child: CustomSearchBar(),
              ),
              const SizedBox(width: 20),
              Container(child:
              Row(children: [
                Text("add"),
                Text("edit"),
              ])),
            ],
          ),
          ),
        ],
    );
  }
}
