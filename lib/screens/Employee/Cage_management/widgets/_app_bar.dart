// lib/screens/Employee/Cage_Management/widgets/_app_bar.dart
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const DetailAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 48,
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF3E7B27),
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      centerTitle: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppStyles.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Iconify(
              MaterialSymbols.home_work_rounded,
              size: 18,
              color: Color(0xFF3E7B27),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: AppStyles.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
