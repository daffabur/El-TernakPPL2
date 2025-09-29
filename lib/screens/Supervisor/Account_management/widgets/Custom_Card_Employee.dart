import 'package:el_ternak_ppl2/base/res/media.dart';
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Button.dart';
import 'package:flutter/material.dart';

class CustomCardEmployee extends StatelessWidget {
  const CustomCardEmployee({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: AppStyles.primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Gambar Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset(
              AppMedia.placeHolderImg,
              width: 45,
              height: 45,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person, size: 40, color: Colors.white);
              },
            ),
          ),
          const SizedBox(width: 12),

          // ============ INI SOLUSINYA ============
          // Bungkus Text dengan Expanded agar fleksibel
          Expanded(
            child: Text(
              "Nama Pengguna",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis, // Tampilkan "..." jika nama terlalu panjang
            ),
          ),
          // =======================================

          const SizedBox(width: 8),

          // Tombol Edit akan muncul karena sekarang ada ruang yang cukup
          CustomButton(text: "Edit"),

          const SizedBox(width: 8),

          // Tombol Delete
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}