import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/widgets/Detail_Transaction.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionItem extends StatefulWidget {
  final IconData icon;
  final String title, date, amount;
  final Color color;

  const TransactionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.color,
  });

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailTransaction()
          )
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: widget.color.withOpacity(0.15),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: AppStyles.primaryColor,
                      ),
                    ),
                    Text(
                      widget.date,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppStyles.primaryColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              widget.amount,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: AppStyles.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
