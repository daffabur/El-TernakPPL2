import 'package:el_ternak_ppl2/base/res/media.dart';
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Bottom_Sheets.dart';
import 'package:flutter/material.dart';

class CustomCardEmployee extends StatelessWidget {
  final User user;
  final VoidCallback onDataChanged;
  const CustomCardEmployee({super.key, required this.user,  required this.onDataChanged,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          builder: (context) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: CustomBottomSheets(
              mode: BottomSheetMode.edit,
              user: user, // <-- Teruskan objek user ke bottom sheet
            ),
          ),
        ).then((result) {
          if (result == true) {
            onDataChanged();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Daftar akun telah diperbarui.'), duration: Duration(seconds: 2)),
            );

          }

        });
      },
      child: Container( 
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: AppStyles.primaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
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
            Text(user.username,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),

          ],
        ),
      ),
    );
  }
}