import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/Custom_Detail_Cage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

class CustomCardCage extends StatelessWidget {
  final Cage cage;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const CustomCardCage({
    super.key,
    required this.cage,
    this.onTap,
    this.onEdit,
  });

  void _defaultTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomDetailCage(cage: cage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => _defaultTap(context),
      onLongPress: onEdit,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppStyles.borderCageColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            // Icon kiri
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppStyles.IconCageCardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Iconify(
                MaterialSymbols.house_siding,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),

            // Title & subtitle
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cage.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppStyles.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                // Tampilkan KAPASITAS (bukan populasi)
                Text(
                  "${cage.capacity} Populasi",
                  style: GoogleFonts.poppins(
                    color: AppStyles.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Tombol edit kanan
            IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
