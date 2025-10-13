import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/Custom_Detail_Cage.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCardCage extends StatelessWidget {
  const CustomCardCage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              CustomDetailCage())
        );
      },
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppStyles.borderCageColor.withOpacity(0.1)
          )
        ),
        child:
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppStyles.IconCageCardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Iconify(
                    MaterialSymbols.house_siding,
                    color: Colors.white,
                    size: 40,
                ),
              ),
              SizedBox(width: 20,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Kandang 1",
                  style: GoogleFonts.poppins(
                    color: AppStyles.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  ),
                  Text("8000 Populasi",
                  style: GoogleFonts.poppins(
                    color: AppStyles.primaryColor,
                    fontSize: 14,)
                  ),
                ],
              )
            ],
          ),
      ),
    );
  }
}
