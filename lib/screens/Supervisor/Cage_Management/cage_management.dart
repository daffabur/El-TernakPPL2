import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/Custom_Bottom_Sheets.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/Custom_Card_Cage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

class CageManagement extends StatefulWidget {
  const CageManagement({super.key});

  @override
  State<CageManagement> createState() => _CageManagementState();
}

class _CageManagementState extends State<CageManagement> {
  @override
  void _showAddSheet() {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: CustomBottomSheets()
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
        children: [
          Row(
            children: [
              Center(child: Text("Informasi Kandang",
              style: GoogleFonts.poppins(
                color: AppStyles.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 20
              ),
              ))
            ]
          ),
          SizedBox(height: 20,),
          Column(
            children: [
              CustomCardCage(),
              SizedBox(height: 5,),
              CustomCardCage(),
              SizedBox(height: 5,),
              CustomCardCage(),
              SizedBox(height: 5,),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: AppStyles.highlightColor,
        child: Iconify(
            MaterialSymbols.add_rounded,
            color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
