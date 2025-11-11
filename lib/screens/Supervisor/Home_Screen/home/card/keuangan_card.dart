import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardSaldoUsaha extends StatelessWidget {
  const CardSaldoUsaha({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 30, bottom: 40, left: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
        border: const Border(
          bottom: BorderSide(
            color: Color(0xffE0E0E0),
            width: 1.2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Usaha',
            style: GoogleFonts.poppins(
              color: const Color(0xff123524),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Rp. 50.000.200',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xff104E3E),
            ),
          ),
          const SizedBox(height: 35),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff123524),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  'Add +',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xff123524), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  foregroundColor: const Color(0xff123524),
                ),
                child: Text(
                  'Riwayat',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
